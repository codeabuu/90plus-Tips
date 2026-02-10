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


class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000';
  
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Main method to get league matches
  // Future<List<Prediction>> getLeagueMatches(String leagueEndpoint) async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse('$baseUrl/api/$leagueEndpoint'),
  //       headers: _headers,
  //     );

  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = json.decode(response.body);
  //       return data.map((json) => Prediction.fromJson(json)).toList();
  //     } else {
  //       throw Exception('Failed to load $leagueEndpoint matches');
  //     }
  //   } catch (e) {
  //     print('Error fetching $leagueEndpoint: $e');
  //     return [];
  //   }
  // }

  // League-specific methods for easier access
  Future<List<MatchItem>> getLaLigaMatches() async {
    return await getMatchPredictions('laliga-matches/');
  }

  Future<List<MatchItem>> getEPLMatches() async {
    return await getMatchPredictions('epl-matches/');
  }

  Future<List<MatchItem>> getEFLCupMatches() async {
    return await getMatchPredictions('efl-cup-matches/');
  }

  Future<List<MatchItem>> getSerieAMatches() async {
    return await getMatchPredictions('serie-a-matches/');
  }

  Future<List<MatchItem>> getBundesligaMatches() async {
    return await getMatchPredictions('bundesliga-matches/');
  }

  Future<List<MatchItem>> getLigue1Matches() async {
    return await getMatchPredictions('ligue1-matches/');
  }

  Future<List<MatchItem>> getEliteserienMatches() async {
    return await getMatchPredictions('eliteserien-matches/');
  }

  Future<List<MatchItem>> getSwedishAllsvenskanMatches() async {
    return await getMatchPredictions('swedish-allsvenskan/');
  }

  Future<List<MatchItem>> getLigaPortugalMatches() async {
    return await getMatchPredictions('liga-portugal-matches/');
  }

  Future<List<MatchItem>> getUEFACLMatches() async {
    return await getMatchPredictions('uefa-cl-matches/');
  }

  Future<List<MatchItem>> getDutchEredivisieMatches() async {
    return await getMatchPredictions('dutch-eredivisie-matches/');
  }

  Future<List<MatchItem>> getTurkishSuperLigMatches() async {
    return await getMatchPredictions('turkish-super-lig-matches/');
  }

  Future<List<MatchItem>> getEuropaLeagueMatches() async {
    return await getMatchPredictions('europa-league-matches/');
  }

  Future<List<MatchItem>> getWorldCupQualificationMatches() async {
    return await getMatchPredictions('worldcup-qualification-matches/');
  }

  Future<List<MatchItem>> getWorldCupQualificationAfricaMatches() async {
    return await getMatchPredictions('worldcup-qualification-africa-matches/');
  }

  Future<List<MatchItem>> getWorldCupQualificationAsiaMatches() async {
    return await getMatchPredictions('worldcup-qualification-asia-matches/');
  }

  Future<List<MatchItem>> getScottishPremiershipMatches() async {
    return await getMatchPredictions('scottish-premiership-matches/');
  }

  Future<List<MatchItem>> getAFCON2025Matches() async {
    return await getMatchPredictions('afcon-2025-matches/');
  }

  // Betting tips methods - UPDATED FOR YOUR MODELS
  Future<BetOfDayAccumulator?> getBetOfTheDay() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/bet-of-the-day/'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Return a single BTTSWinAccumulator object
        return BetOfDayAccumulator.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error fetching bet of the day: $e');
      return null;
    }
  }

  Future<BTTSAccumulator?> getBTTSPredictions() async {
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
  }

  // Future<List<Prediction>> getGoalscorerPredictions() async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse('$baseUrl/api/goalscorer/'),
  //       headers: _headers,
  //     );

  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = json.decode(response.body);
  //       return data.map((json) => Prediction.fromJson(json)).toList();
  //     }
  //     return [];
  //   } catch (e) {
  //     print('Error fetching goalscorer predictions: $e');
  //     return [];
  //   }
  // }

  // In api_service.dart - FIX THE getDailyAccumulators METHOD
