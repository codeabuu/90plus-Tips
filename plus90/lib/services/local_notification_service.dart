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
      
      // Request exact alarm permission for Android 12+
      await _requestExactAlarmPermission();

      // Schedule all notifications
      await _scheduleAllNotifications();
      
      // COMMENTED OUT: Test methods
      // await _runNotificationTests();
      
      _isInitialized = true;
      print('✅ LocalNotificationService initialized successfully');
    } catch (e) {
      print('❌ Error initializing LocalNotificationService: $e');
    }
  }
  
  // COMMENTED OUT: All test methods below
  /*
  Future<void> _runNotificationTests() async {
    print('🧪 ===== RUNNING NOTIFICATION TESTS =====');
    
    // Test 1: Immediate notification
    await _testImmediateNotification();
    
    // Test 2: Schedule for 1 minute from now
    await _testScheduledNotification();
    
    // Test 3: Check all pending notifications
    await _checkPendingNotifications();
    
    print('🧪 ===== TESTS COMPLETE =====');
  }

  // 🔴 Test 1: Immediate notification
  Future<void> _testImmediateNotification() async {
    print('🧪 Test 1: Sending immediate notification...');
    
    try {
      await _notifications.show(
        id: 999991,
        title: '🔔 TEST: Immediate',
        body: 'This notification should appear NOW!',
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'test_channel',
            'Test Channel',
            channelDescription: 'For testing notifications',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            sound: 'default',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: 'test_immediate',
      );
      print('✅ Test 1: Immediate notification sent');
    } catch (e) {
      print('❌ Test 1 failed: $e');
    }
  }

  // 🔴 Test 2: Scheduled notification (1 minute)
  Future<void> _testScheduledNotification() async {
    final testTime = DateTime.now().add(const Duration(minutes: 1));
    print('🧪 Test 2: Scheduling notification for: $testTime');
    
    try {
      final ukLocation = tz.getLocation('Europe/London');
      final tzTestTime = tz.TZDateTime(
        ukLocation,
        testTime.year, testTime.month, testTime.day,
        testTime.hour, testTime.minute,
      );

      await _notifications.zonedSchedule(
        id: 999992,
        title: '⏰ TEST: 1 Minute',
        body: 'This should appear 1 minute after scheduling',
        scheduledDate: tzTestTime,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'test_channel',
            'Test Channel',
            channelDescription: 'For testing notifications',
            importance: Importance.high,
            priority: Priority.high,
            enableVibration: true,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            sound: 'default',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'test_scheduled',
      );
      print('✅ Test 2: Scheduled notification set for ${testTime.toString()}');
    } catch (e) {
      print('❌ Test 2 failed: $e');
    }
  }

  // 🔴 Test 3: Check pending notifications
  Future<void> _checkPendingNotifications() async {
    print('🧪 Test 3: Checking pending notifications...');

    try {
      final pending = await _notifications.pendingNotificationRequests();

      if (pending.isEmpty) {
        print('📭 No pending notifications');
        return;
      }

      print('📋 Total pending: ${pending.length}');

      for (var notification in pending) {
        print('  - ID: ${notification.id}');
        print('    Title: ${notification.title}');
        print('    Body: ${notification.body}');
        print('    Payload: ${notification.payload}');
      }
    } catch (e) {
      print('⚠️ Pending notification check skipped: $e');
    }
  }
  */

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
  
  // Request exact alarm permission for Android 12+
  Future<void> _requestExactAlarmPermission() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestExactAlarmsPermission();

      if (granted == true) {
        print('✅ Exact alarm permission GRANTED');
      } else {
        print('❌ Exact alarm permission DENIED');
      }
    } else {
      print('⚠️ Android plugin not available');
    }
  }

  void _handleNotificationTap(String? payload) {
    print('Notification tapped with payload: $payload');
  }
  
  Future<void> _scheduleAllNotifications() async {
    final today = DateTime.now();
    final uk = tz.getLocation('Europe/London');

    // ============================================
    // PREMIUM WINS (Daily 9:30am)
    // ============================================
    for (int i = 0; i < 7; i++) {
      final date = today.add(Duration(days: i));
      final scheduleTime = tz.TZDateTime(
        uk,
        date.year,
        date.month,
        date.day,
        9,
        30,
      );

      if (scheduleTime.isAfter(tz.TZDateTime.now(uk))) {
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
    // MORNING PREDICTIONS (Weekdays 11am)
    // ============================================
    for (int i = 0; i < 7; i++) {
      final date = today.add(Duration(days: i));

      // Skip weekends
      if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
        continue;
      }

      final scheduleTime = tz.TZDateTime(
        uk,
        date.year,
        date.month,
        date.day,
        11,
        0,
      );

      if (scheduleTime.isAfter(tz.TZDateTime.now(uk))) {
        await _scheduleNotification(
          id: _getNotificationId('morning', date),
          title: '⚽ Morning Predictions',
          body: 'Today\'s predictions are ready! 100+ matches analyzed across all leagues.',
          scheduledTime: scheduleTime,
          payload: 'morning_predictions',
        );
      }
    }

    // ============================================
    // EVENING MATCHES (Weekdays 4pm)
    // ============================================
    for (int i = 0; i < 7; i++) {
      final date = today.add(Duration(days: i));

      if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
        continue;
      }

      final scheduleTime = tz.TZDateTime(
        uk,
        date.year,
        date.month,
        date.day,
        16,
        0,
      );

      if (scheduleTime.isAfter(tz.TZDateTime.now(uk))) {
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
    // FRIDAY NOTIFICATIONS
    // ============================================
    for (int i = 0; i < 7; i++) {
      final date = today.add(Duration(days: i));

      if (date.weekday == DateTime.friday) {
        // Friday morning (10:00 AM)
        final morningTime = tz.TZDateTime(
          uk,
          date.year,
          date.month,
          date.day,
          10,
          0,
        );

        if (morningTime.isAfter(tz.TZDateTime.now(uk))) {
          await _scheduleNotification(
            id: _getNotificationId('friday_morning', date),
            title: '🔮 Weekend Preview',
            body: 'Big weekend ahead! Saturday & Sunday\'s biggest matches previewed.',
            scheduledTime: morningTime,
            payload: 'weekend_preview',
          );
        }

        // Friday afternoon (3:00 PM)
        final afternoonTime = tz.TZDateTime(
          uk,
          date.year,
          date.month,
          date.day,
          15,
          0,
        );

        if (afternoonTime.isAfter(tz.TZDateTime.now(uk))) {
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
        final morningTime = tz.TZDateTime(
          uk,
          date.year,
          date.month,
          date.day,
          10,
          30,
        );

        if (morningTime.isAfter(tz.TZDateTime.now(uk))) {
          await _scheduleNotification(
            id: _getNotificationId('saturday_morning', date),
            title: '⚡ Super Saturday',
            body: 'Big day of football! Get your predictions ready.',
            scheduledTime: morningTime,
            payload: 'saturday_morning',
          );
        }

        // Saturday afternoon (2:30 PM)
        final afternoonTime = tz.TZDateTime(
          uk,
          date.year,
          date.month,
          date.day,
          14,
          30,
        );

        if (afternoonTime.isAfter(tz.TZDateTime.now(uk))) {
          await _scheduleNotification(
            id: _getNotificationId('saturday_afternoon', date),
            title: '🏆 Afternoon Action',
            body: 'Matches underway! Check correct score predictions.',
            scheduledTime: afternoonTime,
            payload: 'saturday_afternoon',
          );
        }

        // Saturday night (10:00 PM)
        final nightTime = tz.TZDateTime(
          uk,
          date.year,
          date.month,
          date.day,
          22,
          0,
        );

        if (nightTime.isAfter(tz.TZDateTime.now(uk))) {
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
        final morningTime = tz.TZDateTime(
          uk,
          date.year,
          date.month,
          date.day,
          10,
          30,
        );

        if (morningTime.isAfter(tz.TZDateTime.now(uk))) {
          await _scheduleNotification(
            id: _getNotificationId('sunday_morning', date),
            title: '☀️ Sunday Football',
            body: 'Super Sunday ahead! Tips ready.',
            scheduledTime: morningTime,
            payload: 'sunday_morning',
          );
        }

        // Sunday afternoon (3:30 PM)
        final afternoonTime = tz.TZDateTime(
          uk,
          date.year,
          date.month,
          date.day,
          15,
          30,
        );

        if (afternoonTime.isAfter(tz.TZDateTime.now(uk))) {
          await _scheduleNotification(
            id: _getNotificationId('sunday_afternoon', date),
            title: '🔥 Main Event',
            body: 'Big match approaching! Goal scorer tips.',
            scheduledTime: afternoonTime,
            payload: 'sunday_afternoon',
          );
        }

        // Sunday evening (8:00 PM)
        final eveningTime = tz.TZDateTime(
          uk,
          date.year,
          date.month,
          date.day,
          20,
          0,
        );

        if (eveningTime.isAfter(tz.TZDateTime.now(uk))) {
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
    // WEEKEND MULTI COMBO (Saturday & Sunday 9:30am)
    // ============================================
    for (int i = 0; i < 14; i++) {
      final date = today.add(Duration(days: i));

      if (date.weekday == DateTime.saturday) {
        final comboTime = tz.TZDateTime(
          uk,
          date.year,
          date.month,
          date.day,
          9,
          30,
        );

        if (comboTime.isAfter(tz.TZDateTime.now(uk))) {
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
        final comboTime = tz.TZDateTime(
          uk,
          date.year,
          date.month,
          date.day,
          9,
          30,
        );

        if (comboTime.isAfter(tz.TZDateTime.now(uk))) {
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
    required tz.TZDateTime scheduledTime,
    String? payload,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationKey = 'scheduled_$id';

    // Skip if already scheduled
    if (prefs.getBool(notificationKey) == true) {
      print('⏭️ Notification $id already scheduled, skipping');
      return;
    }

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
      scheduledDate: scheduledTime,
      notificationDetails: platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
    
    // Mark as scheduled
    await prefs.setBool(notificationKey, true);
    print('✅ Notification $id scheduled for ${scheduledTime.toString()} UK time');
  }

  int _getNotificationId(String type, DateTime date) {
    // Safe: type_code * 100000 + dayOfYear * 100 + yearShort
    // Max value ~7,243,299 — well within Android int32 limit of 2,147,483,647
    final dayOfYear = int.parse(DateFormat('D').format(date));
    final yearShort = int.parse(DateFormat('yy').format(date));
    final suffix = dayOfYear * 100 + yearShort;

    switch (type) {
      case 'premium':            return 10 * 100000 + suffix;
      case 'morning':            return 20 * 100000 + suffix;
      case 'evening':            return 30 * 100000 + suffix;
      case 'friday_morning':     return 41 * 100000 + suffix;
      case 'friday_afternoon':   return 42 * 100000 + suffix;
      case 'saturday_morning':   return 51 * 100000 + suffix;
      case 'saturday_afternoon': return 52 * 100000 + suffix;
      case 'saturday_night':     return 53 * 100000 + suffix;
      case 'sunday_morning':     return 61 * 100000 + suffix;
      case 'sunday_afternoon':   return 62 * 100000 + suffix;
      case 'sunday_evening':     return 63 * 100000 + suffix;
      case 'weekend_combo_sat':  return 71 * 100000 + suffix;
      case 'weekend_combo_sun':  return 72 * 100000 + suffix;
      default:                   return 90 * 100000 + suffix;
    }
  }

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

  Future<void> updateLastActive(String userId, bool isPremium) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      'last_active_$userId',
      DateTime.now().millisecondsSinceEpoch,
    );
    await checkInactivity(userId, isPremium);
  }

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
      print('👑 Premium user - notifications rescheduled');
    }
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
    final prefs = await SharedPreferences.getInstance();
    final keys =
        prefs.getKeys().where((key) => key.startsWith('scheduled_'));
    for (var key in keys) {
      await prefs.remove(key);
    }
  }

  Future<void> cancelById(int id) async {
    await _notifications.cancel(id: id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('scheduled_$id');
  }
}