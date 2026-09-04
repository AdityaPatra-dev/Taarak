import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:taarak/core/config/gemini_config.dart';
import 'package:taarak/core/logging/app_logger.dart';
import 'package:taarak/features/hazards/domain/hazard_type.dart';
import 'package:taarak/features/susceptibility/domain/hazard_susceptibility_prediction.dart';

/// The two things Gemini is trusted to produce for a hazard prediction
/// that's already crossed the create threshold — a short explanation and
/// which of the already-computed signals it thinks matters most.
/// Deliberately does NOT carry a score/severity: this class cannot be
/// asked to invent one, because there's no field here to put it in.
class GeminiRationale {
  final String rationale;
  final String dominantFactor;

  const GeminiRationale({required this.rationale, required this.dominantFactor});
}

/// Thin REST client for Gemini's `generateContent` endpoint, requesting
/// structured JSON output so a caller never has to parse free-form prose.
/// Mirrors [OpenMeteoDataSource]'s own contract: never throws to the
/// caller, degrades to `null` on any HTTP/timeout/parse failure — a
/// missing rationale is an acceptable outcome, a corrupted one is not.
class GeminiHazardClient {
  static const String _model = 'gemini-2.0-flash';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';
  static const List<String> _allowedDominantFactors = ['rainfall24h', 'soilMoisture'];

  final Dio _dio;

  GeminiHazardClient({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 6),
              receiveTimeout: const Duration(seconds: 6),
            ),
          );

  Future<GeminiRationale?> classify({
    required HazardSusceptibilityPrediction prediction,
    required HazardType hazardType,
    required String habitationName,
    required int populationExposed,
  }) async {
    try {
      final response = await _dio.post(
        _baseUrl,
        queryParameters: {'key': GeminiConfig.apiKey},
        data: {
          'contents': [
            {
              'parts': [
                {'text': _prompt(prediction, hazardType, habitationName, populationExposed)},
              ],
            },
          ],
          'generationConfig': {
            'responseMimeType': 'application/json',
            'responseSchema': {
              'type': 'OBJECT',
              'properties': {
                'rationale': {'type': 'STRING'},
                'dominantFactor': {
                  'type': 'STRING',
                  'enum': _allowedDominantFactors,
                },
              },
              'required': ['rationale', 'dominantFactor'],
            },
          },
        },
      );
      return _parse(response.data);
    } on DioException catch (error) {
      AppLogger.warning('Gemini hazard classification request failed: ${error.message}');
      return null;
    } catch (error, stackTrace) {
      AppLogger.error('Could not parse Gemini hazard classification response', error, stackTrace);
      return null;
    }
  }

  String _prompt(
    HazardSusceptibilityPrediction prediction,
    HazardType hazardType,
    String habitationName,
    int populationExposed,
  ) {
    final factors = prediction.featureContributions.entries
        .map((e) => '${e.key}: ${e.value.toStringAsFixed(2)}')
        .join(', ');
    return 'A disaster-response app has already computed, from live weather '
        'data, that "$habitationName" (approx. $populationExposed people) has '
        'a ${hazardType.storageValue} susceptibility score of '
        '${prediction.score.toStringAsFixed(2)} (0-1 scale), driven by these '
        'already-computed factors: $factors. Do not invent a different score '
        'or any new factors. In no more than 220 characters, write a plain, '
        'calm rationale a local official could read at a glance, and name '
        'which of the given factors is dominant.';
  }

  /// Even though a response schema was requested, a schema is a request,
  /// not a guarantee — every field is still defensively re-validated here.
  GeminiRationale? _parse(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    final candidates = data['candidates'];
    if (candidates is! List || candidates.isEmpty) return null;
    final content = candidates.first['content'];
    if (content is! Map<String, dynamic>) return null;
    final parts = content['parts'];
    if (parts is! List || parts.isEmpty) return null;
    final text = parts.first['text'];
    if (text is! String) return null;

    final Object? decoded;
    try {
      decoded = jsonDecode(text);
    } on FormatException {
      return null;
    }
    if (decoded is! Map<String, dynamic>) return null;

    final rationale = decoded['rationale'];
    final dominantFactor = decoded['dominantFactor'];
    if (rationale is! String || rationale.trim().isEmpty) return null;
    if (dominantFactor is! String || !_allowedDominantFactors.contains(dominantFactor)) {
      return null;
    }

    final trimmedRationale = rationale.length > 220 ? rationale.substring(0, 220) : rationale;
    return GeminiRationale(rationale: trimmedRationale, dominantFactor: dominantFactor);
  }
}
