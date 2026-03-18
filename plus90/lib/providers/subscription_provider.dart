import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../services/revenuecat_service.dart';
import '../services/reviewer_access_service.dart';
import '../config/revenuecat_config.dart';

class SubscriptionProvider with ChangeNotifier {
  final RevenueCatService _revenueCat = RevenueCatService();

  bool _isLoading = false;
  bool _isInitialized = false;
  DateTime? _expiresAt;
  bool _isPremium = false;
  bool _isReviewerAccess = false; // ← tracks reviewer-granted premium
  Map<String, dynamic>? _subscriptionInfo;
  List<Package> _packages = [];

  DateTime? get expiresAt => _expiresAt;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  /// True if the user has a real subscription OR active reviewer access.
  bool get isPremium => _isPremium || _isReviewerAccess;

  /// True specifically if access came from the reviewer backdoor (not a real sub).
  bool get isReviewerAccess => _isReviewerAccess;

  Map<String, dynamic>? get subscriptionInfo => _subscriptionInfo;
  List<Package> get packages => _packages;

  Future<String> getAppUserId() async {
    return await _revenueCat.getAppUserId();
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('🔄 Initializing RevenueCat service...');
      await _revenueCat.initialize();
      debugPrint('✅ RevenueCat service initialized');

      _revenueCat.premiumStatusStream.listen((premium) {
        _isPremium = premium;
        _subscriptionInfo = _revenueCat.getSubscriptionInfo();
        notifyListeners();
      });

      _revenueCat.packagesStream.listen((packages) {
        _packages = packages;
        notifyListeners();
      });

      _isPremium = _revenueCat.isPremium;
      _subscriptionInfo = _revenueCat.getSubscriptionInfo();
      _packages = _revenueCat.availablePackages;

      // ── Check reviewer access ──────────────────────────────────────────────
      _isReviewerAccess = await ReviewerAccessService.hasActiveAccess();
      debugPrint('🔓 Reviewer access on init: $_isReviewerAccess');

      _isInitialized = true;
      debugPrint('✅ SubscriptionProvider initialized. Premium: $isPremium');
      debugPrint('📦 Packages loaded: ${_packages.length}');
      debugPrint('🎯 Active plan on init: $activePlanName');
    } catch (e) {
      debugPrint('❌ Error initializing SubscriptionProvider: $e');
      _isInitialized = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Called from the hero icon tap sequence. Grants reviewer premium and
  /// notifies listeners so the UI updates immediately.
  Future<void> grantReviewerAccess() async {
    await ReviewerAccessService.grantAccess();
    _isReviewerAccess = true;
    notifyListeners();
    debugPrint('🔓 Reviewer access granted via tap sequence');
  }

  Future<void> debugSubscriptionState() async {
    debugPrint('🔍 ===== SUBSCRIPTION DEBUG =====');
    debugPrint('isInitialized: $_isInitialized');
    debugPrint('isLoading: $_isLoading');
    debugPrint('isPremium (real): $_isPremium');
    debugPrint('isReviewerAccess: $_isReviewerAccess');
    debugPrint('isPremium (combined): $isPremium');
    debugPrint('packages count: ${_packages.length}');

    if (_subscriptionInfo != null) {
      debugPrint('📋 subscriptionInfo keys: ${_subscriptionInfo!.keys.toList()}');
      _subscriptionInfo!.forEach((k, v) => debugPrint('  $k: $v'));
    }

    final productId = _revenueCat.getActiveProductId();
    debugPrint('🎯 getActiveProductId() → $productId');
    debugPrint('🏷️  activePlanName → $activePlanName');

    for (var package in _packages) {
      debugPrint('📦 Package: ${package.identifier}');
      debugPrint('  - Price: ${package.storeProduct.priceString}');
      debugPrint('  - Title: ${package.storeProduct.title}');
    }

    debugPrint('🔍 ===== END DEBUG =====');
  }

  Future<CustomPurchaseResult> purchasePackage(Package package) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _revenueCat.purchasePackage(package);

      if (result.success) {
        _isPremium = _revenueCat.isPremium;
        _subscriptionInfo = _revenueCat.getSubscriptionInfo();
        debugPrint('📡 Purchase successful');
        debugPrint('🎯 Post-purchase activePlanName: $activePlanName');
      }

      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<RestoreResult> restorePurchases() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _revenueCat.restorePurchases();

      if (result.success) {
        _isPremium = _revenueCat.isPremium;
        _subscriptionInfo = _revenueCat.getSubscriptionInfo();
        debugPrint('📡 Restore successful');
        debugPrint('🎯 Post-restore activePlanName: $activePlanName');
      }

      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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

  Package? getPackageById(String identifier) {
    return _revenueCat.getPackageById(identifier);
  }

  String getFormattedPrice(Package package) {
    return package.storeProduct.priceString;
  }

  /// Returns the active plan name.
  /// For reviewer access, returns 'Yearly' so all upgrade buttons stay correct.
  String? get activePlanName {
    // Reviewer access: treat as yearly so no UPGRADE prompts appear
    if (_isReviewerAccess && !_isPremium) return 'Yearly';

    if (!_isPremium) return null;

    final productId = _revenueCat.getActiveProductId()
        ?? _subscriptionInfo?['productIdentifier'] as String?;

    if (productId == null) {
      debugPrint('⚠️ activePlanName: productId is null');
      return 'Premium';
    }

    debugPrint('🎯 activePlanName resolving from productId: $productId');

    for (final entry in RevenueCatConfig.productIds.entries) {
      if (productId == entry.value) return _labelForKey(entry.key);
    }

    final id = productId.toLowerCase();
    if (id.contains('week'))                                  return 'Weekly';
    if (id.contains('3month') || id.contains('three-month')) return '3 Months';
    if (id.contains('month'))                                 return 'Monthly';
    if (id.contains('year') || id.contains('annual'))        return 'Yearly';

    debugPrint('⚠️ activePlanName: no match found for "$productId"');
    return 'Premium';
  }

  String _labelForKey(String key) {
    switch (key) {
      case 'weekly':   return 'Weekly';
      case 'monthly':  return 'Monthly';
      case '3_months': return '3 Months';
      case 'yearly':   return 'Yearly';
      default:         return 'Premium';
    }
  }

  String getExpirationDateString() {
    // Show reviewer expiry if that's the active access mode
    if (_isReviewerAccess && !_isPremium) {
      return 'Reviewer access: expires in ~1 year';
    }
    if (_subscriptionInfo == null || _subscriptionInfo!['expiration'] == null) {
      return '';
    }
    try {
      final date = DateTime.parse(_subscriptionInfo!['expiration'].toString());
      return 'Renews: ${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }

  String getSubscriptionPeriod(Package package) {
    final id = package.identifier.toLowerCase();
    if (id.contains('week'))                                        return 'per week';
    if (id.contains('3month') || id.contains('three_month'))       return 'per 3 months';
    if (id.contains('month'))                                       return 'per month';
    if (id.contains('year') || id.contains('annual'))              return 'per year';
    if (id.contains('lifetime'))                                    return 'one-time';
    return '';
  }

  String? calculateSavings(Package monthly, Package yearly) {
    try {
      final monthlyPrice = monthly.storeProduct.price;
      final yearlyPrice = yearly.storeProduct.price;

      if (monthlyPrice > 0 && yearlyPrice > 0) {
        final monthlyCostForYear = monthlyPrice * 12;
        final savings = monthlyCostForYear - yearlyPrice;
        final percentage = ((savings / monthlyCostForYear) * 100).round();
        if (savings > 0 && percentage > 0) return 'Save 50%';
      }
    } catch (e) {
      debugPrint('Error calculating savings: $e');
    }
    return null;
  }

  /// True if user is currently in a free trial period

  bool hasActiveTrial() => _revenueCat.hasActiveTrial();
  bool isSubscriptionCancelled() => _revenueCat.isSubscriptionCancelled();
  int? getDaysUntilExpiration() => _revenueCat.getDaysUntilExpiration();

  @override
  void dispose() {
    _revenueCat.dispose();
    super.dispose();
  }
}