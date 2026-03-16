// services/reviewer_access_service.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewerAccessService {
  static const String _keyGrantedAt = 'reviewer_access_granted_at';
  static const Duration _accessDuration = Duration(days: 365);

  /// Grants reviewer premium access, valid for 1 year from now.
  static Future<void> grantAccess() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toIso8601String();
    await prefs.setString(_keyGrantedAt, now);
    debugPrint('🔓 Reviewer access granted at $now');
  }

  /// Returns true if reviewer access was granted and has not yet expired.
  static Future<bool> hasActiveAccess() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyGrantedAt);
    if (raw == null) return false;

    try {
      final grantedAt = DateTime.parse(raw);
      final expiry = grantedAt.add(_accessDuration);
      final active = DateTime.now().isBefore(expiry);
      debugPrint('🔓 Reviewer access: grantedAt=$raw, expiry=$expiry, active=$active');
      return active;
    } catch (e) {
      debugPrint('⚠️ Reviewer access parse error: $e');
      return false;
    }
  }

  /// Revokes reviewer access (useful for testing).
  static Future<void> revokeAccess() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyGrantedAt);
    debugPrint('🔒 Reviewer access revoked');
  }

  /// Returns the expiry date string, or null if not active.
  static Future<DateTime?> getExpiry() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyGrantedAt);
    if (raw == null) return null;
    try {
      return DateTime.parse(raw).add(_accessDuration);
    } catch (_) {
      return null;
    }
  }
}