Future<DailyAccumulator> getDailyAccumulators() async {  // Changed method name to singular
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/api/daily-accumulator/'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      
      // Always return a DailyAccumulator, even if empty
      if (data == null || data.isEmpty) {
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
      // Return empty accumulator on error
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
    // Return empty accumulator on exception
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
}

  // FIX JUST THIS METHOD IN YOUR ApiService:
  Future<BTTSWinAccumulator?> getBTTSWinAccumulator() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/btts-win-accumulator/'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Return a single BTTSWinAccumulator object
        return BTTSWinAccumulator.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error fetching BTTS win accumulator: $e');
      return null;
    }
  }

  Future<Over25GoalsAccumulator?> getOver25GoalsAccumulator() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/over-25-goals-accumulator/'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Return a single Over25GoalsAccumulator object
        return Over25GoalsAccumulator.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error fetching over 2.5 goals accumulator: $e');
      return null;
    }
  }

  // // Helper method to get all league data
  // Future<Map<String, List<Prediction>>> getAllLeagueMatches() async {
  //   final Map<String, List<Prediction>> leagueData = {};
    
  //   // Define all league endpoints
  //   final leagues = {
  //     'La Liga': 'laliga-matches/',
  //     'Premier League': 'epl-matches/',
  //     'EFL Cup': 'efl-cup-matches/',
  //     'Serie A': 'serie-a-matches/',
  //     'Bundesliga': 'bundesliga-matches/',
  //     'Ligue 1': 'ligue1-matches/',
  //     'Eliteserien': 'eliteserien-matches/',
  //     'Swedish Allsvenskan': 'swedish-allsvenskan/',
  //     'Liga Portugal': 'liga-portugal-matches/',
  //     'UEFA Champions League': 'uefa-cl-matches/',
  //     'Dutch Eredivisie': 'dutch-eredivisie-matches/',
  //     'Turkish Super Lig': 'turkish-super-lig-matches/',
  //     'Europa League': 'europa-league-matches/',
  //     'World Cup Qualification': 'worldcup-qualification-matches/',
  //     'World Cup Qualification (Africa)': 'worldcup-qualification-africa-matches/',
  //     'World Cup Qualification (Asia)': 'worldcup-qualification-asia-matches/',
  //     'Scottish Premiership': 'scottish-premiership-matches/',
  //     'AFCON 2025': 'afcon-2025-matches/',
  //   };

  //   // Fetch data for each league
  //   for (var entry in leagues.entries) {
  //     try {
  //       final predictions = await getLeagueMatches(entry.value);
  //       leagueData[entry.key] = predictions;
  //     } catch (e) {
  //       print('Error fetching ${entry.key}: $e');
  //       leagueData[entry.key] = [];
  //     }
  //   }

  //   return leagueData;
  // }

  // Helper method to get all betting tips
  Future<Map<String, dynamic>> getAllBettingTips() async {
    final Map<String, dynamic> tips = {};

    try {
      tips['bet_of_the_day'] = await getBetOfTheDay();
      tips['btts_predictions'] = await getBTTSPredictions();
      // tips['goalscorer_predictions'] = await getGoalscorerPredictions();
      tips['daily_accumulators'] = await getDailyAccumulators();
      tips['btts_win_accumulator'] = await getBTTSWinAccumulator();
      tips['over_25_goals_accumulator'] = await getOver25GoalsAccumulator();
    } catch (e) {
      print('Error fetching betting tips: $e');
    }

    return tips;
  }

  // In api_service.dart, update the getMatchPredictions method
