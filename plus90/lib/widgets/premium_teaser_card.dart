import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PremiumTeaserCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isLocked;
  final bool isHighlighted;
  final VoidCallback onTap;

  const PremiumTeaserCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isLocked = true,
    this.isHighlighted = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          border: isHighlighted
              ? Border.all(
                  color: AppTheme.accentGold.withOpacity(0.3),
                  width: 2,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
            if (isHighlighted)
              BoxShadow(
                color: AppTheme.accentGold.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 0),
              ),
          ],
        ),
        child: Stack(
          children: [
            // Frosted Glass Effect
            if (isLocked)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcOver,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Lock Icon
                  if (isLocked)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryNavy.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock,
                        size: 20,
                        color: AppTheme.primaryNavy,
                      ),
                    ),

                  // Content Icon
                  Icon(
                    icon,
                    size: 32,
                    color: isHighlighted
                        ? AppTheme.accentGold
                        : AppTheme.primaryNavy,
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isLocked
                          ? Colors.grey[600]
                          : AppTheme.primaryNavy,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),

                  // Subtitle
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isHighlighted
                          ? AppTheme.accentGold
                          : Colors.grey,
                      fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
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