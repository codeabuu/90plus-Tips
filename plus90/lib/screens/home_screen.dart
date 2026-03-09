// screens/home_screen_part1.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/predictions_provider.dart';
import '../widgets/hero_section.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../services/local_notification_service.dart'; // Add this import
import '../models/league_model.dart';
import '../providers/subscription_provider.dart';
import '../widgets/upgrade_modal.dart';
import 'dart:convert';

// Import other parts
import 'homescreen2.dart';
import 'homescreen3.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onNavigate;

  const HomeScreen({super.key, required this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver { // Add WidgetsBindingObserver
  final ApiService _apiService = ApiService();
  final CacheService _cache = CacheService();
  final LocalNotificationService _notifications = LocalNotificationService(); // Add notifications
  bool _isFreeTipsExpanded = false;
  List<FreeTipData> _freeTips = [];
  bool _isLoadingFreeTips = false;

  // Cache keys
  static const String _freeTipsCacheKey = 'home_free_tips';
  static const String _freeTipsTimestampKey = 'home_free_tips_timestamp';
  static const Duration _cacheDuration = Duration(hours: 12);

  // User ID for notifications (use device ID or auth user ID)
  String get _userId {
    // You can use a device ID or get from auth provider
    // For now, using a simple identifier
    return 'user_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add observer
    
    _initNotifications(); // Initialize notifications
    _cache.init();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PredictionsProvider>().fetchAllPredictions();
      _updateUserActivity(); // Track initial app open
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Track app lifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updateUserActivity(); // Track when app comes to foreground
    }
  }

  // Initialize notifications
  Future<void> _initNotifications() async {
    await _notifications.init();
  }

  // Update user activity for inactivity tracking
  Future<void> _updateUserActivity() async {
    final subscriptionProvider = context.read<SubscriptionProvider>();
    await _notifications.updateLastActive(_userId, subscriptionProvider.isPremium);
  }

  // Handle user upgrade
  Future<void> _handleUserUpgrade() async {
    final subscriptionProvider = context.read<SubscriptionProvider>();
    await _notifications.rescheduleForPremiumStatus(subscriptionProvider.isPremium);
  }

  Future<void> _saveTipsToCache() async {
    try {
      final tipsJson = _freeTips.map((tip) {
        return {
          'homeTeam': tip.homeTeam,
          'awayTeam': tip.awayTeam,
          'prediction': tip.prediction,
          'odds': tip.odds,
          'date': tip.date,
          'color': tip.color.value,
        };
      }).toList();
      
      await _cache.setCache(
        key: _freeTipsCacheKey,
        data: tipsJson,
      );
      
      await _cache.setCache(
        key: _freeTipsTimestampKey,
        data: DateTime.now().toIso8601String(),
      );
      
      print('✅ Home free tips cached (12h expiry)');
    } catch (e) {
      print('❌ Error caching home tips: $e');
    }
  }

  Future<List<FreeTipData>?> _loadTipsFromCache() async {
    try {
      final timestampStr = await _cache.getCache(
        key: _freeTipsTimestampKey,
        fromJson: (json) => json as String,
      );
      
      if (timestampStr == null) return null;
      
      final cachedTime = DateTime.parse(timestampStr);
      final age = DateTime.now().difference(cachedTime);
      
      if (age > _cacheDuration) {
        print('⏰ Home tips cache expired (${age.inHours}h old)');
        return null;
      }
      
      final cachedData = await _cache.getCache(
        key: _freeTipsCacheKey,
        fromJson: (jsonString) {
          final List<dynamic> jsonList = json.decode(jsonString);
          return jsonList.map((item) {
            return FreeTipData(
              homeTeam: item['homeTeam'],
              awayTeam: item['awayTeam'],
              prediction: item['prediction'],
              odds: item['odds'],
              date: item['date'],
              color: Color(item['color']),
            );
          }).toList();
        },
      );
      
      if (cachedData != null && cachedData.isNotEmpty) {
        print('📦 Using cached home tips (${age.inHours}h old)');
        return cachedData;
      }
    } catch (e) {
      print('❌ Error loading home tips from cache: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final predictionsProvider = context.watch<PredictionsProvider>();
    final subscriptionProvider = context.watch<SubscriptionProvider>();

    const double heroMax = 200;
    const double heroMin = 56;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _refreshData(predictionsProvider),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: HeroSliverDelegate(
                  maxExtent: heroMax,
                  minExtent: heroMin,
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    FreeTipsDropdown(
                      isExpanded: _isFreeTipsExpanded,
                      isLoading: _isLoadingFreeTips,
                      tips: _freeTips,
                      onToggle: _toggleFreeTips,
                      onNavigate: widget.onNavigate,
                      isPremium: subscriptionProvider.isPremium,
                      onUpgradeTap: _showUpgradeModal,
                    ),
                    const SizedBox(height: 24),
                    PredictionCategoriesSection(
                      provider: predictionsProvider,
                      onNavigate: widget.onNavigate,
                      isPremium: subscriptionProvider.isPremium,
                      onUpgradeTap: _showUpgradeModal,
                    ),
                    const SizedBox(height: 32),
                    const PerformanceSection(),
                    const SizedBox(height: 32),
                    const TrustSignalSection(),
                    const SizedBox(height: 32),
                    const ResponsibleGamblingFooter(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUpgradeModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        // When modal closes, check if user upgraded
        return const UpgradeModal();
      },
    ).then((_) {
      // After modal closes, check premium status and update notifications
      final subscriptionProvider = context.read<SubscriptionProvider>();
      if (subscriptionProvider.isPremium) {
        _handleUserUpgrade();
      }
    });
  }

  Future<void> _refreshData(PredictionsProvider provider) async {
    await provider.fetchAllPredictions();
    if (_isFreeTipsExpanded) {
      await _loadFreeTips(forceRefresh: true);
    }
    _updateUserActivity(); // Track refresh as activity
  }

  Future<void> _toggleFreeTips() async {
    if (!_isFreeTipsExpanded && _freeTips.isEmpty) {
      await _loadFreeTips();
    }
    setState(() => _isFreeTipsExpanded = !_isFreeTipsExpanded);
    _updateUserActivity(); // Track interaction
  }

  Future<void> _loadFreeTips({bool forceRefresh = false}) async {
    setState(() {
      _isLoadingFreeTips = true;
      _freeTips.clear();
    });

    try {
      if (!forceRefresh) {
        final cachedTips = await _loadTipsFromCache();
        if (cachedTips != null) {
          setState(() {
            _freeTips = cachedTips;
            _isLoadingFreeTips = false;
          });
          
          final timestampStr = await _cache.getCache(
            key: _freeTipsTimestampKey,
            fromJson: (json) => json as String,
          );
          
          if (timestampStr != null) {
            final cachedTime = DateTime.parse(timestampStr);
            final age = DateTime.now().difference(cachedTime);
            if (age > const Duration(hours: 6)) {
              _refreshTipsInBackground();
            }
          }
          return;
        }
      }

      await _loadFreshTips();

    } catch (e) {
      print('Error loading free tips: $e');
      setState(() => _isLoadingFreeTips = false);
    }
  }

  Future<void> _loadFreshTips() async {
    try {
      print('🌐 Fetching fresh home tips (1 tip only)');
      
      final tipSources = [
        _loadMegaAccumulatorTip(),
        _loadBTTSTip(),
        _loadFeaturedLeagueTip(),
      ];
      
      tipSources.shuffle();
      
      FreeTipData? successfulTip;
      for (var source in tipSources) {
        try {
          successfulTip = await source;
          if (successfulTip != null) break;
        } catch (e) {
          continue;
        }
      }

      setState(() {
        _freeTips = successfulTip != null ? [successfulTip] : [];
        _isLoadingFreeTips = false;
      });

      if (_freeTips.isNotEmpty) {
        await _saveTipsToCache();
      }

    } catch (e) {
      print('Error loading fresh tips: $e');
      rethrow;
    }
  }

  Future<void> _refreshTipsInBackground() async {
    try {
      await _loadFreshTips();
      print('✅ Home tips refreshed in background');
    } catch (e) {
      print('❌ Background refresh failed: $e');
    }
  }

  Future<FreeTipData?> _loadMegaAccumulatorTip() async {
    try {
      final accumulator = await _apiService.getDailyAccumulators();
      if (accumulator.matches.isEmpty) return null;

      final match = accumulator.matches.first;
      return FreeTipData(
        homeTeam: _extractTeam(match.matchTitle, isHome: true),
        awayTeam: _extractTeam(match.matchTitle, isHome: false),
        prediction: match.prediction,
        odds: _formatOdds(accumulator.totalOdds),
        date: _formatDate(match.date),
        color: Colors.blue,
      );
    } catch (e) {
      return null;
    }
  }

  Future<FreeTipData?> _loadBTTSTip() async {
    try {
      final accumulator = await _apiService.getBTTSPredictions();
      if (accumulator?.matches.isEmpty ?? true) return null;

      final match = accumulator!.matches.first;
      return FreeTipData(
        homeTeam: _extractTeam(match.matchTitle, isHome: true),
        awayTeam: _extractTeam(match.matchTitle, isHome: false),
        prediction: match.prediction,
        odds: _formatOdds(accumulator.totalOdds),
        date: _formatDate(match.date),
        color: Colors.teal,
      );
    } catch (e) {
      return null;
    }
  }

  Future<FreeTipData?> _loadFeaturedLeagueTip() async {
    final featuredLeagues = [
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
    ]..shuffle();

    for (var league in featuredLeagues) {
      try {
        final matches = await _apiService.getMatchPredictions(league.apiEndpoint);
        if (matches.isEmpty) continue;

        matches.shuffle();
        final match = matches.first;

        if (match.predictions.isEmpty) continue;

        return FreeTipData(
          homeTeam: match.homeTeam,
          awayTeam: match.awayTeam,
          prediction: match.predictions.first.prediction,
          odds: _formatOdds(match.predictions.first.odds),
          date: _formatDate(match.date),
          color: league.color,
        );
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  String _extractTeam(String? matchTitle, {required bool isHome}) {
    if (matchTitle == null || matchTitle.isEmpty) {
      return isHome ? 'Team A' : 'Team B';
    }
    if (!matchTitle.contains(' vs ')) return matchTitle;

    final parts = matchTitle.split(' vs ');
    return isHome ? parts[0].trim() : (parts.length > 1 ? parts[1].trim() : 'Opponent');
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'TODAY';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      if (date.day == now.day && 
          date.month == now.month && 
          date.year == now.year) {
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
}

// Data Model
class FreeTipData {
  final String homeTeam;
  final String awayTeam;
  final String prediction;
  final String odds;
  final String date;
  final Color color;

  FreeTipData({
    required this.homeTeam,
    required this.awayTeam,
    required this.prediction,
    required this.odds,
    required this.date,
    required this.color,
  });
}