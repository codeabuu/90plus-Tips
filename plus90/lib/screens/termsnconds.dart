// screens/terms_screen.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import 'contanct_us_screen.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Terms of Service',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryNavy,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Last Updated
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.accentGreen.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.update,
                      size: 18,
                      color: AppTheme.accentGreen,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Last Updated: March 2026',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Welcome Text
              const Text(
                'Welcome to our football prediction application. By downloading, installing, or using this application, you agree to the following Terms of Service.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // 1. Purpose
              _buildSection(
                number: '1',
                title: 'Purpose of the Application',
                content: 'This application provides football match predictions and related content for entertainment and informational purposes only. The predictions provided are based on analysis, algorithms, or opinions and are not guaranteed to be accurate.',
              ),
              
              // 2. No Betting Advice
              _buildSection(
                number: '2',
                title: 'No Betting Advice',
                content: 'The predictions available in this application do not constitute betting advice, financial advice, or professional guidance. Users are solely responsible for how they interpret and use the predictions provided in the app.',
                warning: 'The developers of this application are not responsible for any financial losses or damages resulting from the use of predictions or related content.',
              ),
              
              // 3. User Responsibility
              _buildSection(
                number: '3',
                title: 'User Responsibility',
                content: 'By using this application, you acknowledge that:',
                bulletPoints: [
                  'Football predictions are inherently uncertain.',
                  'Any decisions you make based on the predictions are made entirely at your own risk.',
                  'The app developers cannot be held liable for any outcomes related to sports betting or gambling activities.',
                ],
              ),
              
              // 4. Subscriptions and Payments
              _buildSection(
                number: '4',
                title: 'Subscriptions and Payments',
                content: 'Some features of the application may require a paid subscription.',
                extraContent: 'All subscriptions and payments are handled by Google Play. We do not process or store payment information directly.',
                note: 'By purchasing a subscription, you agree to the payment terms and billing policies set by Google Play.',
              ),
              
              // 5. Refund Policy
              _buildSection(
                number: '5',
                title: 'Refund Policy',
                content: 'All payments and subscription charges are final and non-refundable, unless otherwise determined by Google Play in accordance with their refund policies.',
              ),
              
              // 6. Availability of Service
              _buildSection(
                number: '6',
                title: 'Availability of Service',
                content: 'We strive to keep the application available and functioning properly; however, we do not guarantee uninterrupted access. The service may be modified, suspended, or discontinued at any time without prior notice.',
              ),
              
              // 7. Limitation of Liability
              _buildSection(
                number: '7',
                title: 'Limitation of Liability',
                content: 'To the maximum extent permitted by law, the developers of this application shall not be liable for any losses, damages, or consequences arising from:',
                bulletPoints: [
                  'Use of the predictions',
                  'Betting decisions made by users',
                  'Service interruptions',
                  'Errors or inaccuracies in predictions',
                ],
              ),
              
              // 8. Changes to These Terms
              _buildSection(
                number: '8',
                title: 'Changes to These Terms',
                content: 'We may update these Terms of Service from time to time. Continued use of the application after updates means you accept the revised terms.',
              ),
              
              // 9. Contact
              _buildSection(
                number: '9',
                title: 'Contact Us',
                content: 'If you have any questions regarding these Terms of Service, please reach out to us.',
              ),
              
              const SizedBox(height: 24),
              
              // Contact Button
              Container(
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
                    // Quick Response Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.accentGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: AppTheme.accentGreen,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'We reply within 12 hours',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryNavy,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Contact Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ContactUsScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.support_agent),
                        label: const Text(
                          'Contact Support',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentGreen,
                          foregroundColor: AppTheme.primaryNavy,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Email Option
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey[200]!,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.email,
                              size: 20,
                              color: Colors.blue[700],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Email us directly',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryNavy,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'support@scorewise.com',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.blue[700],
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Google Play Link
              Center(
                child: TextButton.icon(
                  onPressed: () async {
                    final Uri url = Uri.parse(
                      'https://play.google.com/store/apps/details?id=com.example.plus90'
                    );
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: Icon(
                    Icons.play_circle_outline,
                    size: 16,
                    color: Colors.grey[500],
                  ),
                  label: Text(
                    'View on Google Play',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[500],
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String number,
    required String title,
    required String content,
    String? warning,
    String? extraContent,
    String? note,
    List<String>? bulletPoints,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryNavy,
                      AppTheme.primaryNavy.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryNavy,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Main Content
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
                
                // Bullet Points
                if (bulletPoints != null) ...[
                  const SizedBox(height: 12),
                  ...bulletPoints.map((point) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            point,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ],
                
                // Extra Content
                if (extraContent != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    extraContent,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                ],
                
                // Warning
                if (warning != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 18,
                          color: Colors.red[400],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            warning,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.red[700],
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                // Note
                if (note != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: Colors.blue[400],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            note,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue[700],
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}