import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String _cachePrefix = 'api_cache_';
  static const String _timestampSuffix = '_timestamp';
  static const Duration defaultCacheDuration = Duration(hours: 4);

  // Singleton pattern
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  SharedPreferences? _prefs;
  bool get isInitialized => _prefs != null;

  // Initialize the cache service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Ensure prefs is initialized
  Future<SharedPreferences> get _getPrefs async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  // Store data in cache
  Future<void> setCache<T>({
    required String key,
    required T data,
    Duration? duration,
  }) async {
    try {
      final prefs = await _getPrefs;
      final cacheKey = _cachePrefix + key;
      
      // Convert data to JSON string
      String jsonData;
      if (data is String) {
        jsonData = data;
      } else {
        jsonData = json.encode(data);
      }
      
      await prefs.setString(cacheKey, jsonData);
      await prefs.setString(
        cacheKey + _timestampSuffix,
        DateTime.now().toIso8601String(),
      );
      
      print('✅ Cache set for: $key');
    } catch (e) {
      print('❌ Error setting cache for $key: $e');
    }
  }

  // Get cached data
  Future<T?> getCache<T>({
    required String key,
    required T Function(String) fromJson,
    Duration? maxAge,
  }) async {
    try {
      final prefs = await _getPrefs;
      final cacheKey = _cachePrefix + key;
      final cacheDuration = maxAge ?? defaultCacheDuration;
      
      final cachedData = prefs.getString(cacheKey);
      final cachedTimestamp = prefs.getString(cacheKey + _timestampSuffix);
      
      if (cachedData == null || cachedTimestamp == null) {
        print('📭 No cache found for: $key');
        return null;
      }
      
      final cachedTime = DateTime.parse(cachedTimestamp);
      final now = DateTime.now();
      
      // Check if cache is still valid
      if (now.difference(cachedTime) < cacheDuration) {
        print('📦 Cache hit for: $key (age: ${now.difference(cachedTime).inMinutes} minutes)');
        return fromJson(cachedData);
      } else {
        print('🕒 Cache expired for: $key (age: ${now.difference(cachedTime).inMinutes} minutes)');
        return null;
      }
    } catch (e) {
      print('❌ Error getting cache for $key: $e');
      return null;
    }
  }

  // Get cached list data
  Future<List<T>?> getCacheList<T>({
    required String key,
    required T Function(Map<String, dynamic>) fromJson,
    Duration? maxAge,
  }) async {
    try {
      final prefs = await _getPrefs;
      final cacheKey = _cachePrefix + key;
      final cacheDuration = maxAge ?? defaultCacheDuration;
      
      final cachedData = prefs.getString(cacheKey);
      final cachedTimestamp = prefs.getString(cacheKey + _timestampSuffix);
      
      if (cachedData == null || cachedTimestamp == null) {
        print('📭 No cache list found for: $key');
        return null;
      }
      
      final cachedTime = DateTime.parse(cachedTimestamp);
      final now = DateTime.now();
      
      // Check if cache is still valid
      if (now.difference(cachedTime) < cacheDuration) {
        print('📦 Cache list hit for: $key (age: ${now.difference(cachedTime).inMinutes} minutes)');
        final List<dynamic> jsonList = json.decode(cachedData);
        return jsonList.map((item) => fromJson(item)).toList();
      } else {
        print('🕒 Cache list expired for: $key (age: ${now.difference(cachedTime).inMinutes} minutes)');
        return null;
      }
    } catch (e) {
      print('❌ Error getting cache list for $key: $e');
      return null;
    }
  }

  // Set cache for list data
  Future<void> setCacheList<T>({
    required String key,
    required List<T> data,
    Duration? duration,
  }) async {
    try {
      final prefs = await _getPrefs;
      final cacheKey = _cachePrefix + key;
      
      // Convert list to JSON
      final jsonList = json.encode(data);
      
      await prefs.setString(cacheKey, jsonList);
      await prefs.setString(
        cacheKey + _timestampSuffix,
        DateTime.now().toIso8601String(),
      );
      
      print('✅ Cache list set for: $key (${data.length} items)');
    } catch (e) {
      print('❌ Error setting cache list for $key: $e');
    }
  }

  // Get cache with fallback - automatically fetches if expired/not found
  // Get cache with fallback - automatically fetches if expired/not found
