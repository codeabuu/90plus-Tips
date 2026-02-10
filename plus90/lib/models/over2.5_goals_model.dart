// models/over_25_goals_model.dart
import 'accumulator_base_model.dart';

class Over25GoalsAccumulator extends BaseAccumulator {
  final double totalOdds;
  final List<Over25GoalsMatch> matches;
  final double totalOddsRaw;

  Over25GoalsAccumulator({
    required this.totalOdds,
    required this.matches,
    required this.totalOddsRaw,
    required String type,
    required DateTime scrapedAt,
    required int count,
    required bool cached,
  }) : super(
          type: type,
          scrapedAt: scrapedAt,
          count: count,
          cached: cached,
        );

  factory Over25GoalsAccumulator.fromJson(Map<String, dynamic> json) {
    return Over25GoalsAccumulator(
      totalOdds: double.parse(json['total_odds'].toString().replaceAll(' Odds', '')),
      matches: (json['matches'] as List)
          .map((match) => Over25GoalsMatch.fromJson(match))
          .toList(),
      totalOddsRaw: double.parse(json['total_odds_raw']?.toString() ?? '0'),
      type: json['type'] ?? 'Over 2.5 Goals Accumulator',
      scrapedAt: DateTime.parse(json['scraped_at']),
      count: json['count'] ?? 0,
      cached: json['cached'] ?? false,
    );
  }
}

class Over25GoalsMatch extends BaseMatch {
  Over25GoalsMatch({
    required super.date,
    required super.matchTitle,
    required super.teams,
    required super.prediction,
    required super.matchUrl,
  });

  factory Over25GoalsMatch.fromJson(Map<String, dynamic> json) {
    return Over25GoalsMatch(
      date: json['date'] ?? '',
      matchTitle: json['match_title'] ?? '',
      teams: (json['teams'] as List?)?.cast<String>() ?? [],
      prediction: json['prediction'] ?? '',
      matchUrl: json['match_url'] ?? '',
    );
  }
}