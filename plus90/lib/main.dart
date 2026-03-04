// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_screen.dart';
import 'screens/today_tips_screen.dart';
import 'screens/leagues_screen.dart';
import 'screens/more_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/predictions_provider.dart';
import 'providers/subscription_provider.dart';
import 'theme/app_theme.dart';
import 'widgets/upgrade_modal.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: "assets/.env");
  
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
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    
    // Initialize subscription provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSubscription();
    });

    _screens = [
      HomeScreen(onNavigate: _navigateToScreen),
      TodayTipsScreen(onNavigate: _navigateToScreen),
      LeaguesScreen(onNavigate: _navigateToScreen),
      MoreScreen(onNavigate: _navigateToScreen),
    ];
  }

  Future<void> _initializeSubscription() async {
    final subscriptionProvider = context.read<SubscriptionProvider>();
    await subscriptionProvider.initialize();
  }

  void _navigateToScreen(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onItemTapped(int index) {
    // Check if premium is required for Today and Leagues tabs
    if (index == 1 || index == 2) {
      final subscriptionProvider = context.read<SubscriptionProvider>();
      if (!subscriptionProvider.isPremium) {
        _showUpgradeModal(context);
        return;
      }
    }
    
    setState(() {
      _selectedIndex = index;
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
    return WillPopScope(
      onWillPop: () async {
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: Container(
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
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppTheme.accentGreen,
            unselectedItemColor: Colors.grey[600],
            selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home, size: 24),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    const Icon(Icons.flash_on, size: 24),
                    Consumer<SubscriptionProvider>(
                      builder: (context, provider, child) {
                        if (!provider.isPremium) {
                          return Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.lock, size: 8, color: Colors.white),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
                label: 'Today',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    const Icon(Icons.leaderboard, size: 24),
                    Consumer<SubscriptionProvider>(
                      builder: (context, provider, child) {
                        if (!provider.isPremium) {
                          return Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(Icons.lock, size: 8, color: Colors.white),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
                label: 'Leagues',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.more_horiz, size: 24),
                label: 'More',
              ),
            ],
          ),
        ),
      ),
    );
  }
}