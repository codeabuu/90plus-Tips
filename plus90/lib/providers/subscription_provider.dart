import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/revenuecat_service.dart';
import '../config/revenuecat_config.dart';

class SubscriptionProvider with ChangeNotifier {
  final RevenueCatService _revenueCat = RevenueCatService();
  
  bool _isLoading = false;
  bool _isInitialized = false;
  DateTime? _expiresAt;
  bool _isPremium = false;
  Map<String, dynamic>? _subscriptionInfo;
  List<Package> _packages = [];
  
  // Getters
  DateTime? get expiresAt => _expiresAt;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get isPremium => _isPremium;
  Map<String, dynamic>? get subscriptionInfo => _subscriptionInfo;
  List<Package> get packages => _packages;
  
  // ✅ Get app_user_id for reference
  Future<String> getAppUserId() async {
    return await _revenueCat.getAppUserId();
  }
  
  // Initialize
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      await _revenueCat.initialize();
      
      // Listen to premium status changes
      _revenueCat.premiumStatusStream.listen((premium) {
        _isPremium = premium;
        _subscriptionInfo = _revenueCat.getSubscriptionInfo();
        notifyListeners();
      });
      
      // Listen to packages updates
      _revenueCat.packagesStream.listen((packages) {
        _packages = packages;
        notifyListeners();
      });
      
      // Set initial state
      _isPremium = _revenueCat.isPremium;
      _subscriptionInfo = _revenueCat.getSubscriptionInfo();
      _packages = _revenueCat.availablePackages;
      
      _isInitialized = true;
      debugPrint('✅ SubscriptionProvider initialized. Premium: $_isPremium');
    } catch (e) {
      debugPrint('❌ Error initializing SubscriptionProvider: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // ✅ UPDATED: Return type changed to CustomPurchaseResult
  Future<CustomPurchaseResult> purchasePackage(Package package) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final result = await _revenueCat.purchasePackage(package);
      
      if (result.success) {
        _isPremium = _revenueCat.isPremium;
        _subscriptionInfo = _revenueCat.getSubscriptionInfo();
        
        // ✅ Webhook handles Django sync automatically
        debugPrint('📡 Purchase successful - webhook will update Django');
      }
      
      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // ✅ UPDATED: Return type changed to CustomRestoreResult
  Future<RestoreResult> restorePurchases() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final result = await _revenueCat.restorePurchases();
      
      if (result.success) {
        _isPremium = _revenueCat.isPremium;
        _subscriptionInfo = _revenueCat.getSubscriptionInfo();
        
        // ✅ Webhook handles restore sync automatically
        debugPrint('📡 Restore successful - webhook will update Django');
      }
      
      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Refresh packages
  Future<void> refreshPackages() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      await _revenueCat.fetchPackages();
      _packages = _revenueCat.availablePackages;
    } catch (e) {
      debugPrint('Error refreshing packages: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Get package by identifier
  Package? getPackageById(String identifier) {
    return _revenueCat.getPackageById(identifier);
  }
  
  // Get formatted price
  String getFormattedPrice(Package package) {
    return package.storeProduct.priceString;
  }
  
  // Get subscription period
  String getSubscriptionPeriod(Package package) {
  final identifier = package.identifier.toLowerCase();
  
  if (identifier.contains('week')) return 'per week';
  if (identifier.contains('month')) return 'per month';
  if (identifier.contains('3month') || identifier.contains('three_month')) return 'per 3 months';
  if (identifier.contains('year') || identifier.contains('annual')) return 'per year';
  if (identifier.contains('lifetime')) return 'one-time';
  
  return '';
}
  
  // Calculate savings for yearly vs monthly
  String? calculateSavings(Package monthly, Package yearly) {
    try {
      final monthlyPrice = monthly.storeProduct.price;
      final yearlyPrice = yearly.storeProduct.price;
      
      if (monthlyPrice > 0 && yearlyPrice > 0) {
        final monthlyCostForYear = monthlyPrice * 12;
        final savings = monthlyCostForYear - yearlyPrice;
        final percentage = ((savings / monthlyCostForYear) * 100).round();
        
        if (savings > 0 && percentage > 0) {
          return 'Save $percentage%';
        }
      }
    } catch (e) {
      debugPrint('Error calculating savings: $e');
    }
    return null;
  }
  
  // Check if user has trial
  bool hasActiveTrial() {
    return _revenueCat.hasActiveTrial();
  }
  
  // Check if subscription is cancelled
  bool isSubscriptionCancelled() {
    return _revenueCat.isSubscriptionCancelled();
  }
  
  // Get days until expiration
  int? getDaysUntilExpiration() {
    return _revenueCat.getDaysUntilExpiration();
  }
  
  @override
  void dispose() {
    _revenueCat.dispose();
    super.dispose();
  }
}