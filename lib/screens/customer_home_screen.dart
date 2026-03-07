// customer_home_screen.dart
import 'package:flutter/material.dart';
import 'package:newsmartcartapp/services/api_service.dart';
import 'package:newsmartcartapp/services/auth_service.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({Key? key}) : super(key: key);

  @override
  _CustomerHomeScreenState createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    _initializeCart();
  }

  Future<void> _initializeCart() async {
    if (_isInitializing) return;
    
    setState(() {
      _isInitializing = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      
      // First try to get session cart from auth provider
      String? sessionCart = await authProvider.getSessionCart();
      print('🛒 CustomerHomeScreen - Session cart from auth: $sessionCart');
      
      if (sessionCart == null) {
        // If no session cart, try to get active cart from API directly
        print('🔄 No session cart, trying to get active cart from API...');
        final token = await authProvider.getToken();
        if (token != null) {
          sessionCart = await ApiService.getActiveCart(token: token);
          print('🛒 Active cart from API: $sessionCart');
          
          // If we got a cart, save it to session using PUBLIC method
          if (sessionCart != null && sessionCart.isNotEmpty) {
            await AuthService.saveSessionCart(sessionCart);  // Now using public method
            print('✅ Session cart saved via public method');
          }
        }
      }
      
      if (sessionCart != null && sessionCart.isNotEmpty) {
        await cartProvider.initializeCart(sessionCart: sessionCart);
        print('✅ Cart initialized with ID: $sessionCart');
      } else {
        print('❌ No cart available');
        // Show error to user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No shopping carts available. Please contact staff.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error initializing cart: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: _isInitializing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing your cart...'),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome message
                  Text(
                    'Welcome, ${authProvider.currentUser?.username ?? 'Customer'}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ready to start shopping?',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  
                  // Cart ID display
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 233, 253, 227),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color.fromARGB(255, 172, 249, 144)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.shopping_cart, color: const Color.fromARGB(255, 67, 192, 21)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Cart ID:',
                                style: TextStyle(fontSize: 14, color: Color.fromARGB(255, 158, 158, 158)),
                              ),
                              Text(
                                cartProvider.cartId ?? 'Not assigned',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: cartProvider.cartId != null 
                                      ? Colors.blue.shade800 
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Cart items count
                  if (cartProvider.items.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.inventory, color: Colors.green.shade800),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Items in cart:',
                                  style: TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                                Text(
                                  '${cartProvider.items.length} items',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  
                  const Spacer(),
                  
                  // Action buttons
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/scanner');
                      },
                      icon: const Icon(Icons.qr_code_scanner, size: 24, color: Colors.white),
                      label: const Text(
                        'Start Scanning',
                        style: TextStyle(fontSize: 16,color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 78, 192, 21),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/cart');
                      },
                      icon: const Icon(Icons.shopping_cart, color: Color.fromARGB(255, 72, 179, 63)),
                      label: const Text(
                        'View Cart',
                        style: TextStyle(fontSize: 16,color: Colors.green),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: const Color.fromARGB(255, 41, 192, 21)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}