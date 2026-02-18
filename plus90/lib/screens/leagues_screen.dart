// screens/leagues_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/predictions_provider.dart';
import '../widgets/prediction_card.dart';
import '../theme/app_theme.dart';
import '../models/league_model.dart';

class LeaguesScreen extends StatefulWidget {
  final Function(int) onNavigate;
  const LeaguesScreen({super.key, required this.onNavigate});

  @override
  State<LeaguesScreen> createState() => _LeaguesScreenState();
}

class _LeaguesScreenState extends State<LeaguesScreen> {
  final Map<String, bool> _expandedLeagues = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PredictionsProvider>();
      if (provider.leagueMatches.isEmpty) {
        provider.fetchLeagueMatches();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final predictionsProvider = context.watch<PredictionsProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Navigate to Home tab (index 0)
            widget.onNavigate(0);
          },
        ),
        title: const Text('Leagues'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              predictionsProvider.fetchLeagueMatches();
            },
          ),
        ],
      ),
      body: predictionsProvider.isLoadingLeagueMatches
          ? const Center(child: CircularProgressIndicator())
          : _buildLeagueList(predictionsProvider),
    );
  }

  Widget _buildLeagueList(PredictionsProvider provider) {
    final leagues = provider.availableLeagues;
    
    if (leagues.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.sports_soccer, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No league predictions available',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                provider.fetchLeagueMatches();
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: leagues.length,
      itemBuilder: (context, index) {
        final leagueName = leagues[index];
        final matches = provider.getLeagueMatches(leagueName);
        final isExpanded = _expandedLeagues[leagueName] ?? false;
        
        // Get league data from League model
        final league = provider.getLeagueData().firstWhere(
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
              // League Header
              GestureDetector(
                onTap: () {
                  setState(() {
                    _expandedLeagues[leagueName] = !isExpanded;
                  });
                },
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
              
              // Matches List
              if (isExpanded)
                _buildMatchesList(matches, leagueName),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMatchesList(List<MatchItem> matches, String leagueName) {
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
        ],
      ),
    );
  }
}