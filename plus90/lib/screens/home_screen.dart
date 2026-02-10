import 'package:flutter/material.dart';
import 'package:plus90/screens/prediction_screen.dart';
import 'package:provider/provider.dart';
import '../providers/predictions_provider.dart';
import '../widgets/hero_section.dart';
import '../theme/app_theme.dart';
import 'btts_win_screen.dart';

import 'bet_of_day_screen.dart';
import 'over25_screen.dart';
import 'daily_accum_screen.dart';
import 'btts_screen.dart';
import 'leagues_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PredictionsProvider>().fetchAllPredictions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final predictionsProvider = context.watch<PredictionsProvider>();

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await predictionsProvider.fetchAllPredictions();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Section
                const HeroSection(),

                const SizedBox(height: 24),

                // Prediction Categories Grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Browse Predictions',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 16),
                      
                      // Grid of Category Cards
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1.0,
                        children: [
                          _buildCategoryCard(
                            context: context,
                            title: 'Free Tips',
                            subtitle: '${predictionsProvider.freeTips.length} tips',
                            icon: Icons.card_giftcard,
                            color: AppTheme.accentGreen,
                            onTap: () {
                              Navigator.pushNamed(context, '/free-tips');
                            },
                          ),
                          _buildCategoryCard(
                            context: context,
                            title: 'Todays Tips',
                            subtitle: 'Featured ⭐⭐⭐⭐⭐\n',
                            icon: Icons.whatshot,
                            color: AppTheme.accentGold,
                            onTap: () {
                              Navigator.push(
                                context, 
                                MaterialPageRoute(
                                  builder: (context) => BetOfDayScreen(),
                                ),
                              );
                            },
                          ),
                          _buildCategoryCard(
                            context: context,
                            title: 'Predictions',
                            subtitle: 'Live predictions',
                            icon: Icons.whatshot,
                            color: AppTheme.accentGold,
                            onTap: () {
                              Navigator.push(
                                context, 
                                MaterialPageRoute(
                                  builder: (context) => PredictionsScreen(),
                                ),
                              );
                            },
                          ),
                          _buildCategoryCard(
                            context: context,
                            title: 'Tip of Day',
                            subtitle: predictionsProvider.betOfDayAccumulator == null
                                ? 'Featured ⭐⭐⭐⭐⭐\n'  // Show this while loading
                                : '${predictionsProvider.betOfDayAccumulator!.count} matches',  // Show actual count when loaded
                            icon: Icons.star,
                            color: AppTheme.accentGold,
                            onTap: () {
                              Navigator.push(
                                context, 
                                MaterialPageRoute(
                                  builder: (context) => BetOfDayScreen(),
                                ),
                              );
                            },
                          ),
                          _buildCategoryCard(
                            context: context,
                            title: 'Multi Combinations',
                            subtitle: predictionsProvider.dailyAccumulator == null
                                ? 'Updating...'
                                : '${predictionsProvider.dailyAccumulator!.count} matches',
                            icon: Icons.sports_soccer,
                            color: Color(0xFF2196F3),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DailyAccumulatorScreen(),
                                ),
                              );
                            },
                          ),
                         _buildCategoryCard(
                            context: context,
                            title: 'BTTS & Win',
                            subtitle: predictionsProvider.bttsWinAccumulator == null
                                ? 'Loading...'
                                : '${predictionsProvider.bttsWinAccumulator!.count} matches',
                            icon: Icons.sports_soccer,
                            color: Color(0xFF2196F3),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BttsWinScreen(),
                                ),
                              );
                            },
                          ),
                           _buildCategoryCard(
                            context: context,
                            title: 'BTTS',
                            subtitle: predictionsProvider.bttsAccumulator == null
                                ? 'Updating...'
                                : '${predictionsProvider.bttsAccumulator!.count} matches',
                            icon: Icons.sports_soccer,
                            color: Color(0xFF2196F3),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BttsScreen(),
                                ),
                              );
                            },
                          ),
                          _buildCategoryCard(
                            context: context,
                            title: 'Over 2.5',
                            subtitle: predictionsProvider.over25GoalsAccumulator == null
                                ? 'Updating...'
                                : '${predictionsProvider.over25GoalsAccumulator!.count} matches',
                            icon: Icons.trending_up,
                            color: Color(0xFFFF9800),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Over25GoalsScreen(),
                                ),
                              );
                            },
                          ),
                          // _buildCategoryCard(
                          //   context: context,
                          //   title: 'Correct Score',
                          //   subtitle: 'Exact results',
                          //   icon: Icons.scoreboard,
                          //   color: Color(0xFF9C27B0),
                          //   onTap: () {
                          //     Navigator.pushNamed(context, '/correct-score');
                          //   },
                          // ),
                          _buildCategoryCard(
                            context: context,
                            title: 'Leagues',
                            subtitle: 'By competition',
                            icon: Icons.emoji_events,
                            color: Color(0xFFE91E63),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LeaguesScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Quick Stats Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Our Performance',
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.accentGreen.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem(
                              label: 'Win Rate',
                              value: '73%',
                              icon: Icons.trending_up,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey[300],
                            ),
                            _buildStatItem(
                              label: 'Total Tips',
                              value: '500+',
                              icon: Icons.list_alt,
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey[300],
                            ),
                            _buildStatItem(
                              label: 'This Week',
                              value: '45',
                              icon: Icons.calendar_today,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Trust Signals
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.verified,
                          size: 32,
                          color: AppTheme.accentGreen,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Verified Accuracy',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryNavy,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'All predictions tracked transparently',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall!
                                    .copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Footer
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  color: AppTheme.primaryNavy.withOpacity(0.05),
                  child: Column(
                    children: [
                      const Icon(Icons.shield, size: 32, color: AppTheme.primaryNavy),
                      const SizedBox(height: 12),
                      Text(
                        'Responsible Gambling',
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                              color: AppTheme.primaryNavy,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This app provides predictions for entertainment purposes. Please gamble responsibly and within your means.',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          // Show gambling help resources
                        },
                        child: const Text('Gamble Aware Resources'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          border: Border.all(
            color: color.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: color,
                ),
              ),
              
              const SizedBox(height: 4),
              
              // Title
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryNavy,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 8),
              
              // Subtitle
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // View Tips Button
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'View Tips',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, size: 24, color: AppTheme.accentGreen),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryNavy,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}