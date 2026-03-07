// screens/free_tips_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../widgets/free_tip_card.dart';
import '../models/daily_accumulator_model.dart';
import '../models/btts_model.dart';
import '../models/league_model.dart';
import 'package:plus90/theme/app_theme.dart';
import 'dart:convert';

class FreeTipsScreen extends StatefulWidget {
  const FreeTipsScreen({super.key});

  @override
  State<FreeTipsScreen> createState() => _FreeTipsScreenState();
}

class _FreeTipsScreenState extends State<FreeTipsScreen> {
  final ApiService _apiService = ApiService();
  final CacheService _cache = CacheService();
  
  final List<Map<String, dynamic>> _freeTips = [];
  
  bool _isLoading = true;
  String _errorMessage = '';
  DateTime? _lastUpdated; // Track when data was last updated

  static const String _cacheKey = 'free_tips_data';
  static const String _timestampKey = 'free_tips_timestamp';
  static const Duration _cacheDuration = Duration(hours: 12); // 12-hour cache

  final List<League> _featuredLeagues = [
    League(
      name: 'Premier League',
      country: 'England',
      icon: Icons.sports_soccer,
      color: const Color(0xFF8B5CF6),
      description: 'English Premier League',
      apiEndpoint: 'epl-matches',
    ),
    League(
      name: 'La Liga',
      country: 'Spain',
      icon: Icons.sports_soccer,
      color: const Color(0xFFEF4444),
      description: 'Spanish La Liga',
      apiEndpoint: 'laliga-matches',
    ),
    League(
      name: 'Serie A',
      country: 'Italy',
      icon: Icons.sports_soccer,
      color: const Color(0xFF3B82F6),
      description: 'Italian Serie A',
      apiEndpoint: 'serie-a-matches',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _cache.init();
    _loadFreeTips();
  }

  // Save tips with timestamp for 12-hour expiry
  Future<void> _saveTipsToCache() async {
    try {
      final tipsJson = _freeTips.map((tip) {
        return {
          'homeTeam': tip['homeTeam'],
          'awayTeam': tip['awayTeam'],
          'prediction': tip['prediction'],
          'odds': tip['odds'],
          'date': tip['date'],
          'color': tip['color'].value,
        };
      }).toList();
      
      // Save the actual data
      await _cache.setCache(
        key: _cacheKey,
        data: tipsJson,
      );
      
      // Save timestamp separately
      final now = DateTime.now().toIso8601String();
      await _cache.setCache(
        key: _timestampKey,
        data: now,
      );
      
      setState(() {
        _lastUpdated = DateTime.parse(now);
      });
      
      print('✅ Free tips cached successfully (12-hour expiry)');
    } catch (e) {
      print('❌ Error caching free tips: $e');
    }
  }

  // Check if cache is still valid (within 12 hours)
  Future<bool> _isCacheValid() async {
    try {
      final timestampStr = await _cache.getCache(
        key: _timestampKey,
        fromJson: (json) => json as String,
      );
      
      if (timestampStr == null) return false;
      
      final cachedTime = DateTime.parse(timestampStr);
      final age = DateTime.now().difference(cachedTime);
      final isValid = age < _cacheDuration;
      
      print('📊 Cache age: ${age.inHours}h ${age.inMinutes % 60}m - ${isValid ? 'Valid' : 'Expired'}');
      return isValid;
    } catch (e) {
      print('❌ Error checking cache validity: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>?> _loadTipsFromCache() async {
    try {
      // First check if cache is still valid
      final isValid = await _isCacheValid();
      if (!isValid) {
        print('⏰ Cache expired (older than 12 hours)');
        return null;
      }
      
      final cachedData = await _cache.getCache(
        key: _cacheKey,
        fromJson: (jsonString) {
          final List<dynamic> jsonList = json.decode(jsonString);
          return jsonList.map((item) {
            return {
              'homeTeam': item['homeTeam'],
              'awayTeam': item['awayTeam'],
              'prediction': item['prediction'],
              'odds': item['odds'],
              'date': item['date'],
              'color': Color(item['color']),
            };
          }).toList();
        },
      );
      
      if (cachedData != null && cachedData.isNotEmpty) {
        print('📦 Using cached free tips (within 12-hour window)');
        
        // Load timestamp for display
        final timestampStr = await _cache.getCache(
          key: _timestampKey,
          fromJson: (json) => json as String,
        );
        if (timestampStr != null) {
          _lastUpdated = DateTime.parse(timestampStr);
        }
        
        return cachedData;
      }
    } catch (e) {
      print('❌ Error loading free tips from cache: $e');
    }
    return null;
  }

  Future<void> _loadFreeTips() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _freeTips.clear();
    });

    try {
      // Try cache first (with 12-hour expiry check)
      final cachedTips = await _loadTipsFromCache();
      if (cachedTips != null) {
        setState(() {
          _freeTips.addAll(cachedTips);
          _isLoading = false;
        });
        
        // Only refresh if cache is older than 6 hours (half of 12)
        // This reduces background refreshes
        if (_lastUpdated != null) {
          final age = DateTime.now().difference(_lastUpdated!);
          if (age > const Duration(hours: 6)) {
            print('🔄 Cache is >6 hours old, refreshing in background');
            _refreshInBackground();
          } else {
            print('✅ Cache is fresh (<6 hours old), skipping background refresh');
          }
        }
        return;
      }

      // No cache or expired - load everything fresh
      await _loadAllTipsFromNetwork();

    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load free tips';
        _isLoading = false;
      });
      print('Error loading free tips: $e');
    }
  }

  Future<void> _loadAllTipsFromNetwork() async {
    print('🌐 Fetching ALL free tips data in one batch');
    
    try {
      // Create a list of futures for ALL API calls
      final futures = [
        _apiService.getDailyAccumulators().catchError((e) => null),
        _apiService.getBTTSPredictions().catchError((e) => null),
        ..._featuredLeagues.map((league) => 
          _apiService.getMatchPredictions(league.apiEndpoint).catchError((e) => <dynamic>[])
        ),
      ];

      final results = await Future.wait(futures);
      
      // Process results
      final megaAccumulator = results[0] as DailyAccumulator?;
      if (megaAccumulator?.matches.isNotEmpty ?? false) {
        final match = megaAccumulator!.matches.first;
        _freeTips.add({
          'homeTeam': _getHomeTeam(match.matchTitle),
          'awayTeam': _getAwayTeam(match.matchTitle),
          'prediction': match.prediction,
          'odds': _formatOdds(megaAccumulator.totalOdds),
          'date': _formatDate(match.date),
          'color': Colors.purple,
        });
      }

      final bttsAccumulator = results[1] as BTTSAccumulator?;
      if (bttsAccumulator?.matches.isNotEmpty ?? false) {
        final match = bttsAccumulator!.matches.first;
        _freeTips.add({
          'homeTeam': _getHomeTeam(match.matchTitle),
          'awayTeam': _getAwayTeam(match.matchTitle),
          'prediction': match.prediction,
          'odds': _formatOdds(bttsAccumulator.totalOdds),
          'date': _formatDate(match.date),
          'color': Colors.teal,
        });
      }

      for (int i = 0; i < _featuredLeagues.length; i++) {
        final matches = results[2 + i] as List;
        if (matches.isNotEmpty) {
          matches.shuffle();
          final match = matches.first;
          
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
            'color': _featuredLeagues[i].color,
          });
        }
      }

      // Save to cache with timestamp
      await _saveTipsToCache();

      setState(() {
        _isLoading = false;
      });

    } catch (e) {
      print('Error in batch loading: $e');
      rethrow;
    }
  }

  Future<void> _refreshInBackground() async {
    try {
      await _loadAllTipsFromNetwork();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tips updated (next refresh in 12 hours)'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Background refresh failed: $e');
    }
  }

  Future<void> _refreshTips() async {
    // Clear both data and timestamp
    await _cache.clearCache(_cacheKey);
    await _cache.clearCache(_timestampKey);
    await _loadFreeTips();
  }

  // Get cache status for display
  String _getCacheStatus() {
    if (_lastUpdated == null) return 'Never updated';
    
    final age = DateTime.now().difference(_lastUpdated!);
    final hours = age.inHours;
    final minutes = age.inMinutes % 60;
    
    if (hours > 0) {
      return 'Updated $hours hour${hours > 1 ? 's' : ''} ago';
    } else {
      return 'Updated $minutes min ago';
    }
  }

  // Helper methods
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
      return '${date.day}.${date.month}';
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
            Row(
              children: [
                Text(
                  'EPL · La Liga · Serie A',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                // Add small cache indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '12h cache',
                    style: TextStyle(
                      fontSize: 8,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
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
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Today\'s Free Predictions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    // Show last updated time
                    Text(
                      _getCacheStatus(),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
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
          
          ..._freeTips.map((tip) => FreeTipCard(
            homeTeam: tip['homeTeam'],
            awayTeam: tip['awayTeam'],
            prediction: tip['prediction'],
            odds: tip['odds'],
            date: tip['date'],
            leagueColor: tip['color'],
          )).toList(),
          
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  'Updated daily • Data cached for 12 hours',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (_lastUpdated != null)
                  Text(
                    'Last API call: ${DateFormat('MMM d, h:mm a').format(_lastUpdated!)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[400],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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