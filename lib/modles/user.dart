// lib/models/user.dart
class User {
  final String id;
  final String username;
  final String role;
  String? cartId;

  User({
    required this.id,
    required this.username,
    required this.role,
    this.cartId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? json['user_id']?.toString() ?? '',
      username: json['username'] ?? '',
      role: json['role']?.toString().toLowerCase() ?? 'customer',
      cartId: json['cartId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'role': role,
      'cartId': cartId,
    };
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, role: $role, cartId: $cartId)';
  }
}