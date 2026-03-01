// widgets/sticky_hero_header.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StickyHeroHeader extends StatelessWidget {
  final double scrollOffset;
  final VoidCallback onUpgradeTap;

  const StickyHeroHeader({
    super.key,
    required this.scrollOffset,
    required this.onUpgradeTap,
  });

  @override
  Widget build(BuildContext context) {
    // Show header when scrolled past 100 pixels
    final bool isScrolled = scrollOffset > 100;
    final double height = isScrolled ? 70.0 : 0.0;
    final double opacity = isScrolled ? 1.0 : 0.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryNavy,
            const Color(0xFF2A3658),
          ],
        ),
        boxShadow: isScrolled
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: opacity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo and Title
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.sports_soccer,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Premium Predictions',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              
              // Upgrade Button
              GestureDetector(
                onTap: onUpgradeTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.star,
                        size: 14,
                        color: AppTheme.primaryNavy,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Upgrade',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryNavy,
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
    );
  }
}