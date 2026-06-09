import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider() {
    _checkLoginState();
  }

  bool _isLoggedIn = false;
  bool _isLoading = true;
  String? _errorMessage;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> _checkLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String userId, String password) async {
    _errorMessage = null;

    if (userId.trim() == AppConstants.hardcodedUserId &&
        password == AppConstants.hardcodedPassword) {
      _isLoggedIn = true;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyIsLoggedIn, true);
      notifyListeners();
      return true;
    } else {
      _errorMessage = 'Invalid User ID or Password';
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoggedIn = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyIsLoggedIn, false);
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
