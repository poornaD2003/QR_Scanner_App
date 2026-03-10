// In modles/product.dart
class Product {
  final String productId;  // Change from int to String
  final String name;
  final double price;
  final int quantity;

  var transactions;

  Product({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['product_id']?.toString() ?? '',  // Ensure string
      name: json['name']?.toString() ?? 'Unknown',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  double get total => price * quantity;

  get qrCode => null;

  @override
  String toString() {
    return 'Product{id: $productId, name: $name, price: $price, qty: $quantity}';
  }
}