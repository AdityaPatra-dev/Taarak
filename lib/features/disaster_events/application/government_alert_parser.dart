import 'package:taarak/features/disaster_events/domain/disaster_event.dart';

/// What [GovernmentAlertParser.parse] could actually extract from a free-
/// text bulletin. Deliberately doesn't attempt to geocode a place name out
/// of the text — a regex guessing at a location and being wrong is worse
/// than admitting it doesn't know one, so [DisasterEvent.latitude]/
/// [longitude] for a parsed alert always comes from a human confirming a
/// point on the map, not from this parser.
class ParsedGovernmentAlert {
  final DisasterEventType? hazardType;
  final double? rainfall24hMm;
  final List<String> riverMentions;
  final List<String> roadMentions;
  final String rawText;

  const ParsedGovernmentAlert({
    required this.hazardType,
    required this.rainfall24hMm,
    required this.riverMentions,
    required this.roadMentions,
    required this.rawText,
  });

  bool get hasAnyStructuredData =>
      hazardType != null ||
      rainfall24hMm != null ||
      riverMentions.isNotEmpty ||
      roadMentions.isNotEmpty;
}

/// Deterministic, regex-based extraction of the fields a government
/// bulletin typically states plainly — not an LLM, not a guess. This is
/// exactly the kind of "AI" this project's architecture notes explicitly
/// warn against needing: the structure in an alert like "180mm expected
/// within 24 hours" doesn't need a model to find, it needs a pattern
/// match. A field this parser can't find is left `null`/empty rather than
/// invented.
class GovernmentAlertParser {
  static final RegExp _rainfallPattern = RegExp(
    r'(\d+(?:\.\d+)?)\s*mm',
    caseSensitive: false,
  );
  static final RegExp _riverPattern = RegExp(
    r'([A-Z][a-zA-Z]+)\s+river\b',
    caseSensitive: false,
  );
  static final RegExp _roadPattern = RegExp(
    r'\b([NS]H\s?-?\s?\d+)\b',
    caseSensitive: false,
  );

  ParsedGovernmentAlert parse(String text) {
    final lowerText = text.toLowerCase();

    final rainfallMatch = _rainfallPattern.firstMatch(text);
    final rainfall = rainfallMatch == null
        ? null
        : double.tryParse(rainfallMatch.group(1)!);

    final riverMentions = _riverPattern
        .allMatches(text)
        .map((m) => m.group(1)!)
        .toSet()
        .toList();

    final roadMentions = _roadPattern
        .allMatches(text)
        .map((m) => m.group(1)!.toUpperCase().replaceAll(RegExp(r'\s|-'), ''))
        .toSet()
        .toList();

    final hazardType = _classifyHazard(lowerText);

    return ParsedGovernmentAlert(
      hazardType: hazardType,
      rainfall24hMm: rainfall,
      riverMentions: riverMentions,
      roadMentions: roadMentions,
      rawText: text,
    );
  }

  DisasterEventType? _classifyHazard(String lowerText) {
    if (lowerText.contains('landslide')) return DisasterEventType.landslide;
    if (lowerText.contains('river') && lowerText.contains('ris')) {
      return DisasterEventType.riverRise;
    }
    if (lowerText.contains('rainfall') || lowerText.contains('rain')) {
      return DisasterEventType.heavyRainfall;
    }
    if (lowerText.contains('road') ||
        lowerText.contains('blocked') ||
        lowerText.contains('vulnerable')) {
      return DisasterEventType.roadBlocked;
    }
    if (lowerText.contains('evacuat')) {
      return DisasterEventType.evacuationOrder;
    }
    return null;
  }
}
