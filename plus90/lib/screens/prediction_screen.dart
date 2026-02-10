// screens/predictions_screen.dart
import 'package:flutter/material.dart';
import '../widgets/prediction_card.dart';
import '../services/api_service.dart';
import '../models/league_model.dart'; // Only need league_model.dart

class PredictionsScreen extends StatefulWidget {
  const PredictionsScreen({super.key});

  @override
  State<PredictionsScreen> createState() => _PredictionsScreenState();
}

class _PredictionsScreenState extends State<PredictionsScreen> {
  final ApiService _apiService = ApiService();
  
  // Map to store league predictions
  final Map<String, List<MatchItem>> _leaguePredictions = {};
  
  // Currently selected league
  String? _selectedLeague;
  
  // Loading states
  bool _isLoading = false;
  bool _initialLoading = true;
  String _errorMessage = '';
  
  // List of available leagues - use League.topLeagues
  List<League> get _leagues => League.topLeagues;

  @override
  void initState() {
    super.initState();
    _loadAllLeagues();
  }

  Future<void> _loadAllLeagues() async {
    setState(() {
      _initialLoading = true;
      _errorMessage = '';
    });

    try {
      // Load all league data
      for (var league in _leagues) {
        try {
          final predictions = await _apiService.getMatchPredictions(league.apiEndpoint);
          if (predictions.isNotEmpty) {
            _leaguePredictions[league.name] = predictions;
          }
        } catch (e) {
          print('Error loading ${league.name}: $e');
        }
      }
      
      // Select first league with predictions by default
      if (_leaguePredictions.isNotEmpty) {
        _selectedLeague = _leaguePredictions.keys.first;
      }
      
      setState(() {
        _initialLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load predictions';
        _initialLoading = false;
      });
      print('Error: $e');
    }
  }

  Future<void> _refreshLeague(String leagueName) async {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Find the endpoint for this league
      final league = _leagues.firstWhere(
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
        final predictions = await _apiService.getMatchPredictions(league.apiEndpoint);
        
        setState(() {
          _leaguePredictions[leagueName] = predictions;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to refresh $leagueName';
        _isLoading = false;
      });
      print('Error refreshing $leagueName: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            _buildHeader(),
            
            // Main Content
            if (_initialLoading)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Loading predictions...',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              )
            else if (_errorMessage.isNotEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadAllLeagues,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_leaguePredictions.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.sports_soccer, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'No predictions available',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadAllLeagues,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: Column(
                  children: [
                    // League Selector Dropdown
                    _buildLeagueSelector(),
                    
                    // League Predictions
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _selectedLeague != null 
                            ? () => _refreshLeague(_selectedLeague!)
                            : () async {},
                        child: _buildPredictionsList(),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SCOREWISE',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Today's Tips | Predictions | Leagues",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.blue),
            onPressed: _loadAllLeagues,
          ),
        ],
      ),
    );
  }

  Widget _buildLeagueSelector() {
    final leaguesWithPredictions = _leaguePredictions.keys.toList();
    
    if (leaguesWithPredictions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: const Text(
          'No leagues with predictions available',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select a League',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedLeague,
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.blue),
                iconSize: 24,
                elevation: 16,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedLeague = newValue;
                  });
                },
                items: leaguesWithPredictions.map<DropdownMenuItem<String>>((String leagueName) {
                  // Find league data
                  final league = _leagues.firstWhere(
                    (l) => l.name == leagueName,
                    orElse: () => League(
                      name: leagueName,
                      country: '',
                      icon: Icons.sports_soccer,
                      color: Colors.grey,
                      description: '',
                      apiEndpoint: '',
                    ),
                  );
                  
                  final matchCount = _leaguePredictions[leagueName]?.length ?? 0;
                  
                  return DropdownMenuItem<String>(
                    value: leagueName,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(league.icon, size: 18, color: league.color),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                leagueName,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            Text(
                              '($matchCount)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          league.country,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionsList() {
    if (_selectedLeague == null || 
        _leaguePredictions[_selectedLeague] == null || 
        _leaguePredictions[_selectedLeague]!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_available, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No matches available for $_selectedLeague',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _refreshLeague(_selectedLeague!),
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    final predictions = _leaguePredictions[_selectedLeague]!;
    final league = _leagues.firstWhere(
      (l) => l.name == _selectedLeague,
      orElse: () => League(
        name: _selectedLeague!,
        country: '',
        icon: Icons.sports_soccer,
        color: Colors.grey,
        description: '',
        apiEndpoint: '',
      ),
    );
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // League Header
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: league.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  league.icon,
                  size: 24,
                  color: league.color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      league.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      league.country,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${predictions.length} matches',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Matches List - FIX THIS LINE: pass matchItem instead of matchPrediction
        ...predictions.map((matchItem) {
          return PredictionCard(matchItem: matchItem); // Changed parameter name
        }).toList(),

        // Footer
        Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Upcoming Football Predictions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Looking for accurate football predictions today? At ScoreWise, our experts provide daily football prediction tips & insights covering all major leagues.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}