class RevenueCatConfig {
  // Entitlement ID - Use your existing entitlement ID
  static const String premiumEntitlementId = '90plus Pro';
  
  // Product IDs - Use your existing product IDs from RevenueCat dashboard
  static const Map<String, String> productIds = {
    'weekly': 'weekly_sub',    // Your weekly product ID
    'monthly': 'monthly_sub',    // Your monthly product ID
    'yearly': 'yearly_sub',     // Your yearly product ID 
    '3 months': '3_months',     // Your 3 months product ID
  };
  
  // Offerings ID (optional - if you have multiple offerings)
  static const String offeringsId = 'default';
}