import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoggingIn = false;
  bool _testingConnection = false;
  String _connectionStatus = '';
  String _loginError = '';

  // Demo credentials
  final List<Map<String, String>> demoUsers = [
    {'username': 'admin', 'password': 'password123', 'role': 'Admin'},
    {'username': 'customer1', 'password': 'password123', 'role': 'Customer'},
  ];

  @override
  void initState() {
    super.initState();
    // Auto-test connection when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _testConnection();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color.fromARGB(255, 125, 233, 71),
              const Color.fromARGB(255, 137, 186, 165),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    Icons.shopping_cart,
                    size: 60,
                    color: const Color.fromARGB(255, 95, 242, 3),
                  ),
                ),
                const SizedBox(height: 20),

                // App Name
                Text(
                  'QR Scanner System',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Smart Shopping Experience',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 40),

                // Login Card
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 63, 237, 15),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Connection Status
                          if (_connectionStatus.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _connectionStatus.contains('✅')
                                    ? Colors.green.shade50
                                    : Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _connectionStatus.contains('✅')
                                      ? Colors.green.shade200
                                      : Colors.orange.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _connectionStatus.contains('✅')
                                        ? Icons.check_circle
                                        : Icons.warning,
                                    color: _connectionStatus.contains('✅')
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _connectionStatus,
                                      style: TextStyle(
                                        color: _connectionStatus.contains('✅')
                                            ? Colors.green.shade800
                                            : Colors.orange.shade800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Login Error
                          if (_loginError.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error, color: Colors.red),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _loginError,
                                      style: TextStyle(
                                        color: Colors.red.shade800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Username Field
                          TextFormField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              labelText: 'Username',
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter username';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password Field
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoggingIn ? null : _handleLogin,
                              child: _isLoggingIn
                                  ? CircularProgressIndicator(
                                      color: const Color.fromARGB(
                                        255,
                                        255,
                                        255,
                                        255,
                                      ),
                                    )
                                  : Text(
                                      'LOGIN',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(
                                  218,
                                  50,
                                  226,
                                  80,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // signup Button
                          SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: OutlinedButton(
                              onPressed: _testingConnection
                                  ? null
                                  : () {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/signup',
                                      );
                                    },
                              child: _testingConnection
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Signup',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: const Color.fromARGB(255, 72, 213, 93),
                                      ),
                                    ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: const Color.fromARGB(255, 21, 192, 35)),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Demo Users Section

                          // Server Info
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _testConnection() async {
    setState(() {
      _testingConnection = true;
      _connectionStatus = 'Testing connection...';
      _loginError = ''; // Clear login errors
    });

    try {
      final isConnected = await ApiService.testConnection();

      setState(() {
        _connectionStatus = isConnected
            ? '✅ Connected to server!\nYou can now login.'
            : '❌ Cannot connect to server.\nCheck:\n• Backend is running (node server.js)\n• Correct IP address\n• Firewall settings\n\nCurrent URL: ${ApiService.baseUrl}';
      });
    } catch (e) {
      setState(() {
        _connectionStatus = '❌ Connection test failed: $e';
      });
    } finally {
      setState(() {
        _testingConnection = false;
      });
    }
  }

  // In login_screen.dart - update _handleLogin method
  Future<void> _handleLogin() async {
    // ... validation code ...

    setState(() => _isLoggingIn = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final result = await authProvider.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      if (result['success'] == true) {
        print('✅ Login successful for: ${_usernameController.text}');

        // Get session cart from auth provider
        final sessionCart = await authProvider.getSessionCart();
        print('🛒 Session cart from login: $sessionCart');

        // Initialize cart with session cart for customers
        if (authProvider.isCustomer) {
          final cartProvider = Provider.of<CartProvider>(
            context,
            listen: false,
          );

          if (sessionCart != null) {
            await cartProvider.initializeCart(sessionCart: sessionCart);
            print('✅ Cart initialized with session cart: $sessionCart');
          } else {
            print('⚠️ No session cart available');
          }
        }

        // Navigate based on role
        if (authProvider.isAdmin) {
          Navigator.pushReplacementNamed(context, '/admin-home');
        } else {
          Navigator.pushReplacementNamed(context, '/customer-home');
        }
      } else {
        setState(() => _loginError = result['message'] ?? 'Login failed');
      }
    } catch (e) {
      setState(() => _loginError = 'Error: $e');
    } finally {
      setState(() => _isLoggingIn = false);
    }
  }
}
