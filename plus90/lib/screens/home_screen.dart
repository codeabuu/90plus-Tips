// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:plus90/screens/prediction_screen.dart';
import 'package:plus90/screens/today_tips_screen.dart';
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
import 'free_tips_screen.dart';
import '../services/api_service.dart';
import '../models/league_model.dart';

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

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _refreshData(predictionsProvider),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HeroSection(),
                const SizedBox(height: 24),
                
                _FreeTipsDropdown(
                  isExpanded: _isFreeTipsExpanded,
                  isLoading: _isLoadingFreeTips,
                  tips: _freeTips,
                  onToggle: _toggleFreeTips,
                  onNavigate: widget.onNavigate,
                ),
                
                const SizedBox(height: 24),
                _PredictionCategoriesSection(provider: predictionsProvider, onNavigate: widget.onNavigate,),
                const SizedBox(height: 32),
                const _PerformanceSection(),
                const SizedBox(height: 32),
                const _TrustSignalSection(),
                const SizedBox(height: 32),
                const _ResponsibleGamblingFooter(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
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

// ============================================================================
// DATA MODEL
// ============================================================================

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

// ============================================================================
// EXTRACTED WIDGETS
// ============================================================================

class _FreeTipsDropdown extends StatelessWidget {
  final bool isExpanded;
  final bool isLoading;
  final List<FreeTipData> tips;
  final VoidCallback onToggle;
  final Function(int) onNavigate;

  const _FreeTipsDropdown({
    required this.isExpanded,
    required this.isLoading,
    required this.tips,
    required this.onToggle,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            if (isExpanded) _buildContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.card_giftcard,
                size: 20,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Today\'s Free Tips',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap to view free predictions',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                color: Colors.grey[600],
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
      ),
      child: isLoading
          ? const _LoadingIndicator()
          : tips.isEmpty
              ? const _EmptyTipsMessage()
              : _TipsListContent(tips: tips, onNavigate: onNavigate),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
        ),
      ),
    );
  }
}

class _EmptyTipsMessage extends StatelessWidget {
  const _EmptyTipsMessage();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'No free tips available',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ),
    );
  }
}

class _TipsListContent extends StatelessWidget {
  final List<FreeTipData> tips;

  final Function(int) onNavigate;

  const _TipsListContent({required this.tips, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildInfoHeader(context),
        const SizedBox(height: 16),
        ...tips.map((tip) => _FreeTipRow(tip: tip)),
        const SizedBox(height: 8),
        _buildViewAllButton(context),
      ],
    );
  }

  Widget _buildInfoHeader(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.info_outline, size: 14, color: Colors.blue),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Enjoy these free tips from our experts. Upgrade to VIP for unlimited access!',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildViewAllButton(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FreeTipsScreen()),
        );
      },
      style: TextButton.styleFrom(foregroundColor: Colors.blue),
      child: const Text('View all free tips →'),
    );
  }
}

class _FreeTipRow extends StatelessWidget {
  final FreeTipData tip;

  const _FreeTipRow({required this.tip});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDateLabel(),
          const SizedBox(height: 6),
          _buildTeamsText(),
          const SizedBox(height: 8),
          _buildPredictionRow(),
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Divider(height: 1, thickness: 1, color: Color(0xFFF0F0F0)),
          ),
        ],
      ),
    );
  }

  Widget _buildDateLabel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        tip.date,
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTeamsText() {
    return Text(
      '${tip.homeTeam} vs ${tip.awayTeam}',
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppTheme.primaryNavy,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildPredictionRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildPredictionBadge(),
        _buildOddsBadge(),
      ],
    );
  }

  Widget _buildPredictionBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: tip.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: tip.color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        tip.prediction,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: tip.color,
        ),
      ),
    );
  }

  Widget _buildOddsBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[200]!, width: 1),
      ),
      child: Text(
        tip.odds,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.green[700],
        ),
      ),
    );
  }
}

class _PredictionCategoriesSection extends StatelessWidget {
  final PredictionsProvider provider;
  final Function(int) onNavigate;

  const _PredictionCategoriesSection({required this.provider, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Browse Predictions',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.0,
            children: _buildCategoryCards(context),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCategoryCards(BuildContext context) {
    return [
      _CategoryCard(
        title: 'Todays Tips',
        subtitle: 'Featured ⭐⭐⭐⭐⭐\n',
        icon: Icons.whatshot,
        color: AppTheme.accentGold,
        onTap: () => onNavigate(1),
      ),
      _CategoryCard(
        title: 'Predictions',
        subtitle: 'Live predictions',
        icon: Icons.whatshot,
        color: AppTheme.accentGold,
        onTap: () => _navigate(context, const PredictionsScreen()),
      ),
      _CategoryCard(
        title: 'Tip of Day',
        subtitle: provider.betOfDayAccumulator == null
            ? 'Featured ⭐⭐⭐⭐⭐\n'
            : '${provider.betOfDayAccumulator!.count} matches',
        icon: Icons.star,
        color: AppTheme.accentGold,
        onTap: () => _navigate(context, const BetOfDayScreen()),
      ),
      _CategoryCard(
        title: 'Multi Combinations',
        subtitle: provider.dailyAccumulator == null
            ? 'Updating...'
            : '${provider.dailyAccumulator!.count} matches',
        icon: Icons.sports_soccer,
        color: const Color(0xFF2196F3),
        onTap: () => _navigate(context, const DailyAccumulatorScreen()),
      ),
      _CategoryCard(
        title: 'BTTS & Win',
        subtitle: provider.bttsWinAccumulator == null
            ? 'Loading...'
            : '${provider.bttsWinAccumulator!.count} matches',
        icon: Icons.sports_soccer,
        color: const Color(0xFF2196F3),
        onTap: () => _navigate(context, const BttsWinScreen()),
      ),
      _CategoryCard(
        title: 'BTTS',
        subtitle: provider.bttsAccumulator == null
            ? 'Updating...'
            : '${provider.bttsAccumulator!.count} matches',
        icon: Icons.sports_soccer,
        color: const Color(0xFF2196F3),
        onTap: () => _navigate(context, const BttsScreen()),
      ),
      _CategoryCard(
        title: 'Over 2.5',
        subtitle: provider.over25GoalsAccumulator == null
            ? 'Updating...'
            : '${provider.over25GoalsAccumulator!.count} matches',
        icon: Icons.trending_up,
        color: const Color(0xFFFF9800),
        onTap: () => _navigate(context, const Over25GoalsScreen()),
      ),
      _CategoryCard(
        title: 'Leagues',
        subtitle: 'By competition',
        icon: Icons.emoji_events,
        color: const Color(0xFFE91E63),
        onTap: () => onNavigate(2),
      ),
    ];
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
          border: Border.all(color: color.withOpacity(0.1), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              const SizedBox(height: 4),
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
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
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
}

class _PerformanceSection extends StatelessWidget {
  const _PerformanceSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                _buildStatItem('Win Rate', '73%', Icons.trending_up),
                _buildDivider(),
                _buildStatItem('Total Tips', '500+', Icons.list_alt),
                _buildDivider(),
                _buildStatItem('This Week', '45', Icons.calendar_today),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
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
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 40, color: Colors.grey[300]);
  }
}

class _TrustSignalSection extends StatelessWidget {
  const _TrustSignalSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResponsibleGamblingFooter extends StatelessWidget {
  const _ResponsibleGamblingFooter();

  @override
  Widget build(BuildContext context) {
    return Container(
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
    );
  }
}