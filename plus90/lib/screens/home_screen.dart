// screens/home_screen_part1.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/predictions_provider.dart';
import '../widgets/hero_section.dart';
import '../services/api_service.dart';
import '../models/league_model.dart';
import '../providers/subscription_provider.dart';
import '../widgets/upgrade_modal.dart';

// Import other parts
import 'homescreen2.dart';
import 'homescreen3.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onNavigate;

  const HomeScreen({super.key, required this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  bool _isFreeTipsExpanded = false;
  List<FreeTipData> _freeTips = [];
  bool _isLoadingFreeTips = false;

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
    final subscriptionProvider = context.watch<SubscriptionProvider>();

    // Full hero height = 200, sticky bar height = 56
    const double heroMax = 200;
    const double heroMin = 56;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _refreshData(predictionsProvider),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Sticky Hero
              SliverPersistentHeader(
                pinned: true,
                delegate: HeroSliverDelegate(
                  maxExtent: heroMax,
                  minExtent: heroMin,
                ),
              ),

              // Rest of content
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
                      isPremium: subscriptionProvider.isPremium, // Pass premium status
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
      builder: (context) => const UpgradeModal(),
    );
  }

  Future<void> _refreshData(PredictionsProvider provider) async {
    await provider.fetchAllPredictions();
    if (_isFreeTipsExpanded) {
      await _loadFreeTips();
    }
  }

  Future<void> _toggleFreeTips() async {
    if (!_isFreeTipsExpanded && _freeTips.isEmpty) {
      await _loadFreeTips();
    }
    setState(() => _isFreeTipsExpanded = !_isFreeTipsExpanded);
  }

  Future<void> _loadFreeTips() async {
    setState(() {
      _isLoadingFreeTips = true;
      _freeTips.clear();
    });

    try {
      final tips = await Future.wait([
        _loadMegaAccumulatorTip(),
        _loadBTTSTip(),
        _loadFeaturedLeagueTip(),
      ]);

      setState(() {
        _freeTips = tips.whereType<FreeTipData>().toList();
        _isLoadingFreeTips = false;
      });
    } catch (e) {
      print('Error loading free tips: $e');
      setState(() => _isLoadingFreeTips = false);
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