import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool _isLoading = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  // For local development
  final String baseUrl = 'http://192.168.8.205:3000/api';
  // For production (use this when deployed)
  // final String baseUrl = 'https://your-backend-url.onrender.com/api';

  Future<void> _signUp() async {
    // Validation
    if (_usernameController.text.isEmpty) {
      _showDialog('Error', 'Username is required');
      return;
    }
    
    if (_passwordController.text.isEmpty) {
      _showDialog('Error', 'Password is required');
      return;
    }
    
    if (_passwordController.text.length < 6) {
      _showDialog('Error', 'Password must be at least 6 characters');
      return;
    }
    
    if (_passwordController.text != _confirmPasswordController.text) {
      _showDialog('Error', 'Passwords do not match');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Try to create user via your backend
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': _usernameController.text,
          'password': _passwordController.text,
          'role': 'customer',
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          _showDialog('Success', 'Account created successfully!', isSuccess: true);
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) Navigator.pushReplacementNamed(context, '/login');
          });
        }
      } else {
        final error = json.decode(response.body);
        if (mounted) {
          _showDialog('Error', error['error'] ?? 'Failed to create account');
        }
      }
    } catch (e) {
      print('Signup error: $e');
      if (mounted) {
        _showDialog('Error', 'Connection failed. Please check your internet.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showDialog(String title, String message, {bool isSuccess = false}) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isSuccess ? 'OK' : 'Try Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       
        backgroundColor: const Color.fromARGB(255, 146, 233, 117),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                
                // Username field
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Password field
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Confirm password field
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                ),
                const SizedBox(height: 32),
                
                // Sign Up button (your code)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : _signUp,
                    
                      
                    
                    
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 16,
                              color: const Color.fromARGB(255, 21, 192, 52),
                            ),
                          ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: const Color.fromARGB(255, 81, 192, 21), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Login link
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context,'/login'),
                  child: const Text(
                    'Already have an account? Login',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}