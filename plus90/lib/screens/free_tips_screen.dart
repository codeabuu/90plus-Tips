// screens/free_tips_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../widgets/free_tip_card.dart';
import '../models/daily_accumulator_model.dart';
import '../models/btts_model.dart';
import '../models/league_model.dart';
import 'package:plus90/theme/app_theme.dart';

class FreeTipsScreen extends StatefulWidget {
  const FreeTipsScreen({super.key});

  @override
  State<FreeTipsScreen> createState() => _FreeTipsScreenState();
}

class _FreeTipsScreenState extends State<FreeTipsScreen> {
  final ApiService _apiService = ApiService();
  
  // Free tips data - simplified to a list
  final List<Map<String, dynamic>> _freeTips = [];
  
  // Loading states
  bool _isLoading = true;
  String _errorMessage = '';

  // Only La Liga, EPL, and Serie A
  final List<League> _featuredLeagues = [
    League(
      name: 'Premier League',
      country: 'England',
      icon: Icons.sports_soccer,
      color: const Color(0xFF8B5CF6), // Purple
      description: 'English Premier League',
      apiEndpoint: 'epl-matches',
    ),
    League(
      name: 'La Liga',
      country: 'Spain',
      icon: Icons.sports_soccer,
      color: const Color(0xFFEF4444), // Red
      description: 'Spanish La Liga',
      apiEndpoint: 'laliga-matches',
    ),
    League(
      name: 'Serie A',
      country: 'Italy',
      icon: Icons.sports_soccer,
      color: const Color(0xFF3B82F6), // Blue
      description: 'Italian Serie A',
      apiEndpoint: 'serie-a-matches',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadFreeTips();
  }

  Future<void> _loadFreeTips() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _freeTips.clear();
    });

    try {
      // 1. Load Mega Accumulator tip
      final megaAccumulator = await _apiService.getDailyAccumulators();
      if (megaAccumulator.matches.isNotEmpty) {
        final match = megaAccumulator.matches.first;
        _freeTips.add({
          'homeTeam': _getHomeTeam(match.matchTitle),
          'awayTeam': _getAwayTeam(match.matchTitle),
          'prediction': match.prediction,
          'odds': _formatOdds(megaAccumulator.totalOdds),
          'date': _formatDate(match.date),
          'color': Colors.purple,
        });
      }

      // 2. Load BTTS tip
      final bttsAccumulator = await _apiService.getBTTSPredictions();
      if (bttsAccumulator != null && bttsAccumulator.matches.isNotEmpty) {
        final match = bttsAccumulator.matches.first;
        _freeTips.add({
          'homeTeam': _getHomeTeam(match.matchTitle),
          'awayTeam': _getAwayTeam(match.matchTitle),
          'prediction': match.prediction,
          'odds': _formatOdds(bttsAccumulator.totalOdds),
          'date': _formatDate(match.date),
          'color': Colors.teal,
        });
      }

      // 3. Load random league tip from La Liga, EPL, or Serie A
      _featuredLeagues.shuffle();
      for (var league in _featuredLeagues) {
        try {
          final matches = await _apiService.getMatchPredictions(league.apiEndpoint);
          if (matches.isNotEmpty) {
            matches.shuffle();
            final match = matches.first;
            
            // Get prediction and odds from the match
            String prediction = 'N/A';
            String odds = '';
            
            if (match.predictions.isNotEmpty) {
              prediction = match.predictions.first.prediction;
              odds = _formatOdds(match.predictions.first.odds);
            }
            
            _freeTips.add({
              'homeTeam': match.homeTeam,
              'awayTeam': match.awayTeam,
              'prediction': prediction,
              'odds': odds,
              'date': _formatDate(match.date),
              'color': league.color,
            });
            break;
          }
        } catch (e) {
          print('Error loading ${league.name}: $e');
          continue;
        }
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load free tips';
        _isLoading = false;
      });
      print('Error loading free tips: $e');
    }
  }

  Future<void> _refreshTips() async {
    await _loadFreeTips();
  }

  String _getHomeTeam(String? matchTitle) {
    if (matchTitle == null || matchTitle.isEmpty) return 'Team A';
    if (matchTitle.contains(' vs ')) {
      return matchTitle.split(' vs ')[0].trim();
    }
    return matchTitle;
  }

  String _getAwayTeam(String? matchTitle) {
    if (matchTitle == null || matchTitle.isEmpty) return 'Team B';
    if (matchTitle.contains(' vs ')) {
      final parts = matchTitle.split(' vs ');
      return parts.length > 1 ? parts[1].trim() : 'Opponent';
    }
    return 'Opponent';
  }

  String _formatDate(String? dateString) {
  if (dateString == null || dateString.isEmpty) return 'TODAY';
  try {
    final date = DateTime.parse(dateString);
    final now = DateTime.now();
    if (date.day == now.day && date.month == now.month && date.year == now.year) {
      return 'TODAY';
    }
    return '${date.day}.${date.month}'; // Removed day name, just day.month
  } catch (e) {
    return dateString;
  }
}

  String _formatOdds(dynamic odds) {
    if (odds == null) return '1.00';
    if (odds is double) return odds.toStringAsFixed(2);
    if (odds is String) {
      try {
        return double.parse(odds.replaceAll(' Odds', '')).toStringAsFixed(2);
      } catch (e) {
        return odds;
      }
    }
    return odds.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'FREE TIPS',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                letterSpacing: 1,
              ),
            ),
            Text(
              'EPL · La Liga · Serie A',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            onPressed: _refreshTips,
          ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red, fontSize: 15),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _refreshTips,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_freeTips.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.card_giftcard,
                size: 48,
                color: Colors.green[400],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Free Tips Available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Check back later for today\'s predictions',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshTips,
      color: Colors.blue,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Simple header
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s Free Predictions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Expert picks from top leagues',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Free Tips Cards - SIMPLIFIED
          ..._freeTips.map((tip) => FreeTipCard(
            homeTeam: tip['homeTeam'],
            awayTeam: tip['awayTeam'],
            prediction: tip['prediction'],
            odds: tip['odds'],
            date: tip['date'],
            leagueColor: tip['color'],
          )).toList(),
          
          const SizedBox(height: 24),
          
          // Simple footer
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: Text(
              'Updated daily • More tips with Premium',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Loading Shimmer for Free Tips - SIMPLIFIED
class FreeTipShimmer extends StatelessWidget {
  const FreeTipShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 12,
                  color: Colors.grey[200],
                ),
                const SizedBox(height: 8),
                Container(
                  width: 180,
                  height: 16,
                  color: Colors.grey[200],
                ),
                const SizedBox(height: 8),
                Container(
                  width: 100,
                  height: 24,
                  color: Colors.grey[200],
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}