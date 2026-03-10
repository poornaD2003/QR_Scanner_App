// // 
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../modles/product.dart';

// class ApiService {
//   static const String baseUrl = 'http://192.168.8.149:3000'; // Change to your IP  http://172.19.57.94:3000

//   // Add this method to ApiService class
// static Future<bool> notifyCartUpdate(int cartId) async {
//   try {
//     final response = await _safeRequest('POST', '/cart/update', body: {
//       'cart_id': cartId,
//     });
//     return response?.statusCode == 200;
//   } catch (e) {
//     print('❌ Error notifying cart update: $e');
//     return false;
//   }
// }
//   // Helper method for safe HTTP requests
//   static Future<http.Response?> _safeRequest(
//     String method,
//     String endpoint, {
//     Map<String, dynamic>? body,
//   }) async {
//     try {
//       final uri = Uri.parse('$baseUrl$endpoint');
//       final headers = {'Content-Type': 'application/json'};

//       print('🌐 $method request to: $uri');
//       if (body != null) {
//         print('📦 Body: $body');
//       }

//       http.Response response;
//       switch (method.toUpperCase()) {
//         case 'GET':
//           response = await http.get(uri, headers: headers);
//           break;
//         case 'POST':
//           response = await http.post(
//             uri,
//             headers: headers,
//             body: body != null ? json.encode(body) : null,
//           );
//           break;
//         default:
//           throw Exception('Unsupported HTTP method: $method');
//       }

//       print('📨 Response status: ${response.statusCode}');
//       print('📄 Response body: ${response.body.length > 200 ? '${response.body.substring(0, 200)}...' : response.body}');

//       return response;
//     } catch (e) {
//       print('❌ Network error: $e');
//       return null;
//     }
//   }

//   // Add this method to ApiService
// static Future<bool> testConnection() async {
//   try {
//     print('🌐 Testing connection to: $baseUrl');
    
//     final response = await http.get(
//       Uri.parse('$baseUrl/api/test'),
//       headers: {'Content-Type': 'application/json'},
//     );
    
//     print('📡 Response status: ${response.statusCode}');
//     print('📡 Response body: ${response.body}');
    
//     return response.statusCode == 200;
//   } catch (e) {
//     print('❌ Connection test failed: $e');
//     return false;
//   }
// }


//   // Get active cart
//   static Future<int?> getActiveCart() async {
//     try {
//       final response = await _safeRequest('GET', '/active-cart');
      
//       if (response == null || response.statusCode != 200) {
//         print('❌ Failed to get active cart');
//         return null;
//       }

//       final data = json.decode(response.body);
//       final cartId = data['cart_id'];
      
//       if (cartId == null) {
//         print('⚠️ No cart_id in response');
//         return null;
//       }
      
//       return cartId is int ? cartId : int.tryParse(cartId.toString());
//     } catch (e) {
//       print('❌ Error getting active cart: $e');
//       return null;
//     }
//   }

//   // Get product by QR code
//   // static Future<Product?> getProductByCode(String code) async {
//   //   try {
//   //     final response = await _safeRequest('GET', '/products/$code');
      
//   //     if (response == null) {
//   //       print('❌ No response from server');
//   //       return null;
//   //     }

//   //     if (response.statusCode == 200) {
//   //       final data = json.decode(response.body);
//   //       return Product.fromJson(data);
//   //     } else if (response.statusCode == 404) {
//   //       print('📭 Product not found for code: $code');
//   //       return null;
//   //     } else {
//   //       print('❌ Server error: ${response.statusCode}');
//   //       return null;
//   //     }
//   //   } catch (e) {
//   //     print('❌ Error getting product: $e');
//   //     return null;
//   //   }
//   // }

//   // api_service.dart (update methods to accept token)
// static Future<Product?> getProductByCode(String code, {String? token}) async {
//   try {
//     final headers = {'Content-Type': 'application/json'};
//     if (token != null) {
//       headers['Authorization'] = 'Bearer $token';
//     }
    
//     final response = await http.get(
//       Uri.parse('$baseUrl/products/$code'),
//       headers: headers,
//     );
//     // ... rest of the method
//   } catch (e) {
//     // ... error handling
//   }
// }

