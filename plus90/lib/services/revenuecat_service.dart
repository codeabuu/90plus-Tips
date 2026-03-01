// services/revenuecat_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import '../config/revenuecat_config.dart';

class RevenueCatService {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Stream controllers
  final _customerInfoController = StreamController<CustomerInfo>.broadcast();
  final _premiumStatusController = StreamController<bool>.broadcast();
  final _packagesController = StreamController<List<Package>>.broadcast();

  // Stream getters
  Stream<CustomerInfo> get customerInfoStream => _customerInfoController.stream;
  Stream<bool> get premiumStatusStream => _premiumStatusController.stream;
  Stream<List<Package>> get packagesStream => _packagesController.stream;

  // Current state
  CustomerInfo? _currentCustomerInfo;
  bool _isPremium = false;
  List<Package> _availablePackages = [];

  // Getters
  CustomerInfo? get currentCustomerInfo => _currentCustomerInfo;
  bool get isPremium => _isPremium;
  List<Package> get availablePackages => _availablePackages;

  // ✅ Get app_user_id for webhook reference
  Future<String> getAppUserId() async {
    if (_currentCustomerInfo != null) {
      return _currentCustomerInfo!.originalAppUserId;
    }
    
    final customerInfo = await Purchases.getCustomerInfo();
    return customerInfo.originalAppUserId;
  }

  // Initialize RevenueCat with test API key
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await dotenv.load(fileName: kIsWeb ? 'assets/.env' : '.env');
      
      // Get API key from .env
      final apiKey = dotenv.get('REVENUECAT_API_KEY');
      
      debugPrint('📱 Initializing RevenueCat with test key...');
      
      // Configure with the same key for all platforms in test mode
      await Purchases.setup(apiKey);
      
      // Enable debug logs in test mode
      Purchases.setLogLevel(LogLevel.debug);

      // Set user attributes for testing
      await Purchases.setAttributes({
        'test_mode': 'true',
        'platform': defaultTargetPlatform.toString(),
      });

      // Get initial customer info
      final initialCustomerInfo = await Purchases.getCustomerInfo();
      debugPrint('📱 RevenueCat initialized. App User ID: ${initialCustomerInfo.originalAppUserId}');
      debugPrint('🔧 Running in TEST MODE - No real charges will be made');

