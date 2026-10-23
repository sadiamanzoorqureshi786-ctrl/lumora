import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_service.dart';

/// Ports App.js's token/localStorage + /api/auth/me flow.
/// React: localStorage.getItem('token') on mount, then fetchUserData().
/// Flutter: SharedPreferences is the equivalent persistent client storage.
class AuthProvider extends ChangeNotifier {
  String? _token;
  AppUser? _user;
  bool _loading = true;
  String? _error;

  String? get token => _token;
  AppUser? get user => _user;
  bool get loading => _loading;
  bool get isAuthenticated => _token != null && _user != null;
  String? get error => _error;

  ApiService get api => ApiService(token: _token);

  Future<void> init() async {
    _loading = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final storedToken = prefs.getString('token');
    if (storedToken != null) {
      _token = storedToken;
      await _fetchUser();
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> _fetchUser() async {
    try {
      final data = await api.getMe();
      _user = AppUser.fromJson(data);
    } catch (_) {
      // Invalid/expired token — mirrors App.js clearing it on /me failure.
      await logout();
    }
  }

  Future<void> signIn(String email, String password) async {
    final data = await api.signIn(email, password);
    await _persistLogin(data);
  }

  Future<void> signUp(String username, String email, String password) async {
    final data = await api.signUp(username, email, password);
    await _persistLogin(data);
  }

  Future<void> _persistLogin(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    _token = data['token'];
    await prefs.setString('token', _token!);
    _user = AppUser.fromJson(data['user']);
    notifyListeners();
  }

  /// Call this after a successful Settings profile update so the whole app
  /// (Header, Drawer, etc.) reflects the new username/profilePic instantly.
  void updateLocalUser(AppUser updated) {
    _user = updated;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    _token = null;
    _user = null;
    notifyListeners();
  }
}
