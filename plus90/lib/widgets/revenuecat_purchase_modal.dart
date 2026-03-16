import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../providers/subscription_provider.dart';
import '../theme/app_theme.dart';
import '../screens/termsnconds.dart';
import '../screens/privacypolicy.dart';

class RevenueCatPurchaseModal extends StatelessWidget {
  const RevenueCatPurchaseModal({super.key});

  // ---------------------------------------------------------------------------
  // Plan hierarchy: weekly=1, monthly=2, 3months=3, yearly=4
  // ---------------------------------------------------------------------------
  static const Map<String, int> _planOrder = {
    'weekly':   1,
    'monthly':  2,
    '3_months': 3,
    'yearly':   4,
  };

  /// Returns the hierarchy key for a package identifier string.
  String? _planKey(String packageId) {
    final id = packageId.toLowerCase();
    if (id.contains('week'))                                  return 'weekly';
    if (id.contains('3month') || id.contains('three_month')) return '3_months';
    if (id.contains('month'))                                 return 'monthly';
    if (id.contains('year') || id.contains('annual'))        return 'yearly';
    return null;
  }

  /// Returns the hierarchy key for the active plan name string coming from
  /// [SubscriptionProvider.activePlanName] (e.g. "Weekly", "Monthly", …).
  String? _activePlanKey(String? activePlanName) {
    if (activePlanName == null) return null;
    switch (activePlanName) {
      case 'Weekly':   return 'weekly';
      case 'Monthly':  return 'monthly';
      case '3 Months': return '3_months';
      case 'Yearly':   return 'yearly';
      default:         return null;
    }
  }

