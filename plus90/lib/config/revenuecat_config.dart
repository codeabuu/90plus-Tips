// config/revenuecat_config.dart
class RevenueCatConfig {
  // Entitlement ID - Use your test entitlement ID
  static const String premiumEntitlementId = 'pro'; // or whatever your test entitlement is called
  
  // Product IDs - Use your test product IDs from RevenueCat dashboard
  static const Map<String, String> productIds = {
    'weekly': 'weekly_test',      // Your test weekly product ID
    'monthly': 'monthly_test',    // Your test monthly product ID
    'yearly': 'yearly_test',      // Your test yearly product ID 
    '3_months': '3_months_test',  // Your test 3 months product ID
  };
  
  // Offerings ID (optional - if you have multiple offerings)
  static const String offeringsId = 'default';
}