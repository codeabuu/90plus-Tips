// screens/daily_accumulator_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/daily_accumulator_model.dart';

class DailyAccumulatorScreen extends StatefulWidget {
  const DailyAccumulatorScreen({super.key});

  @override
  State<DailyAccumulatorScreen> createState() => _DailyAccumulatorScreenState();
}

class _DailyAccumulatorScreenState extends State<DailyAccumulatorScreen> {
  final ApiService _apiService = ApiService();
  DailyAccumulator? _accumulator;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchDailyAccumulatorData();
  }

  Future<void> _fetchDailyAccumulatorData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final accumulator = await _apiService.getDailyAccumulators();
      
      setState(() {
        _accumulator = accumulator;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load Daily Accumulator predictions';
        _isLoading = false;
      });
      print('Error: $e');
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
            // Header with back button
            _buildHeader(),
            
            if (_isLoading)
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ),
              )
            else if (_errorMessage.isNotEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchDailyAccumulatorData,
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_accumulator == null)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.sports_soccer, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No Daily Accumulator predictions available',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    _buildAccumulatorCard(_accumulator!),
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
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(width: 8),
          // Title
          Expanded(
            child: Text(
              'SCOREWISE',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
                letterSpacing: 1.5,
              ),
            ),
          ),
          // Refresh Button
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.blue),
            onPressed: _fetchDailyAccumulatorData,
          ),
        ],
      ),
    );
  }

Widget _buildAccumulatorCard(DailyAccumulator accumulator) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    margin: const EdgeInsets.only(bottom: 16),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Only (centered like in the image)
          Center(
            child: Text(
              accumulator.type,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 8),
          
          // Date (if you still want to show it but smaller and less prominent)
          Center(
            child: Text(
              DateFormat('dd.MM.yyyy, EEEE').format(accumulator.scrapedAt),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
          SizedBox(height: 8),
          
          // Divider
          Divider(thickness: 1, color: Colors.grey[300]),
          SizedBox(height: 16),
          
          // Matches List
          ...accumulator.matches.map((match) {
            return _buildMatchItem(match);
          }).toList(),
          
          // Divider
          Divider(thickness: 1, color: Colors.grey[300]),
          SizedBox(height: 16),
          
          // Analysis Section Title
          Text(
            'Daily Accumulator Analysis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          
          // What is Daily Accumulator?
          Text(
            'What is a Daily Accumulator?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          SizedBox(height: 8),
          
          // Analysis Description
          Text(
            'Our Daily Accumulator combines the best value bets from today\'s football matches into a single, high-odds accumulator. Each selection is carefully analyzed based on team form, head-to-head statistics, injury news, and tactical setups to maximize your chances of success.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          SizedBox(height: 16),
          
          // Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoBox(
                title: 'Total Odds',
                value: accumulator.totalOdds.toStringAsFixed(2),
                color: Colors.green,
              ),
              _buildInfoBox(
                title: 'Raw Odds',
                value: accumulator.totalOddsRaw.toStringAsFixed(2),
                color: Colors.blue,
              ),
              _buildInfoBox(
                title: 'Matches',
                value: accumulator.count.toString(),
                color: Colors.orange,
              ),
            ],
          ),
          
          // Cache status (optional)
          // if (accumulator.cached)
          //   Padding(
          //     padding: const EdgeInsets.only(top: 12),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: [
          //         Icon(Icons.cloud_done, size: 16, color: Colors.green),
          //         SizedBox(width: 8),
          //         Text(
          //           'Cached data • Live updates every 30 minutes',
          //           style: TextStyle(
          //             fontSize: 12,
          //             color: Colors.grey[600],
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
        ],
      ),
    ),
  );
}

  Widget _buildMatchItem(DailyAccumulatorMatch match) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey[200]!),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Match Title - SHOW THIS ONLY ONCE
        Text(
          match.matchTitle,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 12), // Increased spacing
        
        // Prediction and Date - REMOVED THE DUPLICATE TEAMS ROW
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.purple),
              ),
              child: Text(
                match.prediction,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[700],
                ),
              ),
            ),
            
          ],
        ),
      ],
    ),
  );
}

  Widget _buildInfoBox({required String title, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}