// // Similarly update other methods that need authentication:
// // addToCart, getCartItems, getCartTotal, checkoutCart, etc.

//   // Get unknown barcodes
//   static Future<List<Map<String, dynamic>>> getUnknownBarcodes() async {
//     try {
//       final response = await _safeRequest('GET', '/unknown-barcodes');
      
//       if (response == null || response.statusCode != 200) {
//         print('❌ Failed to fetch unknown barcodes');
//         return [];
//       }

//       final List<dynamic> data = json.decode(response.body);
      
//       // Convert to list of maps with safe null handling
//       final List<Map<String, dynamic>> barcodes = [];
      
//       for (var item in data) {
//         if (item is Map<String, dynamic>) {
//           barcodes.add({
//             'id': item['id']?.toString() ?? '0',
//             'barcode': item['qr_content']?.toString() ?? item['barcode']?.toString() ?? 'Unknown',
//             'type': item['qr_type']?.toString() ?? item['barcode_type']?.toString() ?? 'Unknown',
//             'time': item['detected_at']?.toString() ?? item['scan_time']?.toString() ?? '',
//             'processed': item['processed'] ?? item['is_processed'] ?? false,
//           });
//         }
//       }
      
//       print('✅ Found ${barcodes.length} unknown barcodes');
//       return barcodes;
//     } catch (e) {
//       print('❌ Error fetching unknown barcodes: $e');
//       return [];
//     }
//   }

//   // Add product from unknown barcode
//   static Future<Map<String, dynamic>> addProductFromBarcode({
//     required String barcode,
//     required String name,
//     required double price,
//   }) async {
//     try {
//       final response = await _safeRequest('POST', '/add-product', body: {
//         'qr_code': barcode,
//         'name': name,
//         'price': price,
//       });
      
//       if (response == null) {
//         return {'success': false, 'message': 'No response from server'};
//       }

//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else if (response.statusCode == 400) {
//         try {
//           final error = json.decode(response.body);
//           return {'success': false, 'message': error['error'] ?? 'Bad request'};
//         } catch (_) {
//           return {'success': false, 'message': 'Bad request'};
//         }
//       } else {
//         return {'success': false, 'message': 'Server error: ${response.statusCode}'};
//       }
//     } catch (e) {
//       print('❌ Error adding product: $e');
//       return {'success': false, 'message': 'Error: $e'};
//     }
//   }

//   // Add item to cart
//   static Future<Map<String, dynamic>> addToCart(int cartId, int productId, {String? token}) async {
//     try {
//       final response = await _safeRequest('POST', '/cart/add', body: {
//         'cart_id': cartId,
//         'product_id': productId,
//       });
      
//       if (response == null || response.statusCode != 200) {
//         return {'success': false, 'message': 'Failed to add item to cart'};
//       }
      
//       return json.decode(response.body);
//     } catch (e) {
//       print('❌ Error adding to cart: $e');
//       return {'success': false, 'message': 'Error: $e'};
//     }
//   }

//   // Get cart items
//   static Future<List<Product>> getCartItems(int cartId, {String? token}) async {
//   if (token == null) {
//     print('❌ Cannot get cart items without authentication token');
//     return [];
//   }
  
//   try {
//     final response = await _authenticatedRequest(
//       'GET',
//       '/cart/$cartId/items',
//       token: token,
//     );
    
//     if (response == null || response.statusCode != 200) {
//       print('❌ Failed to fetch cart items');
//       return [];
//     }

//     final List<dynamic> data = json.decode(response.body);
    
//     if (data.isEmpty) {
//       return [];
//     }
    
//     final List<Product> products = [];
    
//     for (var item in data) {
//       try {
//         if (item is Map<String, dynamic>) {
//           products.add(Product.fromJson(item));
//         }
//       } catch (e) {
//         print('⚠️ Error parsing product item: $e');
//         print('⚠️ Item data: $item');
//       }
//     }
    
//     print('✅ Found ${products.length} items in cart');
//     return products;
//   } catch (e) {
//     print('❌ Error getting cart items: $e');
//     return [];
//   }
// }

// // Similarly update other cart-related methods:
// // addToCart, getCartTotal, checkoutCart, etc.

