// screens/predictions_screen.dart
import 'package:flutter/material.dart';
import '../widgets/prediction_card.dart';
import '../services/api_service.dart';
import '../models/league_model.dart';
import '../theme/app_theme.dart'; // Add this to use AppTheme

class PredictionsScreen extends StatefulWidget {
  const PredictionsScreen({super.key});

  @override
  State<PredictionsScreen> createState() => _PredictionsScreenState();
}

class _PredictionsScreenState extends State<PredictionsScreen> {
  final ApiService _apiService = ApiService();
  
  // Map to store league predictions
  final Map<String, List<MatchItem>> _leaguePredictions = {};
  
  // Map to track expanded state - all leagues expanded by default
  final Map<String, bool> _expandedLeagues = {};
  
  // Loading states
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
      // Clear existing data
      _leaguePredictions.clear();
      
      // Load all league data
      for (var league in _leagues) {
        try {
          final predictions = await _apiService.getMatchPredictions(league.apiEndpoint);
          if (predictions.isNotEmpty) {
            _leaguePredictions[league.name] = predictions;
            // Set all leagues with predictions to expanded by default
            _expandedLeagues[league.name] = true;
          }
        } catch (e) {
          print('Error loading ${league.name}: $e');
        }
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
          // Ensure the league remains expanded after refresh
          _expandedLeagues[leagueName] = true;
        });
      }
    } catch (e) {
      print('Error refreshing $leagueName: $e');
      rethrow;
    }
  }

  Future<void> _refreshAllLeagues() async {
    setState(() {
      _initialLoading = true;
    });
    await _loadAllLeagues();
  }

  void _toggleLeagueExpansion(String leagueName) {
    setState(() {
      _expandedLeagues[leagueName] = !(_expandedLeagues[leagueName] ?? false);
    });
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
                      const CircularProgressIndicator(
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
                child: RefreshIndicator(
                  onRefresh: _refreshAllLeagues,
                  child: _buildLeaguesList(),
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
            onPressed: _refreshAllLeagues,
          ),
        ],
      ),
    );
  }

  Widget _buildLeaguesList() {
    // Get leagues that have predictions, sorted alphabetically
    final leaguesWithPredictions = _leaguePredictions.keys.toList()..sort();
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: leaguesWithPredictions.length,
      itemBuilder: (context, index) {
        final leagueName = leaguesWithPredictions[index];
        final matches = _leaguePredictions[leagueName] ?? [];
        final isExpanded = _expandedLeagues[leagueName] ?? true; // Default to expanded
        
        // Get league data from League model
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
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // League Header - Exactly like LeaguesScreen
              GestureDetector(
                onTap: () => _toggleLeagueExpansion(leagueName),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.neutralGray,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      // League Icon with color
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
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryNavy,
                              ),
                            ),
                            Text(
                              league.country,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Match Count Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${matches.length} matches',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Matches List - Only show if expanded
              if (isExpanded)
                _buildMatchesList(matches, leagueName, league),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMatchesList(List<MatchItem> matches, String leagueName, League league) {
    if (matches.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(
              Icons.event_available,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 12),
            Text(
              'No matches available for $leagueName',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _refreshLeague(leagueName),
              child: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // League info header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${matches.length} matches with expert predictions',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
                // Add a small refresh button for this league
                IconButton(
                  icon: const Icon(Icons.refresh, size: 18),
                  color: Colors.blue[700],
                  onPressed: () => _refreshLeague(leagueName),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          
          // Match cards
          ...matches.map((matchItem) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PredictionCard(matchItem: matchItem),
            );
          }).toList(),
          
          // Footer for this league - only show if there are matches
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.trending_up, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Expert analysis and predictions for ${league.name}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}