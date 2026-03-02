import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  // FAQ data
  final List<FaqItem> _faqItems = [
    FaqItem(
      question: 'What are Today\'s Tips?',
      answer: 'Today\'s Tips is our curated collection of all predictions for the current day. It includes expert analysis and predictions across all major leagues and betting markets. Updated daily with fresh insights.',
      icon: Icons.whatshot,
      color: AppTheme.accentGold,
    ),
    FaqItem(
      question: 'How do Predictions work?',
      answer: 'Our Predictions section displays match predictions from different leagues including EPL, La Liga, Serie A, Bundesliga, and more. Each prediction includes match details, predicted outcome, and odds. You can browse by league or view all matches.',
      icon: Icons.sports_soccer,
      color: Colors.blue,
    ),
    FaqItem(
      question: 'What is Tip of the Day?',
      answer: 'Tip of the Day is our most confident prediction with a 99.99% accuracy rating. It\'s a single, carefully analyzed pick that our experts believe has the highest probability of success. This is a premium feature that gives you our best bet of the day.',
      icon: Icons.star,
      color: AppTheme.accentGold,
    ),
    FaqItem(
      question: 'What are Multi Combinations?',
      answer: 'Multi Combinations (also called accumulators) combine multiple predictions into a single bet. This increases potential returns but requires all selections to win. Our Multi Combinations feature provides carefully selected accumulator bets with calculated total odds.',
      icon: Icons.layers,
      color: const Color(0xFF2196F3),
    ),
    FaqItem(
      question: 'What is BTTS & Win?',
      answer: 'BTTS & Win (Both Teams To Score & Win) is a specific bet type where you predict that both teams will score AND the home team will win. Our BTTS & Win picks are carefully selected matches where this outcome is statistically likely.',
      icon: Icons.swap_horiz,
      color: const Color(0xFF2196F3),
    ),
    FaqItem(
      question: 'What is BTTS?',
      answer: 'BTTS (Both Teams To Score) is a bet where you predict that both teams will score at least one goal in the match, regardless of the final result. Our BTTS predictions focus on matches where both teams have strong attacking and weak defensive records.',
      icon: Icons.sync_alt,
      color: const Color(0xFF2196F3),
    ),
    FaqItem(
      question: 'What is Over 2.5 Goals?',
      answer: 'Over 2.5 Goals is a bet predicting that the total goals scored in a match will be 3 or more. Our Over 2.5 predictions focus on matches between attacking teams with historically high-scoring encounters.',
      icon: Icons.trending_up,
      color: const Color(0xFFFF9800),
    ),
    FaqItem(
      question: 'How do Leagues work?',
      answer: 'The Leagues section organizes predictions by competition (EPL, La Liga, Serie A, etc.). You can expand each league to see all available matches and predictions for that specific competition. Perfect for focusing on your favorite league.',
      icon: Icons.emoji_events,
      color: const Color(0xFFE91E63),
    ),
    FaqItem(
      question: 'What is the difference between Free and Premium?',
      answer: 'Free users get access to basic predictions and a limited number of daily tips. Premium subscribers unlock all features including Today\'s Tips, Tip of the Day, Multi Combinations, BTTS & Win, BTTS, Over 2.5, detailed analysis, and all league predictions.',
      icon: Icons.workspace_premium,
      color: AppTheme.accentGreen,
    ),
    FaqItem(
      question: 'How accurate are your predictions?',
      answer: 'Our predictions are based on comprehensive data analysis including team form, head-to-head records, player statistics, injuries, and advanced metrics. While we strive for high accuracy, no prediction is guaranteed. Our Tip of the Day has a 99.99% historical accuracy rate.',
      icon: Icons.analytics,
      color: Colors.purple,
    ),
    FaqItem(
      question: 'Do I need an account to use the app?',
      answer: 'No, you don\'t need an account to use the app! Free features are accessible immediately. For Premium features, you can purchase a subscription through Google Play without creating an account. Your subscription is linked to your Google account.',
      icon: Icons.person_outline,
      color: Colors.grey,
    ),
    FaqItem(
      question: 'How do I upgrade to Premium?',
      answer: 'You can upgrade to Premium by tapping on any premium feature (like Today\'s Tips, Tip of the Day, etc.) or by tapping the status badge in the header. This will open our premium purchase modal where you can choose from Weekly, Monthly, 3 Months, or Yearly plans. Free trials may be available.',
      icon: Icons.card_giftcard,
      color: AppTheme.accentGold,
    ),
  ];

  List<FaqItem> get _filteredFaqItems {
    if (_searchQuery.isEmpty) return _faqItems;
    return _faqItems.where((item) {
      return item.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             item.answer.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Help Center'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryNavy,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How can we help you?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryNavy,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search for help...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Quick Topics
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quick Topics',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryNavy,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Scroll to top or clear search
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
          ),
          
          // Topics Grid
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildTopicChip('Today\'s Tips', Icons.whatshot, AppTheme.accentGold),
                _buildTopicChip('Predictions', Icons.sports_soccer, Colors.blue),
                _buildTopicChip('Tip of Day', Icons.star, AppTheme.accentGold),
                _buildTopicChip('Multi Combos', Icons.layers, const Color(0xFF2196F3)),
                _buildTopicChip('BTTS & Win', Icons.swap_horiz, const Color(0xFF2196F3)),
                _buildTopicChip('BTTS', Icons.sync_alt, const Color(0xFF2196F3)),
                _buildTopicChip('Over 2.5', Icons.trending_up, const Color(0xFFFF9800)),
                _buildTopicChip('Leagues', Icons.emoji_events, const Color(0xFFE91E63)),
                _buildTopicChip('Premium', Icons.workspace_premium, AppTheme.accentGreen),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // FAQ List
          Expanded(
            child: _filteredFaqItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No results found',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try different keywords',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredFaqItems.length,
                    itemBuilder: (context, index) {
                      return _buildFaqCard(_filteredFaqItems[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicChip(String label, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      child: FilterChip(
        label: Text(label),
        avatar: Icon(icon, size: 16, color: color),
        selected: false,
        onSelected: (_) {
          setState(() {
            _searchQuery = label;
            _searchController.text = label;
          });
        },
        backgroundColor: Colors.white,
        selectedColor: color.withOpacity(0.2),
        checkmarkColor: color,
        labelStyle: TextStyle(
          color: AppTheme.primaryNavy,
          fontWeight: FontWeight.w500,
        ),
        side: BorderSide(color: color.withOpacity(0.3)),
      ),
    );
  }

  Widget _buildFaqCard(FaqItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              color: item.color,
              size: 20,
            ),
          ),
          title: Text(
            item.question,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryNavy,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(56, 0, 16, 16),
              child: Text(
                item.answer,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FaqItem {
  final String question;
  final String answer;
  final IconData icon;
  final Color color;

  FaqItem({
    required this.question,
    required this.answer,
    required this.icon,
    required this.color,
  });
}