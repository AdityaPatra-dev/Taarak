import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taarak/features/hazards/domain/hazard_type.dart';
import 'package:taarak/features/susceptibility/application/gemini_hazard_client.dart';
import 'package:taarak/features/susceptibility/application/gemini_hazard_susceptibility_decorator.dart';
import 'package:taarak/features/susceptibility/application/hazard_susceptibility_model.dart';
import 'package:taarak/features/susceptibility/domain/hazard_susceptibility_prediction.dart';

class _FixedModel implements HazardSusceptibilityModel {
  final HazardSusceptibilityPrediction? fixed;
  _FixedModel(this.fixed);

  @override
  Future<HazardSusceptibilityPrediction?> predict({
    required String habitationId,
    required double latitude,
    required double longitude,
    required HazardType hazardType,
    DateTime? now,
    String habitationName = '',
    int populationExposed = 0,
  }) async => fixed;
}

Dio scriptedDio(void Function(RequestOptions options, RequestInterceptorHandler handler) onRequest) {
  final dio = Dio();
  dio.interceptors.add(InterceptorsWrapper(onRequest: onRequest));
  return dio;
}

void main() {
  final now = DateTime.utc(2026, 1, 1, 12);

  HazardSusceptibilityPrediction basePrediction({double score = 0.8}) => HazardSusceptibilityPrediction(
    score: score,
    modelName: 'deterministic-rainfall-soil-threshold',
    modelVersion: '1.0.0',
    featureContributions: const {'rainfall24h': 0.9, 'soilMoisture': 0.7},
    confidence: 0.75,
    predictedAt: now,
  );

  Map<String, dynamic> okGeminiResponse({
    String rationale = 'Heavy sustained rainfall on already-saturated ground.',
    String dominantFactor = 'soilMoisture',
  }) => {
    'candidates': [
      {
        'content': {
          'parts': [
            {
              'text':
                  '{"rationale": "$rationale", "dominantFactor": "$dominantFactor"}',
            },
          ],
        },
      },
    ],
  };

  Future<HazardSusceptibilityPrediction?> runDecorator({
    required Dio dio,
    HazardSusceptibilityPrediction? inner,
    bool enabled = true,
    double enrichmentThreshold = 0.6,
  }) {
    final decorator = GeminiHazardSusceptibilityDecorator(
      inner: _FixedModel(inner),
      client: GeminiHazardClient(dio: dio),
      isEnabled: () => enabled,
      enrichmentThreshold: enrichmentThreshold,
    );
    return decorator.predict(
      habitationId: 'hab-1',
      latitude: 1,
      longitude: 1,
      hazardType: HazardType.landslide,
      now: now,
      habitationName: 'Ridge Colony',
      populationExposed: 120,
    );
  }

  test('a well-formed response attaches a rationale but leaves the numbers byte-identical', () async {
    final base = basePrediction();
    final dio = scriptedDio((options, handler) {
      handler.resolve(Response(requestOptions: options, statusCode: 200, data: okGeminiResponse()));
    });

    final result = await runDecorator(dio: dio, inner: base);

    expect(result, isNotNull);
    expect(result!.rationale, 'Heavy sustained rainfall on already-saturated ground.');
    expect(result.score, base.score);
    expect(result.confidence, base.confidence);
    expect(result.featureContributions, base.featureContributions);
  });

  test('a malformed (non-JSON) response body falls back to the inner prediction exactly', () async {
    final base = basePrediction();
    final dio = scriptedDio((options, handler) {
      handler.resolve(Response(requestOptions: options, statusCode: 200, data: 'not json'));
    });

    final result = await runDecorator(dio: dio, inner: base);

    expect(result, isNotNull);
    expect(result!.rationale, isNull);
    expect(result.score, base.score);
  });

  test('a network failure falls back to the inner prediction exactly', () async {
    final base = basePrediction();
    final dio = scriptedDio((options, handler) {
      handler.reject(DioException(requestOptions: options, type: DioExceptionType.connectionTimeout));
    });

    final result = await runDecorator(dio: dio, inner: base);

    expect(result, isNotNull);
    expect(result!.rationale, isNull);
    expect(result.score, base.score);
  });

  test('disabled: falls back with zero HTTP requests made', () async {
    final base = basePrediction();
    var requestCount = 0;
    final dio = scriptedDio((options, handler) {
      requestCount++;
      handler.resolve(Response(requestOptions: options, statusCode: 200, data: okGeminiResponse()));
    });

    final result = await runDecorator(dio: dio, inner: base, enabled: false);

    expect(result!.rationale, isNull);
    expect(requestCount, 0);
  });

  test('below the enrichment threshold: falls back with zero HTTP requests made', () async {
    final base = basePrediction(score: 0.5);
    var requestCount = 0;
    final dio = scriptedDio((options, handler) {
      requestCount++;
      handler.resolve(Response(requestOptions: options, statusCode: 200, data: okGeminiResponse()));
    });

    final result = await runDecorator(dio: dio, inner: base, enrichmentThreshold: 0.6);

    expect(result!.rationale, isNull);
    expect(requestCount, 0);
  });

  test('inner model returning null: decorator returns null with no HTTP call', () async {
    var requestCount = 0;
    final dio = scriptedDio((options, handler) {
      requestCount++;
      handler.resolve(Response(requestOptions: options, statusCode: 200, data: okGeminiResponse()));
    });

    final result = await runDecorator(dio: dio, inner: null);

    expect(result, isNull);
    expect(requestCount, 0);
  });

  test('an unrecognized dominantFactor value is rejected, falls back to inner', () async {
    final base = basePrediction();
    final dio = scriptedDio((options, handler) {
      handler.resolve(
        Response(
          requestOptions: options,
          statusCode: 200,
          data: okGeminiResponse(dominantFactor: 'wind'),
        ),
      );
    });

    final result = await runDecorator(dio: dio, inner: base);

    expect(result!.rationale, isNull);
  });
}