      // Listen for customer info updates
      Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);

      // Fetch initial customer info
      await fetchCustomerInfo();

      // Fetch available packages
      await fetchPackages();

      _isInitialized = true;
      debugPrint('✅ RevenueCat initialized successfully in TEST MODE');
    } catch (e) {
      debugPrint('❌ Error initializing RevenueCat: $e');
      rethrow;
    }
  }

  // Fetch customer info from RevenueCat
  Future<CustomerInfo> fetchCustomerInfo() async {
    try {
      _currentCustomerInfo = await Purchases.getCustomerInfo();
      _updatePremiumStatus(_currentCustomerInfo!);
      _customerInfoController.add(_currentCustomerInfo!);
      
      debugPrint('🔄 Customer info updated in test mode');
      
      return _currentCustomerInfo!;
    } catch (e) {
      debugPrint('Error fetching customer info: $e');
      rethrow;
    }
  }

  // Fetch available packages/offerings
  Future<List<Package>> fetchPackages() async {
    try {
      final offerings = await Purchases.getOfferings();
      
      // Use your configured offerings ID or default to current
      final offering = offerings.getOffering(RevenueCatConfig.offeringsId) ?? 
                      offerings.current;
      
      if (offering != null) {
        _availablePackages = offering.availablePackages;
        _packagesController.add(_availablePackages);
        debugPrint('📦 Found ${_availablePackages.length} packages in test mode');
        
        // Log package details for debugging
        for (var package in _availablePackages) {
          debugPrint('  - ${package.identifier}: ${package.storeProduct.priceString}');
        }
      } else {
        debugPrint('⚠️ No offerings found in test mode');
      }
      
      return _availablePackages;
    } catch (e) {
      debugPrint('Error fetching packages: $e');
      return [];
    }
  }

  // Purchase a package
  Future<CustomPurchaseResult> purchasePackage(Package package) async {
    try {
      debugPrint('🛒 Attempting to purchase: ${package.identifier} in TEST MODE');
      
      final purchaserInfo = await Purchases.purchasePackage(package);
      _currentCustomerInfo = purchaserInfo.customerInfo;
      _updatePremiumStatus(_currentCustomerInfo!);
      
      final appUserId = _currentCustomerInfo!.originalAppUserId;
      debugPrint('🎯 Test purchase successful! App User ID: $appUserId');
      debugPrint('🧪 Remember: This is a TEST purchase - no real charge occurred');
      
      return CustomPurchaseResult(
        success: true,
        customerInfo: _currentCustomerInfo,
        package: package,
      );
    } on PlatformException catch (e) {
      if (e.code == PurchasesErrorCode.purchaseCancelledError.toString()) {
        debugPrint('Test purchase was cancelled by user');
        return CustomPurchaseResult(
          success: false,
          error: 'Purchase cancelled',
          isCancelled: true,
        );
      }

      debugPrint('Test purchase failed: ${e.message}');
      return CustomPurchaseResult(
        success: false,
        error: e.message ?? 'Unknown error',
      );
    } catch (e) {
      debugPrint('Error purchasing package: $e');
      return CustomPurchaseResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  // Restore purchases
  Future<RestoreResult> restorePurchases() async {
    try {
      debugPrint('🔄 Attempting to restore purchases in TEST MODE');
      
      final customerInfo = await Purchases.restorePurchases();
      _currentCustomerInfo = customerInfo;
      _updatePremiumStatus(_currentCustomerInfo!);
      
      debugPrint('✅ Test purchases restored successfully');
      
      return RestoreResult(
        success: true,
        customerInfo: _currentCustomerInfo,
      );
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
      return RestoreResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  // Update premium status based on entitlement
  void _updatePremiumStatus(CustomerInfo customerInfo) {
    final entitlement = customerInfo.entitlements.all[RevenueCatConfig.premiumEntitlementId];
    final newStatus = entitlement?.isActive ?? false;
    
    if (newStatus != _isPremium) {
      _isPremium = newStatus;
      _premiumStatusController.add(_isPremium);
      debugPrint('Premium status changed: $_isPremium (TEST MODE)');
    }
  }

  // Handle customer info updates
  void _onCustomerInfoUpdated(CustomerInfo customerInfo) {
    _currentCustomerInfo = customerInfo;
    _updatePremiumStatus(customerInfo);
    _customerInfoController.add(customerInfo);
    
    debugPrint('📡 Customer info updated via listener (TEST MODE)');
  }

  // Get subscription info
  Map<String, dynamic>? getSubscriptionInfo() {
    if (_currentCustomerInfo == null) return null;
    
    final entitlement = _currentCustomerInfo!.entitlements.all[RevenueCatConfig.premiumEntitlementId];
    if (entitlement == null || !entitlement.isActive) return null;
    
    return {
      'isActive': entitlement.isActive,
      'productIdentifier': entitlement.identifier,
      'latestPurchase': entitlement.latestPurchaseDate,
      'expiration': entitlement.expirationDate,
      'willRenew': entitlement.willRenew,
      'store': entitlement.store,
      'periodType': entitlement.periodType.name,
    };
  }

  // Get package by identifier
  Package? getPackageById(String identifier) {
    try {
      return _availablePackages.firstWhere(
        (pkg) => pkg.identifier == identifier,
      );
    } catch (e) {
      return null;
    }
  }

  // Get subscription packages
  List<Package> getSubscriptionPackages() {
    return _availablePackages.where((package) {
      return package.identifier.contains('monthly') || 
             package.identifier.contains('yearly');
    }).toList();
  }

  // Get lifetime package
  Package? getLifetimePackage() {
    try {
      return _availablePackages.firstWhere(
        (package) => package.identifier.contains('lifetime'),
      );
    } catch (e) {
      return null;
    }
  }

  // Check if user has active trial
  bool hasActiveTrial() {
    if (_currentCustomerInfo == null) return false;
    
    final entitlement = _currentCustomerInfo!.entitlements.all[RevenueCatConfig.premiumEntitlementId];
    return entitlement?.periodType == PeriodType.intro;
  }

  // Check if subscription is cancelled
  bool isSubscriptionCancelled() {
    final info = getSubscriptionInfo();
    if (info == null) return false;
    
    final willRenew = info['willRenew'] as bool?;
    return willRenew == false;
  }

  // Get days until expiration
  int? getDaysUntilExpiration() {
    final info = getSubscriptionInfo();
    if (info == null || info['expiration'] == null) return null;
    
    try {
      final expiration = DateTime.parse(info['expiration']!);
      final now = DateTime.now();
      return expiration.difference(now).inDays;
    } catch (e) {
      return null;
    }
  }

  // Dispose
  void dispose() {
    _customerInfoController.close();
    _premiumStatusController.close();
    _packagesController.close();
    Purchases.removeCustomerInfoUpdateListener(_onCustomerInfoUpdated);
  }
}

// Purchase Result
class CustomPurchaseResult {
  final bool success;
  final CustomerInfo? customerInfo;
  final Package? package;
  final String? error;
  final bool isCancelled;

  CustomPurchaseResult({
    required this.success,
    this.customerInfo,
    this.package,
    this.error,
    this.isCancelled = false,
  });
}

// Restore Result
class RestoreResult {
  final bool success;
  final CustomerInfo? customerInfo;
  final String? error;

  RestoreResult({
    required this.success,
    this.customerInfo,
    this.error,
  });
}