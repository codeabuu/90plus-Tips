// screens/today_tips_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../widgets/today_tip_card.dart';
import '../models/betofday_model.dart';
import '../models/daily_accumulator_model.dart';
import '../models/btts_win_model.dart';
import '../models/over2.5_goals_model.dart';
import '../models/btts_model.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class TodayTipsScreen extends StatefulWidget {
   final Function(int) onNavigate;

  const TodayTipsScreen({super.key, required this.onNavigate});

  @override
  State<TodayTipsScreen> createState() => _TodayTipsScreenState();
}

class _TodayTipsScreenState extends State<TodayTipsScreen> {
  final ApiService _apiService = ApiService();
  
  // Tip data
  BetOfDayAccumulator? _betOfTheDay;
  DailyAccumulator? _megaAccumulator;
  BTTSWinAccumulator? _bttsAndWin;
  Over25GoalsAccumulator? _over25Goals;
  BTTSAccumulator? _btts;
  
  // Loading states
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadAllTips();
  }

  Future<void> _loadAllTips() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Load all tips in parallel
      final results = await Future.wait([
        _apiService.getBetOfTheDay(),
        _apiService.getDailyAccumulators(),
        _apiService.getBTTSWinAccumulator(),
        _apiService.getOver25GoalsAccumulator(),
        _apiService.getBTTSPredictions(),
      ], eagerError: false);

      setState(() {
        _betOfTheDay = results[0] as BetOfDayAccumulator?;
        _megaAccumulator = results[1] as DailyAccumulator;
        _bttsAndWin = results[2] as BTTSWinAccumulator?;
        _over25Goals = results[3] as Over25GoalsAccumulator?;
        _btts = results[4] as BTTSAccumulator?;
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load today\'s tips';
        _isLoading = false;
      });
      print('Error loading tips: $e');
    }
  }

  Future<void> _refreshTips() async {
    await _loadAllTips();
  }

  void _navigateToTipDetail(String tipType, dynamic data) {
    // TODO: Navigate to detailed view for each tip type
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening $tipType details...'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
  
  /// Get team names from matchTitle which already has the correct format
  Map<String, String> _getTeamNamesFromMatchTitle(String matchTitle) {
    String homeTeam = '';
    String awayTeam = '';
    
    if (matchTitle.contains(' vs ')) {
      final parts = matchTitle.split(' vs ');
      homeTeam = parts[0].trim();
      awayTeam = parts.length > 1 ? parts[1].trim() : 'Opponent';
    } else {
      // If no "vs" in title, just use the whole string
      homeTeam = matchTitle;
      awayTeam = 'Opponent';
    }
    
    return {'home': homeTeam, 'away': awayTeam};
  }

  // ============== MASTER MATCHES LIST BUILDER ==============
  
  List<Widget> _buildMatchesList({
    required List<dynamic> matches,
    required String tipType,
  }) {
    if (matches.isEmpty) return [];
    
    return matches.map((match) {
      final isLast = matches.last == match;
      
      // USE matchTitle INSTEAD OF teams LIST - THIS IS THE KEY FIX
      final teamNames = _getTeamNamesFromMatchTitle(match.matchTitle ?? '');
      
      return MatchPreviewTile(
        homeTeam: teamNames['home']!,
        awayTeam: teamNames['away']!,
        prediction: match.prediction?.toString() ?? 'N/A',
        isLast: isLast,
      );
    }).toList();
  }

  // ============== SIMPLIFIED MATCH BUILDERS ==============
  
  List<Widget> _buildBetOfTheDayMatches(BetOfDayAccumulator accumulator) {
    return _buildMatchesList(
      matches: accumulator.matches, 
      tipType: 'Bet of the Day'
    );
  }

  List<Widget> _buildMegaAccumulatorMatches(DailyAccumulator accumulator) {
    return _buildMatchesList(
      matches: accumulator.matches, 
      tipType: 'Mega Accumulator'
    );
  }

  List<Widget> _buildBTTSWinMatches(BTTSWinAccumulator accumulator) {
    return _buildMatchesList(
      matches: accumulator.matches, 
      tipType: 'BTTS & Win'
    );
  }

  List<Widget> _buildOver25Matches(Over25GoalsAccumulator accumulator) {
    return _buildMatchesList(
      matches: accumulator.matches, 
      tipType: 'Over 2.5 Goals'
    );
  }

  List<Widget> _buildBTTSMatches(BTTSAccumulator accumulator) {
    return _buildMatchesList(
      matches: accumulator.matches, 
      tipType: 'BTTS'
    );
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
              child: _buildContent(),
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
        // Use widget.onNavigate to go to Home tab (index 0)
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
      onPressed: _refreshTips,
    ),
  ],
),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
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

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshTips,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshTips,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tip of the Day
          if (_betOfTheDay != null && _betOfTheDay!.matches.isNotEmpty)
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
                          _formatDate(_betOfTheDay!.scrapedAt),
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
                  odds: _formatOdds(_betOfTheDay!.totalOdds),
                  matchCount: _betOfTheDay!.matches.length,
                  onTap: () => _navigateToTipDetail('Bet of the Day', _betOfTheDay),
                  isLoading: false,
                  matchesList: _buildBetOfTheDayMatches(_betOfTheDay!),
                ),
              ],
            ),

          const SizedBox(height: 8),

          // Mega Accumulator (Daily Accumulator)
          if (_megaAccumulator != null && _megaAccumulator!.matches.isNotEmpty)
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
                          _formatDate(_megaAccumulator!.scrapedAt),
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
                  odds: _formatOdds(_megaAccumulator!.totalOdds),
                  matchCount: _megaAccumulator!.matches.length,
                  onTap: () => _navigateToTipDetail('Mega Accumulator', _megaAccumulator),
                  isLoading: false,
                  matchesList: _buildMegaAccumulatorMatches(_megaAccumulator!),
                ),
              ],
            ),

          const SizedBox(height: 8),

          // BTTS & Win
          if (_bttsAndWin != null && _bttsAndWin!.matches.isNotEmpty)
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
                          _formatDate(_bttsAndWin!.scrapedAt),
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
                  odds: _formatOdds(_bttsAndWin!.totalOdds),
                  matchCount: _bttsAndWin!.matches.length,
                  onTap: () => _navigateToTipDetail('BTTS & Win', _bttsAndWin),
                  isLoading: false,
                  matchesList: _buildBTTSWinMatches(_bttsAndWin!),
                ),
              ],
            ),

          const SizedBox(height: 8),

          // Over 2.5 Goals
          if (_over25Goals != null && _over25Goals!.matches.isNotEmpty)
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
                          _formatDate(_over25Goals!.scrapedAt),
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
                  odds: _formatOdds(_over25Goals!.totalOdds),
                  matchCount: _over25Goals!.matches.length,
                  onTap: () => _navigateToTipDetail('Over 2.5 Goals', _over25Goals),
                  isLoading: false,
                  matchesList: _buildOver25Matches(_over25Goals!),
                ),
              ],
            ),

          const SizedBox(height: 8),

          // BTTS
          if (_btts != null && _btts!.matches.isNotEmpty)
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
                          _formatDate(_btts!.scrapedAt),
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
                  odds: _formatOdds(_btts!.totalOdds),
                  matchCount: _btts!.matches.length,
                  onTap: () => _navigateToTipDetail('BTTS', _btts),
                  isLoading: false,
                  matchesList: _buildBTTSMatches(_btts!),
                ),
              ],
            ),

          // If no tips available
          if (_betOfTheDay?.matches.isEmpty == true &&
              _megaAccumulator?.matches.isEmpty == true &&
              _bttsAndWin?.matches.isEmpty == true &&
              _over25Goals?.matches.isEmpty == true &&
              _btts?.matches.isEmpty == true)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.sports_soccer,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No predictions available for today',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back later for expert tips',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
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
  }
}