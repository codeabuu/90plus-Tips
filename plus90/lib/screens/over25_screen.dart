// screens/over_25_goals_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/over2.5_goals_model.dart';

class Over25GoalsScreen extends StatefulWidget {
  const Over25GoalsScreen({super.key});

  @override
  State<Over25GoalsScreen> createState() => _Over25GoalsScreenState();
}

class _Over25GoalsScreenState extends State<Over25GoalsScreen> {
  final ApiService _apiService = ApiService();
  Over25GoalsAccumulator? _accumulator;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchOver25GoalsData();
  }

  Future<void> _fetchOver25GoalsData() async {
  setState(() {
    _isLoading = true;
    _errorMessage = '';
  });

  try {
    final accumulator = await _apiService.getOver25GoalsAccumulator();
    
    // Check if accumulator is null or has no matches
    if (accumulator == null || accumulator.matches.isEmpty) {
      setState(() {
        _accumulator = null;
        _isLoading = false;
      });
    } else {
      setState(() {
        _accumulator = accumulator;
        _isLoading = false;
      });
    }
  } catch (e) {
    setState(() {
      _errorMessage = 'Failed to load Over 2.5 Goals predictions';
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Loading Over 2.5 Goals predictions...',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
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
                      Icon(Icons.error_outline, size: 64, color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchOver25GoalsData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_accumulator == null || _accumulator!.matches.isEmpty)
              _buildNoPredictionsView()
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

  Widget _buildNoPredictionsView() {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 80,
                color: Colors.blue.withOpacity(0.5),
              ),
              SizedBox(height: 24),
              Text(
                'No Over 2.5 Goals Tips Available',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                'Our experts are currently analyzing matches and will have Over 2.5 Goals predictions available soon.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _fetchOver25GoalsData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Check Again'),
              ),
              SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Back to Home',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
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
          // Refresh Button - Only show when we have predictions
          if (_accumulator != null && _accumulator!.matches.isNotEmpty)
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.blue),
              onPressed: _fetchOver25GoalsData,
            ),
        ],
      ),
    );
  }

  Widget _buildAccumulatorCard(Over25GoalsAccumulator accumulator) {
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
            
            // Date
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
              'Analyzing Goal Scoring Patterns',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            SizedBox(height: 8),
            
            // What is Over 2.5 Goals?
            Text(
              'What is Over 2.5 Goals?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            SizedBox(height: 8),
            
            // Analysis Description
            Text(
              'This analytical approach examines matches where both teams demonstrate strong offensive capabilities and high-scoring tendencies. We focus on games where team form, attacking statistics, and historical data suggest a high probability of at least 3 total goals being scored in the match.',
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
            
            // Last updated info
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 14, color: Colors.grey[500]),
                  SizedBox(width: 6),
                  Text(
                    'Data updated ${DateFormat('HH:mm').format(accumulator.scrapedAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
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

  Widget _buildMatchItem(Over25GoalsMatch match) {
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
          // Match Title
          Text(
            match.matchTitle,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 12),
          
          // Prediction and Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green),
                ),
                child: Text(
                  match.prediction,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
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