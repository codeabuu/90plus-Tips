// widgets/profile_dropdown.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subscription_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/upgrade_modal.dart';

class ProfileDropdown extends StatefulWidget {
  const ProfileDropdown({super.key});

  @override
  State<ProfileDropdown> createState() => _ProfileDropdownState();
}

class _ProfileDropdownState extends State<ProfileDropdown> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _showUpgradeModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const UpgradeModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubscriptionProvider>(
      builder: (context, subscriptionProvider, child) {
        // Define elegant color scheme
        final Color premiumColor = AppTheme.accentGold;
        final Color freeColor = const Color(0xFF6B7280); // Elegant gray
        final Color accentColor = subscriptionProvider.isPremium ? premiumColor : freeColor;
        final Color bgColor = subscriptionProvider.isPremium 
            ? premiumColor.withOpacity(0.08) 
            : freeColor.withOpacity(0.08);
        final Color borderColor = subscriptionProvider.isPremium
            ? premiumColor.withOpacity(0.2)
            : freeColor.withOpacity(0.15);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header - Always visible
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _toggleExpand,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        // Icon Container
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.primaryNavy,
                                const Color(0xFF2A3658),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryNavy.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            subscriptionProvider.isPremium
                                ? Icons.workspace_premium
                                : Icons.person_outline,
                            color: subscriptionProvider.isPremium
                                ? premiumColor
                                : Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        
                        // Profile Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Your Profile',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryNavy,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      subscriptionProvider.isPremium
                                          ? Icons.stars
                                          : Icons.fiber_manual_record,
                                      size: 12,
                                      color: accentColor,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      subscriptionProvider.isPremium
                                          ? 'PREMIUM'
                                          : 'FREE',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: accentColor,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Expand/Collapse Icon
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.grey[500],
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Expanded Content
              SizeTransition(
                sizeFactor: _animation,
                axisAlignment: -1.0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
                  child: Column(
                    children: [
                      Container(
                        height: 1,
                        color: Colors.grey[100],
                      ),
                      const SizedBox(height: 16),
                      
                      // Status Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: bgColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: borderColor,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              subscriptionProvider.isPremium
                                  ? Icons.verified
                                  : Icons.info_outline,
                              size: 20,
                              color: accentColor,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    subscriptionProvider.isPremium
                                        ? 'Premium Member'
                                        : 'Free Member',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.primaryNavy,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    subscriptionProvider.isPremium
                                        ? 'You have access to all premium features'
                                        : 'Upgrade to unlock all predictions and features',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Upgrade Button - Elegant design for both states
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => _showUpgradeModal(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: subscriptionProvider.isPremium
                                ? AppTheme.primaryNavy
                                : premiumColor,
                            foregroundColor: subscriptionProvider.isPremium
                                ? Colors.white
                                : AppTheme.primaryNavy,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                subscriptionProvider.isPremium
                                    ? Icons.swap_horiz
                                    : Icons.workspace_premium,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                subscriptionProvider.isPremium
                                    ? 'Change Plan'
                                    : 'Upgrade to Premium',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                                           
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}