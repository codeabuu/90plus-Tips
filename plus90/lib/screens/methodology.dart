// screens/methodology_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class MethodologyScreen extends StatefulWidget {
  const MethodologyScreen({super.key});

  @override
  State<MethodologyScreen> createState() => _MethodologyScreenState();
}

class _MethodologyScreenState extends State<MethodologyScreen> {
  final List<bool> _expandedSections = List.generate(6, (index) => false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Our Methodology',
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
              // Header with science icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryNavy,
                      const Color(0xFF2A3658),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryNavy.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.science,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Text(
                            'The Science Behind Our Forecasts',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'At ScoreWise, we don\'t rely on guesswork. Our predictions are generated through a sophisticated multi-layered analytical framework combining statistical models with cutting-edge machine learning.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Data Foundation Section
              _buildMethodSection(
                number: 1,
                title: 'Data Foundation',
                icon: Icons.storage,
                iconColor: Colors.blue,
                content: 'Our system continuously processes thousands of data points for every match.',
                metrics: const [
                  {'Team Performance': 'Goals scored/conceded, shots on target, possession, passing accuracy, defensive actions'},
                  {'Advanced Metrics': 'Expected Goals (xG), Expected Goal Contributions (xGC), Pressure Index, Duel Power'},
                  {'Historical Data': 'Head-to-head records, form trends, home/away performance splits'},
                  {'Contextual Factors': 'Injuries, suspensions, player availability, tactical matchups'},
                ],
              ),
              
              // Multi-Model Approach
              _buildMethodSection(
                number: 2,
                title: 'Multi-Model Ensemble',
                icon: Icons.schema,
                iconColor: Colors.purple,
                content: 'Rather than a single method, our engine employs an ensemble of proven statistical and machine learning models.',
                subsections: const [
                  {'title': 'Poisson & Dixon-Coles Models', 'content': 'Analyze goal-scoring patterns to calculate expected goals, probability distributions, and outcome likelihood with correction for low-scoring games and time decay.'},
                  {'title': 'Machine Learning Ensemble', 'content': 'Random Forest, XGBoost, Neural Networks, and SVM combined in a voting ensemble for robust, reliable forecasts.'},
                ],
              ),
              
              // Team Rating Systems
              _buildMethodSection(
                number: 3,
                title: 'Team Rating Systems',
                icon: Icons.trending_up,
                iconColor: Colors.green,
                content: 'We employ modified rating systems to dynamically measure team strength.',
                subsections: const [
                  {'title': 'Elo-Based Power Ratings', 'content': 'Teams swap rating points based on match result, margin of victory, expected vs actual performance, and opposition strength.'},
                  {'title': 'Glicko2 Implementation', 'content': 'Tracks team strength rating, rating reliability (confidence interval), and performance volatility over time.'},
                ],
              ),
              
              // Feature Engineering
              _buildMethodSection(
                number: 4,
                title: 'Feature Engineering',
                icon: Icons.tune,
                iconColor: Colors.orange,
                content: 'Sophisticated derived metrics that capture nuanced aspects of team performance.',
                metrics: const [
                  {'Attack Strength': 'Goals scored relative to league average'},
                  {'Defensive Solidity': 'Goals conceded adjusted for opponent strength'},
                  {'Home/Away Splits': 'Performance differentials based on venue'},
                  {'Form Indicators': 'Weighted performance over last 3, 5, and 10 matches'},
                  {'Pressure Index': 'Defensive intensity metrics'},
                  {'Duel Power': 'Success rate in aerial and ground duels'},
                ],
              ),
              
              // Simulation Engine
              _buildMethodSection(
                number: 5,
                title: 'Monte Carlo Simulation Engine',
                icon: Icons.animation,
                iconColor: Colors.red,
                content: 'For each fixture, we run thousands of Monte Carlo simulations that:',
                bulletPoints: const [
                  'Use current team ratings and form metrics',
                  'Apply probability distributions for goal scoring',
                  'Account for home advantage and tactical matchups',
                  'Produce win/draw/loss probabilities and expected goal ranges',
                ],
                note: 'Aggregated results give us confidence levels and likelihood of specific events (Over 2.5 goals, Both Teams to Score).',
              ),
              
              // Continuous Validation
              _buildMethodSection(
                number: 6,
                title: 'Continuous Validation & Improvement',
                icon: Icons.verified,
                iconColor: AppTheme.accentGreen,
                content: 'Our models are rigorously tested using:',
                bulletPoints: const [
                  'Cross-validation on historical data',
                  'Holdout testing on unseen matches',
                  'Back-testing against actual results',
                  'Accuracy tracking by league and prediction type',
                ],
                note: 'We continuously monitor performance metrics to refine and optimize our algorithms.',
              ),
              
              const SizedBox(height: 24),
              
              // Track Record Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
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
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.accentGold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.emoji_events,
                            color: AppTheme.accentGold,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Our Track Record',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Stats Grid
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _buildStatCard('Tip of the Day', '99.7%', AppTheme.accentGold),
                        _buildStatCard('Multi Combinations', '98.0%', Colors.blue),
                        _buildStatCard('BTTS & Win', '97.8%', Colors.purple),
                        _buildStatCard('Premier League', '97.7%', Colors.red),
                        _buildStatCard('La Liga', '96.9%', Colors.orange),
                        _buildStatCard('Overall', '6,900+ tips', AppTheme.accentGreen),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Disclaimer
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey[300]!,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 18,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Football is inherently unpredictable. While our methodology represents cutting-edge sports analytics, no prediction system can guarantee outcomes. Use responsibly and for entertainment purposes.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodSection({
    required int number,
    required String title,
    required IconData icon,
    required Color iconColor,
    required String content,
    List<Map<String, String>>? metrics,
    List<Map<String, String>>? subsections,
    List<String>? bulletPoints,
    String? note,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  iconColor.withOpacity(0.8),
                  iconColor,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          title: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: iconColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryNavy,
                  ),
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
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
                  
                  if (metrics != null) ...[
                    const SizedBox(height: 16),
                    ...metrics.map((metric) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: iconColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  metric.keys.first,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryNavy,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  metric.values.first,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ],
                  
                  if (subsections != null) ...[
                    const SizedBox(height: 16),
                    ...subsections.map((sub) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.arrow_right,
                                size: 18,
                                color: iconColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                sub['title']!,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: iconColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.only(left: 22),
                            child: Text(
                              sub['content']!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ],
                  
                  if (bulletPoints != null) ...[
                    const SizedBox(height: 16),
                    ...bulletPoints.map((point) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 16,
                            color: AppTheme.accentGreen,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              point,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ],
                  
                  if (note != null) ...[
                    const SizedBox(height: 16),
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
                            Icons.lightbulb_outline,
                            size: 18,
                            color: Colors.blue[400],
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              note,
                              style: TextStyle(
                                fontSize: 12,
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
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}