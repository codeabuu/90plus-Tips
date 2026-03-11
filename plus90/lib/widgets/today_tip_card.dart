// widgets/today_tip_card.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum TipType {
  betOfTheDay,
  megaAccumulator,
  bttsAndWin,
  goalScorer,
  over25Goals,
  btts,
}

extension TipTypeExtension on TipType {
  String get title {
    switch (this) {
      case TipType.betOfTheDay:
        return 'BET OF THE DAY';
      case TipType.megaAccumulator:
        return 'MEGA ACCUMULATOR';
      case TipType.bttsAndWin:
        return 'BTTS & WIN';
      case TipType.goalScorer:
        return 'GOAL SCORER';
      case TipType.over25Goals:
        return 'OVER 2.5 GOALS';
      case TipType.btts:
        return 'BOTH TEAMS TO SCORE';
    }
  }

  String get subtitle {
    switch (this) {
      case TipType.betOfTheDay:
        return 'Top rated prediction for today';
      case TipType.megaAccumulator:
        return 'High odds accumulator bet';
      case TipType.bttsAndWin:
        return 'Both teams score & home win';
      case TipType.goalScorer:
        return 'Anytime goalscorer tips';
      case TipType.over25Goals:
        return 'Matches with 3+ goals';
      case TipType.btts:
        return 'Both teams to score tips';
    }
  }

  // Add image paths to match home screen icons
  String? get imagePath {
    switch (this) {
      case TipType.betOfTheDay:
        return 'assets/icons/tip_of_the_day.png';
      case TipType.megaAccumulator:
        return 'assets/icons/multicombo.png';
      case TipType.bttsAndWin:
        return 'assets/icons/bttswin.jpg';
      case TipType.over25Goals:
        return 'assets/icons/over_25.png';
      case TipType.btts:
        return 'assets/icons/btts.jpg';
      default:
        return null;
    }
  }

  Color get color {
    switch (this) {
      case TipType.betOfTheDay:
        return AppTheme.accentGold; // Match home screen
      case TipType.megaAccumulator:
        return const Color(0xFF2196F3); // blueColor
      case TipType.bttsAndWin:
        return const Color(0xFF2196F3); // blueColor
      case TipType.goalScorer:
        return Colors.green;
      case TipType.over25Goals:
        return const Color(0xFFFF9800); // orangeColor
      case TipType.btts:
        return const Color(0xFF2196F3); // blueColor
    }
  }

  // Keep icons as fallback
  IconData get icon {
    switch (this) {
      case TipType.betOfTheDay:
        return Icons.emoji_events;
      case TipType.megaAccumulator:
        return Icons.layers;
      case TipType.bttsAndWin:
        return Icons.swap_horiz;
      case TipType.goalScorer:
        return Icons.sports_soccer;
      case TipType.over25Goals:
        return Icons.format_list_numbered;
      case TipType.btts:
        return Icons.sync_alt;
    }
  }
}

class TodayTipCard extends StatelessWidget {
  final TipType tipType;
  final String? odds;
  final int? matchCount;
  final String? mainPrediction;
  final VoidCallback onTap;
  final bool isLoading;
  final Widget? customContent;
  final List<Widget>? matchesList;

  const TodayTipCard({
    super.key,
    required this.tipType,
    this.odds,
    this.matchCount,
    this.mainPrediction,
    required this.onTap,
    this.isLoading = false,
    this.customContent,
    this.matchesList,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: tipType.color.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: tipType.color.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: Colors.white,
            child: InkWell(
              onTap: isLoading ? null : onTap,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Row(
                      children: [
                        // Icon with image or fallback - NO BACKGROUND
                        Container(
                          width: 48,
                          height: 48,
                          child: tipType.imagePath != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    tipType.imagePath!,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      // Fallback to icon if image fails
                                      return Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: tipType.color.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          tipType.icon,
                                          size: 24,
                                          color: tipType.color,
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: tipType.color.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    tipType.icon,
                                    size: 24,
                                    color: tipType.color,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tipType.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryNavy,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                tipType.subtitle,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (odds != null && odds != '0' && odds != '0.0')
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: tipType.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: tipType.color.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 14,
                                  color: Colors.amber,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$odds',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: tipType.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Content Area
                    if (isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (matchesList != null && matchesList!.isNotEmpty)
                      Column(
                        children: [
                          ...matchesList!,
                          const SizedBox(height: 8),
                          if (odds != null && odds != '0' && odds != '0.0')
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'Total Odds: ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  '$odds',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      )
                    else if (customContent != null)
                      customContent!
                    else
                      _buildDefaultContent(),
                    
                    if (matchCount != null && 
                        matchCount! > 0 && 
                        (matchesList == null || matchesList!.isEmpty))
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.sports_soccer,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${matchCount} ${matchCount == 1 ? 'match' : 'matches'}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultContent() {
    if (mainPrediction != null) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: tipType.color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: tipType.color.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.bolt,
              size: 16,
              color: tipType.color,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                mainPrediction!,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primaryNavy,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'No predictions available for today',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Match Preview Tile
class MatchPreviewTile extends StatelessWidget {
  final String homeTeam;
  final String awayTeam;
  final String prediction;
  final String? odds;
  final bool isLast;

  const MatchPreviewTile({
    super.key,
    required this.homeTeam,
    required this.awayTeam,
    required this.prediction,
    this.odds,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isLast ? Colors.transparent : Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$homeTeam vs $awayTeam',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryNavy,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    prediction,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (odds != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.green[200]!,
                  width: 1,
                ),
              ),
              child: Text(
                odds!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ),
        ],
      ),
    );
  }
}