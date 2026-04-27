// services/notification_toggle_service.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationToggleService {
  // Check if notifications are enabled
  static Future<bool> isNotificationEnabled() async {
    final status = await Permission.notification.status;
    return status.isGranted;
  }

  // Always open app settings (for both turning ON or OFF)
  static Future<void> openNotificationSettings(BuildContext context) async {
    final status = await Permission.notification.status;
    
    if (status.isDenied && !status.isPermanentlyDenied) {
      // If not permanently denied, we can request once more
      final result = await Permission.notification.request();
      
      if (result.isGranted) {
        
        return;
      }
    }
    
    // For all other cases (already granted, permanently denied, or user denied again)
    // Just open app settings
    _showSettingsDialog(context);
  }

  static void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings'),
        content: const Text(
          'You can manage notifications in your device settings.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}