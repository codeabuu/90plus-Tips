import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
  });
}

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  // In a real app, this would handle Google/Firebase auth
  Future<void> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    _currentUser = User(
      id: 'user_123',
      name: 'John Doe',
      email: 'john@example.com',
      photoUrl: null,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    _currentUser = null;
    notifyListeners();
  }

  static AuthProvider of(BuildContext context) {
    return context.read<AuthProvider>();
  }
}