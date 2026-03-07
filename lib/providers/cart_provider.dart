// lib/providers/cart_provider.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../modles/product.dart';
import 'auth_provider.dart';

class CartProvider extends ChangeNotifier {
  String? _cartId;
  List<Product> _items = [];
  Timer? _refreshTimer;
  bool _isLoading = false;
  double _lastTotal = 0.0;

  String? get cartId => _cartId;
  List<Product> get items => _items;
  bool get isLoading => _isLoading;
  double get lastTotal => _lastTotal;
  
  double get total {
    _lastTotal = _items.fold(0.0, (sum, item) => sum + item.total);
    return _lastTotal;
  }

  // Initialize cart from session
  // In cart_provider.dart - update initializeCart
Future<void> initializeCart({required String sessionCart}) async {
  _isLoading = true;
  notifyListeners();
  
  try {
    if (sessionCart.isEmpty) {
      print('⚠️ Empty session cart provided');
      // Try to get from AuthService as fallback
      final savedCart = await AuthService.getSessionCart();
      if (savedCart != null) {
        _cartId = savedCart;
        print('✅ Using saved session cart: $_cartId');
      } else {
        print('❌ No session cart available');
        _cartId = null;
      }
    } else {
      _cartId = sessionCart;
      print('✅ Using provided session cart: $_cartId');
    }
    
    // Load cart items if we have a cart ID
    if (_cartId != null) {
      await _loadCartItems();
      
      // Set up periodic refresh
      _refreshTimer?.cancel();
      _refreshTimer = Timer.periodic(
        const Duration(seconds: 3),
        (timer) => _refreshCartItems(),
      );
    }
  } catch (e) {
    print('❌ Error initializing cart: $e');
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  // Load cart items from server
  // In cart_provider.dart - update _loadCartItems method
Future<void> _loadCartItems() async {
  if (_cartId == null) {
    print('❌ Cannot load items: cartId is null');
    return;
  }
  
  try {
    final token = await AuthService.getToken();
    if (token == null) {
      print('❌ No token for loading cart items');
      return;
    }
    
    print('🔄 Loading items for cart $_cartId');
    final items = await ApiService.getCartItems(_cartId!, token: token);
    
    print('📦 Received ${items.length} items from API');
    
    // Update items even if empty (to show empty cart)
    _items = items;
    notifyListeners();
    
    print('✅ Cart updated with ${items.length} items');
  } catch (e) {
    print('❌ Error loading cart items: $e');
  }
}

  Future<void> _refreshCartItems() async {
    if (_cartId == null) return;
    await _loadCartItems();
  }

// Add these methods to CartProvider class

// Increase quantity
Future<void> increaseQuantity(String productId) async {
  if (_cartId == null) return;
  
  try {
    _isLoading = true;
    notifyListeners();
    
    final token = await AuthService.getToken();
    if (token == null) return;
    
    // You need to implement an API endpoint for updating quantity
    // For now, we'll simulate by adding the same product again
    // This will create a new transaction which will increase quantity when grouped
    
    final result = await ApiService.addToCart(
      _cartId!,
      productId,
      token: token,
    );
    
    if (result['success'] == true) {
      await _loadCartItems();
    }
  } catch (e) {
    print('❌ Error increasing quantity: $e');
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

// Decrease quantity
Future<void> decreaseQuantity(String productId, {required String cartId}) async {
  if (cartId.isEmpty) {
    print('❌ Cannot decrease quantity: cartId is empty');
    return;
  }
  
  try {
    _isLoading = true;
    notifyListeners();
    
    final token = await AuthService.getToken();
    if (token == null) {
      print('❌ No token available');
      return;
    }
    
    print('🔄 Decreasing quantity for product: $productId in cart: $cartId');
    
    final result = await ApiService.removeOneFromCart(
      cartId: cartId,
      productId: productId,
      token: token,
    );
    
    if (result['success'] == true) {
      print('✅ Quantity decreased successfully maked API call');
      await _loadCartItems();
    } else {
      print('❌ Failed to decrease quantity: ${result['message']}');
    }
  } catch (e) {
    print('❌ Error decreasing quantity: $e');
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}


// Remove item completely
Future<void> removeItem(String productId) async {
  if (_cartId == null) return;
  
  try {
    _isLoading = true;
    notifyListeners();
    
    final token = await AuthService.getToken();
    if (token == null) return;
    
    // Remove all transactions for this product
    await ApiService.removeAllProductTransactions(_cartId!, productId, token);
    await _loadCartItems();
  } catch (e) {
    print('❌ Error removing item: $e');
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
  // Add item to cart
Future<bool> addItem(String qrCode) async {
  if (_cartId == null) {
    print('❌ No session cart available');
    return false;
  }
  
  try {
    _isLoading = true;
    notifyListeners();
    
    final token = await AuthService.getToken();
    if (token == null) return false;
    
    print('🔍 Looking up product: $qrCode');
    final product = await ApiService.getProductByCode(qrCode, token: token);
    
    if (product == null) {
      // Unknown barcode - notify backend
      print('📝 Unknown barcode: $qrCode');
      await ApiService.notifyUnknownBarcode(
        barcode: qrCode,
        type: 'QR',
        cartId: int.tryParse(_cartId!.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
        token: token,
      );
      return false;
    }
    
    print('✅ Found product: ${product.name} (ID: ${product.productId})');
    
    // Convert product ID to string when adding to cart
    final result = await ApiService.addToCart(
      _cartId!,
      product.productId.toString(), // Send as string, not int
      token: token,
    );
    
    if (result['success'] == true) {
      print('✅ Item added to cart');
      await _loadCartItems();
      return true;
    }
    
    return false;
  } catch (e) {
    print('❌ Error adding item: $e');
    return false;
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

  // Checkout cart
  Future<bool> checkout() async {
    if (_cartId == null) return false;
    
    try {
      _isLoading = true;
      notifyListeners();
      
      final token = await AuthService.getToken();
      if (token == null) return false;
      
      print('💳 Checking out cart $_cartId');
      print('💰 Total: \$${total.toStringAsFixed(2)}');
      
      final result = await ApiService.checkoutCart(_cartId!, token: token);
      
      if (result['success'] == true) {
        print('✅ Checkout successful');
        
        // Clear local cart data
        _items.clear();
        _cartId = null;
        _refreshTimer?.cancel();
        
        // Clear session cart from AuthService
        await AuthService.clearSessionCart();
        
        notifyListeners();
        return true;
      }
      
      return false;
    } catch (e) {
      print('❌ Error during checkout: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshCart() async {
    await _loadCartItems();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}