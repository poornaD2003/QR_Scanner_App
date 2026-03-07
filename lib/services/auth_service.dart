// lib/services/auth_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../modles/user.dart';
import 'api_service.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _sessionCartKey = 'session_cart';

  // Login
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      print('🔐 Attempting login to: ${ApiService.baseUrl}/auth/login');
      
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );
      
      print('📡 Login response status: ${response.statusCode}');
      print('📡 Login response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true) {
          final String? token = data['token'];
          final Map<String, dynamic>? userData = data['user'];
          final String? sessionCart = data['sessionCart'];
          
          print('📊 Parsed data:');
          print('  - Token: ${token != null}');
          print('  - User: ${userData != null}');
          print('  - sessionCart: $sessionCart');
          
          if (token != null && userData != null) {
            // Save login data
            await _saveLoginData(token, userData);
            
            // Save session cart separately if it exists
            if (sessionCart != null) {
              await saveSessionCart(sessionCart);  // Use public method
              print('✅ Session cart saved: $sessionCart');
            } else {
              print('ℹ️ No session cart returned');
            }
            
            return {
              'success': true,
              'user': User.fromJson(userData),
              'token': token,
              'sessionCart': sessionCart,
            };
          }
        }
        return {'success': false, 'message': 'Invalid server response'};
      } else if (response.statusCode == 401) {
        return {'success': false, 'message': 'Invalid username or password'};
      } else {
        return {'success': false, 'message': 'Login failed: ${response.statusCode}'};
      }
    } catch (e) {
      print('❌ Login error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // PUBLIC method to save session cart (was private before)
  static Future<void> saveSessionCart(String cartId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionCartKey, cartId);
    print('✅ Session cart saved: $cartId');
  }

  // Get session cart
  static Future<String?> getSessionCart() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_sessionCartKey);
  }

  // Clear session cart
  static Future<void> clearSessionCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionCartKey);
    print('✅ Session cart cleared');
  }

  // Save login data (private)
  static Future<void> _saveLoginData(String token, Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    
    final user = User.fromJson(userData);
    await prefs.setString(_userKey, json.encode(user.toJson()));
    
    print('✅ Login data saved - User: ${user.username}');
  }

  // Get token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Get current user
  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    
    if (userJson != null) {
      try {
        final Map<String, dynamic> userMap = json.decode(userJson);
        return User.fromJson(userMap);
      } catch (e) {
        print('❌ Error parsing user: $e');
        return null;
      }
    }
    return null;
  }

  // Verify token
  static Future<bool> verifyToken(String token) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/verify'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Token verification error: $e');
      return false;
    }
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_sessionCartKey);
    print('✅ Logged out, all data cleared');
  }

  // Check if logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}