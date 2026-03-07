// lib/screens/admin_home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          child: Icon(Icons.admin_panel_settings),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome, ${user?.username ?? 'Admin'}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Administrator',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'You have full access to manage unknown barcodes and products.',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            Text(
              'Admin Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  // Manage Unknown Barcodes
                  _buildAdminCard(
                    icon: Icons.list,
                    title: 'Unknown Barcodes',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.pushNamed(context, '/unknown-barcodes');
                    },
                  ),
                  
                  // View All Products
                  _buildAdminCard(
                    icon: Icons.inventory,
                    title: 'All Products',
                    color: Colors.blue,
                    onTap: () {
                      // TODO: Implement products management screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Products management coming soon')),
                      );
                    },
                  ),
                  
                  // Sales Reports
                  _buildAdminCard(
                    icon: Icons.analytics,
                    title: 'Sales Reports',
                    color: Colors.green,
                    onTap: () {
                      // TODO: Implement sales reports
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Reports coming soon')),
                      );
                    },
                  ),
                  
                  // Cart Management
                  _buildAdminCard(
                    icon: Icons.shopping_cart_checkout,
                    title: 'Active Carts',
                    color: Colors.purple,
                    onTap: () {
                      // TODO: Implement cart monitoring
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Cart monitoring coming soon')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}