Future<List<MatchItem>> getMatchPredictions(String leagueEndpoint) async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/api/$leagueEndpoint'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final dynamic data = json.decode(response.body);
      
      // If it's already a List, return it
      if (data is List) {
        return data.map((item) => MatchItem.fromJson(item)).toList();
      }
      
      // If it's a Map, handle common patterns
      if (data is Map<String, dynamic>) {
        print('⚠️ League endpoint $leagueEndpoint returned a Map: ${data.keys}');
        
        // Pattern 1: Django REST Framework error
        if (data.containsKey('detail')) {
          print('❌ API Error: ${data['detail']}');
          return [];
        }
        
        // Pattern 2: Custom error format
        if (data.containsKey('error')) {
          print('❌ API Error: ${data['error']}');
          return [];
        }
        
        // Pattern 3: Has matches array
        if (data.containsKey('matches') && data['matches'] is List) {
          return (data['matches'] as List).map((item) => MatchItem.fromJson(item)).toList();
        }
        
        // Pattern 4: Has data array
        if (data.containsKey('data') && data['data'] is List) {
          return (data['data'] as List).map((item) => MatchItem.fromJson(item)).toList();
        }
        
        // Pattern 5: Single match (unlikely but possible)
        try {
          final match = MatchItem.fromJson(data);
          return [match];
        } catch (e) {
          print('❌ Could not parse as single match: $e');
        }
        
        return [];
      }
      
      // Any other type
      print('❌ Unexpected response type for $leagueEndpoint: ${data.runtimeType}');
      return [];
      
    } else if (response.statusCode == 404) {
      print('❌ Endpoint $leagueEndpoint not found (404)');
      return [];
    } else {
      print('❌ HTTP ${response.statusCode} for $leagueEndpoint');
      print('Response: ${response.body}');
      return [];
    }
  } catch (e) {
    print('❌ Exception for $leagueEndpoint: $e');
    return [];
  }
}

// Also add this method for league predictions
Future<List<MatchItem>> fetchLeagueMatches(String endpoint) async {
  return await getMatchPredictions(endpoint);
}

  // Get all accumulator types in one call
  // Future<List<Accumulator>> getAllAccumulators() async {
  //   final List<Accumulator> allAccumulators = [];
    
  //   try {
  //     final daily = await getDailyAccumulators();
  //     final bttsWin = await getBTTSWinAccumulator();
  //     final over25 = await getOver25GoalsAccumulator();
      
  //     // allAccumulators.addAll(daily);
  //     // allAccumulators.addAll(bttsWin);
  //     // allAccumulators.addAll(over25);
  //   } catch (e) {
  //     print('Error fetching all accumulators: $e');
  //   }
    
  //   return allAccumulators;
  // }

  // Filter predictions by date
  // Future<List<Prediction>> getPredictionsByDate(DateTime date, String league) async {
  //   final predictions = await getLeagueMatches('${league.toLowerCase().replaceAll(' ', '-')}-matches/');
    
  //   return predictions.where((prediction) {
  //     return prediction.matchTime.year == date.year &&
  //            prediction.matchTime.month == date.month &&
  //            prediction.matchTime.day == date.day;
  //   }).toList();
  // }

  // Get predictions by league
  // Future<List<Prediction>> getPredictionsByLeague(String leagueName) async {
  //   final leagueMap = {
  //     'La Liga': 'laliga',
  //     'Premier League': 'epl',
  //     'Bundesliga': 'bundesliga',
  //     'Serie A': 'serie-a',
  //     'Ligue 1': 'ligue1',
  //     'Champions League': 'uefa-cl',
  //     'Europa League': 'europa-league',
  //   };
    
  //   final endpoint = leagueMap[leagueName] ?? leagueName.toLowerCase().replaceAll(' ', '-');
  //   return await getLeagueMatches('$endpoint-matches/');
  // }

  // Subscription and contact methods
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
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/contact-us/'),
        headers: _headers,
        body: json.encode({
          'name': name,
          'email': email,
          'category': category,
          'message': message,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error submitting contact form: $e');
      return false;
    }
  }
}