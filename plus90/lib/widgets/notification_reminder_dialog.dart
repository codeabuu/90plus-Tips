import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationReminderDialog extends StatelessWidget {
  final int reminderCount;
  final VoidCallback? onEnable;
  final VoidCallback? onSettings;
  final VoidCallback? onDontRemind;
  final VoidCallback? onLater;

  const NotificationReminderDialog({
    Key? key,
    required this.reminderCount,
    this.onEnable,
    this.onSettings,
    this.onDontRemind,
    this.onLater,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Different messages based on reminder count
    String title = "🔔 Don't Miss Out!";
    String message = "Get notified when new free predictions are available. "
        "Be the first to know about winning tips!";
    
    if (reminderCount == 0) {
      message = "Would you like to get instant alerts for new predictions? "
          "We'll notify you when new tips are available.";
    } else if (reminderCount == 1) {
      message = "We noticed you've been enjoying our tips! "
          "Turn on notifications to get instant alerts for new predictions.";
    } else if (reminderCount == 2) {
      title = "⚽ Last Chance for Alerts!";
      message = "You're missing out on timely predictions. "
          "Enable notifications to stay ahead of the game!";
    }

    return AlertDialog(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_active,
              size: 48,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14),
          ),
          if (reminderCount >= 1) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.timer, color: Colors.amber.shade800, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Free tips refresh every 12 hours. Get notified instantly!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (reminderCount >= 1) // Only show "Don't remind" after first reminder
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onDontRemind != null) onDontRemind!();
            },
            child: Text(
              "Don't remind again",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            if (onLater != null) onLater!();
          },
          child: Text(
            'Later',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
        // Use FutureBuilder to get the status for the button text
        FutureBuilder<PermissionStatus>(
          future: Permission.notification.status,
          builder: (context, snapshot) {
            final isPermanentlyDenied = snapshot.hasData && snapshot.data!.isPermanentlyDenied;
            
            return ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                
                // Check if permanently denied
                final status = await Permission.notification.status;
                if (status.isPermanentlyDenied) {
                  if (onSettings != null) onSettings!();
                } else {
                  if (onEnable != null) onEnable!();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                isPermanentlyDenied ? 'Open Settings' : 'Enable Notifications',
              ),
            );
          },
        ),
      ],
    );
  }
}