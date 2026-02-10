// models/goalscorer_model.dart
import 'accumulator_base_model.dart';

class GoalscorerAccumulator extends BaseAccumulator {
  final double totalOdds;
  final List<GoalscorerMatch> matches;
  final double totalOddsRaw;

  GoalscorerAccumulator({
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

  factory GoalscorerAccumulator.fromJson(Map<String, dynamic> json) {
    return GoalscorerAccumulator(
      totalOdds: double.parse(json['total_odds'].toString().replaceAll(' Odds', '')),
      matches: (json['matches'] as List)
          .map((match) => GoalscorerMatch.fromJson(match))
          .toList(),
      totalOddsRaw: double.parse(json['total_odds_raw']?.toString() ?? '0'),
      type: json['type'] ?? 'Goalscorer Predictions',
      scrapedAt: DateTime.parse(json['scraped_at']),
      count: json['count'] ?? 0,
      cached: json['cached'] ?? false,
    );
  }
}

class GoalscorerMatch extends BaseMatch {
  final String playerName;
  final String? team;
  final String? odds;

  GoalscorerMatch({
    required super.date,
    required super.matchTitle,
    required super.teams,
    required super.prediction,
    required super.matchUrl,
    required this.playerName,
    this.team,
    this.odds,
  });

  factory GoalscorerMatch.fromJson(Map<String, dynamic> json) {
    return GoalscorerMatch(
      date: json['date'] ?? '',
      matchTitle: json['match_title'] ?? '',
      teams: (json['teams'] as List?)?.cast<String>() ?? [],
      prediction: json['prediction'] ?? '',
      matchUrl: json['match_url'] ?? '',
      playerName: json['player_name'] ?? '',
      team: json['team'],
      odds: json['odds'],
    );
  }
}