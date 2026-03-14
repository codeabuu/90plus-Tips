class RevenueCatConfig {

  // Must match your RevenueCat entitlement identifier
  static const String premiumEntitlementId = '90plus Pro';

  // Must match the Play Store product IDs
  static const Map<String, String> productIds = {
    'weekly': 'weekly_plans:weekly',
    'monthly': 'monthly:monthly-base',
    '3_months': '3months_plans:three-month-base',
    'yearly': 'yearly_plans:yearly-base',
  };

  // Must match the offering ID in RevenueCat (probably 'default')
  static const String offeringsId = 'default';
}