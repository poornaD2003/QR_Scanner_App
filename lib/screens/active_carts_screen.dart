// lib/screens/admin/active_carts_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../modles/product.dart';

class ActiveCartsScreen extends StatefulWidget {
  const ActiveCartsScreen({Key? key}) : super(key: key);

  @override
  _ActiveCartsScreenState createState() => _ActiveCartsScreenState();
}

class _ActiveCartsScreenState extends State<ActiveCartsScreen> {
  List<Map<String, dynamic>> _carts = [];
  bool _isLoading = true;
  String? _error;
  Map<String, List<Product>> _cartItems = {};
  Map<String, double> _cartTotals = {};

  @override
  void initState() {
    super.initState();
    _loadActiveCarts();
  }

  Future<void> _loadActiveCarts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await context.read<AuthProvider>().getToken();
      if (token == null) throw Exception('Not authenticated');

      // Get all active carts
      final carts = await ApiService.getActiveCarts(token: token);
      
      // Load items for each cart
      final Map<String, List<Product>> itemsMap = {};
      final Map<String, double> totalsMap = {};
      
      for (var cart in carts) {
        final cartId = cart['id'];
        final items = await ApiService.getCartItems(cartId, token: token);
        final total = await ApiService.getCartTotal(cartId, token: token);
        
        itemsMap[cartId] = items;
        totalsMap[cartId] = total;
      }
      
      setState(() {
        _carts = carts;
        _cartItems = itemsMap;
        _cartTotals = totalsMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _forceCheckout(String cartId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Force Checkout'),
        content: const Text('Are you sure you want to force checkout this cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Force Checkout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final token = await context.read<AuthProvider>().getToken();
        if (token == null) throw Exception('Not authenticated');

        await ApiService.forceCheckoutCart(cartId, token: token);
        await _loadActiveCarts();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cart checked out successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: 'Rs ');
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Carts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadActiveCarts,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadActiveCarts,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _carts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No active carts',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _carts.length,
                      itemBuilder: (context, index) {
                        final cart = _carts[index];
                        final cartId = cart['id'];
                        final items = _cartItems[cartId] ?? [];
                        final total = _cartTotals[cartId] ?? 0;
                        final assignedTo = cart['assigned_to'] ?? 'Unknown';
                        final assignedAt = cart['assigned_at'] ?? 0;
                        final date = DateTime.fromMillisecondsSinceEpoch(assignedAt);
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.orange.shade100,
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(color: Colors.orange.shade800),
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(
                                  cartId,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'ACTIVE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.green.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Customer: $assignedTo'),
                                Text('Started: ${dateFormat.format(date)}'),
                                Text('Items: ${items.length}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    currencyFormat.format(total),
                                    style: TextStyle(
                                      color: Colors.blue.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.check_circle, color: Colors.green),
                                  onPressed: () => _forceCheckout(cartId),
                                  tooltip: 'Force Checkout',
                                ),
                              ],
                            ),
                            children: [
                              if (items.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      ...items.map((item) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${item.name} x${item.quantity}',
                                                style: const TextStyle(fontSize: 14),
                                              ),
                                            ),
                                            Text(
                                              currencyFormat.format(item.price * item.quantity),
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      )),
                                      const Divider(),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Total:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            currencyFormat.format(total),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}