// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../modles/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;
  String? _token;
  String? _sessionCart;  // Session cart stored separately
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  String? get token => _token;
  String? get sessionCart => _sessionCart;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _token != null && _currentUser != null;
  bool get isAdmin => _currentUser?.role?.toLowerCase() == 'admin';
  bool get isCustomer => _currentUser?.role?.toLowerCase() == 'customer';

 Future<Map<String, dynamic>> login(String username, String password) async {
  _isLoading = true;
  notifyListeners();

  try {
    final result = await AuthService.login(username, password);
    
    if (result['success'] == true) {
      _currentUser = result['user'];
      _token = await AuthService.getToken();
      _sessionCart = result['sessionCart'];
      
      print('✅ AuthProvider: Login successful');
      print('👤 User: ${_currentUser?.username}');
      print('🛒 Session Cart: $_sessionCart');
      print('🔑 Token: ${_token != null}');
    }
    
    return result;
  } catch (e) {
    print('❌ AuthProvider error: $e');
    return {'success': false, 'message': 'Login error: $e'};
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}


  Future<void> logout() async {
    await AuthService.logout();
    _currentUser = null;
    _token = null;
    _sessionCart = null;
    notifyListeners();
    print('✅ AuthProvider: Logged out');
  }

  Future<bool> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await AuthService.getToken();
      final user = await AuthService.getCurrentUser();
      final sessionCart = await AuthService.getSessionCart();  // Get session cart
      
      print('🔍 Checking auth - Token: ${token != null}, User: ${user != null}, Cart: $sessionCart');
      
      if (token != null && user != null) {
        final isValid = await AuthService.verifyToken(token);
        
        if (isValid) {
          _currentUser = user;
          _token = token;
          _sessionCart = sessionCart;
          return true;
        } else {
          await AuthService.logout();
        }
      }
      
      _currentUser = null;
      _token = null;
      _sessionCart = null;
      return false;
    } catch (e) {
      print('❌ AuthProvider check error: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> getToken() async {
    if (_token != null) return _token;
    _token = await AuthService.getToken();
    return _token;
  }

  Future<String?> getSessionCart() async {
    if (_sessionCart != null) return _sessionCart;
    _sessionCart = await AuthService.getSessionCart();
    return _sessionCart;
  }

  // Clear session cart after checkout
  Future<void> clearSessionCart() async {
    await AuthService.clearSessionCart();
    _sessionCart = null;
    notifyListeners();
  }
}