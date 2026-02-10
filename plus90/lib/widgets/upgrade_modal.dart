import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/revenuecat_purchase_modal.dart';

class UpgradeModal extends StatelessWidget {
  const UpgradeModal({super.key});

  @override
  Widget build(BuildContext context) {
    return const RevenueCatPurchaseModal();
  }

  Widget _buildFeature(String text) {
    return Row(
      children: [
        Icon(Icons.check_circle, size: 20, color: AppTheme.accentGreen),
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
    );
  }
}