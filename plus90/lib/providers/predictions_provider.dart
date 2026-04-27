// predictions_provider.dart
import 'package:flutter/material.dart';
import 'package:plus90/models/betofday_model.dart';
import 'package:plus90/models/btts_model.dart';
import 'package:plus90/models/over2.5_goals_model.dart';
import '../services/api_service.dart';
import '../models/btts_win_model.dart';
import '../models/daily_accumulator_model.dart';
import '../models/betofday_model.dart';
import '../models/btts_model.dart';
import '../models/league_model.dart'; // Import league_model.dart

class PredictionsProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  // Change to MatchItem
  final Map<String, List<MatchItem>> _leagueMatches = {};
  
  // Accumulators
  BTTSWinAccumulator? _bttsWinAccumulator;
  BTTSWinAccumulator? get bttsWinAccumulator => _bttsWinAccumulator;

  DailyAccumulator? _dailyAccumulator;
  DailyAccumulator? get dailyAccumulator => _dailyAccumulator;

  BetOfDayAccumulator? _betOfDayAccumulator;
  BetOfDayAccumulator? get betOfDayAccumulator => _betOfDayAccumulator;

  Over25GoalsAccumulator? _over25GoalsAccumulator;
  Over25GoalsAccumulator? get over25GoalsAccumulator => _over25GoalsAccumulator;

  BTTSAccumulator? _bttsAccumulator;
  BTTSAccumulator? get bttsAccumulator => _bttsAccumulator;

  // Loading states
  bool _isLoading = false;
  bool _isLoadingLeagueMatches = false;
  String? _error;

  // Getters - Update to MatchItem
  Map<String, List<MatchItem>> get leagueMatches => _leagueMatches;
  List<String> get availableLeagues => _leagueMatches.keys.toList();
  
  // Update to return MatchItem
  List<MatchItem> get freeTips {
    final List<MatchItem> tips = [];
    for (var league in _leagueMatches.values) {
      if (league.isNotEmpty) {
        tips.add(league.first);
        if (league.length > 1) {
          tips.add(league[1]);
        }
      }
    }
    return tips.take(4).toList();
  }
  
  // Update to return MatchItem
  List<MatchItem> get todayTips {
    final List<MatchItem> allTips = [];
    for (var league in _leagueMatches.values) {
      allTips.addAll(league);
    }
    return allTips;
  }
  
  // Get matches count
  int get todayTipsCount => todayTips.length;
  
  // Get accumulator counts
  int get bttsWinCount => _bttsWinAccumulator?.count ?? 0;
  int get over25GoalsCount => _over25GoalsAccumulator?.count ?? 0;
  int get dailyAccumulatorCount => _dailyAccumulator?.count ?? 0;
  int get bttsCount => _bttsAccumulator?.count ?? 0;

  bool get isLoading => _isLoading;
  bool get isLoadingLeagueMatches => _isLoadingLeagueMatches;
  String? get error => _error;

  // Fetch all data
  Future<void> fetchAllPredictions() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch league matches
      await fetchLeagueMatches();
      
      // Fetch all accumulators
      await Future.wait([
        _fetchBTTSPredictions(),
        _fetchBTTSWinAccumulator(),
        _fetchOver25GoalsAccumulator(),
        _fetchDailyAccumulator(),
        _fetchBetOfTheDay(),
      ]);

      _error = null;
    } catch (e) {
      _error = 'Failed to load predictions: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fetch league matches - Update to use MatchItem
  Future<void> fetchLeagueMatches() async {
    _isLoadingLeagueMatches = true;
    notifyListeners();

    try {
      // Use League.topLeagues from league_model.dart
      for (var league in League.topLeagues) {
        try {
          final matches = await _apiService.getMatchPredictions(league.apiEndpoint);
          if (matches.isNotEmpty) {
            _leagueMatches[league.name] = matches;
          }
        } catch (e) {
          print('Error loading ${league.name}: $e');
        }
      }

      _error = null;
    } catch (e) {
      _error = 'Failed to load league matches: $e';
    } finally {
      _isLoadingLeagueMatches = false;
      notifyListeners();
    }
  }

  // Individual fetch methods for accumulators (keep as is)
  Future<void> _fetchBTTSWinAccumulator() async {
    try {
      _bttsWinAccumulator = await _apiService.getBTTSWinAccumulator();
    } catch (e) {
      print('Error fetching BTTS Win accumulator: $e');
    }
  }

  Future<void> _fetchOver25GoalsAccumulator() async {
    try {
      _over25GoalsAccumulator = await _apiService.getOver25GoalsAccumulator();
    } catch (e) {
      print('Error fetching Over 2.5 Goals accumulator: $e');
    }
  }

  Future<void> _fetchDailyAccumulator() async {
    try {
      _dailyAccumulator = await _apiService.getDailyAccumulators();
    } catch (e) {
      print('Error fetching Daily accumulator: $e');
    }
  }

  Future<void> _fetchBTTSPredictions() async {
    try {
      _bttsAccumulator = await _apiService.getBTTSPredictions();
    } catch (e) {
      print('Error fetching BTTS predictions: $e');
    }
  }

  Future<void> _fetchBetOfTheDay() async {
    try {
      _betOfDayAccumulator = await _apiService.getBetOfTheDay();
    } catch (e) {
      print('Error fetching Bet of the Day: $e');
    }
  }

  // Refresh specific league predictions
  Future<void> refreshLeagueMatches(String leagueName) async {
    try {
      // Find the league in League.topLeagues
      final league = League.topLeagues.firstWhere(
        (l) => l.name == leagueName,
        orElse: () => League(
          name: '',
          country: '',
          icon: Icons.sports_soccer,
          color: Colors.grey,
          description: '',
          apiEndpoint: '',
        ),
      );
      
      if (league.apiEndpoint.isNotEmpty) {
        final matches = await _apiService.getMatchPredictions(league.apiEndpoint);
        _leagueMatches[leagueName] = matches;
        notifyListeners();
      }
    } catch (e) {
      print('Error refreshing $leagueName: $e');
    }
  }

  // Get league matches by league name - Update to return MatchItem
  List<MatchItem> getLeagueMatches(String league) {
    return _leagueMatches[league] ?? [];
  }

  // Get league data from League model
  List<League> getLeagueData() {
    return League.topLeagues;
  }

  // Get total match count for a league
  int getMatchCountForLeague(String league) {
    return _leagueMatches[league]?.length ?? 0;
  }

  // Check if a league has matches
  bool hasLeagueMatches(String league) {
    return _leagueMatches.containsKey(league) && 
           _leagueMatches[league]!.isNotEmpty;
  }
}