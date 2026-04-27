// models/accumulator_base_model.dart
abstract class BaseAccumulator {
  final String type;
  final DateTime scrapedAt;
  final int count;
  final bool cached;

  BaseAccumulator({
    required this.type,
    required this.scrapedAt,
    required this.count,
    required this.cached,
  });
}

class BaseMatch {
  final String date;
  final String matchTitle;
  final List<String> teams;
  final String prediction;
  final String matchUrl;

  BaseMatch({
    required this.date,
    required this.matchTitle,
    required this.teams,
    required this.prediction,
    required this.matchUrl,
  });

  factory BaseMatch.fromJson(Map<String, dynamic> json) {
    return BaseMatch(
      date: json['date'] ?? '',
      matchTitle: json['match_title'] ?? '',
      teams: (json['teams'] as List?)?.cast<String>() ?? [],
      prediction: json['prediction'] ?? '',
      matchUrl: json['match_url'] ?? '',
    );
  }
}