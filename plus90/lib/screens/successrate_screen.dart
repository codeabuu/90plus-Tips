import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'package:intl/intl.dart';

class SuccessRatesScreen extends StatefulWidget {
  const SuccessRatesScreen({super.key});

  @override
  State<SuccessRatesScreen> createState() => _SuccessRatesScreenState();
}

class _SuccessRatesScreenState extends State<SuccessRatesScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final List<SuccessStat> _stats = [
    SuccessStat(
      category: 'Tip of the Day',
      successRate: 99.6,
      icon: Icons.star,
      color: AppTheme.accentGold,
      totalTips: 1250,
      description: 'Our premium daily pick with exceptional accuracy',
      badge: 'BEST PERFORMER',
    ),
    SuccessStat(
      category: 'Multi Combinations',
      successRate: 94.2,
      icon: Icons.layers,
      color: const Color(0xFF2196F3),
      totalTips: 850,
      description: 'Accumulator bets with carefully selected matches',
      badge: 'HIGH VALUE',
    ),
    SuccessStat(
      category: 'BTTS & Win',
      successRate: 91.8,
      icon: Icons.swap_horiz,
      color: const Color(0xFF2196F3),
      totalTips: 720,
      description: 'Both teams score + home win predictions',
    ),
    SuccessStat(
      category: 'BTTS',
      successRate: 88.5,
      icon: Icons.sync_alt,
      color: const Color(0xFF2196F3),
      totalTips: 1100,
      description: 'Both teams to score predictions',
    ),
    SuccessStat(
      category: 'Over 2.5 Goals',
      successRate: 86.3,
      icon: Icons.trending_up,
      color: const Color(0xFFFF9800),
      totalTips: 950,
      description: 'Matches with 3+ total goals',
    ),
    SuccessStat(
      category: 'Premier League',
      successRate: 89.7,
      icon: Icons.emoji_events,
      color: const Color(0xFF6C0BA9),
      totalTips: 680,
      description: 'English Premier League predictions',
    ),
    SuccessStat(
      category: 'La Liga',
      successRate: 88.9,
      icon: Icons.emoji_events,
      color: const Color(0xFFDC2A2A),
      totalTips: 590,
      description: 'Spanish La Liga predictions',
    ),
    SuccessStat(
      category: 'Serie A',
      successRate: 87.2,
      icon: Icons.emoji_events,
      color: const Color(0xFF0066CC),
      totalTips: 520,
      description: 'Italian Serie A predictions',
    ),
    SuccessStat(
      category: 'Bundesliga',
      successRate: 86.8,
      icon: Icons.emoji_events,
      color: const Color(0xFFD30505),
      totalTips: 480,
      description: 'German Bundesliga predictions',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            stretch: true,
            backgroundColor: AppTheme.primaryNavy,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
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
                child: Stack(
                  children: [
                    // Animated background particles
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: CustomPaint(
                          painter: _ParticlePainter(),
                        ),
                      ),
                    ),
                    
                    // Main content
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Our Success Rates',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Transparent tracking of all predictions',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Overall stats row
                          Row(
                            children: [
                              _buildOverallStat(
                                'Total Tips',
                                '6,940+',
                                Icons.analytics,
                              ),
                              Container(
                                height: 40,
                                width: 1,
                                color: Colors.white.withOpacity(0.3),
                                margin: const EdgeInsets.symmetric(horizontal: 20),
                              ),
                              _buildOverallStat(
                                'Avg Success',
                                '90.3%',
                                Icons.verified,
                              ),
                              Container(
                                height: 40,
                                width: 1,
                                color: Colors.white.withOpacity(0.3),
                                margin: const EdgeInsets.symmetric(horizontal: 20),
                              ),
                              _buildOverallStat(
                                'Win Streak',
                                '12 days',
                                Icons.trending_up,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Trust badges
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTrustBadge('assets/verified.png', 'Verified'),
                      _buildTrustBadge('assets/professional.png', 'Professional'),
                      _buildTrustBadge('assets/transparent.png', 'Transparent'),
                    ],
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Performance over time
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Performance by Month',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: Row(
                          children: [
                            _buildMonthBar('Jan', 89),
                            _buildMonthBar('Feb', 92),
                            _buildMonthBar('Mar', 94),
                            _buildMonthBar('Apr', 91),
                            _buildMonthBar('May', 93),
                            _buildMonthBar('Jun', 96),
                            _buildMonthBar('Jul', 95),
                            _buildMonthBar('Aug', 94),
                            _buildMonthBar('Sep', 97),
                            _buildMonthBar('Oct', 96),
                            _buildMonthBar('Nov', 98),
                            _buildMonthBar('Dec', 99),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Section header
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Category Performance',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                ),
              ]),
            ),
          ),
          
          // Stats list
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildStatCard(_stats[index], index),
                  );
                },
                childCount: _stats.length,
              ),
            ),
          ),
          
          const SliverPadding(padding: EdgeInsets.only(bottom: 20)),
        ],
      ),
    );
  }

  Widget _buildOverallStat(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrustBadge(String asset, String label) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppTheme.accentGreen.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            label == 'Verified' ? Icons.verified :
            label == 'Professional' ? Icons.work : Icons.insights,
            color: AppTheme.accentGreen,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryNavy,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthBar(String month, int rate) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '$rate%',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppTheme.accentGreen,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: rate.toDouble(),
            width: 8,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppTheme.accentGreen.withOpacity(0.5),
                  AppTheme.accentGreen,
                ],
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            month,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

Widget _buildStatCard(SuccessStat stat, int index) {
  // Determine color based on rate (same logic)
  Color rateColor = Colors.green;
  if (stat.successRate < 85) rateColor = Colors.orange;
  if (stat.successRate < 80) rateColor = Colors.red;

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left icon – slightly larger and with a nicer shape
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: stat.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              stat.icon,
              color: stat.color,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),

          // Middle content – now takes remaining space
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category and badge on same line
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        stat.category,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B), // dark navy
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (stat.badge != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: stat.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          stat.badge!,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: stat.color,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),

                // Description – slightly smaller, softer color
                Text(
                  stat.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),

                // Total tips – smaller, with an icon
                Row(
                  children: [
                    Icon(
                      Icons.list_alt,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${NumberFormat('#,###').format(stat.totalTips)} tips',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Success rate – using a circular progress indicator for better engagement
          Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      value: stat.successRate / 100,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(rateColor),
                      strokeWidth: 4,
                    ),
                  ),
                  Text(
                    '${stat.successRate.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: rateColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'success',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
}

class SuccessStat {
  final String category;
  final double successRate;
  final IconData icon;
  final Color color;
  final int totalTips;
  final String description;
  final String? badge;

  SuccessStat({
    required this.category,
    required this.successRate,
    required this.icon,
    required this.color,
    required this.totalTips,
    required this.description,
    this.badge,
  });
}

class _ParticlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 30; i++) {
      final x = (i * 37) % size.width.toInt();
      final y = (i * 23) % size.height.toInt();
      final radius = 1 + (i % 4).toDouble();
      canvas.drawCircle(Offset(x.toDouble(), y.toDouble()), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}