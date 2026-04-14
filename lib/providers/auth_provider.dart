import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class AuthProvider extends ChangeNotifier {
  UserProfile? _currentUser;
  bool _isLoggedIn = false;
  bool _isFirstTimeUser = true;
  bool _isLoading = true;

  UserProfile? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isFirstTimeUser => _isFirstTimeUser;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    _isFirstTimeUser = prefs.getBool('isFirstTimeUser') ?? true;

    final userJson = prefs.getString('currentUser');
    if (userJson != null) {
      _currentUser = UserProfile.fromJsonString(userJson);
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();

    // Check stored credentials (local mock auth)
    final storedEmail = prefs.getString('user_email');
    final storedPassword = prefs.getString('user_password');

    if (storedEmail == email && storedPassword == password) {
      _isLoggedIn = true;
      await prefs.setBool('isLoggedIn', true);

      // Load user profile
      final userJson = prefs.getString('currentUser');
      if (userJson != null) {
        _currentUser = UserProfile.fromJsonString(userJson);
      }

      // Check if questionnaire was completed
      _isFirstTimeUser = prefs.getBool('isFirstTimeUser') ?? true;

      notifyListeners();
      return true;
    }

    return false;
  }

  Future<bool> signup(String name, String email, String password) async {
    final prefs = await SharedPreferences.getInstance();

    // Store credentials
    await prefs.setString('user_email', email);
    await prefs.setString('user_password', password);

    // Create initial user profile
    _currentUser = UserProfile(name: name, email: email);
    await prefs.setString('currentUser', _currentUser!.toJsonString());

    _isLoggedIn = true;
    _isFirstTimeUser = true;
    await prefs.setBool('isLoggedIn', true);
    await prefs.setBool('isFirstTimeUser', true);

    notifyListeners();
    return true;
  }

  Future<void> updateProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    _currentUser = profile;
    await prefs.setString('currentUser', profile.toJsonString());
    notifyListeners();
  }

  Future<void> completeQuestionnaire() async {
    final prefs = await SharedPreferences.getInstance();
    _isFirstTimeUser = false;
    await prefs.setBool('isFirstTimeUser', false);
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = false;
    await prefs.setBool('isLoggedIn', false);
    notifyListeners();
  }
}
