import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../theme/app_theme.dart';
import 'revenuecat_purchase_modal.dart';
import 'package:intl/intl.dart';

// ─── Full Hero ────────────────────────────────────────────────────────────────

class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> {
  int _tapCount = 0;
  DateTime? _firstTapAt;

  /// 6 taps within 4 seconds triggers reviewer access.
  static const int _requiredTaps = 6;
  static const Duration _tapWindow = Duration(seconds: 4);

  void _handleIconTap() async {
    final now = DateTime.now();

    // Reset if outside the time window
    if (_firstTapAt != null && now.difference(_firstTapAt!) > _tapWindow) {
      _tapCount = 0;
      _firstTapAt = null;
    }

    if (_tapCount == 0) _firstTapAt = now;
    _tapCount++;

    debugPrint('🤫 Icon tap $_tapCount/$_requiredTaps');

    if (_tapCount >= _requiredTaps) {
      _tapCount = 0;
      _firstTapAt = null;
      await _activateReviewerAccess();
    }
  }

  Future<void> _activateReviewerAccess() async {
    final provider = context.read<SubscriptionProvider>();

    // Already premium — nothing to do
    if (provider.isPremium) {
      debugPrint('ℹ️ Already premium, reviewer tap ignored');
      return;
    }

    await provider.grantReviewerAccess();

    if (!mounted) return;

    // Subtle confirmation — no mention of "reviewer" or "backdoor"
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.workspace_premium, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text(
              'Premium unlocked!',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: AppTheme.accentGold,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionProvider = context.watch<SubscriptionProvider>();

    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryNavy,
            const Color(0xFF2A3658),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: CustomPaint(painter: _ParticlePainter()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    // ── Tappable icon ─────────────────────────────────────────
                    GestureDetector(
                      onTap: _handleIconTap,
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Image.asset(
                          'assets/icons/heroicon.png',
                          width: 24,
                          height: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '90PLUS TIPS',
                      style: Theme.of(context).textTheme.displayLarge!.copyWith(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                    ),
                    const Spacer(),
                    _buildTappableStatusBadge(context, subscriptionProvider),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _getFormattedDate(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Expert Analysis, Reliable Predictions & Insights For Every Game',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTappableStatusBadge(
      BuildContext context, SubscriptionProvider provider) {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (provider.isPremium) {
      statusText = 'PREMIUM';
      statusColor = AppTheme.accentGold;
      statusIcon = Icons.workspace_premium;
    } else if (provider.isSubscriptionCancelled()) {
      statusText = 'EXPIRED';
      statusColor = Colors.red;
      statusIcon = Icons.error_outline;
    } else {
      statusText = 'FREE';
      statusColor = Colors.green;
      statusIcon = Icons.person_outline;
    }

    return GestureDetector(
      onTap: () => _showUpgradeModal(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              statusColor.withOpacity(0.2),
              statusColor.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: statusColor.withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(statusIcon, size: 16, color: statusColor),
            const SizedBox(width: 6),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: statusColor,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpgradeModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RevenueCatPurchaseModal(),
    );
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final String weekday = DateFormat('EEEE').format(now);
    final String dayWithSuffix = _getDayWithSuffix(now.day);
    return '$weekday, $dayWithSuffix';
  }

  String _getDayWithSuffix(int day) {
    if (day >= 11 && day <= 13) return '${day}th';
    switch (day % 10) {
      case 1: return '${day}st';
      case 2: return '${day}nd';
      case 3: return '${day}rd';
      default: return '${day}th';
    }
  }
}

// ─── Sticky Compact Header ────────────────────────────────────────────────────

class StickyHeroHeader extends StatefulWidget {
  const StickyHeroHeader({super.key});

  @override
  State<StickyHeroHeader> createState() => _StickyHeroHeaderState();
}

class _StickyHeroHeaderState extends State<StickyHeroHeader> {
  int _tapCount = 0;
  DateTime? _firstTapAt;

  static const int _requiredTaps = 6;
  static const Duration _tapWindow = Duration(seconds: 4);

  void _handleIconTap() async {
    final now = DateTime.now();

    if (_firstTapAt != null && now.difference(_firstTapAt!) > _tapWindow) {
      _tapCount = 0;
      _firstTapAt = null;
    }

    if (_tapCount == 0) _firstTapAt = now;
    _tapCount++;

    debugPrint('🤫 Compact icon tap $_tapCount/$_requiredTaps');

    if (_tapCount >= _requiredTaps) {
      _tapCount = 0;
      _firstTapAt = null;
      await _activateReviewerAccess();
    }
  }

  Future<void> _activateReviewerAccess() async {
    final provider = context.read<SubscriptionProvider>();

    if (provider.isPremium) return;

    await provider.grantReviewerAccess();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.workspace_premium, color: Colors.white, size: 16),
            SizedBox(width: 8),
            Text(
              'Premium unlocked!',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        backgroundColor: AppTheme.accentGold,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subscriptionProvider = context.watch<SubscriptionProvider>();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryNavy,
            const Color(0xFF2A3658),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: CustomPaint(painter: _ParticlePainter()),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                // ── Tappable icon ───────────────────────────────────────────
                GestureDetector(
                  onTap: _handleIconTap,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset(
                      'assets/icons/heroicon.png',
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '90PLUS TIPS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _buildTappableCompactStatusBadge(context, subscriptionProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTappableCompactStatusBadge(
      BuildContext context, SubscriptionProvider provider) {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (provider.isPremium) {
      statusText = 'PREMIUM';
      statusColor = AppTheme.accentGold;
      statusIcon = Icons.workspace_premium;
    } else if (provider.isSubscriptionCancelled()) {
      statusText = 'EXPIRED';
      statusColor = Colors.red;
      statusIcon = Icons.error_outline;
    } else {
      statusText = 'FREE';
      statusColor = Colors.green;
      statusIcon = Icons.person_outline;
    }

    return GestureDetector(
      onTap: () => _showUpgradeModal(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: statusColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(statusIcon, size: 12, color: statusColor),
            const SizedBox(width: 4),
            Text(
              statusText,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: statusColor,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpgradeModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RevenueCatPurchaseModal(),
    );
  }
}

// ─── Sliver Delegate ──────────────────────────────────────────────────────────

class HeroSliverDelegate extends SliverPersistentHeaderDelegate {
  final double maxExtent;
  final double minExtent;

  const HeroSliverDelegate({
    required this.maxExtent,
    required this.minExtent,
  });

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);

    return Stack(
      fit: StackFit.expand,
      children: [
        Opacity(
          opacity: (1 - progress * 2).clamp(0.0, 1.0),
          child: const HeroSection(),
        ),
        Opacity(
          opacity: (progress * 2 - 1).clamp(0.0, 1.0),
          child: const StickyHeroHeader(),
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(covariant HeroSliverDelegate oldDelegate) => false;
}

// ─── Particle Painter ─────────────────────────────────────────────────────────

class _ParticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 20; i++) {
      final x = (i * 37) % size.width.toInt();
      final y = (i * 23) % size.height.toInt();
      final radius = 1 + (i % 3).toDouble();
      canvas.drawCircle(Offset(x.toDouble(), y.toDouble()), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}