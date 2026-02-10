// models/bet_of_day_model.dart - CORRECTED
import 'accumulator_base_model.dart';

class BetOfDayAccumulator extends BaseAccumulator {
  final double totalOdds;
  final List<BetOfDayMatch> matches;
  final double totalOddsRaw;

  BetOfDayAccumulator({
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

  factory BetOfDayAccumulator.fromJson(Map<String, dynamic> json) {
    return BetOfDayAccumulator(
      totalOdds: double.parse(json['total_odds'].toString().replaceAll(' Odds', '')),
      matches: (json['matches'] as List)
          .map((match) => BetOfDayMatch.fromJson(match))
          .toList(),
      totalOddsRaw: double.parse(json['total_odds_raw']?.toString() ?? '0'),
      type: 'Bet of the Day', // Hardcode this since API doesn't provide it
      scrapedAt: DateTime.now(), // Since API doesn't have scraped_at, use current time
      count: json['count'] ?? 0,
      cached: json['cached'] ?? false,
    );
  }
}

class BetOfDayMatch extends BaseMatch {
  BetOfDayMatch({
    required super.date,
    required super.matchTitle,
    required super.teams,
    required super.prediction,
    required super.matchUrl,
  });

  factory BetOfDayMatch.fromJson(Map<String, dynamic> json) {
    return BetOfDayMatch(
      date: json['date'] ?? '',
      matchTitle: json['match_title'] ?? '',
      teams: (json['teams'] as List?)?.cast<String>() ?? [],
      prediction: json['prediction'] ?? '',
      matchUrl: json['match_url'] ?? '',
    );
  }
}