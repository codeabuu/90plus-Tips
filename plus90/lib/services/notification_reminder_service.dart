import 'package:shared_preferences/shared_preferences.dart';

class NotificationReminderService {
  static const String _lastDeniedKey = 'notification_last_denied';
  static const String _reminderCountKey = 'notification_reminder_count';
  static const String _dontRemindAgainKey = 'notification_dont_remind';
  
  // Record that user denied
  static Future<void> recordDenial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastDeniedKey, DateTime.now().millisecondsSinceEpoch);
    print('📝 Recorded denial at ${DateTime.now()}');
  }
  
  // Check if we should show a scheduled reminder (4/10/30 days)
  static Future<bool> shouldShowReminder() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if user said "don't remind again"
    final dontRemind = prefs.getBool(_dontRemindAgainKey) ?? false;
    if (dontRemind) {
      print('🚫 User selected "Don\'t remind again"');
      return false;
    }
    
    // Get last denied timestamp
    final lastDenied = prefs.getInt(_lastDeniedKey);
    if (lastDenied == null) {
      print('📝 No denial record found');
      return false;
    }
    
    // Calculate days since last denial
    final now = DateTime.now().millisecondsSinceEpoch;
    final daysSinceDenied = (now - lastDenied) / (24 * 60 * 60 * 1000);
    
    // Get reminder count
    final reminderCount = prefs.getInt(_reminderCountKey) ?? 0;
    
    // Don't show if we've already shown 3 reminders
    if (reminderCount >= 3) {
      print('✅ Already shown 3 reminders, stopping');
      return false;
    }
    
    // Schedule: 4 days, 10 days, 30 days
    final requiredDays = [4, 10, 30][reminderCount];
    final shouldShow = daysSinceDenied >= requiredDays;
    
    print('📊 Days since denial: ${daysSinceDenied.toStringAsFixed(1)}');
    print('📊 Required days: $requiredDays');
    print('📊 Should show: $shouldShow');
    
    return shouldShow;
  }
  
  // Record that we showed a reminder
  static Future<void> recordReminderShown() async {
    final prefs = await SharedPreferences.getInstance();
    final currentCount = prefs.getInt(_reminderCountKey) ?? 0;
    await prefs.setInt(_reminderCountKey, currentCount + 1);
    print('🔔 Recorded reminder #${currentCount + 1}');
  }
  
  // User said "don't remind again"
  static Future<void> setDontRemindAgain() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dontRemindAgainKey, true);
    print('🚫 Don\'t remind again set');
  }
  
  // Clear all reminders (when user finally allows)
  static Future<void> clearReminders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastDeniedKey);
    await prefs.remove(_reminderCountKey);
    await prefs.remove(_dontRemindAgainKey);
    print('🗑️ Cleared all reminders');
  }
  
  // Get reminder count
  static Future<int> getReminderCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_reminderCountKey) ?? 0;
  }
}