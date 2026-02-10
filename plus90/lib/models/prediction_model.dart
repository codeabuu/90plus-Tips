// models/match_prediction_model.dart
class MatchPrediction {
  final String teams;
  final String date;
  final String homeTeam;
  final String awayTeam;
  final List<PredictionItem> predictions;

  MatchPrediction({
    required this.teams,
    required this.date,
    required this.homeTeam,
    required this.awayTeam,
    required this.predictions,
  });

  factory MatchPrediction.fromJson(Map<String, dynamic> json) {
    return MatchPrediction(
      teams: json['teams'] ?? '',
      date: json['date'] ?? '',
      homeTeam: json['home_team'] ?? '',
      awayTeam: json['away_team'] ?? '',
      predictions: (json['predictions'] as List?)
          ?.map((p) => PredictionItem.fromJson(p))
          .toList() ?? [],
    );
  }
}

class PredictionItem {
  final String prediction;
  final double odds;
  final String? analysis;

  PredictionItem({
    required this.prediction,
    required this.odds,
    this.analysis,
  });

  factory PredictionItem.fromJson(Map<String, dynamic> json) {
    return PredictionItem(
      prediction: json['prediction'] ?? '',
      odds: (json['odds'] ?? 0).toDouble(),
      analysis: json['analysis'],
    );
  }
}