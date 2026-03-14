// screens/home_screen_part2.dart
import 'package:flutter/material.dart';
import 'package:plus90/screens/free_tips_screen.dart';
import '../theme/app_theme.dart';

// Import Part 1 for FreeTipData
import 'home_screen.dart';

class FreeTipsDropdown extends StatelessWidget {
  final bool isExpanded;
  final bool isLoading;
  final List<FreeTipData> tips;
  final VoidCallback onToggle;
  final Function(int) onNavigate;
  final bool isPremium;
  final VoidCallback onUpgradeTap;

  const FreeTipsDropdown({
    required this.isExpanded,
    required this.isLoading,
    required this.tips,
    required this.onToggle,
    required this.onNavigate,
    required this.isPremium,
    required this.onUpgradeTap,
  });

  // Calculate total odds from all free tips
  String _calculateTotalOdds() {
    if (tips.isEmpty) return '';
    
    double totalOdds = 1.0;
    bool hasValidOdds = false;
    
    for (var tip in tips) {
      final oddsString = tip.odds.replaceAll('×', '').trim();
      final odds = double.tryParse(oddsString);
      if (odds != null && odds > 0) {
        totalOdds *= odds;
        hasValidOdds = true;
      }
    }
    
    return hasValidOdds ? totalOdds.toStringAsFixed(2) : '';
  }

  @override
  Widget build(BuildContext context) {
    final totalOdds = _calculateTotalOdds();
    
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
            _buildHeader(context, totalOdds),
            if (isExpanded) _buildContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String totalOdds) {
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
            if (totalOdds.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.green[200]!,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    
                    const SizedBox(width: 4),
                    Text(
                      'Total: $totalOdds',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.green[700],
                      ),
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
              : _TipsListContent(
                  tips: tips,
                  onNavigate: onNavigate,
                  isPremium: isPremium,
                  onUpgradeTap: onUpgradeTap,
                ),
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
  final bool isPremium;
  final VoidCallback onUpgradeTap;

  const _TipsListContent({
    required this.tips,
    required this.onNavigate,
    required this.isPremium,
    required this.onUpgradeTap,
  });

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
        if (isPremium) {
          // If premium, navigate to Today's Tips screen (index 1)
          onNavigate(1);
        } else {
          // If not premium, show upgrade modal
          onUpgradeTap();
        }
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
        // _buildOddsBadge(),
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

class LiveIndicator extends StatefulWidget {
  const LiveIndicator();

  @override
  State<LiveIndicator> createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<LiveIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Container(
        margin: const EdgeInsets.only(left: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.red.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'LIVE',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}