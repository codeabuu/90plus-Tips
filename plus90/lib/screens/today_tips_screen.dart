// screens/today_tips_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../widgets/today_tip_card.dart';
import '../models/betofday_model.dart';
import '../models/daily_accumulator_model.dart';
import '../models/btts_win_model.dart';
import '../models/over2.5_goals_model.dart';
import '../models/btts_model.dart';
import '../providers/predictions_provider.dart'; // Add this import
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'bet_of_day_screen.dart';
import 'daily_accum_screen.dart';
import 'btts_screen.dart';
import 'btts_win_screen.dart';
import 'over25_screen.dart';

class TodayTipsScreen extends StatefulWidget {
  final Function(int) onNavigate;

  const TodayTipsScreen({super.key, required this.onNavigate});

  @override
  State<TodayTipsScreen> createState() => _TodayTipsScreenState();
}

class _TodayTipsScreenState extends State<TodayTipsScreen> {
  // Remove individual ApiService and tip data - we'll get from Provider
  bool _isLocalLoading = false; // For refresh indicator
  
  @override
  void initState() {
    super.initState();
    // Trigger a refresh when screen opens to ensure fresh data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshFromProvider();
    });
  }

  Future<void> _refreshFromProvider() async {
    setState(() => _isLocalLoading = true);
    
    // Force refresh from Provider
    await context.read<PredictionsProvider>().fetchAllPredictions();
    
    setState(() => _isLocalLoading = false);
  }

  // Check if any data exists in provider
  bool _hasAnyData(PredictionsProvider provider) {
    return (provider.betOfDayAccumulator != null && provider.betOfDayAccumulator!.matches.isNotEmpty) ||
           (provider.dailyAccumulator != null && provider.dailyAccumulator!.matches.isNotEmpty) ||
           (provider.bttsWinAccumulator != null && provider.bttsWinAccumulator!.matches.isNotEmpty) ||
           (provider.over25GoalsAccumulator != null && provider.over25GoalsAccumulator!.matches.isNotEmpty) ||
           (provider.bttsAccumulator != null && provider.bttsAccumulator!.matches.isNotEmpty);
  }

  String _formatOdds(dynamic odds) {
    if (odds == null) return '';
    if (odds is double) {
      return odds.toStringAsFixed(2);
    }
    if (odds is String) {
      try {
        final parsed = double.parse(odds.replaceAll(' Odds', ''));
        return parsed.toStringAsFixed(2);
      } catch (e) {
        return odds;
      }
    }
    return odds.toString();
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    
    final now = DateTime.now();
    if (dateTime.day == now.day && 
        dateTime.month == now.month && 
        dateTime.year == now.year) {
      return 'Today, ${DateFormat('dd MMM').format(dateTime)}';
    }
    
    return DateFormat('EEEE, dd MMM').format(dateTime);
  }

  // ============== HELPER METHOD TO GET TEAM NAMES ==============
  
  Map<String, String> _getTeamNamesFromMatchTitle(String matchTitle) {
    String homeTeam = '';
    String awayTeam = '';
    
    if (matchTitle.contains(' vs ')) {
      final parts = matchTitle.split(' vs ');
      homeTeam = parts[0].trim();
      awayTeam = parts.length > 1 ? parts[1].trim() : 'Opponent';
    } else {
      homeTeam = matchTitle;
      awayTeam = 'Opponent';
    }
    
    return {'home': homeTeam, 'away': awayTeam};
  }

  // ============== MATCHES LIST BUILDER ==============
  
  List<Widget> _buildMatchesList({
    required List<dynamic> matches,
    required String tipType,
  }) {
    if (matches.isEmpty) return [];
    
    return matches.map((match) {
      final isLast = matches.last == match;
      final teamNames = _getTeamNamesFromMatchTitle(match.matchTitle ?? '');
      
      return MatchPreviewTile(
        homeTeam: teamNames['home']!,
        awayTeam: teamNames['away']!,
        prediction: match.prediction?.toString() ?? 'N/A',
        isLast: isLast,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            Expanded(
              child: Consumer<PredictionsProvider>(
                builder: (context, provider, child) {
                  // Show loading if provider is loading OR local refresh is happening
                  if (provider.isLoading && !_hasAnyData(provider) || _isLocalLoading) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Loading today\'s predictions...',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }

                  // Check if there's any data
                  bool hasAnyData = _hasAnyData(provider);

                  // If no data at all, show empty state
                  if (!hasAnyData) {
                    return _buildEmptyState();
                  }

                  // Show the data
                  return RefreshIndicator(
                    onRefresh: _refreshFromProvider,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Tip of the Day
                        if (provider.betOfDayAccumulator != null && 
                            provider.betOfDayAccumulator!.matches.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8, bottom: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        _formatDate(provider.betOfDayAccumulator!.scrapedAt),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.blue[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TodayTipCard(
                                tipType: TipType.betOfTheDay,
                                odds: _formatOdds(provider.betOfDayAccumulator!.totalOdds),
                                matchCount: provider.betOfDayAccumulator!.matches.length,
                                onTap: () {
                                  // Navigate to bet of day screen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const BetOfDayScreen(),
                                    ),
                                  );
                                },
                                isLoading: false,
                                matchesList: _buildMatchesList(
                                  matches: provider.betOfDayAccumulator!.matches,
                                  tipType: 'Bet of the Day',
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 8),

                        // Mega Accumulator (Daily Accumulator)
                        if (provider.dailyAccumulator != null && 
                            provider.dailyAccumulator!.matches.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8, bottom: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.purple[50],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        _formatDate(provider.dailyAccumulator!.scrapedAt),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.purple[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TodayTipCard(
                                tipType: TipType.megaAccumulator,
                                odds: _formatOdds(provider.dailyAccumulator!.totalOdds),
                                matchCount: provider.dailyAccumulator!.matches.length,
                                onTap: () {
                                  // Navigate to mega accumulator screen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const DailyAccumulatorScreen(),
                                    ),
                                  );
                                },
                                isLoading: false,
                                matchesList: _buildMatchesList(
                                  matches: provider.dailyAccumulator!.matches,
                                  tipType: 'Mega Accumulator',
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 8),

                        // BTTS & Win
                        if (provider.bttsWinAccumulator != null && 
                            provider.bttsWinAccumulator!.matches.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8, bottom: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        _formatDate(provider.bttsWinAccumulator!.scrapedAt),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.blue[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TodayTipCard(
                                tipType: TipType.bttsAndWin,
                                odds: _formatOdds(provider.bttsWinAccumulator!.totalOdds),
                                matchCount: provider.bttsWinAccumulator!.matches.length,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const BttsWinScreen(),
                                    ),
                                  );
                                },
                                isLoading: false,
                                matchesList: _buildMatchesList(
                                  matches: provider.bttsWinAccumulator!.matches,
                                  tipType: 'BTTS & Win',
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 8),

                        // Over 2.5 Goals
                        if (provider.over25GoalsAccumulator != null && 
                            provider.over25GoalsAccumulator!.matches.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8, bottom: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.orange[50],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        _formatDate(provider.over25GoalsAccumulator!.scrapedAt),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.orange[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TodayTipCard(
                                tipType: TipType.over25Goals,
                                odds: _formatOdds(provider.over25GoalsAccumulator!.totalOdds),
                                matchCount: provider.over25GoalsAccumulator!.matches.length,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Over25GoalsScreen(),
                                    ),
                                  );
                                },
                                isLoading: false,
                                matchesList: _buildMatchesList(
                                  matches: provider.over25GoalsAccumulator!.matches,
                                  tipType: 'Over 2.5 Goals',
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 8),

                        // BTTS
                        if (provider.bttsAccumulator != null && 
                            provider.bttsAccumulator!.matches.isNotEmpty)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8, bottom: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.teal[50],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        _formatDate(provider.bttsAccumulator!.scrapedAt),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.teal[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TodayTipCard(
                                tipType: TipType.btts,
                                odds: _formatOdds(provider.bttsAccumulator!.totalOdds),
                                matchCount: provider.bttsAccumulator!.matches.length,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const BttsScreen(),
                                    ),
                                  );
                                },
                                isLoading: false,
                                matchesList: _buildMatchesList(
                                  matches: provider.bttsAccumulator!.matches,
                                  tipType: 'BTTS',
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 20),

                        // Disclaimer
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info_outline, size: 18, color: Colors.grey[600]),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Disclaimer',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryNavy,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Predictions are for entertainment purposes only. Please gamble responsibly.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              widget.onNavigate(0);
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'TODAY\'S TIPS',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'HOT',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Expert predictions For Today',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            onPressed: _refreshFromProvider,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.analytics_outlined,
                size: 48,
                color: Colors.blue.shade400,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Our Experts Are Currently Analysing',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryNavy,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Our team of expert analysts is currently reviewing today\'s matches and will have predictions available soon. Check back in a little while!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Predictions available soon',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _refreshFromProvider,
              child: const Text(
                'Tap to refresh',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
    );
  }
}