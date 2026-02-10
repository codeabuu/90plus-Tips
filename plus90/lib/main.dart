import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/home_screen.dart';
import '../screens/today_screen.dart';
import '../screens/leagues_screen.dart';
import '../screens/more_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/predictions_provider.dart';
import '../providers/subscription_provider.dart';
import '../theme/app_theme.dart';
// import '../widgets/upgrade_modal.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PredictionsProvider()),
        ChangeNotifierProvider(create: (_) => SubscriptionProvider()),
      ],
      child: MaterialApp(
        title: 'Premium Football Predictions',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainAppScreen(),
      ),
    );
  }
}

class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    // const TodayScreen(),
    const LeaguesScreen(),
    const MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          // final isPremium = context.read<SubscriptionProvider>().isPremium;
          // if ((index == 1 || index == 2) && !isPremium) {
            // _showUpgradeModal(context);
          // } else {
            setState(() {
              _selectedIndex = index;
            });
          // }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.accentGreen,
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 24),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(Icons.flash_on, size: 24),
                Consumer<SubscriptionProvider>(
                  builder: (context, provider, child) {
                    if (!provider.isPremium) {
                      return Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(Icons.lock, size: 8, color: Colors.white),
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
              ],
            ),
            label: 'Today',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                Icon(Icons.leaderboard, size: 24),
                Consumer<SubscriptionProvider>(
                  builder: (context, provider, child) {
                    if (!provider.isPremium) {
                      return Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(Icons.lock, size: 8, color: Colors.white),
                        ),
                      );
                    }
                    return SizedBox.shrink();
                  },
                ),
              ],
            ),
            label: 'Leagues',
          ),
          
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz, size: 24),
            label: 'More',
          ),
        ],
      ),
    );
  }

  // void _showUpgradeModal(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     isScrollControlled: true,
  //     backgroundColor: Colors.transparent,
  //     builder: (context) => UpgradeModal(),
  //   );
  // }
}