//   // Get cart total
//   static Future<double> getCartTotal(int cartId) async {
//     try {
//       final response = await _safeRequest('GET', '/cart/$cartId/total');
      
//       if (response == null || response.statusCode != 200) {
//         print('❌ Failed to fetch cart total');
//         return 0.0;
//       }

//       final data = json.decode(response.body);
//       final total = data['total'];
      
//       if (total == null) {
//         return 0.0;
//       }
      
//       if (total is int) {
//         return total.toDouble();
//       } else if (total is double) {
//         return total;
//       } else if (total is String) {
//         return double.tryParse(total) ?? 0.0;
//       } else {
//         return 0.0;
//       }
//     } catch (e) {
//       print('❌ Error getting cart total: $e');
//       return 0.0;
//     }
//   }

//   // Checkout cart
//   static Future<Map<String, dynamic>> checkoutCart(int cartId) async {
//     try {
//       final response = await _safeRequest('POST', '/cart/$cartId/checkout');
      
//       if (response == null) {
//         return {'success': false, 'message': 'No response from server'};
//       }

//       if (response.statusCode == 200) {
//         return json.decode(response.body);
//       } else {
//         return {'success': false, 'message': 'Checkout failed: ${response.statusCode}'};
//       }
//     } catch (e) {
//       print('❌ Error during checkout: $e');
//       return {'success': false, 'message': 'Error: $e'};
//     }
//   }

//   // Notify about unknown barcode
//   static Future<bool> notifyUnknownBarcode({
//     required String barcode,
//     required String type,
//     required int cartId, String? token,
//   }) async {
//     try {
//       final response = await _safeRequest('POST', '/unknown-barcode', body: {
//         'barcode': barcode,
//         'type': type,
//         'cart_id': cartId,
//       });
      
//       return response?.statusCode == 200;
//     } catch (e) {
//       print('❌ Error notifying about barcode: $e');
//       return false;
//     }
//   }
//   // Add these methods to your existing ApiService class
// static Future<Map<String, dynamic>> login(String username, String password) async {
//   try {
//     print('🔐 Attempting login to: $baseUrl/auth/login');
//     print('👤 Username: $username');
    
//     final response = await http.post(
//       Uri.parse('$baseUrl/auth/login'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({
//         'username': username,
//         'password': password,
//       }),
//     );
    
//     print('📡 Login response status: ${response.statusCode}');
//     print('📡 Login response body: ${response.body}');
    
//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else if (response.statusCode == 404) {
//       print('❌ 404 Error: Endpoint not found');
//       print('❌ Check if server is running at: $baseUrl');
//       return {'success': false, 'message': 'Server not found. Check if backend is running.'};
//     } else if (response.statusCode == 401) {
//       return {'success': false, 'message': 'Invalid username or password'};
//     } else {
//       return {'success': false, 'message': 'Login failed: ${response.statusCode}'};
//     }
//   } catch (e) {
//     print('❌ Login error: $e');
//     return {'success': false, 'message': 'Network error: $e'};
//   }
// }


// static Future<Map<String, dynamic>> verifyToken(String token) async {
//   try {
//     final response = await http.post(
//       Uri.parse('$baseUrl/auth/verify'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//     );
    
//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       return {'success': false};
//     }
//   } catch (e) {
//     print('❌ Token verification error: $e');
//     return {'success': false};
//   }
// }

// static Future<Map<String, dynamic>> logout(String token, int? cartId) async {
//   try {
//     final response = await http.post(
//       Uri.parse('$baseUrl/auth/logout'),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//       body: json.encode({'cart_id': cartId}),
//     );
    
//     if (response.statusCode == 200) {
//       return json.decode(response.body);
//     } else {
//       return {'success': false};
//     }
//   } catch (e) {
//     print('❌ Logout error: $e');
//     return {'success': false};
//   }
// }
// static Future<http.Response?> _authenticatedRequest(
//   String method,
//   String endpoint, {
//   Map<String, dynamic>? body,
//   String? token,
// }) async {
//   if (token == null) {
//     print('❌ No authentication token provided');
//     return null;
//   }
  
//   try {
//     final uri = Uri.parse('$baseUrl$endpoint');
//     final headers = {
//       'Content-Type': 'application/json',
//       'Authorization': 'Bearer $token',
//     };

