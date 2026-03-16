import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/predictions_provider.dart';
import '../widgets/hero_section.dart';
import '../services/api_service.dart';
import '../services/cache_service.dart';
import '../services/local_notification_service.dart';
import '../services/notification_reminder_service.dart';
import '../widgets/notification_reminder_dialog.dart';
import '../models/league_model.dart';
import '../providers/subscription_provider.dart';
import '../widgets/upgrade_modal.dart';
import 'dart:convert';

// Import other parts
import 'homescreen2.dart';
import 'homescreen3.dart';

class HomeScreen extends StatefulWidget {
  final Function(int) onNavigate;

  const HomeScreen({super.key, required this.onNavigate});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

bool _hasShownSystemDialog = false;

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final ApiService _apiService = ApiService();
  final CacheService _cache = CacheService();
  final LocalNotificationService _notifications = LocalNotificationService();
  bool _isFreeTipsExpanded = false;
  List<FreeTipData> _freeTips = [];
  bool _isLoadingFreeTips = false;

  // Cache keys
  static const String _freeTipsCacheKey = 'home_free_tips';
  static const String _freeTipsTimestampKey = 'home_free_tips_timestamp';
  static const Duration _cacheDuration = Duration(hours: 12);

  // Track if we've shown the system dialog this session
  bool _hasShownSystemDialog = false;