  /// Core button-state logic.
  ///
  /// Returns a map with:
  ///   - `label`    → String shown on the button
  ///   - `disabled` → bool
  ///   - `color`    → Color for the button background
  Map<String, dynamic> _getButtonState({
    required String packageId,
    required String? activePlanName,
    required bool isPremium,
    required String? trialText, // if a free-trial is available, honour it
  }) {
    // Not a subscriber yet → normal "Select" / "Try Free" flow
    if (!isPremium || activePlanName == null) {
      return {
        'label': trialText != null ? 'Try Free' : 'SELECT PLAN',
        'disabled': false,
        'color': trialText != null ? Colors.blue : AppTheme.accentGreen,
      };
    }

    final activeKey  = _activePlanKey(activePlanName);
    final thisKey    = _planKey(packageId);

    final activeOrder = _planOrder[activeKey] ?? 0;
    final thisOrder   = _planOrder[thisKey]   ?? 0;

    // ── CURRENT PLAN ──────────────────────────────────────────────────────────
    if (activeKey != null && thisKey == activeKey) {
      return {
        'label': 'CURRENT',
        'disabled': true,
        'color': Colors.grey.shade500,
      };
    }

    // ── UPGRADE (this plan is higher than current) ────────────────────────────
    if (thisOrder > activeOrder) {
      return {
        'label': 'UPGRADE',
        'disabled': false,
        'color': AppTheme.accentGreen,
      };
    }

    // ── COVERED (this plan is lower than current) ─────────────────────────────
    if (thisOrder < activeOrder && thisOrder > 0) {
      return {
        'label': 'COVERED',
        'disabled': true,
        'color': Colors.grey.shade400,
      };
    }

    // Fallback
    return {
      'label': 'SELECT PLAN',
      'disabled': false,
      'color': AppTheme.accentGreen,
    };
  }

  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 10)),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),

            const SizedBox(height: 4),

            // Icon + Title inline
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.workspace_premium, size: 20, color: AppTheme.accentGreen),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Go Premium',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primaryNavy)),
                      const Text('Unlock all xpert predictions & advanced stats',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 20),

            // Pricing plans
            Consumer<SubscriptionProvider>(
              builder: (context, provider, child) {
                if (!provider.isInitialized && !provider.isLoading) {
                  return _buildErrorState(
                    context, provider,
                    'Failed to connect to payment service',
                    'Check your connection and try again',
                    Colors.red,
                    onRetry: () => provider.initialize(),
                  );
                }
                if (!provider.isInitialized || provider.isLoading) {
                  return _buildLoadingState(context, provider);
                }
                if (provider.packages.isEmpty) {
                  return _buildErrorState(
                    context, provider,
                    'No subscription plans available',
                    'Connection issue or no products configured',
                    Colors.orange,
                    onRetry: () => provider.refreshPackages(),
                  );
                }
                return _buildPricingPlans(context, provider);
              },
            ),

            const Divider(height: 20),

            // Features in 2-column grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 5,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              children: [
                _buildFeature('50+ daily predictions'),
                _buildFeature('Major leagues & competitions'),
                _buildFeature('Accumulator builder'),
                _buildFeature('Instant notifications'),
              ],
            ),

            const SizedBox(height: 12),

            // Restore Purchases
            Consumer<SubscriptionProvider>(
              builder: (context, provider, child) {
                return Center(
                  child: TextButton(
                    onPressed: provider.isLoading ? null : () => _handleRestore(context, provider),
                    child: Text('Restore Purchases',
                        style: TextStyle(fontSize: 12, color: AppTheme.primaryNavy)),
                  ),
                );
              },
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TermsScreen()),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Terms & Conditions',
                    style: TextStyle(fontSize: 10, color: Colors.blue),
                  ),
                ),
                const Text('|', style: TextStyle(fontSize: 10, color: Colors.grey)),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PrivacyScreen()),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Privacy Policy',
                    style: TextStyle(fontSize: 10, color: Colors.blue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, SubscriptionProvider provider) {
    return const Column(
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentGreen),
        ),
        SizedBox(height: 12),
      ],
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    SubscriptionProvider provider,
    String title,
    String subtitle,
    Color color, {
    required VoidCallback onRetry,
  }) {
    return Column(
      children: [
        Icon(Icons.error_outline, size: 40, color: color),
        const SizedBox(height: 12),
        Text(title,
            style: TextStyle(fontSize: 15, color: color, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Text(subtitle,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
            textAlign: TextAlign.center),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentGreen,
                foregroundColor: AppTheme.primaryNavy,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPricingPlans(BuildContext context, SubscriptionProvider provider) {
    Package? weeklyPackage, monthlyPackage, threeMonthPackage, yearlyPackage;

    for (var pkg in provider.packages) {
      final id = pkg.identifier.toLowerCase();
      if (id.contains('week')) {
        weeklyPackage = pkg;
      } else if (id.contains('3month') || id.contains('three_month')) {
        threeMonthPackage = pkg;
      } else if (id.contains('month')) {
        monthlyPackage = pkg;
      } else if (id.contains('year') || id.contains('annual')) {
        yearlyPackage = pkg;
      }
    }

    String? savings;
    if (monthlyPackage != null && yearlyPackage != null) {
      savings = provider.calculateSavings(monthlyPackage, yearlyPackage);
    }

    return Column(
      children: [
        if (weeklyPackage != null) ...[
          _buildPlanCard(
            context: context, provider: provider, package: weeklyPackage,
            title: 'Weekly', subtitle: 'Cheap & flexible',
          ),
          const SizedBox(height: 8),
        ],
        if (monthlyPackage != null) ...[
          _buildPlanCard(
            context: context, provider: provider, package: monthlyPackage,
            title: 'Monthly', subtitle: 'Flexible',
          ),
          const SizedBox(height: 8),
        ],
        if (threeMonthPackage != null) ...[
          _buildPlanCard(
            context: context, provider: provider, package: threeMonthPackage,
            title: '3 Months', subtitle: 'Popular choice',
            badge: 'Popular', badgeColor: AppTheme.accentGreen,
          ),
          const SizedBox(height: 8),
        ],
        if (yearlyPackage != null)
          _buildPlanCard(
            context: context, provider: provider, package: yearlyPackage,
            title: 'Yearly', subtitle: 'Best value',
            badge: savings, badgeColor: AppTheme.accentGold, badgeOnRight: true,
          ),
      ],
    );
  }

  Widget _buildPlanCard({
    required BuildContext context,
    required SubscriptionProvider provider,
    required Package package,
    required String title,
    required String subtitle,
    String? badge,
    Color? badgeColor,
    bool badgeOnRight = false,
  }) {
    // ── Resolve free-trial text (same logic as before) ───────────────────────
    String? trialText;
    Color? trialColor;

    try {
      if (package.storeProduct.introductoryPrice != null) {
        final introPrice = package.storeProduct.introductoryPrice!;
        if (introPrice.price == 0.0) {
          final period = introPrice.period;
          if (period.contains('D')) {
            trialText = '${period.replaceAll('P', '').replaceAll('D', '')}d free';
            trialColor = Colors.blue;
          } else if (period.contains('W')) {
            trialText = '${period.replaceAll('P', '').replaceAll('W', '')}w free';
            trialColor = Colors.purple;
          } else if (period.contains('M')) {
            trialText = '${period.replaceAll('P', '').replaceAll('M', '')}m free';
            trialColor = Colors.orange;
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Error parsing trial info: $e');
    }

    // ── Resolve button state ─────────────────────────────────────────────────
    final btnState = _getButtonState(
      packageId: package.identifier,
      activePlanName: provider.activePlanName,
      isPremium: provider.isPremium,
      trialText: trialText,
    );

    final String  btnLabel    = btnState['label']    as String;
    final bool    btnDisabled = btnState['disabled'] as bool;
    final Color   btnColor    = btnState['color']    as Color;

    // ── Badge resolution (trial text overrides badge) ────────────────────────
    final effectiveBadge = trialText ?? badge;
    final effectiveColor = trialText != null ? trialColor! : (badgeColor ?? AppTheme.accentGreen);
    final showBadge      = effectiveBadge != null;
    final isBadgeOnRight = trialText == null && badgeOnRight;

    // ── Visual dimming for disabled (covered / current) cards ────────────────
    final double cardOpacity = btnDisabled ? 0.55 : 1.0;

    return Opacity(
      opacity: cardOpacity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            // Only trigger purchase if the button is enabled
            onTap: btnDisabled ? null : () => _purchasePackage(context, provider, package),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: showBadge ? effectiveColor.withOpacity(0.5) : AppTheme.neutralGray,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  // Left: title + subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryNavy)),
                        Text(subtitle,
                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),

                  // Right: was-price + current price + period
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _getOriginalPriceString(package, title),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: Colors.red,
                          decorationThickness: 2,
                        ),
                      ),
                      Text(
                        provider.getFormattedPrice(package),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryNavy),
                      ),
                      Text(
                        provider.getSubscriptionPeriod(package),
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),

                  const SizedBox(width: 8),

                  // ── Button ──────────────────────────────────────────────────
                  ElevatedButton(
                    onPressed: btnDisabled
                        ? null
                        : () => _purchasePackage(context, provider, package),
                    style: ElevatedButton.styleFrom(
                      // Use disabledBackgroundColor so the colour is visible even
                      // when the button is disabled (Flutter greys it out otherwise)
                      backgroundColor: btnColor,
                      disabledBackgroundColor: btnColor.withOpacity(0.6),
                      disabledForegroundColor: Colors.white70,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                    child: Text(btnLabel),
                  ),
                ],
              ),
            ),
          ),

          // Badge floats above the card border
          if (showBadge)
            Positioned(
              top: -9,
              left: isBadgeOnRight ? null : 10,
              right: isBadgeOnRight ? 10 : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: effectiveColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  effectiveBadge!,
                  style: const TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getOriginalPriceString(Package package, String title) {
    String priceString = package.storeProduct.priceString;
    String numericPart = priceString.replaceAll(',', '').replaceAll(RegExp(r'[^0-9.]'), '');
    double currentPrice = double.tryParse(numericPart) ?? 0;
    int originalPrice = (currentPrice * 1.5).round();
    String currencySymbol = priceString.replaceAll(RegExp(r'[0-9.,]'), '').trim();
    return 'was $currencySymbol $originalPrice';
  }

  Future<void> _handleRestore(BuildContext context, SubscriptionProvider provider) async {
    try {
      final result = await provider.restorePurchases();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result.success
            ? 'Purchases restored successfully!'
            : result.error ?? 'Failed to restore purchases'),
        backgroundColor: result.success ? AppTheme.accentGreen : AppTheme.mutedRed,
      ));
      if (result.success && provider.isPremium) Navigator.pop(context);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppTheme.mutedRed,
        ));
      }
    }
  }

  Future<void> _purchasePackage(
      BuildContext context, SubscriptionProvider provider, Package package) async {
    try {
      final result = await provider.purchasePackage(package);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(result.success
              ? 'Purchase successful!'
              : result.isCancelled
                  ? 'Purchase cancelled'
                  : result.error ?? 'Purchase failed'),
          backgroundColor: result.success
              ? AppTheme.accentGreen
              : result.isCancelled
                  ? AppTheme.accentGold
                  : AppTheme.mutedRed,
        ));
        if (result.success) Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppTheme.mutedRed,
        ));
      }
    }
  }

  Widget _buildFeature(String text) {
    return Row(
      children: [
        Icon(Icons.check, size: 13, color: AppTheme.accentGreen),
        const SizedBox(width: 5),
        Expanded(
          child: Text(text,
              style: const TextStyle(fontSize: 12, color: AppTheme.primaryNavy)),
        ),
      ],
    );
  }
}