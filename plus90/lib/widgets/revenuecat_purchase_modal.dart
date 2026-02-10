import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../providers/subscription_provider.dart';
import '../theme/app_theme.dart';

class RevenueCatPurchaseModal extends StatelessWidget {
  const RevenueCatPurchaseModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close Button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ),

            // Premium Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accentGreen.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.workspace_premium,
                size: 32,
                color: AppTheme.accentGreen,
              ),
            ),

            const SizedBox(height: 16),

            // Title
            const Text(
              'Go Premium',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryNavy,
              ),
            ),

            const SizedBox(height: 12),

            // Description
            const Text(
              'Unlock expert predictions, advanced statistics, and premium features',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Loading indicator if packages not loaded
            Consumer<SubscriptionProvider>(
              builder: (context, provider, child) {
                if (!provider.isInitialized || provider.isLoading) {
                  return const CircularProgressIndicator();
                }

                if (provider.packages.isEmpty) {
                  return Column(
                    children: [
                      const Text(
                        'No subscription plans available',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => provider.refreshPackages(),
                        child: const Text('Retry'),
                      ),
                    ],
                  );
                }

                return _buildPricingPlans(context, provider);
              },
            ),

            const SizedBox(height: 24),

            // Features
            _buildFeature('50+ daily predictions'),
            _buildFeature('All leagues & competitions'),
            _buildFeature('Advanced statistics'),
            _buildFeature('Accumulator builder'),
            _buildFeature('Instant notifications'),

            const SizedBox(height: 24),

            // Restore Purchases Button
            Consumer<SubscriptionProvider>(
              builder: (context, provider, child) {
                return TextButton(
                  onPressed: provider.isLoading
                      ? null
                      : () async {
                          final result = await provider.restorePurchases();
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result.success
                                  ? 'Purchases restored successfully!'
                                  : result.error ?? 'Failed to restore purchases'),
                              backgroundColor: result.success
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          );
                          
                          if (result.success && provider.isPremium) {
                            Navigator.pop(context);
                          }
                        },
                  child: const Text('Restore Purchases'),
                );
              },
            ),

            const SizedBox(height: 8),

            // Terms and Privacy
            const Text(
              'Subscription automatically renews unless canceled. Cancel anytime.',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingPlans(BuildContext context, SubscriptionProvider provider) {
    // Find packages
    final monthlyPackage = provider.packages.firstWhere(
      (pkg) => pkg.identifier.contains('monthly'),
      orElse: () => provider.packages.first,
    );
    
    final yearlyPackage = provider.packages.firstWhere(
      (pkg) => pkg.identifier.contains('yearly'),
      orElse: () => provider.packages.length > 1 ? provider.packages[1] : monthlyPackage,
    );
    
    final savings = provider.calculateSavings(monthlyPackage, yearlyPackage);

    return Column(
      children: [
        // Yearly Plan
        _buildPlanCard(
          context: context,
          provider: provider,
          package: yearlyPackage,
          title: 'Yearly',
          subtitle: 'Best Value',
          isRecommended: true,
          savings: savings,
        ),

        const SizedBox(height: 12),

        // Monthly Plan
        _buildPlanCard(
          context: context,
          provider: provider,
          package: monthlyPackage,
          title: 'Monthly',
          subtitle: 'Flexible',
          isRecommended: false,
        ),

        // Lifetime Plan (if available)
        if (provider.packages.any((pkg) => pkg.identifier.contains('lifetime'))) ...[
          const SizedBox(height: 12),
          _buildPlanCard(
            context: context,
            provider: provider,
            package: provider.packages.firstWhere(
              (pkg) => pkg.identifier.contains('lifetime'),
            ),
            title: 'Lifetime',
            subtitle: 'One-time Purchase',
            isRecommended: false,
          ),
        ],
      ],
    );
  }

  Widget _buildPlanCard({
    required BuildContext context,
    required SubscriptionProvider provider,
    required Package package,
    required String title,
    required String subtitle,
    required bool isRecommended,
    String? savings,
  }) {
    return GestureDetector(
      onTap: () => _purchasePackage(context, provider, package),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRecommended ? AppTheme.accentGreen : Colors.grey[300]!,
            width: isRecommended ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            if (isRecommended && savings != null)
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    savings,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    if (isRecommended)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'RECOMMENDED',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.accentGreen,
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.getFormattedPrice(package),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                        Text(
                          provider.getSubscriptionPeriod(package),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => _purchasePackage(context, provider, package),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentGreen,
                        foregroundColor: AppTheme.primaryNavy,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Select'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _purchasePackage(BuildContext context, SubscriptionProvider provider, Package package) async {
    final result = await provider.purchasePackage(package);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.success
              ? 'Purchase successful!'
              : result.isCancelled
                  ? 'Purchase cancelled'
                  : result.error ?? 'Purchase failed'),
          backgroundColor: result.success
              ? Colors.green
              : result.isCancelled
                  ? Colors.orange
                  : Colors.red,
        ),
      );
      
      if (result.success) {
        Navigator.pop(context);
      }
    }
  }

  Widget _buildFeature(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 20, color: AppTheme.accentGreen),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.primaryNavy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}