// models/league_model.dart
import 'package:flutter/material.dart';

class Prediction {
  final String prediction;
  final double? odds;

  Prediction({
    required this.prediction,
    this.odds,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return Prediction(
      prediction: json['prediction'] ?? '',
      odds: json['odds'] != null ? double.tryParse(json['odds'].toString()) : null,
    );
  }
}

class MatchItem {
  final String teams;
  final String date;
  final String time;
  final String homeTeam;
  final String awayTeam;
  final List<Prediction> predictions;
  final String detailLink;

  MatchItem({
    required this.teams,
    required this.date,
    this.time = '',
    required this.homeTeam,
    required this.awayTeam,
    required this.predictions,
    required this.detailLink,
  });

  factory MatchItem.fromJson(Map<String, dynamic> json) {
    return MatchItem(
      teams: json['teams'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      homeTeam: json['home_team'] ?? '',
      awayTeam: json['away_team'] ?? '',
      predictions: (json['predictions'] as List? ?? [])
          .map((prediction) => Prediction.fromJson(prediction))
          .toList(),
      detailLink: json['detail_link'] ?? '',
    );
  }
}

class LeagueMatchesResponse {
  final List<MatchItem> matches;
  final String message;
  final bool available;

  LeagueMatchesResponse({
    required this.matches,
    required this.message,
    required this.available,
  });

  factory LeagueMatchesResponse.fromJson(Map<String, dynamic> json) {
    return LeagueMatchesResponse(
      matches: (json['matches'] as List? ?? [])
          .map((match) => MatchItem.fromJson(match))
          .toList(),
      message: json['message'] ?? '',
      available: json['available'] ?? false,
    );
  }
}

class League {
  final String name;
  final String country;
  final IconData icon;
  final Color color;
  final String description;
  final String apiEndpoint;
  final String? imagePath;

  League({
    required this.name,
    required this.country,
    required this.icon,
    required this.color,
    required this.description,
    required this.apiEndpoint,
    this.imagePath,
  });

  static List<League> topLeagues = [
    League(
      name: 'English Premier League',
      country: 'England',
      icon: Icons.sports_soccer,
      color: Colors.purple,
      description: 'View predictions for the top English league',
      apiEndpoint: 'epl-matches/',
      // imagePath: 'assets/images/EPL.png',
    ),
    League(
      name: 'Spanish La Liga',
      country: 'Spain',
      icon: Icons.sports_soccer,
      color: Colors.orange,
      description: 'Spanish football predictions and insights',
      apiEndpoint: 'laliga-matches/',
      // imagePath: 'assets/images/LALIGA.png',
    ),
    League(
      name: 'Italian Serie A',
      country: 'Italy',
      icon: Icons.sports_soccer,
      color: Colors.blue,
      description: 'Italian Serie A match predictions',
      apiEndpoint: 'serie-a-matches/',
      // imagePath: 'assets/images/SERIE.png',
    ),
    League(
      name: 'German Bundesliga',
      country: 'Germany',
      icon: Icons.sports_soccer,
      color: Colors.red,
      description: 'German Bundesliga expert tips',
      apiEndpoint: 'bundesliga-matches/',
      // imagePath: 'assets/images/BUNDESLIGA.png',
    ),
    League(
      name: 'French Ligue 1',
      country: 'France',
      icon: Icons.sports_soccer,
      color: Colors.blue,
      description: 'French Ligue 1 predictions',
      apiEndpoint: 'ligue1-matches/',
      // imagePath: 'assets/images/LIGUE1.png',
    ),
    League(
      name: 'UEFA Champions League',
      country: 'Europe',
      icon: Icons.emoji_events,
      color: Colors.indigo,
      description: 'UEFA Champions League predictions',
      apiEndpoint: 'uefa-cl-matches/',
      // imagePath: 'assets/images/UCL.png',
    ),
    League(
      name: 'EFL Cup',
      country: 'England',
      icon: Icons.sports_soccer,
      color: Colors.green,
      description: 'English EFL Cup predictions',
      apiEndpoint: 'efl-cup-matches/',
      // imagePath: 'assets/images/EFL.png',
    ),
    League(
      name: 'Eliteserien',
      country: 'Norway',
      icon: Icons.sports_soccer,
      color: Colors.red,
      description: 'Norwegian Eliteserien predictions',
      apiEndpoint: 'eliteserien-matches/',
      // imagePath: 'assets/images/ELITESERIEN.png',
    ),
    League(
      name: 'Swedish Allsvenskan',
      country: 'Sweden',
      icon: Icons.sports_soccer,
      color: Colors.yellow,
      description: 'Swedish Allsvenskan predictions',
      apiEndpoint: 'swedish-allsvenskan/',
      // imagePath: 'assets/images/SWEALV.png',
    ),
    League(
      name: 'Liga Portugal',
      country: 'Portugal',
      icon: Icons.sports_soccer,
      color: Colors.green,
      description: 'Portuguese Liga predictions',
      apiEndpoint: 'liga-portugal-matches/',
      // imagePath: 'assets/images/LIGAPOR.png',
    ),
    League(
      name: 'Dutch Eredivisie',
      country: 'Netherlands',
      icon: Icons.sports_soccer,
      color: Colors.green,
      description: 'Dutch Eredivisie predictions',
      apiEndpoint: 'dutch-eredivisie-matches/',
      // imagePath: 'assets/images/EREDIVISIE.png',
    ),
    League(
      name: 'Turkish Super Lig',
      country: 'Turkey',
      icon: Icons.sports_soccer,
      color: Colors.red,
      description: 'Turkish Super Lig predictions',
      apiEndpoint: 'turkish-super-lig-matches/',
      // imagePath: 'assets/images/SUPERLIG.png',
    ),
    League(
      name: 'Europa League',
      country: 'Europe',
      icon: Icons.sports_soccer,
      color: Colors.red,
      description: 'UEFA Europa League predictions',
      apiEndpoint: 'europa-league-matches/',
      // imagePath: 'assets/images/EUROPA.png',
    ),
    League(
      name: 'Scottish Premiership',
      country: 'Scotland',
      icon: Icons.sports_soccer,
      color: Colors.green,
      description: 'Scottish Premiership predictions',
      apiEndpoint: 'scottish-premiership-matches/',
      // imagePath: 'assets/images/SCOTTISH.png',
    ),
    League(
      name: 'World Cup Qualification',
      country: 'World',
      icon: Icons.sports_soccer,
      color: Colors.blue,
      description: 'World Cup Qualification predictions',
      apiEndpoint: 'worldcup-qualification-matches/',
      // imagePath: 'assets/images/WCQ.jpg',
    ),
    League(
      name: 'AFCON 2025',
      country: 'Africa',
      icon: Icons.sports_soccer,
      color: Colors.red,
      description: 'Africa Cup of Nations predictions',
      apiEndpoint: 'afcon-2025-matches/',
      // imagePath: 'assets/images/afcon2025.jpg',
    ),
  ];
}