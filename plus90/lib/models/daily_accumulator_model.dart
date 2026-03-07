// models/daily_accumulator_model.dart
import 'accumulator_base_model.dart';

class DailyAccumulator extends BaseAccumulator {
  final double totalOdds;
  final List<DailyAccumulatorMatch> matches;
  final double totalOddsRaw;

  DailyAccumulator({
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

  factory DailyAccumulator.fromJson(Map<String, dynamic> json) {
    return DailyAccumulator(
      totalOdds: double.tryParse(
        json['total_odds']?.toString().replaceAll(' Odds', '') ?? '0'
      ) ?? 0.0,
      matches: (json['matches'] as List?)
          ?.map((match) => DailyAccumulatorMatch.fromJson(match))
          .toList() ?? [],
      totalOddsRaw: double.tryParse(json['total_odds_raw']?.toString() ?? '0') ?? 0.0,
      type: json['type'] ?? 'Daily Accumulator',
      scrapedAt: json['scraped_at'] != null 
          ? DateTime.parse(json['scraped_at'])
          : DateTime.now(),
      count: json['count'] ?? 0,
      cached: json['cached'] ?? false,
    );
  }

  // Add toJson method
  Map<String, dynamic> toJson() {
    return {
      'total_odds': totalOdds.toString(),
      'matches': matches.map((match) => match.toJson()).toList(),
      'total_odds_raw': totalOddsRaw,
      'type': type,
      'scraped_at': scrapedAt.toIso8601String(),
      'count': count,
      'cached': cached,
    };
  }
}

class DailyAccumulatorMatch extends BaseMatch {
  DailyAccumulatorMatch({
    required super.date,
    required super.matchTitle,
    required super.teams,
    required super.prediction,
    required super.matchUrl,
  });

  factory DailyAccumulatorMatch.fromJson(Map<String, dynamic> json) {
    return DailyAccumulatorMatch(
      date: json['date'] ?? '',
      matchTitle: json['match_title'] ?? '',
      teams: (json['teams'] as List?)?.cast<String>() ?? [],
      prediction: json['prediction'] ?? '',
      matchUrl: json['match_url'] ?? '',
    );
  }

  // Add toJson method
  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'match_title': matchTitle,
      'teams': teams,
      'prediction': prediction,
      'match_url': matchUrl,
    };
  }
}