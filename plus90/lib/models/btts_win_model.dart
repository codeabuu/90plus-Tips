// models/btts_win_model.dart (updated)
import 'accumulator_base_model.dart';

class BTTSWinAccumulator extends BaseAccumulator {
  final double totalOdds;
  final List<BTTSWinMatch> matches;
  final double totalOddsRaw;

  BTTSWinAccumulator({
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

  factory BTTSWinAccumulator.fromJson(Map<String, dynamic> json) {
    return BTTSWinAccumulator(
      totalOdds: double.parse(json['total_odds'].toString().replaceAll(' Odds', '')),
      matches: (json['matches'] as List)
          .map((match) => BTTSWinMatch.fromJson(match))
          .toList(),
      totalOddsRaw: double.parse(json['total_odds_raw']?.toString() ?? '0'),
      type: json['type'] ?? 'BTTS and Win Accumulator',
      scrapedAt: DateTime.parse(json['scraped_at']),
      count: json['count'] ?? 0,
      cached: json['cached'] ?? false,
    );
  }

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

class BTTSWinMatch extends BaseMatch {
  BTTSWinMatch({
    required super.date,
    required super.matchTitle,
    required super.teams,
    required super.prediction,
    required super.matchUrl,
  });

  factory BTTSWinMatch.fromJson(Map<String, dynamic> json) {
    return BTTSWinMatch(
      date: json['date'] ?? '',
      matchTitle: json['match_title'] ?? '',
      teams: (json['teams'] as List?)?.cast<String>() ?? [],
      prediction: json['prediction'] ?? '',
      matchUrl: json['match_url'] ?? '',
    );
  }

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