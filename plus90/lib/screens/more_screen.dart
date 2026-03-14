import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/contanct_us_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screens/Helpcenterscreen.dart';
import '../screens/successrate_screen.dart';
import 'termsnconds.dart';
import 'privacypolicy.dart';
import 'methodology.dart';
import '../widgets/profile_dropdown.dart';


class MoreScreen extends StatefulWidget {
  final Function(int) onNavigate;

  const MoreScreen({super.key, required this.onNavigate});
  

  @override
  State<MoreScreen> createState() => _MoreScreenState();
}

class _MoreScreenState extends State<MoreScreen> {
  void _shareApp() async {
  const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.troncores.plus90';

  final String message =
      "⚽ Winning starts with smart predictions!\n\n"
      "Get expert football tips, accurate stats & daily matches.\n\n"
      "Download here 👇\n$playStoreUrl";

  if (kIsWeb) {
    // For web: just open Play Store link
    final Uri url = Uri.parse(playStoreUrl);
    await launchUrl(url);
  } else {
    // For Android/iOS
    await Share.share(message);
  }
}

void _rateApp() async {
  final Uri url = Uri.parse(
    'https://play.google.com/store/apps/details?id=com.troncores.plus90',
  );

  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
    throw 'Could not launch $url';
  }
}
  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
           // Header - FIXED
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryNavy,
                    const Color(0xFF2A3658),
                  ],
                ),
              ),
              child: Column(  // ← This was missing!
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.settings,
                    size: 32,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Settings & More',
                    style: Theme.of(context).textTheme.displayLarge!.copyWith(
                          color: Colors.white,
                          fontSize: 28,
                        ),
                  ),
                ],
              ),
            ),

              const SizedBox(height: 16),

              const ProfileDropdown(),
              _buildSettingsSection(context, 'APP', [
                _buildSettingsItem(
                  icon: Icons.language,
                  title: 'Language',
                  trailing: Text(
                    'English',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  onTap: () {},
                ),
                // _buildSettingsItem(
                //   icon: Icons.dark_mode,
                //   title: 'Dark Mode',
                //   trailing: Switch(
                //     value: false,
                //     onChanged: (value) {},
                //     activeColor: AppTheme.accentGreen,
                //   ),
                //   onTap: null,
                // ),
                _buildSettingsItem(
                  icon: Icons.text_snippet,
                  title: 'Our Methodology',
                  onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MethodologyScreen(),
                    ),
                  );
                },
              ),
                _buildSettingsItem(
                  icon: Icons.bar_chart,
                  title: 'Success Rates',
                  onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SuccessRatesScreen(),
                    ),
                  );
                },
                ),
              ]),

             _buildSettingsSection(context, 'SUPPORT', [
              _buildSettingsItem(
                icon: Icons.help,
                title: 'Help Center',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HelpCenterScreen(),
                    ),
                  );
                },
              ),
                _buildSettingsItem(
                  icon: Icons.contact_support,
                  title: 'Contact Us',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ContactUsScreen(),
                      ),
                    );
                  },
                ),
                _buildSettingsItem(
                  icon: Icons.star,
                  title: 'Rate This App',
                  onTap: _rateApp,
                ),
                _buildSettingsItem(
                  icon: Icons.share,
                  title: 'Share App',
                  onTap: _shareApp,
                ),
              ]),

              _buildSettingsSection(context, 'LEGAL', [
                _buildSettingsItem(
                  icon: Icons.description,
                  title: 'Terms & Conditions',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TermsScreen(),
                      ),
                    );
                  },
                ),
                _buildSettingsItem(
                  icon: Icons.privacy_tip,
                  title: 'Privacy Policy',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PrivacyScreen(),
                      ),
                    );
                  },
                ),
                
              ]),

              const SizedBox(height: 32),

              // App Info
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Football Predictions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    const Text(
                      'Data-driven football predictions from expert analysts. '
                      'We use statistical models, form analysis, and years of '
                      'expertise to deliver reliable tips across all major leagues.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.primaryNavy,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Our Commitment
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.neutralGray,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Our Commitment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildCommitmentItem('Transparent success tracking'),
                    _buildCommitmentItem('Responsible gambling advocacy'),
                    _buildCommitmentItem('Expert analysis, not guesses'),
                    _buildCommitmentItem('No hidden fees or tricks'),
                    _buildCommitmentItem('Real customer support'),
                  ],
                ),
              ),

              // Responsible Gambling
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.mutedRed.withOpacity(0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.health_and_safety,
                          color: AppTheme.mutedRed,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Responsible Usage',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.mutedRed,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'This app provides predictions for entertainment purposes. '
                      'Please use them responsibly and within your means.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.primaryNavy,
                        height: 1.5,
                      ),
                    ),
                    
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsSection(
    BuildContext context,
    String title,
    List<Widget> items,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.grey,
                letterSpacing: 1,
              ),
            ),
          ),
          ...items,
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryNavy),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          color: AppTheme.primaryNavy,
        ),
      ),
      trailing: trailing ??
          const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
    );
  }

  Widget _buildCommitmentItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            size: 16,
            color: AppTheme.accentGreen,
          ),
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