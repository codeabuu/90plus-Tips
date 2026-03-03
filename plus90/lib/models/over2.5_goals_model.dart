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
    // Parse total_odds - remove " Odds" text and convert to double
    double parsedTotalOdds = 0.0;
    if (json['total_odds'] != null) {
      String totalOddsStr = json['total_odds'].toString();
      // Simple replace to remove " Odds" text
      totalOddsStr = totalOddsStr.replaceAll(' Odds', '');
      parsedTotalOdds = double.tryParse(totalOddsStr) ?? 0.0;
    }
    
    // Parse total_odds_raw - ensure it's a double
    double parsedRawOdds = 0.0;
    if (json['total_odds_raw'] != null) {
      if (json['total_odds_raw'] is num) {
        parsedRawOdds = (json['total_odds_raw'] as num).toDouble();
      } else {
        parsedRawOdds = double.tryParse(json['total_odds_raw'].toString()) ?? 0.0;
      }
    }

    return Over25GoalsAccumulator(
      totalOdds: parsedTotalOdds,
      matches: (json['matches'] as List?)
              ?.map((match) => Over25GoalsMatch.fromJson(match))
              .toList() ?? [],
      totalOddsRaw: parsedRawOdds,
      type: json['type'] ?? 'Over 2.5 Goals Accumulator',
      scrapedAt: json['scraped_at'] != null 
          ? DateTime.parse(json['scraped_at']) 
          : DateTime.now(),
      count: json['count'] ?? (json['matches']?.length ?? 0),
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
      teams: (json['teams'] as List?)?.map((e) => e.toString()).toList() ?? [],
      prediction: json['prediction'] ?? '',
      matchUrl: json['match_url'] ?? '',
    );
  }
}