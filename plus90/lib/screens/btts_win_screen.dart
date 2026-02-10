// screens/btts_win_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/btts_win_model.dart';

class BttsWinScreen extends StatefulWidget {
  const BttsWinScreen({super.key});

  @override
  State<BttsWinScreen> createState() => _BttsWinScreenState();
}

class _BttsWinScreenState extends State<BttsWinScreen> {
  final ApiService _apiService = ApiService();
  BTTSWinAccumulator? _accumulator;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchBttsWinData();
  }

  Future<void> _fetchBttsWinData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final accumulator = await _apiService.getBTTSWinAccumulator();
      
      setState(() {
        _accumulator = accumulator;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load BTTS & Win predictions';
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
                        onPressed: _fetchBttsWinData,
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
                        'No BTTS & Win predictions available',
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
            onPressed: _fetchBttsWinData,
          ),
        ],
      ),
    );
  }

Widget _buildAccumulatorCard(BTTSWinAccumulator accumulator) {
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
            'Analyzing Team Scoring Patterns',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          
          // What is BTTS & Win?
          Text(
            'What is a BTTS & Win?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
          SizedBox(height: 8),
          
          // Analysis Description
          Text(
            'This analytical approach examines matches where both teams demonstrate strong offensive capabilities while also considering the likely match outcome based on team form and tactical setups. We focus on games where offensive strength suggests high probability of goals from both sides, combined with clear indicators pointing toward a particular winner.',
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

  Widget _buildMatchItem(BTTSWinMatch match) {
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
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blue),
              ),
              child: Text(
                match.prediction,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ),
            Text(
              match.date,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
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