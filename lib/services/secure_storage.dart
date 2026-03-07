// lib/services/secure_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static final SecureStorage _instance = SecureStorage._internal();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  factory SecureStorage() {
    return _instance;
  }
  
  SecureStorage._internal();
  
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }
  
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
  
  Future<void> saveUserData(String userData) async {
    await _storage.write(key: 'user_data', value: userData);
  }
  
  Future<String?> getUserData() async {
    return await _storage.read(key: 'user_data');
  }
  
  Future<void> clearAll() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'user_data');
  }
}