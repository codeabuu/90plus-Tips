import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:plus90/models/btts_win_model.dart';
import 'package:plus90/models/daily_accumulator_model.dart';
import '../models/prediction_model.dart';
import '../models/accumulator_base_model.dart';
import '../models/betofday_model.dart';
import '../models/btts_model.dart';
import '../models/goalscorer_model.dart';
import '../models/over2.5_goals_model.dart';
import '../models/league_model.dart';
import '../providers/predictions_provider.dart';
import 'dart:io';
import 'cache_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String baseUrl = dotenv.get('BACKEND_URL');
  
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  final CacheService _cache = CacheService(); // Add cache instance

  // Constructor to initialize cache
  ApiService() {
    _cache.init();
  }

  // League-specific methods with caching
  Future<List<MatchItem>> getLaLigaMatches() async {
    return await _cache.getOrFetchList(
      key: 'laliga_matches',
      fetchFunction: () => _fetchMatchPredictions('laliga-matches/'),
      fromJson: (json) => MatchItem.fromJson(json),
    );
  }

  Future<List<MatchItem>> getEPLMatches() async {
    return await _cache.getOrFetchList(
      key: 'epl_matches',
      fetchFunction: () => _fetchMatchPredictions('epl-matches/'),
      fromJson: (json) => MatchItem.fromJson(json),
    );
  }

  Future<List<MatchItem>> getEFLCupMatches() async {
    return await _cache.getOrFetchList(
      key: 'efl_cup_matches',
      fetchFunction: () => _fetchMatchPredictions('efl-cup-matches/'),
      fromJson: (json) => MatchItem.fromJson(json),
    );
  }

  Future<List<MatchItem>> getSerieAMatches() async {
    return await _cache.getOrFetchList(
      key: 'serie_a_matches',
      fetchFunction: () => _fetchMatchPredictions('serie-a-matches/'),
      fromJson: (json) => MatchItem.fromJson(json),
    );
  }

  Future<List<MatchItem>> getBundesligaMatches() async {
    return await _cache.getOrFetchList(
      key: 'bundesliga_matches',
      fetchFunction: () => _fetchMatchPredictions('bundesliga-matches/'),
      fromJson: (json) => MatchItem.fromJson(json),
    );
  }

  Future<List<MatchItem>> getLigue1Matches() async {
    return await _cache.getOrFetchList(
      key: 'ligue1_matches',
      fetchFunction: () => _fetchMatchPredictions('ligue1-matches/'),
      fromJson: (json) => MatchItem.fromJson(json),
    );
  }

  Future<List<MatchItem>> getEliteserienMatches() async {
    return await _cache.getOrFetchList(
      key: 'eliteserien_matches',
      fetchFunction: () => _fetchMatchPredictions('eliteserien-matches/'),
      fromJson: (json) => MatchItem.fromJson(json),
    );
  }

  Future<List<MatchItem>> getSwedishAllsvenskanMatches() async {
    return await _cache.getOrFetchList(
      key: 'swedish_allsvenskan_matches',
      fetchFunction: () => _fetchMatchPredictions('swedish-allsvenskan/'),
      fromJson: (json) => MatchItem.fromJson(json),
    );
  }

  Future<List<MatchItem>> getLigaPortugalMatches() async {
    return await _cache.getOrFetchList(
      key: 'liga_portugal_matches',
      fetchFunction: () => _fetchMatchPredictions('liga-portugal-matches/'),
      fromJson: (json) => MatchItem.fromJson(json),
    );
  }

  Future<List<MatchItem>> getUEFACLMatches() async {
    return await _cache.getOrFetchList(
      key: 'uefa_cl_matches',
      fetchFunction: () => _fetchMatchPredictions('uefa-cl-matches/'),
      fromJson: (json) => MatchItem.fromJson(json),
    );
  }

  Future<List<MatchItem>> getDutchEredivisieMatches() async {
    return await _cache.getOrFetchList(
      key: 'dutch_eredivisie_matches',
      fetchFunction: () => _fetchMatchPredictions('dutch-eredivisie-matches/'),
      fromJson: (json) => MatchItem.fromJson(json),
    );
  }

  Future<List<MatchItem>> getTurkishSuperLigMatches() async {
    return await _cache.getOrFetchList(
      key: 'turkish_super_lig_matches',
      fetchFunction: () => _fetchMatchPredictions('turkish-super-lig-matches/'),
      fromJson: (json) => MatchItem.fromJson(json),
    );
  }

  Future<List<MatchItem>> getEuropaLeagueMatches() async {
    return await _cache.getOrFetchList(
      key: 'europa_league_matches',
      fetchFunction: () => _fetchMatchPredictions('europa-league-matches/'),
      fromJson: (json) => MatchItem.fromJson(json),
    );
  }

  Future<List<MatchItem>> getWorldCupQualificationMatches() async {
    return await _cache.getOrFetchList(
      key: 'worldcup_qualification_matches',
      fetchFunction: () => _fetchMatchPredictions('worldcup-qualification-matches/'),
      fromJson: (json) => MatchItem.fromJson(json),
    );
  }

  Future<List<MatchItem>> getWorldCupQualificationAfricaMatches() async {
    return await _cache.getOrFetchList(
      key: 'worldcup_qualification_africa_matches',
      fetchFunction: () => _fetchMatchPredictions('worldcup-qualification-africa-matches/'),
      fromJson: (json) => MatchItem.fromJson(json),
    );
  }

  Future<List<MatchItem>> getWorldCupQualificationAsiaMatches() async {
    return await _cache.getOrFetchList(
      key: 'worldcup_qualification_asia_matches',
      fetchFunction: () => _fetchMatchPredictions('worldcup-qualification-asia-matches/'),
      fromJson: (json) => MatchItem.fromJson(json),
    );
  }

  Future<List<MatchItem>> getScottishPremiershipMatches() async {
    return await _cache.getOrFetchList(
      key: 'scottish_premiership_matches',
      fetchFunction: () => _fetchMatchPredictions('scottish-premiership-matches/'),
      fromJson: (json) => MatchItem.fromJson(json),
    );
  }

  Future<List<MatchItem>> getAFCON2025Matches() async {
    return await _cache.getOrFetchList(
      key: 'afcon_2025_matches',
      fetchFunction: () => _fetchMatchPredictions('afcon-2025-matches/'),
      fromJson: (json) => MatchItem.fromJson(json),
    );
  }

  // Private method to fetch match predictions (no caching here)
  Future<List<MatchItem>> _fetchMatchPredictions(String leagueEndpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/$leagueEndpoint'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        
        if (data is List) {
          return data.map((item) => MatchItem.fromJson(item)).toList();
        }
        
        if (data is Map<String, dynamic>) {
          if (data.containsKey('matches') && data['matches'] is List) {
            return (data['matches'] as List).map((item) => MatchItem.fromJson(item)).toList();
          }
          if (data.containsKey('data') && data['data'] is List) {
            return (data['data'] as List).map((item) => MatchItem.fromJson(item)).toList();
          }
        }
        return [];
      }
      return [];
    } catch (e) {
      print('❌ Exception for $leagueEndpoint: $e');
      return [];
    }
  }

  // Betting tips methods with caching
  Future<BetOfDayAccumulator?> getBetOfTheDay() async {
    return await _cache.getOrFetch(
      key: 'bet_of_the_day',
      fetchFunction: () async {
        try {
          final response = await http.get(
            Uri.parse('$baseUrl/api/bet-of-the-day/'),
            headers: _headers,
          );

          if (response.statusCode == 200) {
            final Map<String, dynamic> data = json.decode(response.body);
            return BetOfDayAccumulator.fromJson(data);
          }
          return null;
        } catch (e) {
          print('Error fetching bet of the day: $e');
          return null;
        }
      },
      fromJson: (jsonString) => BetOfDayAccumulator.fromJson(json.decode(jsonString)),
    );
  }

  Future<BTTSAccumulator?> getBTTSPredictions() async {
    return await _cache.getOrFetch(
      key: 'btts_predictions',
      fetchFunction: () async {
        try {
          final response = await http.get(
            Uri.parse('$baseUrl/api/BTTS/'),
            headers: _headers,
          );

          if (response.statusCode == 200) {
            final Map<String, dynamic> data = json.decode(response.body);
            return BTTSAccumulator.fromJson(data);
          }
          return null;
        } catch (e) {
          print('Error fetching BTTS predictions: $e');
          return null;
        }
      },
      fromJson: (jsonString) => BTTSAccumulator.fromJson(json.decode(jsonString)),
    );
  }

  Future<DailyAccumulator> getDailyAccumulators() async {
    return await _cache.getOrFetch(
      key: 'daily_accumulator',
      fetchFunction: () async {
        try {
          final response = await http.get(
            Uri.parse('$baseUrl/api/daily-accumulator/'),
            headers: _headers,
          );

          if (response.statusCode == 200) {
            final Map<String, dynamic> data = json.decode(response.body);
            
            if (data.isEmpty) {
              return DailyAccumulator.fromJson({
                'type': 'Daily Accumulator',
                'total_odds': '0',
                'total_odds_raw': 0,
                'scraped_at': DateTime.now().toIso8601String(),
                'count': 0,
                'cached': false,
                'matches': []
              });
            }
            
            return DailyAccumulator.fromJson(data);
          } else {
            return DailyAccumulator.fromJson({
              'type': 'Daily Accumulator',
              'total_odds': '0',
              'total_odds_raw': 0,
              'scraped_at': DateTime.now().toIso8601String(),
              'count': 0,
              'cached': false,
              'matches': []
            });
          }
        } catch (e) {
          print('Error fetching daily accumulator: $e');
          return DailyAccumulator.fromJson({
            'type': 'Daily Accumulator',
            'total_odds': '0',
            'total_odds_raw': 0,
            'scraped_at': DateTime.now().toIso8601String(),
            'count': 0,
            'cached': false,
            'matches': []
          });
        }
      },
      fromJson: (jsonString) => DailyAccumulator.fromJson(json.decode(jsonString)),
    );
  }

  Future<BTTSWinAccumulator?> getBTTSWinAccumulator() async {
    return await _cache.getOrFetch(
      key: 'btts_win_accumulator',
      fetchFunction: () async {
        try {
          final response = await http.get(
            Uri.parse('$baseUrl/api/btts-win-accumulator/'),
            headers: _headers,
          );

          if (response.statusCode == 200) {
            final Map<String, dynamic> data = json.decode(response.body);
            return BTTSWinAccumulator.fromJson(data);
          }
          return null;
        } catch (e) {
          print('Error fetching BTTS win accumulator: $e');
          return null;
        }
      },
      fromJson: (jsonString) => BTTSWinAccumulator.fromJson(json.decode(jsonString)),
    );
  }

  Future<Over25GoalsAccumulator?> getOver25GoalsAccumulator() async {
    return await _cache.getOrFetch(
      key: 'over25_goals_accumulator',
      fetchFunction: () async {
        try {
          final response = await http.get(
            Uri.parse('$baseUrl/api/over-25-goals-accumulator/'),
            headers: _headers,
          );

          if (response.statusCode == 200) {
            final Map<String, dynamic> data = json.decode(response.body);
            return Over25GoalsAccumulator.fromJson(data);
          }
          return null;
        } catch (e) {
          print('Error fetching over 2.5 goals accumulator: $e');
          return null;
        }
      },
      fromJson: (jsonString) => Over25GoalsAccumulator.fromJson(json.decode(jsonString)),
    );
  }

  // Helper method to get all betting tips
  Future<Map<String, dynamic>> getAllBettingTips() async {
    final Map<String, dynamic> tips = {};

    try {
      tips['bet_of_the_day'] = await getBetOfTheDay();
      tips['btts_predictions'] = await getBTTSPredictions();
      tips['daily_accumulators'] = await getDailyAccumulators();
      tips['btts_win_accumulator'] = await getBTTSWinAccumulator();
      tips['over_25_goals_accumulator'] = await getOver25GoalsAccumulator();
    } catch (e) {
      print('Error fetching betting tips: $e');
    }

    return tips;
  }

  // Keep original getMatchPredictions for backward compatibility
  Future<List<MatchItem>> getMatchPredictions(String leagueEndpoint) async {
    return await _cache.getOrFetchList(
      key: 'match_predictions_${leagueEndpoint.replaceAll('/', '_')}',
      fetchFunction: () => _fetchMatchPredictions(leagueEndpoint),
      fromJson: (json) => MatchItem.fromJson(json),
    );
  }

  // Also add this method for league predictions
  Future<List<MatchItem>> fetchLeagueMatches(String endpoint) async {
    return await getMatchPredictions(endpoint);
  }

  // Subscription and contact methods (no caching for these)
  Future<Map<String, dynamic>> checkSubscriptionStatus(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/subscription/status/'),
        headers: _headers,
        body: json.encode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'is_premium': false, 'expires_at': null};
    } catch (e) {
      print('Error checking subscription: $e');
      return {'is_premium': false, 'expires_at': null};
    }
  }

  Future<bool> submitContactMessage({
    required String name,
    required String email,
    required String category,
    required String message,
    File? attachment,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/contact-us/'),
      );
      
      request.headers.addAll({
        'Accept': 'application/json',
      });
      
      request.fields['name'] = name;
      request.fields['email'] = email;
      request.fields['category'] = category;
      request.fields['message'] = message;
      
      if (attachment != null) {
        if (await attachment.exists()) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'attachment',
              attachment.path,
              filename: attachment.path.split('/').last,
            ),
          );
          print('📎 Attachment added: ${attachment.path}');
        } else {
          print('⚠️ Attachment file does not exist');
        }
      }
      
      print('📤 Sending contact form with attachment...');
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');
      
      return response.statusCode == 200;
      
    } catch (e) {
      print('❌ Error submitting contact form: $e');
      return false;
    }
  }

  // Optional: Add cache management methods
  Future<void> clearAllCaches() async {
    await _cache.clearAllCache();
  }

  Future<void> debugCacheStatus() async {
    final stats = await _cache.getCacheStats();
    print('📊 Cache Stats: $stats');
  }
}