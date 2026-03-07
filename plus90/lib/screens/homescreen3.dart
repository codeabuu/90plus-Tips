// screens/home_screen_part3_fixed.dart
import 'package:flutter/material.dart';
import 'package:plus90/screens/prediction_screen.dart';
import 'package:plus90/screens/btts_win_screen.dart';
import 'package:plus90/screens/bet_of_day_screen.dart';
import 'package:plus90/screens/over25_screen.dart';
import 'package:plus90/screens/daily_accum_screen.dart';
import 'package:plus90/screens/btts_screen.dart';
import 'package:plus90/screens/leagues_screen.dart';
import '../providers/predictions_provider.dart';
import '../theme/app_theme.dart';
import 'homescreen2.dart';
import '../widgets/dotanimate.dart';

// Card Configuration - Single source of truth
class _CardConfig {
  final String title;
  final IconData icon;
  final Color color;
  final Widget? targetScreen;
  final int? tabIndex;
  final String? subtitle;
  final String? Function(PredictionsProvider)? subtitleBuilder;
  final String? Function(PredictionsProvider) oddsBuilder;

  const _CardConfig({
    required this.title,
    required this.icon,
    required this.color,
    this.targetScreen,
    this.tabIndex,
    this.subtitle,
    this.subtitleBuilder,
    required this.oddsBuilder,
  });
}

class PredictionCategoriesSection extends StatelessWidget {
  final PredictionsProvider provider;
  final Function(int) onNavigate;
  final bool isPremium;
  final VoidCallback onUpgradeTap;

  const PredictionCategoriesSection({
    required this.provider,
    required this.onNavigate,
    required this.isPremium,
    required this.onUpgradeTap,
  });

  static const Color blueColor = Color(0xFF2196F3);
  static const Color orangeColor = Color(0xFFFF9800);
  static const Color pinkColor = Color(0xFFE91E63);

  List<_CardConfig> get _cards => [
    _CardConfig(
      title: 'Todays Tips',
      icon: Icons.whatshot,
      color: AppTheme.accentGold,
      tabIndex: 1,
       subtitleBuilder: (p) => _getTodaysTipsCount(p),
      oddsBuilder: _calculateTodaysTipsOdds,
    ),
    _CardConfig(
      title: 'Predictions',
      icon: Icons.whatshot,
      color: AppTheme.accentGold,
      targetScreen: const PredictionsScreen(),
      subtitle: 'Live predictions',
      oddsBuilder: (_) => '1200+',
    ),
    _CardConfig(
      title: 'Tip of Day',
      icon: Icons.star,
      color: AppTheme.accentGold,
      targetScreen: const BetOfDayScreen(),
      subtitle: 'Featured ⭐⭐⭐⭐⭐',
      oddsBuilder: (p) => p.betOfDayAccumulator?.totalOdds.toStringAsFixed(2) ?? '',
    ),
    _CardConfig(
      title: 'Multi Combinations',
      icon: Icons.sports_soccer,
      color: blueColor,
      targetScreen: const DailyAccumulatorScreen(),
      subtitleBuilder: (p) => p.dailyAccumulator == null
          ? 'Fetching...'
          : '${p.dailyAccumulator!.count} matches',
      oddsBuilder: (p) => p.dailyAccumulator?.totalOdds.toStringAsFixed(2) ?? '',
    ),
    _CardConfig(
      title: 'BTTS & Win',
      icon: Icons.sports_soccer,
      color: blueColor,
      targetScreen: const BttsWinScreen(),
      subtitleBuilder: (p) => p.bttsWinAccumulator == null
          ? 'Fetching...'
          : '${p.bttsWinAccumulator!.count} matches',
      oddsBuilder: (p) => p.bttsWinAccumulator?.totalOdds.toStringAsFixed(2) ?? '',
    ),
    _CardConfig(
      title: 'BTTS',
      icon: Icons.sports_soccer,
      color: blueColor,
      targetScreen: const BttsScreen(),
      subtitleBuilder: (p) => p.bttsAccumulator == null
          ? 'Fetching...'
          : '${p.bttsAccumulator!.count} matches',
      oddsBuilder: (p) => p.bttsAccumulator?.totalOdds.toStringAsFixed(2) ?? '',
    ),
    _CardConfig(
      title: 'Over 2.5',
      icon: Icons.trending_up,
      color: orangeColor,
      targetScreen: const Over25GoalsScreen(),
      subtitleBuilder: (p) => p.over25GoalsAccumulator == null
          ? 'Fetching...'
          : '${p.over25GoalsAccumulator!.count} matches',
      oddsBuilder: (p) => p.over25GoalsAccumulator?.totalOdds.toStringAsFixed(2) ?? '',
    ),
    _CardConfig(
      title: 'Leagues',
      icon: Icons.emoji_events,
      color: pinkColor,
      tabIndex: 2,
      subtitle: 'By competition',
      oddsBuilder: (_) => '1200+',
    ),
  ];

  String _getTodaysTipsCount(PredictionsProvider p) {
  int totalMatches = 0;
  
  if (p.betOfDayAccumulator != null) {
    totalMatches += p.betOfDayAccumulator!.count;
  }
  if (p.dailyAccumulator != null) {
    totalMatches += p.dailyAccumulator!.count;
  }
  if (p.bttsWinAccumulator != null) {
    totalMatches += p.bttsWinAccumulator!.count;
  }
  if (p.bttsAccumulator != null) {
    totalMatches += p.bttsAccumulator!.count;
  }
  if (p.over25GoalsAccumulator != null) {
    totalMatches += p.over25GoalsAccumulator!.count;
  }
  
  return totalMatches > 0 ? '$totalMatches matches' : 'Fetching...';
}