  // User ID for notifications
  String get _userId {
    return 'user_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _initNotifications();
    _cache.init();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PredictionsProvider>().fetchAllPredictions();
      _updateUserActivity();
      
      // Check permission status after app loads
      _checkInitialNotificationStatus();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Track app lifecycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updateUserActivity();
      
      // When app resumes, check if we need to show reminder
      Future.delayed(const Duration(seconds: 1), () {
        _checkForScheduledReminder();
      });
    }
  }

  // Initialize notifications
  Future<void> _initNotifications() async {
    await _notifications.init();
  }

  // Check initial notification status (right after app starts)
  Future<void> _checkInitialNotificationStatus() async {
    final status = await Permission.notification.status;
    
    if (status.isGranted) {
      // Clear any reminders if user has granted
      await NotificationReminderService.clearReminders();
      print('✅ Notifications already granted');
    } 
    else if (status.isDenied) {
      // This is the first time or user denied before
      print('📝 Notification status: Denied');
      
      // Check if this is first time (no denial record)
      final prefs = await SharedPreferences.getInstance();
      final lastDenied = prefs.getInt('notification_last_denied');
      
      if (lastDenied == null) {
        // First time - show system dialog
        _requestSystemPermission();
      } else {
        // Not first time - just record and check for reminders
        await NotificationReminderService.recordDenial();
      }
    }
    else if (status.isPermanentlyDenied) {
      print('🔒 Notifications permanently denied');
    }
    
    // Check for scheduled reminders after a delay
    Future.delayed(const Duration(seconds: 2), () {
      _checkForScheduledReminder();
    });
  }

  // Request system permission (Google's dialog)
  Future<void> _requestSystemPermission() async {
    if (_hasShownSystemDialog) {
      print('📱 System dialog already shown this session');
      return;
    }
    
    _hasShownSystemDialog = true;
    print('📱 Requesting system permission...');
    final result = await Permission.notification.request();
    
    if (result.isGranted) {
      print('✅ User granted permission');
      await NotificationReminderService.clearReminders();
      _showSuccessMessage('Notifications enabled!');
    } else if (result.isDenied) {
      print('❌ User denied permission');
      await NotificationReminderService.recordDenial();
      
      if (mounted) {
        _showImmediateReminderDialog();
      }
    } else if (result.isPermanentlyDenied) {
      print('🔒 User permanently denied');
      _showPermanentlyDeniedDialog();
    }
  }

  // Show custom dialog immediately after denial
  Future<void> _showImmediateReminderDialog() async {
    final reminderCount = await NotificationReminderService.getReminderCount();
    
    await showDialog(
      context: context,
      barrierDismissible: false, // Can't dismiss by tapping outside
      builder: (context) => NotificationReminderDialog(
        reminderCount: reminderCount,
        onEnable: _handleEnableNotifications,
        onSettings: _openAppSettings,
        onDontRemind: _handleDontRemindAgain,
        onLater: () {
          print('📝 User selected Later');
        },
      ),
    );
    
    // Record that we showed this immediate reminder
    await NotificationReminderService.recordReminderShown();
  }

  // Check for scheduled reminders (4/10/30 days later)
  Future<void> _checkForScheduledReminder() async {
    // Don't show if already granted
    final status = await Permission.notification.status;
    if (status.isGranted) {
      await NotificationReminderService.clearReminders();
      return;
    }
    
    // Don't show if permanently denied
    if (status.isPermanentlyDenied) return;
    
    // Don't show if we're in the middle of something
    if (!mounted) return;
    
    // Check if we should show a scheduled reminder
    final shouldShow = await NotificationReminderService.shouldShowReminder();
    if (!shouldShow) return;
    
    // Get reminder count
    final reminderCount = await NotificationReminderService.getReminderCount();
    
    // Show the reminder dialog
    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => NotificationReminderDialog(
        reminderCount: reminderCount,
        onEnable: _handleEnableNotifications,
        onSettings: _openAppSettings,
        onDontRemind: _handleDontRemindAgain,
        onLater: () {
          print('📝 User selected Later from scheduled reminder');
        },
      ),
    );
    
    // Record that we showed this reminder
    await NotificationReminderService.recordReminderShown();
  }

  // Handle "Don't remind again"
  Future<void> _handleDontRemindAgain() async {
    await NotificationReminderService.setDontRemindAgain();
    _showInfoMessage('You can enable notifications anytime in settings');
  }

  // Handle when user clicks "Enable" in our dialog
  Future<void> _handleEnableNotifications() async {
  final status = await Permission.notification.status;
  
  if (status.isDenied) {
    if (_hasShownSystemDialog) {
      // Already showed system dialog, just record denial
      await NotificationReminderService.recordDenial();
      _showInfoMessage('You can enable notifications in settings');
    } else {
      _hasShownSystemDialog = true;
      final result = await Permission.notification.request();
      
      if (result.isGranted) {
        await NotificationReminderService.clearReminders();
        _showSuccessMessage('Notifications enabled!');
        final subscriptionProvider = context.read<SubscriptionProvider>();
        await _notifications.rescheduleForPremiumStatus(subscriptionProvider.isPremium);
      } else if (result.isDenied) {
        await NotificationReminderService.recordDenial();
        _showInfoMessage('You can enable notifications later in settings');
      } else if (result.isPermanentlyDenied) {
        _openAppSettings();
      }
    }
  } 
  else if (status.isPermanentlyDenied) {
    _openAppSettings();
  }
}

  // Open app settings
  Future<void> _openAppSettings() async {
    await openAppSettings();
  }

  // Show dialog for permanently denied
  void _showPermanentlyDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notifications Disabled'),
        content: const Text(
          'Allow notifications to be the first to know when new predictions drop!'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }

  // Show success message
  void _showSuccessMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ $message'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Show info message
  void _showInfoMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ℹ️ $message'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Update user activity for inactivity tracking
  Future<void> _updateUserActivity() async {
    final subscriptionProvider = context.read<SubscriptionProvider>();
    await _notifications.updateLastActive(_userId, subscriptionProvider.isPremium);
  }

  // Handle user upgrade
  Future<void> _handleUserUpgrade() async {
    final subscriptionProvider = context.read<SubscriptionProvider>();
    await _notifications.rescheduleForPremiumStatus(subscriptionProvider.isPremium);
  }

  Future<void> _saveTipsToCache() async {
    try {
      final tipsJson = _freeTips.map((tip) {
        return {
          'homeTeam': tip.homeTeam,
          'awayTeam': tip.awayTeam,
          'prediction': tip.prediction,
          'odds': tip.odds,
          'date': tip.date,
          'color': tip.color.value,
        };
      }).toList();
      
      await _cache.setCache(
        key: _freeTipsCacheKey,
        data: tipsJson,
      );
      
      await _cache.setCache(
        key: _freeTipsTimestampKey,
        data: DateTime.now().toIso8601String(),
      );
      
      print('✅ Home free tips cached (12h expiry)');
    } catch (e) {
      print('❌ Error caching home tips: $e');
    }
  }

  Future<List<FreeTipData>?> _loadTipsFromCache() async {
    try {
      final timestampStr = await _cache.getCache(
        key: _freeTipsTimestampKey,
        fromJson: (json) => json as String,
      );
      
      if (timestampStr == null) return null;
      
      final cachedTime = DateTime.parse(timestampStr);
      final age = DateTime.now().difference(cachedTime);
      
      if (age > _cacheDuration) {
        print('⏰ Home tips cache expired (${age.inHours}h old)');
        return null;
      }
      
      final cachedData = await _cache.getCache(
        key: _freeTipsCacheKey,
        fromJson: (jsonString) {
          final List<dynamic> jsonList = json.decode(jsonString);
          return jsonList.map((item) {
            return FreeTipData(
              homeTeam: item['homeTeam'],
              awayTeam: item['awayTeam'],
              prediction: item['prediction'],
              odds: item['odds'],
              date: item['date'],
              color: Color(item['color']),
            );
          }).toList();
        },
      );
      
      if (cachedData != null && cachedData.isNotEmpty) {
        print('📦 Using cached home tips (${age.inHours}h old)');
        return cachedData;
      }
    } catch (e) {
      print('❌ Error loading home tips from cache: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final predictionsProvider = context.watch<PredictionsProvider>();
    final subscriptionProvider = context.watch<SubscriptionProvider>();

    const double heroMax = 200;
    const double heroMin = 56;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _refreshData(predictionsProvider),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: HeroSliverDelegate(
                  maxExtent: heroMax,
                  minExtent: heroMin,
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    FreeTipsDropdown(
                      isExpanded: _isFreeTipsExpanded,
                      isLoading: _isLoadingFreeTips,
                      tips: _freeTips,
                      onToggle: _toggleFreeTips,
                      onNavigate: widget.onNavigate,
                      isPremium: subscriptionProvider.isPremium,
                      onUpgradeTap: _showUpgradeModal,
                    ),
                    const SizedBox(height: 24),
                    PredictionCategoriesSection(
                      provider: predictionsProvider,
                      onNavigate: widget.onNavigate,
                      isPremium: subscriptionProvider.isPremium,
                      onUpgradeTap: _showUpgradeModal,
                    ),
                    const SizedBox(height: 32),
                    const PerformanceSection(),
                    const SizedBox(height: 32),
                    const TrustSignalSection(),
                    const SizedBox(height: 32),
                    const ResponsibleGamblingFooter(),
                    const SizedBox(height: 32),
                    
                    // Optional: Add a small persistent reminder banner
                    if (!subscriptionProvider.isPremium) 
                      _buildGentleReminderBanner(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Optional: Add a small banner at the bottom for gentle reminder
  Widget _buildGentleReminderBanner() {
    return FutureBuilder<PermissionStatus>(
      future: Permission.notification.status,
      builder: (context, snapshot) {
        if (snapshot.hasData && !snapshot.data!.isGranted) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: GestureDetector(
              onTap: () => _checkForScheduledReminder(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.notifications_none, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '🔔 Enable Notifications',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade900,
                            ),
                          ),
                          Text(
                            'Get alerts for new free tips',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.blue.shade700),
                  ],
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _showUpgradeModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return const UpgradeModal();
      },
    ).then((_) {
      final subscriptionProvider = context.read<SubscriptionProvider>();
      if (subscriptionProvider.isPremium) {
        _handleUserUpgrade();
      }
    });
  }

  Future<void> _refreshData(PredictionsProvider provider) async {
    await provider.fetchAllPredictions();
    if (_isFreeTipsExpanded) {
      await _loadFreeTips(forceRefresh: false);
    }
    _updateUserActivity();
  }

  Future<void> _toggleFreeTips() async {
    if (!_isFreeTipsExpanded && _freeTips.isEmpty) {
      await _loadFreeTips();
    }
    setState(() => _isFreeTipsExpanded = !_isFreeTipsExpanded);
    _updateUserActivity();
  }

  Future<void> _loadFreeTips({bool forceRefresh = false}) async {
    setState(() {
      _isLoadingFreeTips = true;
      _freeTips.clear();
    });

    try {
      if (!forceRefresh) {
        final cachedTips = await _loadTipsFromCache();
        if (cachedTips != null) {
          setState(() {
            _freeTips = cachedTips;
            _isLoadingFreeTips = false;
          });
          
          final timestampStr = await _cache.getCache(
            key: _freeTipsTimestampKey,
            fromJson: (json) => json as String,
          );
          
          if (timestampStr != null) {
            final cachedTime = DateTime.parse(timestampStr);
            final age = DateTime.now().difference(cachedTime);
            if (age > const Duration(hours: 6)) {
              _refreshTipsInBackground();
            }
          }
          return;
        }
      }

      await _loadFreshTips();

    } catch (e) {
      print('Error loading free tips: $e');
      setState(() => _isLoadingFreeTips = false);
    }
  }

  Future<void> _loadFreshTips() async {
    try {
      print('🌐 Fetching fresh home tips (1 tip only)');
      
      final tipSources = [
        _loadMegaAccumulatorTip(),
        _loadBTTSTip(),
        _loadFeaturedLeagueTip(),
      ];
      
      tipSources.shuffle();
      
      FreeTipData? successfulTip;
      for (var source in tipSources) {
        try {
          successfulTip = await source;
          if (successfulTip != null) break;
        } catch (e) {
          continue;
        }
      }

      setState(() {
        _freeTips = successfulTip != null ? [successfulTip] : [];
        _isLoadingFreeTips = false;
      });

      if (_freeTips.isNotEmpty) {
        await _saveTipsToCache();
      }

    } catch (e) {
      print('Error loading fresh tips: $e');
      rethrow;
    }
  }

  Future<void> _refreshTipsInBackground() async {
    try {
      await _loadFreshTips();
      print('✅ Home tips refreshed in background');
    } catch (e) {
      print('❌ Background refresh failed: $e');
    }
  }

  Future<FreeTipData?> _loadMegaAccumulatorTip() async {
    try {
      final accumulator = await _apiService.getDailyAccumulators();
      if (accumulator.matches.isEmpty) return null;

      final match = accumulator.matches.first;
      return FreeTipData(
        homeTeam: _extractTeam(match.matchTitle, isHome: true),
        awayTeam: _extractTeam(match.matchTitle, isHome: false),
        prediction: match.prediction,
        odds: _formatOdds(accumulator.totalOdds),
        date: _formatDate(match.date),
        color: Colors.blue,
      );
    } catch (e) {
      return null;
    }
  }

  Future<FreeTipData?> _loadBTTSTip() async {
    try {
      final accumulator = await _apiService.getBTTSPredictions();
      if (accumulator?.matches.isEmpty ?? true) return null;

      final match = accumulator!.matches.first;
      return FreeTipData(
        homeTeam: _extractTeam(match.matchTitle, isHome: true),
        awayTeam: _extractTeam(match.matchTitle, isHome: false),
        prediction: match.prediction,
        odds: _formatOdds(accumulator.totalOdds),
        date: _formatDate(match.date),
        color: Colors.teal,
      );
    } catch (e) {
      return null;
    }
  }

  Future<FreeTipData?> _loadFeaturedLeagueTip() async {
    final featuredLeagues = [
      League(
        name: 'Premier League',
        country: 'England',
        icon: Icons.sports_soccer,
        color: const Color(0xFF8B5CF6),
        description: 'English Premier League',
        apiEndpoint: 'epl-matches',
      ),
      League(
        name: 'La Liga',
        country: 'Spain',
        icon: Icons.sports_soccer,
        color: const Color(0xFFEF4444),
        description: 'Spanish La Liga',
        apiEndpoint: 'laliga-matches',
      ),
      League(
        name: 'Serie A',
        country: 'Italy',
        icon: Icons.sports_soccer,
        color: const Color(0xFF3B82F6),
        description: 'Italian Serie A',
        apiEndpoint: 'serie-a-matches',
      ),
    ]..shuffle();

    for (var league in featuredLeagues) {
      try {
        final matches = await _apiService.getMatchPredictions(league.apiEndpoint);
        if (matches.isEmpty) continue;

        matches.shuffle();
        final match = matches.first;

        if (match.predictions.isEmpty) continue;

        return FreeTipData(
          homeTeam: match.homeTeam,
          awayTeam: match.awayTeam,
          prediction: match.predictions.first.prediction,
          odds: _formatOdds(match.predictions.first.odds),
          date: _formatDate(match.date),
          color: league.color,
        );
      } catch (e) {
        continue;
      }
    }
    return null;
  }

  String _extractTeam(String? matchTitle, {required bool isHome}) {
    if (matchTitle == null || matchTitle.isEmpty) {
      return isHome ? 'Team A' : 'Team B';
    }
    if (!matchTitle.contains(' vs ')) return matchTitle;

    final parts = matchTitle.split(' vs ');
    return isHome ? parts[0].trim() : (parts.length > 1 ? parts[1].trim() : 'Opponent');
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'TODAY';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      if (date.day == now.day && 
          date.month == now.month && 
          date.year == now.year) {
        return 'TODAY';
      }
      return '${date.day}.${date.month}';
    } catch (e) {
      return dateString;
    }
  }

  String _formatOdds(dynamic odds) {
    if (odds == null) return '1.00';
    if (odds is double) return odds.toStringAsFixed(2);
    if (odds is String) {
      try {
        return double.parse(odds.replaceAll(' Odds', '')).toStringAsFixed(2);
      } catch (e) {
        return odds;
      }
    }
    return odds.toString();
  }
}

// Data Model
class FreeTipData {
  final String homeTeam;
  final String awayTeam;
  final String prediction;
  final String odds;
  final String date;
  final Color color;

  FreeTipData({
    required this.homeTeam,
    required this.awayTeam,
    required this.prediction,
    required this.odds,
    required this.date,
    required this.color,
  });
}