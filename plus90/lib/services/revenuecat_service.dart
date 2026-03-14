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

  Future<String> getAppUserId() async {
    if (_currentCustomerInfo != null) {
      return _currentCustomerInfo!.originalAppUserId;
    }
    
    final customerInfo = await Purchases.getCustomerInfo();
    return customerInfo.originalAppUserId;
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await dotenv.load(fileName: 'assets/.env');
      final apiKey = dotenv.get('REVENUECAT_API_KEY');
      
      await Purchases.setup(apiKey);
      Purchases.setLogLevel(LogLevel.debug);

      // Get initial customer info
      try {
        await Purchases.getCustomerInfo();
      } catch (e) {
        // Ignore - will retry later
      }

      Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);
      await fetchPackages();

      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      rethrow;
    }
  }

  Future<CustomerInfo> fetchCustomerInfo() async {
    try {
      _currentCustomerInfo = await Purchases.getCustomerInfo();
      _updatePremiumStatus(_currentCustomerInfo!);
      _customerInfoController.add(_currentCustomerInfo!);
      
      return _currentCustomerInfo!;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Package>> fetchPackages() async {
    try {
      final offerings = await Purchases.getOfferings();
      
      final offering = offerings.getOffering(RevenueCatConfig.offeringsId) ?? 
                      offerings.current;
      
      if (offering != null) {
        _availablePackages = offering.availablePackages;
        _packagesController.add(_availablePackages);
      }
      
      return _availablePackages;
    } catch (e) {
      return [];
    }
  }

  Future<CustomPurchaseResult> purchasePackage(Package package) async {
    try {
      final purchaserInfo = await Purchases.purchasePackage(package);
      _currentCustomerInfo = purchaserInfo.customerInfo;
      _updatePremiumStatus(_currentCustomerInfo!);
      
      return CustomPurchaseResult(
        success: true,
        customerInfo: _currentCustomerInfo,
        package: package,
      );
    } on PlatformException catch (e) {
      if (e.code == PurchasesErrorCode.purchaseCancelledError.toString()) {
        return CustomPurchaseResult(
          success: false,
          error: 'Purchase cancelled',
          isCancelled: true,
        );
      }

      return CustomPurchaseResult(
        success: false,
        error: e.message ?? 'Unknown error',
      );
    } catch (e) {
      return CustomPurchaseResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  Future<RestoreResult> restorePurchases() async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      final customerInfo = await Purchases.restorePurchases();
      _currentCustomerInfo = customerInfo;
      _updatePremiumStatus(_currentCustomerInfo!);

      return RestoreResult(
        success: true,
        customerInfo: _currentCustomerInfo,
      );
    } catch (e) {
      return RestoreResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  void _updatePremiumStatus(CustomerInfo customerInfo) {
    final entitlement = customerInfo.entitlements.all[RevenueCatConfig.premiumEntitlementId];
    final newStatus = entitlement?.isActive ?? false;
    
    if (newStatus != _isPremium) {
      _isPremium = newStatus;
      _premiumStatusController.add(_isPremium);
    }
  }

  void _onCustomerInfoUpdated(CustomerInfo customerInfo) {
    _currentCustomerInfo = customerInfo;
    _updatePremiumStatus(customerInfo);
    _customerInfoController.add(customerInfo);
  }

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

  Package? getPackageById(String identifier) {
    try {
      return _availablePackages.firstWhere(
        (pkg) => pkg.identifier == identifier,
      );
    } catch (e) {
      return null;
    }
  }

  List<Package> getSubscriptionPackages() {
    return _availablePackages.where((package) {
      return package.identifier.contains('monthly') || 
             package.identifier.contains('yearly');
    }).toList();
  }

  Package? getLifetimePackage() {
    try {
      return _availablePackages.firstWhere(
        (package) => package.identifier.contains('lifetime'),
      );
    } catch (e) {
      return null;
    }
  }

  bool hasActiveTrial() {
    if (_currentCustomerInfo == null) return false;
    
    final entitlement = _currentCustomerInfo!.entitlements.all[RevenueCatConfig.premiumEntitlementId];
    return entitlement?.periodType == PeriodType.intro;
  }

  bool isSubscriptionCancelled() {
    final info = getSubscriptionInfo();
    if (info == null) return false;
    
    final willRenew = info['willRenew'] as bool?;
    return willRenew == false;
  }

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