Future<T> getOrFetch<T>({
  required String key,
  required Future<T> Function() fetchFunction,
  required T Function(String) fromJson,
  Duration? maxAge,
  bool Function(T)? isValid, // ADD THIS OPTIONAL PARAMETER
}) async {
  // Try to get from cache first
  final cached = await getCache(
    key: key,
    fromJson: fromJson,
    maxAge: maxAge,
  );
  
  if (cached != null) {
    // If validator provided, check if cached data is valid
    if (isValid == null || isValid(cached)) {
      return cached;
    } else {
      print('⚠️ Cached data invalid for: $key, will fetch fresh');
      await clearCache(key);
    }
  }
  
  // If not in cache or expired or invalid, fetch fresh data
  print('🌐 Fetching fresh data for: $key');
  final freshData = await fetchFunction();
  
  // Only cache if data is valid
  if (isValid == null || isValid(freshData)) {
    await setCache(
      key: key,
      data: freshData,
      duration: maxAge,
    );
  } else {
    print('⚠️ Not caching invalid data for: $key');
  }
  
  return freshData;
}

  // Get cache list with fallback
  Future<List<T>> getOrFetchList<T>({
    required String key,
    required Future<List<T>> Function() fetchFunction,
    required T Function(Map<String, dynamic>) fromJson,
    Duration? maxAge,
  }) async {
    // Try to get from cache first
    final cached = await getCacheList(
      key: key,
      fromJson: fromJson,
      maxAge: maxAge,
    );
    
    if (cached != null) {
      return cached;
    }
    
    // If not in cache or expired, fetch fresh data
    print('🌐 Fetching fresh list for: $key');
    final freshData = await fetchFunction();
    
    // Cache the fresh data
    await setCacheList(
      key: key,
      data: freshData,
      duration: maxAge,
    );
    
    return freshData;
  }

  // Check if cache exists and is valid
  Future<bool> hasValidCache(String key, {Duration? maxAge}) async {
    try {
      final prefs = await _getPrefs;
      final cacheKey = _cachePrefix + key;
      final cacheDuration = maxAge ?? defaultCacheDuration;
      
      final cachedData = prefs.getString(cacheKey);
      final cachedTimestamp = prefs.getString(cacheKey + _timestampSuffix);
      
      if (cachedData == null || cachedTimestamp == null) {
        return false;
      }
      
      final cachedTime = DateTime.parse(cachedTimestamp);
      final now = DateTime.now();
      
      return now.difference(cachedTime) < cacheDuration;
    } catch (e) {
      print('❌ Error checking cache for $key: $e');
      return false;
    }
  }

  // Get cache age in minutes
  Future<int?> getCacheAge(String key) async {
    try {
      final prefs = await _getPrefs;
      final cacheKey = _cachePrefix + key;
      
      final cachedTimestamp = prefs.getString(cacheKey + _timestampSuffix);
      
      if (cachedTimestamp == null) {
        return null;
      }
      
      final cachedTime = DateTime.parse(cachedTimestamp);
      final now = DateTime.now();
      
      return now.difference(cachedTime).inMinutes;
    } catch (e) {
      print('❌ Error getting cache age for $key: $e');
      return null;
    }
  }

  // Clear cache for a specific key
  Future<void> clearCache(String key) async {
    try {
      final prefs = await _getPrefs;
      final cacheKey = _cachePrefix + key;
      await prefs.remove(cacheKey);
      await prefs.remove(cacheKey + _timestampSuffix);
      print('🗑️ Cache cleared for: $key');
    } catch (e) {
      print('❌ Error clearing cache for $key: $e');
    }
  }

  // Clear all cache
  Future<void> clearAllCache() async {
    try {
      final prefs = await _getPrefs;
      final keys = prefs.getKeys().where((key) => key.startsWith(_cachePrefix));
      for (String key in keys) {
        await prefs.remove(key);
      }
      print('🗑️ All cache cleared');
    } catch (e) {
      print('❌ Error clearing all cache: $e');
    }
  }

  // Get cache stats
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final prefs = await _getPrefs;
      final cacheKeys = prefs.getKeys().where((key) => key.startsWith(_cachePrefix));
      
      int totalItems = 0;
      int expiredItems = 0;
      final now = DateTime.now();
      
      for (String key in cacheKeys) {
        if (key.endsWith(_timestampSuffix)) continue;
        
        totalItems++;
        final timestampKey = key + _timestampSuffix;
        final timestamp = prefs.getString(timestampKey);
        
        if (timestamp != null) {
          final cachedTime = DateTime.parse(timestamp);
          if (now.difference(cachedTime) >= defaultCacheDuration) {
            expiredItems++;
          }
        }
      }
      
      return {
        'total_items': totalItems,
        'expired_items': expiredItems,
        'valid_items': totalItems - expiredItems,
      };
    } catch (e) {
      print('❌ Error getting cache stats: $e');
      return {'error': e.toString()};
    }
  }
}