import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart'; // Add this import
import '../providers/cart_provider.dart';
import 'add_product_screen.dart';

class UnknownBarcodesScreen extends StatefulWidget {
  const UnknownBarcodesScreen({Key? key}) : super(key: key);

  @override
  _UnknownBarcodesScreenState createState() => _UnknownBarcodesScreenState();
}

class _UnknownBarcodesScreenState extends State<UnknownBarcodesScreen> {
  List<Map<String, dynamic>> _barcodes = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadBarcodes();
  }

  Future<void> _loadBarcodes() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      // Get token first
      final token = await AuthService.getToken();
      if (token == null) {
        setState(() {
          _error = 'Not authenticated. Please login again.';
          _loading = false;
        });
        return;
      }

      // Test connection first
      final connected = await ApiService.testConnection();
      if (!connected) {
        setState(() {
          _error = 'Cannot connect to server. Please check if backend is running.';
          _loading = false;
        });
        return;
      }

      final barcodes = await ApiService.getUnknownBarcodes(token: token);
      setState(() {
        _barcodes = barcodes;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unknown Barcodes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBarcodes,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading unknown barcodes...'),
          ],
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _error,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadBarcodes,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_barcodes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'No unknown barcodes',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'All barcodes are recognized!',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _barcodes.length,
      itemBuilder: (context, index) {
        final barcode = _barcodes[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange,
              child: Text('${index + 1}'),
            ),
            title: Text(
              barcode['barcode']?.toString() ?? 'No barcode',
              style: const TextStyle(
                fontFamily: 'Monospace',
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              'Type: ${barcode['type']?.toString() ?? 'Unknown'}',
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {
              final barcodeText = barcode['barcode']?.toString() ?? '';
              final barcodeType = barcode['type']?.toString() ?? 'QRCODE';
              
              if (barcodeText.isNotEmpty) {
                // Get token to pass to AddProductScreen
                final token = await AuthService.getToken();
                
                if (token == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please login again'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final added = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddProductScreen(
                      barcode: barcodeText,
                      barcodeType: barcodeType,
                      token: token, // Pass token to AddProductScreen
                    ),
                  ),
                );
                
                if (added == true) {
                  _loadBarcodes();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Product added successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
          ),
        );
      },
    );
  }
}