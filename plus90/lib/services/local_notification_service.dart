// services/local_notification_service.dart
// Compatible with flutter_local_notifications ^20.0.0
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> init() async {
    if (_isInitialized) {
      print('✅ Notifications already initialized');
      return;
    }

    try {
      // Android setup
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS setup
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          _handleNotificationTap(response.payload);
        },
      );

      // Initialize timezone database
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Europe/London'));

      // Request permissions
      await _requestPermissions();

      // Schedule all notifications
      await _scheduleAllNotifications();
      
      _isInitialized = true;
      print('✅ LocalNotificationService initialized successfully');
    } catch (e) {
      print('❌ Error initializing LocalNotificationService: $e');
      // Don't rethrow - catch and handle gracefully
    }
  }

  Future<void> _requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    final iosPlugin = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _handleNotificationTap(String? payload) {
    print('Notification tapped with payload: $payload');
    // Navigate based on payload using a global navigator key or event bus
  }

  Future<void> _scheduleAllNotifications() async {
    final today = DateTime.now();

    // ============================================
    // DAILY NOTIFICATIONS (Every day)
    // ============================================
    
    // Premium win notifications (daily 9:30am)
    for (int i = 0; i < 7; i++) {
      final date = today.add(Duration(days: i));
      final scheduleTime = DateTime(date.year, date.month, date.day, 9, 30);

      if (scheduleTime.isAfter(DateTime.now())) {
        await _scheduleNotification(
          id: _getNotificationId('premium', date),
          title: '🏆 Premium Wins',
          body: 'Yesterday\'s premium picks won! Upgrade now to access today\'s winning predictions.',
          scheduledTime: scheduleTime,
          payload: 'premium_win',
        );
      }
    }

    // ============================================
    // WEEKDAY NOTIFICATIONS (Monday - Thursday)
    // ============================================
    
    // Morning Predictions (Weekdays 11am) - Original
    for (int i = 0; i < 7; i++) {
      final date = today.add(Duration(days: i));

      if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
        continue;
      }

      final scheduleTime = DateTime(date.year, date.month, date.day, 11, 0);
      if (scheduleTime.isAfter(DateTime.now())) {
        await _scheduleNotification(
          id: _getNotificationId('morning', date),
          title: '⚽ Morning Predictions',
          body: 'Today\'s predictions are ready! 100+ matches analyzed across all leagues.',
          scheduledTime: scheduleTime,
          payload: 'morning_predictions',
        );
      }
    }

    // Evening Matches (Weekdays 4pm) - Original
    for (int i = 0; i < 7; i++) {
      final date = today.add(Duration(days: i));

      if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
        continue;
      }

      final scheduleTime = DateTime(date.year, date.month, date.day, 16, 0);
      if (scheduleTime.isAfter(DateTime.now())) {
        await _scheduleNotification(
          id: _getNotificationId('evening', date),
          title: '🌙 Evening Matches',
          body: 'Evening matches are live! Check today\'s remaining fixtures before kickoff.',
          scheduledTime: scheduleTime,
          payload: 'evening_matches',
        );
      }
    }

    // ============================================
    // FRIDAY NOTIFICATIONS (Weekend Build-up)
    // ============================================
    
    for (int i = 0; i < 7; i++) {
      final date = today.add(Duration(days: i));

      if (date.weekday == DateTime.friday) {
        // Friday morning (10:00 AM) - Weekend Preview
        final morningTime = DateTime(date.year, date.month, date.day, 10, 0);
        if (morningTime.isAfter(DateTime.now())) {
          await _scheduleNotification(
            id: _getNotificationId('friday_morning', date),
            title: '🔮 Weekend Preview',
            body: 'Big weekend ahead! Saturday & Sunday\'s biggest matches previewed.',
            scheduledTime: morningTime,
            payload: 'weekend_preview',
          );
        }

        // Friday afternoon (3:00 PM) - Friday Night Football
        final afternoonTime = DateTime(date.year, date.month, date.day, 15, 0);
        if (afternoonTime.isAfter(DateTime.now())) {
          await _scheduleNotification(
            id: _getNotificationId('friday_afternoon', date),
            title: '🌙 Friday Night Football',
            body: 'Tonight\'s action: Championship football predictions ready!',
            scheduledTime: afternoonTime,
            payload: 'friday_night_football',
          );
        }
      }
    }

    // ============================================
    // SATURDAY NOTIFICATIONS
    // ============================================
    
    for (int i = 0; i < 14; i++) {
      final date = today.add(Duration(days: i));

      if (date.weekday == DateTime.saturday) {
        // Saturday morning (10:30 AM)
        final morningTime = DateTime(date.year, date.month, date.day, 10, 30);
        if (morningTime.isAfter(DateTime.now())) {
          await _scheduleNotification(
            id: _getNotificationId('saturday_morning', date),
            title: '⚡ Super Saturday',
            body: 'Big day of football! Get your predictions ready.',
            scheduledTime: morningTime,
            payload: 'saturday_morning',
          );
        }

        // Saturday afternoon (2:30 PM)
        final afternoonTime = DateTime(date.year, date.month, date.day, 14, 30);
        if (afternoonTime.isAfter(DateTime.now())) {
          await _scheduleNotification(
            id: _getNotificationId('saturday_afternoon', date),
            title: '🏆 Afternoon Action',
            body: 'Matches underway! Check correct score predictions.',
            scheduledTime: afternoonTime,
            payload: 'saturday_afternoon',
          );
        }

        // Saturday night (10:00 PM)
        final nightTime = DateTime(date.year, date.month, date.day, 22, 0);
        if (nightTime.isAfter(DateTime.now())) {
          await _scheduleNotification(
            id: _getNotificationId('saturday_night', date),
            title: '📝 Saturday Round-up',
            body: 'Today\'s results and early Sunday tips.',
            scheduledTime: nightTime,
            payload: 'saturday_night',
          );
        }
      }
    }

    // ============================================
    // SUNDAY NOTIFICATIONS
    // ============================================
    
    for (int i = 0; i < 14; i++) {
      final date = today.add(Duration(days: i));

      if (date.weekday == DateTime.sunday) {
        // Sunday morning (10:30 AM)
        final morningTime = DateTime(date.year, date.month, date.day, 10, 30);
        if (morningTime.isAfter(DateTime.now())) {
          await _scheduleNotification(
            id: _getNotificationId('sunday_morning', date),
            title: '☀️ Sunday Football',
            body: 'Super Sunday ahead! Tips ready.',
            scheduledTime: morningTime,
            payload: 'sunday_morning',
          );
        }

        // Sunday afternoon (3:30 PM)
        final afternoonTime = DateTime(date.year, date.month, date.day, 15, 30);
        if (afternoonTime.isAfter(DateTime.now())) {
          await _scheduleNotification(
            id: _getNotificationId('sunday_afternoon', date),
            title: '🔥 Main Event',
            body: 'Big match approaching! Goal scorer tips.',
            scheduledTime: afternoonTime,
            payload: 'sunday_afternoon',
          );
        }

        // Sunday evening (8:00 PM)
        final eveningTime = DateTime(date.year, date.month, date.day, 20, 0);
        if (eveningTime.isAfter(DateTime.now())) {
          await _scheduleNotification(
            id: _getNotificationId('sunday_evening', date),
            title: '🔜 Monday Football',
            body: 'Preview tomorrow\'s action.',
            scheduledTime: eveningTime,
            payload: 'monday_preview',
          );
        }
      }
    }

    // ============================================
    // WEEKEND MULTI COMBO
    // ============================================
    
    for (int i = 0; i < 14; i++) {
      final date = today.add(Duration(days: i));

      if (date.weekday == DateTime.saturday) {
        final comboTime = DateTime(date.year, date.month, date.day, 9, 30);
        if (comboTime.isAfter(DateTime.now())) {
          await _scheduleNotification(
            id: _getNotificationId('weekend_combo_sat', date),
            title: '🎯 Saturday Multi Combo',
            body: 'Saturday multi-combo ready!',
            scheduledTime: comboTime,
            payload: 'weekend_combo',
          );
        }
      }

      if (date.weekday == DateTime.sunday) {
        final comboTime = DateTime(date.year, date.month, date.day, 9, 30);
        if (comboTime.isAfter(DateTime.now())) {
          await _scheduleNotification(
            id: _getNotificationId('weekend_combo_sun', date),
            title: '🎯 Sunday Multi Combo',
            body: 'Sunday multi-combo ready!',
            scheduledTime: comboTime,
            payload: 'weekend_combo',
          );
        }
      }
    }
  }

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationKey = 'scheduled_$id';

    // Skip if already scheduled
    if (prefs.getBool(notificationKey) == true) {
      print('⏭️ Notification $id already scheduled, skipping');
      return;
    }

    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'predictions_channel',
      'Predictions',
      channelDescription: 'Daily football predictions',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tzScheduledTime,
      notificationDetails: platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
    
    // Mark as scheduled
    await prefs.setBool(notificationKey, true);
    print('✅ Notification $id scheduled for ${scheduledTime.toString()}');
  }

  int _getNotificationId(String type, DateTime date) {
    final dateStr = DateFormat('yyyyMMdd').format(date);
    switch (type) {
      // Daily
      case 'premium':
        return int.parse('1$dateStr');
      
      // Weekday originals
      case 'morning':
        return int.parse('2$dateStr');
      case 'evening':
        return int.parse('3$dateStr');
      
      // Friday
      case 'friday_morning':
        return int.parse('41$dateStr');
      case 'friday_afternoon':
        return int.parse('42$dateStr');
      
      // Saturday
      case 'saturday_morning':
        return int.parse('51$dateStr');
      case 'saturday_afternoon':
        return int.parse('52$dateStr');
      case 'saturday_night':
        return int.parse('53$dateStr');
      
      // Sunday
      case 'sunday_morning':
        return int.parse('61$dateStr');
      case 'sunday_afternoon':
        return int.parse('62$dateStr');
      case 'sunday_evening':
        return int.parse('63$dateStr');
      
      // Weekend combos
      case 'weekend_combo_sat':
        return int.parse('71$dateStr');
      case 'weekend_combo_sun':
        return int.parse('72$dateStr');
      
      default:
        return int.parse('9$dateStr');
    }
  }

  // Check inactivity and notify (only for free users)
  Future<void> checkInactivity(String userId, bool isPremium) async {
    if (isPremium) return;

    final prefs = await SharedPreferences.getInstance();
    final lastActive = DateTime.fromMillisecondsSinceEpoch(
      prefs.getInt('last_active_$userId') ??
          DateTime.now().millisecondsSinceEpoch,
    );

    final daysInactive = DateTime.now().difference(lastActive).inDays;

    if (daysInactive >= 3) {
      final lastNotified = DateTime.fromMillisecondsSinceEpoch(
        prefs.getInt('inactive_notified_$userId') ?? 0,
      );

      if (DateTime.now().difference(lastNotified).inDays >= 3) {
        await _notifications.show(
          id: 999,
          title: '⏰ Missed Us?',
          body: 'New predictions available! Check today\'s matches before kickoff.',
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'inactive_channel',
              'Re-engagement',
              channelDescription: 'Re-engagement notifications',
              importance: Importance.high,
              priority: Priority.high,
            ),
            iOS: DarwinNotificationDetails(),
          ),
          payload: 'inactive_user',
        );

        await prefs.setInt(
          'inactive_notified_$userId',
          DateTime.now().millisecondsSinceEpoch,
        );
      }
    }
  }

  // Update last active timestamp
  Future<void> updateLastActive(String userId, bool isPremium) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      'last_active_$userId',
      DateTime.now().millisecondsSinceEpoch,
    );
    await checkInactivity(userId, isPremium);
  }

  // Reschedule notifications when premium status changes
  Future<void> rescheduleForPremiumStatus(bool isPremium) async {
    await _notifications.cancelAll();

    final prefs = await SharedPreferences.getInstance();
    final keys =
        prefs.getKeys().where((key) => key.startsWith('scheduled_'));
    for (var key in keys) {
      await prefs.remove(key);
    }

    await _scheduleAllNotifications();

    if (isPremium) {
      print('👑 Premium user - notifications will show premium content');
    }
  }

  // Cancel all notifications and clear stored flags
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
    final prefs = await SharedPreferences.getInstance();
    final keys =
        prefs.getKeys().where((key) => key.startsWith('scheduled_'));
    for (var key in keys) {
      await prefs.remove(key);
    }
  }

  // Cancel a single notification by id
  Future<void> cancelById(int id) async {
    await _notifications.cancel(id: id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('scheduled_$id');
  }
}