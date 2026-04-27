import 'package:flutter/material.dart';
import '../models/league_model.dart';

class PredictionCard extends StatelessWidget {
  final MatchItem matchItem;

  const PredictionCard({
    super.key,
    required this.matchItem,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.blue; // MaterialColor for shades

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primaryColor.shade100, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Match Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        matchItem.teams.isNotEmpty
                            ? matchItem.teams
                            : '${matchItem.homeTeam} vs ${matchItem.awayTeam}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryColor.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${matchItem.date} ${matchItem.time.isNotEmpty ? '• ${matchItem.time}' : ''}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${matchItem.predictions.length} tips',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: primaryColor.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Predictions List
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: matchItem.predictions.map((prediction) {
                return _buildPredictionItem(prediction);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionItem(Prediction prediction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              prediction.prediction,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          if (prediction.odds != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _getOddsColor(prediction.odds!),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                prediction.odds!.toStringAsFixed(2),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getOddsColor(double odds) {
    if (odds < 1.5) return Colors.green;
    if (odds < 2.0) return Colors.blue;
    if (odds < 3.0) return Colors.orange;
    return Colors.red;
  }
}