//     print('🔐 Authenticated $method request to: $uri');
//     if (body != null) {
//       print('📦 Body: $body');
//     }

//     http.Response response;
//     switch (method.toUpperCase()) {
//       case 'GET':
//         response = await http.get(uri, headers: headers);
//         break;
//       case 'POST':
//         response = await http.post(
//           uri,
//           headers: headers,
//           body: body != null ? json.encode(body) : null,
//         );
//         break;
//       default:
//         throw Exception('Unsupported HTTP method: $method');
//     }

//     print('📨 Response status: ${response.statusCode}');
    
//     // Handle authentication errors
//     if (response.statusCode == 401) {
//       print('❌ Authentication failed, token might be expired');
//       return null;
//     }
    
//     return response;
//   } catch (e) {
//     print('❌ Network error: $e');
//     return null;
//   }
// }
// }

// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../modles/product.dart';
import '../modles/user.dart';

class ApiService {
  // ✅ Base URL with /api prefix - use your computer's IP
  static const String baseUrl = 'http://192.168.8.205:3000/api';

  // Helper method for authenticated requests
  static Future<http.Response?> _authenticatedRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    required String token,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      print('🔐 $method request to: $uri');
      if (body != null) {
        print('📦 Body: $body');
      }

      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: headers);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      print('📨 Response status: ${response.statusCode}');
      
      // Handle authentication errors
      if (response.statusCode == 401) {
        print('❌ Authentication failed, token might be expired');
      }
      
      return response;
    } catch (e) {
      print('❌ Network error: $e');
      return null;
    }
  }

  // Helper method for unauthenticated requests (login, signup, test)
  static Future<http.Response?> _publicRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = {'Content-Type': 'application/json'};

      print('🌐 $method request to: $uri');
      if (body != null) {
        print('📦 Body: $body');
      }

      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: headers);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          );
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      print('📨 Response status: ${response.statusCode}');
      return response;
    } catch (e) {
      print('❌ Network error: $e');
      return null;
    }
  }

  // ==================== AUTHENTICATION ====================
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      print('🔐 Attempting login to: $baseUrl/auth/login');
      
      final response = await _publicRequest('POST', '/auth/login', body: {
        'username': username,
        'password': password,
      });
      
      if (response == null) {
        return {'success': false, 'message': 'No response from server'};
      }
      
      print('📡 Login response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else if (response.statusCode == 404) {
        return {'success': false, 'message': 'Server endpoint not found. Check if backend is running.'};
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

  static Future<Map<String, dynamic>> signup(String username, String password) async {
    try {
      print('📝 Attempting signup to: $baseUrl/auth/signup');
      
      final response = await _publicRequest('POST', '/auth/signup', body: {
        'username': username,
        'password': password,
        'role': 'customer',
      });
      
      if (response == null) {
        return {'success': false, 'message': 'No response from server'};
      }
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 400) {
        final error = json.decode(response.body);
        return {'success': false, 'message': error['error'] ?? 'Username already exists'};
      } else {
        return {'success': false, 'message': 'Signup failed: ${response.statusCode}'};
      }
    } catch (e) {
      print('❌ Signup error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> verifyToken(String token) async {
    try {
      print('🔐 Verifying token...');
      
      final response = await _authenticatedRequest('POST', '/auth/verify', token: token);
      
      if (response == null) {
        return {'success': false, 'message': 'No response from server'};
      }
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'message': 'Token invalid'};
      }
    } catch (e) {
      print('❌ Token verification error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> logout(String token, int? cartId) async {
    try {
      print('🔓 Logging out from server...');
      
      final response = await _authenticatedRequest(
        'POST', 
        '/auth/logout', 
        token: token,
        body: {'cart_id': cartId},
      );
      
      if (response == null) {
        return {'success': false, 'message': 'No response from server'};
      }
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'message': 'Logout failed: ${response.statusCode}'};
      }
    } catch (e) {
      print('❌ Logout error: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // ==================== TEST & CONNECTION ====================
  static Future<bool> testConnection() async {
    try {
      print('🌐 Testing connection to: $baseUrl/test');
      
      final response = await _publicRequest('GET', '/test');
      
      return response?.statusCode == 200;
    } catch (e) {
      print('❌ Connection test failed: $e');
      return false;
    }
  }

  // ==================== CART MANAGEMENT ====================
  static Future<String?> getActiveCart({required String token}) async {
    try {
      print('🔍 Getting active cart');
      
      final response = await http.get(
        Uri.parse('$baseUrl/active-cart'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final cartId = data['cart_id']?.toString();
        print('✅ Active cart: $cartId');
        return cartId;
      }
      return null;
    } catch (e) {
      print('❌ Error getting active cart: $e');
      return null;
    }
  }
  static Future<Map<String, dynamic>> checkCartSession(
  String cartId, {
  required String token,
}) async {
  try {
    final response = await _authenticatedRequest(
      'GET',
      '/cart/$cartId/session-status',
      token: token,
    );
    
    if (response?.statusCode == 200) {
      return json.decode(response!.body);
    }
    return {'session_active': true}; // Default to true on error
  } catch (e) {
    print('❌ Error checking session: $e');
    return {'session_active': true};
  }
}

// Admin endpoint to clean up expired sessions
static Future<bool> cleanupExpiredSessions({required String token}) async {
  try {
    final response = await _authenticatedRequest(
      'POST',
      '/admin/cleanup-sessions',
      token: token,
    );
    return response?.statusCode == 200;
  } catch (e) {
    print('❌ Error cleaning up sessions: $e');
    return false;
  }
}

  static Future<List<Map<String, dynamic>>> getActiveCarts({required String token}) async {
  try {
    final response = await _authenticatedRequest(
      'GET', 
      '/carts/active', 
      token: token,
    );
    
    if (response?.statusCode == 200) {
      final List<dynamic> data = json.decode(response!.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  } catch (e) {
    print('❌ Error getting active carts: $e');
    return [];
  }
}

  static Future<bool> forceCheckoutCart(String cartId, {required String token}) async {
  try {
    final response = await _authenticatedRequest(
      'POST', 
      '/carts/$cartId/force-checkout', 
      token: token,
    );
    return response?.statusCode == 200;
  } catch (e) {
    print('❌ Error forcing checkout: $e');
    return false;
  }
}

  // In api_service.dart - Update addToCart method
static Future<Map<String, dynamic>> addToCart(
  String cartId, 
  String productId, {  // Change from int to String
  required String token,
}) async {
  try {
    print('🛒 Adding to cart - Cart: $cartId, Product: $productId');
    
    final response = await http.post(
      Uri.parse('$baseUrl/cart/add'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'cart_id': cartId,
        'product_id': productId,  // Send as string
      }),
    );
    
    print('📡 Add to cart response: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    return {'success': false, 'message': 'Failed to add item'};
  } catch (e) {
    print('❌ Error adding to cart: $e');
    return {'success': false, 'message': 'Error: $e'};
  }
}
// Add these methods to ApiService

// Get transactions for a specific product in a cart
static Future<List<String>> getTransactions(String cartId, String productId, String token) async {
  try {
    final response = await _authenticatedRequest(
      'GET', 
      '/cart/$cartId/transactions/$productId',
      token: token,
    );
    
    if (response?.statusCode == 200) {
      final List<dynamic> data = json.decode(response!.body);
      return data.map((e) => e['id'].toString()).toList();
    }
    return [];
  } catch (e) {
    print('❌ Error getting transactions: $e');
    return [];
  }
}

// Remove a specific transaction
static Future<bool> removeTransaction(String transactionId, String token) async {
  try {
    final response = await _authenticatedRequest(
      'DELETE',
      '/transactions/$transactionId',
      token: token,
    );
    return response?.statusCode == 200;
  } catch (e) {
    print('❌ Error removing transaction: $e');
    return false;
  }
}
// Remove ONE instance of a product from cart (decrease quantity by 1)
static Future<Map<String, dynamic>> removeOneFromCart({
  required String cartId,
  required String productId,
  required String token,
}) async {
  try {
    print('🗑️ Removing one instance of product $productId from cart $cartId');
    
    final response = await http.delete(
      Uri.parse('$baseUrl/cart/$cartId/product/$productId/remove-one'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    print('📡 Remove one response: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      return {'success': true, 'message': 'Item removed'};
    } else {
      return {'success': false, 'message': 'Failed to remove item'};
    }
  } catch (e) {
    print('❌ Error removing one from cart: $e');
    return {'success': false, 'message': 'Error: $e'};
  }
}


// Get all products
static Future<List<Product>> getAllProducts({required String token}) async {
  try {
    final response = await _authenticatedRequest('GET', '/products', token: token);
    
    if (response?.statusCode == 200) {
      final List<dynamic> data = json.decode(response!.body);
      return data.map((e) => Product.fromJson(e)).toList();
    }
    return [];
  } catch (e) {
    print('❌ Error getting products: $e');
    return [];
  }
}

// Delete product
static Future<bool> deleteProduct(String productId, {required String token}) async {
  try {
    final response = await _authenticatedRequest(
      'DELETE', 
      '/products/$productId', 
      token: token,
    );
    return response?.statusCode == 200;
  } catch (e) {
    print('❌ Error deleting product: $e');
    return false;
  }
}
static Future<bool> updateProduct({
  required String productId,
  required String name,
  required double price,
  required int quantity,
  required String token,
}) async {
  try {
    print('📝 Updating product: $productId');
    
    final response = await _authenticatedRequest(
      'PUT',
      '/products/$productId',
      token: token,
      body: {
        'name': name,
        'price': price,
        'quantity': quantity,
        
      },
    );
    
    if (response?.statusCode == 200) {
      print('✅ Product updated successfully');
      return true;
    } else {
      print('❌ Failed to update product: ${response?.statusCode}');
      return false;
    }
  } catch (e) {
    print('❌ Error updating product: $e');
    return false;
  }
}

// Get all bills for reports
static Future<List<Map<String, dynamic>>> getAllBills({required String token}) async {
  try {
    final response = await _authenticatedRequest('GET', '/bills', token: token);
    
    if (response?.statusCode == 200) {
      final List<dynamic> data = json.decode(response!.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  } catch (e) {
    print('❌ Error getting bills: $e');
    return [];
  }
}


// Remove all transactions for a product in a cart
static Future<bool> removeAllProductTransactions(
  String cartId, 
  String productId, 
  String token
) async {
  try {
    final response = await _authenticatedRequest(
      'DELETE',
      '/cart/$cartId/product/$productId',
      token: token,
    );
    return response?.statusCode == 200;
  } catch (e) {
    print('❌ Error removing product transactions: $e');
    return false;
  }
}
  
// In api_service.dart
static Future<List<Product>> getCartItems(String cartId, {required String token}) async {
  try {
    print('🔍 API Call: Getting items for cart "$cartId"');
    
    final response = await http.get(
      Uri.parse('$baseUrl/cart/$cartId/items'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    print('📡 Cart items response status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final String responseBody = response.body;
      print('📄 Response body: $responseBody');
      
      if (responseBody.isEmpty || responseBody == '[]') {
        print('📭 Empty cart response');
        return [];
      }
      
      final List<dynamic> data = json.decode(responseBody);
      print('✅ Found ${data.length} items in API response');
      
      final List<Product> products = [];
      
      for (var item in data) {
        try {
          if (item is Map<String, dynamic>) {
            final product = Product.fromJson(item);
            products.add(product);
            print('✅ Added: ${product.name} x${product.quantity}');
          }
        } catch (e) {
          print('⚠️ Error parsing product: $e');
          print('⚠️ Item data: $item');
        }
      }
      
      return products;
    } else {
      print('❌ Failed to fetch cart items: ${response.statusCode}');
      print('❌ Response: ${response.body}');
      return [];
    }
  } catch (e) {
    print('❌ Error getting cart items: $e');
    return [];
  }
}

  static Future<double> getCartTotal(int cartId, {required String token}) async {
    try {
      final response = await _authenticatedRequest('GET', '/cart/$cartId/total', token: token);
      
      if (response == null || response.statusCode != 200) {
        print('❌ Failed to fetch cart total');
        return 0.0;
      }

      final data = json.decode(response.body);
      final total = data['total'];
      
      return _parseDouble(total);
    } catch (e) {
      print('❌ Error getting cart total: $e');
      return 0.0;
    }
  }

 static Future<Map<String, dynamic>> checkoutCart(
    String cartId, {
    required String token,
  }) async {
    try {
      print('💳 Checking out cart: $cartId');
      
      final response = await http.post(
        Uri.parse('$baseUrl/cart/$cartId/checkout'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Checkout complete. Total: \$${data['total']}');
        return data;
      }
      return {'success': false, 'message': 'Checkout failed'};
    } catch (e) {
      print('❌ Error during checkout: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<bool> notifyCartUpdate(int cartId, {required String token}) async {
    try {
      final response = await _authenticatedRequest(
        'POST', 
        '/cart/update', 
        token: token,
        body: {'cart_id': cartId},
      );
      return response?.statusCode == 200;
    } catch (e) {
      print('❌ Error notifying cart update: $e');
      return false;
    }
  }

  // ==================== PRODUCT MANAGEMENT ====================
  static Future<Product?> getProductByCode(String code, {required String token}) async {
    try {
      print('🔍 Looking up product: $code');
      
      final response = await _authenticatedRequest('GET', '/products/$code', token: token);
      
      if (response == null) {
        print('❌ No response from server');
        return null;
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Product.fromJson(data);
      } else if (response.statusCode == 404) {
        print('📭 Product not found for code: $code');
        return null;
      } else {
        print('❌ Server error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error getting product: $e');
      return null;
    }
  }

  // ==================== UNKNOWN BARCODES ====================
  static Future<List<Map<String, dynamic>>> getUnknownBarcodes({required String token}) async {
    try {
      final response = await _authenticatedRequest('GET', '/unknown-barcodes', token: token);
      
      if (response == null || response.statusCode != 200) {
        print('❌ Failed to fetch unknown barcodes');
        return [];
      }

      final List<dynamic> data = json.decode(response.body);
      
      final List<Map<String, dynamic>> barcodes = [];
      
      for (var item in data) {
        if (item is Map<String, dynamic>) {
          barcodes.add({
            'id': item['id']?.toString() ?? '0',
            'barcode': item['qr_content']?.toString() ?? item['barcode']?.toString() ?? 'Unknown',
            'type': item['qr_type']?.toString() ?? item['barcode_type']?.toString() ?? 'Unknown',
            'time': item['detected_at']?.toString() ?? item['scan_time']?.toString() ?? '',
            'processed': item['processed'] ?? item['is_processed'] ?? false,
          });
        }
      }
      
      print('✅ Found ${barcodes.length} unknown barcodes');
      return barcodes;
    } catch (e) {
      print('❌ Error fetching unknown barcodes: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> addProductFromBarcode({
    required String barcode,
    required String name,
    required double price,
    required String token, 
    required int quantity,
  }) async {
    try {
      final response = await _authenticatedRequest(
        'POST', 
        '/add-product', 
        token: token,
        body: {
          'qr_code': barcode,
          'name': name,
          'price': price,
          'quantity': quantity,
        },
      );
      
      if (response == null) {
        return {'success': false, 'message': 'No response from server'};
      }

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 400) {
        try {
          final error = json.decode(response.body);
          return {'success': false, 'message': error['error'] ?? 'Bad request'};
        } catch (_) {
          return {'success': false, 'message': 'Bad request'};
        }
      } else {
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      print('❌ Error adding product: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  static Future<bool> notifyUnknownBarcode({
    required String barcode,
    required String type,
    required int cartId,
    required String token,
  }) async {
    try {
      final response = await _authenticatedRequest(
        'POST', 
        '/unknown-barcode', 
        token: token,
        body: {
          'barcode': barcode,
          'type': type,
          'cart_id': cartId,
        },
      );
      
      return response?.statusCode == 200;
    } catch (e) {
      print('❌ Error notifying about barcode: $e');
      return false;
    }
  }

  // ==================== HELPER METHODS ====================
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // ==================== DATABASE INFO ====================
  static Future<Map<String, dynamic>> getDbInfo({required String token}) async {
    try {
      final response = await _authenticatedRequest('GET', '/db-info', token: token);
      
      if (response == null || response.statusCode != 200) {
        return {'success': false, 'message': 'Failed to get database info'};
      }
      
      return json.decode(response.body);
    } catch (e) {
      print('❌ Error getting DB info: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}