  String _calculateTodaysTipsOdds(PredictionsProvider p) {
    double totalOdds = 1.0;
    bool hasOdds = false;
    
    final accumulators = [
      p.betOfDayAccumulator?.totalOdds,
      p.dailyAccumulator?.totalOdds,
      p.bttsWinAccumulator?.totalOdds,
      p.bttsAccumulator?.totalOdds,
      p.over25GoalsAccumulator?.totalOdds,
    ];
    
    for (var odds in accumulators) {
      if (odds != null && odds > 0) {
        totalOdds *= odds;
        hasOdds = true;
      }
    }
    
    return hasOdds ? totalOdds.toStringAsFixed(2) : '';
  }

  void _handleTap(BuildContext context, _CardConfig card) {
    // Free features don't require premium
    final isFree = card.title == 'Predictions' || card.title == 'Leagues';
    
    if (!isPremium && !isFree) {
      onUpgradeTap();
      return;
    }
    
    if (card.tabIndex != null) {
      onNavigate(card.tabIndex!);
    } else if (card.targetScreen != null) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => card.targetScreen!));
    }
  }

  String _getSubtitle(_CardConfig card) {
  if (card.subtitleBuilder != null) {
    final subtitle = card.subtitleBuilder!(provider);
    return subtitle ?? ''; // Handle null case
  }
  return card.subtitle ?? ''; // Handle null case
}

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Browse Predictions', style: Theme.of(context).textTheme.displaySmall),
              const Spacer(),
              const LiveIndicator(),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.82,
            ),
            itemCount: _cards.length,
            itemBuilder: (context, index) {
              final card = _cards[index];
              return _CategoryCard(
                title: card.title,
                subtitle: _getSubtitle(card),
                icon: card.icon,
                color: card.color,
                odds: card.oddsBuilder(provider),
                onTap: () => _handleTap(context, card),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String? odds;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.odds,
    required this.onTap,
  });

  static const Color oddsGreen = Color(0xFF00C853);
  static const Color analyzingColor = Colors.grey; // Warm orange for analyzing
  
  bool get _showOdds => odds != null && odds!.isNotEmpty && odds != '0' && odds != '0.00';
  bool get _isFeatured => title == 'Tip of Day' || title == 'Todays Tips';
  bool get _isAnalyzing => subtitle == 'Fetching...' || subtitle == 'Analyzing...' || odds == '0' || odds == '0.00';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
          border: Border.all(color: color.withOpacity(0.1), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.withOpacity(0.8), color],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 2))],
                ),
                child: Icon(icon, size: 24, color: Colors.white),
              ),
              
              const SizedBox(height: 8),
              
              // Title
              Text(
                title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy, letterSpacing: 0.2),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // Subtitle
        // First, import your dotanimate widget at the top of the file
// Adjust the import path as needed

// Then update the subtitle section in your _CategoryCard:

// Subtitle
SizedBox(
  height: 32,
  child: Center(
    child: _isFeatured
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color.withOpacity(0.1), color.withOpacity(0.2)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _isAnalyzing
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Analyzing',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                      AnimatedDots(color: analyzingColor, size: 11), // Your animated dots widget
                    ],
                  )
                : Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11, 
                      fontWeight: FontWeight.w600, 
                      color: color,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
          )
        : _isAnalyzing
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Analyzing',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  AnimatedDots(color: analyzingColor, size: 14), // Your animated dots widget
                ],
              )
            : Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12, 
                  color: Colors.grey[600], 
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
  ),
),
              
              const SizedBox(height: 6),
              
              // Status indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _isAnalyzing ? analyzingColor.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _isAnalyzing
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 10,
                            color: analyzingColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Within 24hrs',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: oddsGreen,
                            ),
                          ),
                        ],
                      )
                    : (_showOdds
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: oddsGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Total Odds: $odds',
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w500, color: oddsGreen),
                            ),
                          )
                        : const SizedBox.shrink()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Reusable Stat Item Widget
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  
  const _StatItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, size: 22, color: AppTheme.accentGreen),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy)),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
    ],
  );
}

class PerformanceSection extends StatelessWidget {
  const PerformanceSection();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Our Performance', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.accentGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.accentGreen.withOpacity(0.3)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(label: 'Win Rate', value: '96.4%', icon: Icons.trending_up),
              _Divider(),
              _StatItem(label: 'Total Tips 2026', value: '1600+', icon: Icons.list_alt),
              _Divider(),
              _StatItem(label: 'This Week', value: '200+', icon: Icons.calendar_today),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) => Container(width: 1, height: 35, color: Colors.grey[300]);
}

class TrustSignalSection extends StatelessWidget {
  const TrustSignalSection();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: const Row(
        children: [
          Icon(Icons.verified, size: 28, color: AppTheme.accentGreen),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Verified Accuracy', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy)),
                SizedBox(height: 2),
                Text('All predictions tracked transparently', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class ResponsibleGamblingFooter extends StatelessWidget {
  const ResponsibleGamblingFooter();

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    color: AppTheme.primaryNavy.withOpacity(0.05),
    child: Column(
      children: [
        const Icon(Icons.shield, size: 28, color: AppTheme.primaryNavy),
        const SizedBox(height: 8),
        const Text('Responsible Gambling', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.primaryNavy)),
        const SizedBox(height: 6),
        const Text(
          'This app provides predictions for entertainment purposes. Please gamble responsibly and within your means.',
          style: TextStyle(fontSize: 12),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: null,
          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)),
          child: const Text('Gamble Aware Resources', style: TextStyle(fontSize: 12)),
        ),
      ],
    ),
  );
}