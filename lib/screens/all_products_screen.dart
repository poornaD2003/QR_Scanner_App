// lib/screens/admin/all_products_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../modles/product.dart';

class AllProductsScreen extends StatefulWidget {
  const AllProductsScreen({Key? key}) : super(key: key);

  @override
  _AllProductsScreenState createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await context.read<AuthProvider>().getToken();
      if (token == null) throw Exception('Not authenticated');

      // You need to implement this in ApiService
      final products = await ApiService.getAllProducts(token: token);

      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Product> get _filteredProducts {
    if (_searchQuery.isEmpty) return _products;
    return _products
        .where(
          (p) =>
              p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.productId.contains(_searchQuery),
        )
        .toList();
  }

  Future<void> _deleteProduct(String productId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final token = await context.read<AuthProvider>().getToken();
        if (token == null) throw Exception('Not authenticated');

        await ApiService.deleteProduct(productId, token: token);
        await _loadProducts();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }
  // Add this method to your _AllProductsScreenState class
Future<void> _showEditDialog(Product product) async {
  final TextEditingController nameController = TextEditingController(text: product.name);
  final TextEditingController priceController = TextEditingController(
    text: product.price.toStringAsFixed(2)
  );
  final TextEditingController quantityController = TextEditingController(
    text: product.quantity.toString()
  );
  
  bool isSaving = false;
  String? errorMessage;

  return showDialog(
    context: context,
    barrierDismissible: false, // Prevent dismissing while saving
    builder: (BuildContext dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Edit Product'),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product ID (read-only)
                    TextFormField(
                      initialValue: product.productId,
                      decoration: const InputDecoration(
                        labelText: 'Product ID',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Color.fromARGB(255, 255, 255, 255),
                      ),
                      readOnly: true,
                      enabled: false,
                    ),
                    const SizedBox(height: 16),
                    
                    // Product Name
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Product Name *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.shopping_bag),
                      ),
                      enabled: !isSaving, // Disable while saving
                    ),
                    const SizedBox(height: 16),
                    
                    // Price
                    TextFormField(
                      controller: priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price (Rs) *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      enabled: !isSaving, // Disable while saving
                    ),
                    const SizedBox(height: 16),
                    
                    // Quantity (optional)
                    TextFormField(
                      controller: quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity ',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.inventory),
                        
                      ),
                      keyboardType: TextInputType.number,
                      enabled: !isSaving, // Disable while saving
                    ),
                    
                    if (errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error, color: Colors.red.shade700, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                errorMessage!,
                                style: TextStyle(color: Colors.red.shade700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: isSaving ? null : () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isSaving 
                    ? null 
                    : () async {
                        // Validate inputs
                        if (nameController.text.trim().isEmpty) {
                          setState(() {
                            errorMessage = 'Product name is required';
                          });
                          return;
                        }
                        
                        final priceText = priceController.text.trim();
                        if (priceText.isEmpty) {
                          setState(() {
                            errorMessage = 'Price is required';
                          });
                          return;
                        }
                        
                        final double? price = double.tryParse(priceText);
                        if (price == null || price <= 0) {
                          setState(() {
                            errorMessage = 'Please enter a valid price';
                          });
                          return;
                        }
                        
                        // Start saving
                        setState(() {
                          isSaving = true;
                          errorMessage = null;
                        });
                        
                        try {
                          // Get token from AuthProvider
                          final authProvider = Provider.of<AuthProvider>(dialogContext, listen: false);
                          final token = await authProvider.getToken();
                          
                          if (token == null) {
                            throw Exception('Not authenticated. Please login again.');
                          }
                          
                          // Prepare quantity (optional)
                          final quantity = quantityController.text.trim();
                          
                          print('📤 Sending update request...');
                          
                          // Call API to update product
                          final success = await ApiService.updateProduct(
                            productId: product.productId,
                            name: nameController.text.trim(),
                            price: price,
                            quantity: int.tryParse(quantity) ?? product.quantity, // Use existing quantity if not provided
                            token: token,
                          );
                          
                          print('📥 Update response: $success');
                          
                          if (success) {
                            // Close dialog first
                            if (context.mounted) {
                              Navigator.pop(dialogContext);
                            }
                            
                            // Then refresh the list
                            await _loadProducts();
                            
                            // Show success message
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('✅ Product updated successfully'),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          } else {
                            throw Exception('Failed to update product. Please try again.');
                          }
                        } catch (e) {
                          print('❌ Error updating product: $e');
                          
                          // Show error in dialog
                          setState(() {
                            isSaving = false;
                            errorMessage = e.toString().replaceAll('Exception: ', '');
                          });
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 91, 220, 58),
                ),
                child: isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Products'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadProducts),
        ],
        // In AllProductsScreen - Search bar in AppBar
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                // For TextField, this is correct:
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
        ),
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
                    onPressed: _loadProducts,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _filteredProducts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _searchQuery.isEmpty ? Icons.inventory : Icons.search_off,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty
                        ? 'No products found'
                        : 'No products matching "$_searchQuery"',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.shade100,
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(color: Colors.blue.shade800),
                      ),
                    ),
                    title: Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ID: ${product.productId}'),
                        Text('QR: ${product.qrCode}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Rs ${product.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.green.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showEditDialog(product),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteProduct(product.productId),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
