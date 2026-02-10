// widgets/prediction_card.dart
import 'package:flutter/material.dart';
import '../models/league_model.dart'; // Use MatchItem from here

class PredictionCard extends StatelessWidget {
  final MatchItem matchItem; // Change from matchPrediction to matchItem

  const PredictionCard({
    super.key,
    required this.matchItem,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
              color: Colors.blue[50],
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
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
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
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${matchItem.predictions.length} tips',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[800],
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