import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../services/auth_service.dart'; // Add this for auth check

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;
  String? _lastScannedCode;
  bool _isAuthenticated = false;
  bool _checkingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    final isLoggedIn = await AuthService.isLoggedIn();
    final token = await AuthService.getToken();
    final user = await AuthService.getCurrentUser();
    
    print('🔐 Scanner - Auth check: isLoggedIn=$isLoggedIn, token=${token != null}, user=${user?.username}');
    
    setState(() {
      _isAuthenticated = isLoggedIn && token != null && user != null;
      _checkingAuth = false;
    });

    if (!_isAuthenticated) {
      // Stop camera if not authenticated
      await cameraController.stop();
    }
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    
    if (barcodes.isEmpty) return;
    
    final String barcode = barcodes.first.rawValue ?? '';
    if (barcode.isEmpty) return;
    
    // Prevent duplicate scans
    if (_isProcessing || barcode == _lastScannedCode) return;
    
    _lastScannedCode = barcode;
    _isProcessing = true;
    
    print('📱 Scanned barcode: $barcode');
    
    // Add item to cart
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Check authentication again before adding
      final isLoggedIn = await AuthService.isLoggedIn();
      if (!isLoggedIn) {
        _showErrorDialog('Please login first');
        _resetProcessing();
        return;
      }

      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      
      // Initialize cart if needed
      if (cartProvider.cartId == null) {
        await cartProvider.initializeCart(sessionCart: '');
      }
      
      final success = await cartProvider.addItem(barcode);
      
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Item added to cart!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Product not found or could not be added'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
      
      // Reset processing state after delay
      _resetProcessing();
    });
  }

  void _resetProcessing() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context); // Go back
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingAuth) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Checking authentication...'),
            ],
          ),
        ),
      );
    }

    if (!_isAuthenticated) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Scanner'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_outline,
                  size: 80,
                  color: Colors.red,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Authentication Required',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Please login to use the scanner',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/');
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(200, 50),
                  ),
                  child: const Text(
                    'Go to Login',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Items'),
        actions: [
          // Torch button
          ValueListenableBuilder<TorchState>(
            valueListenable: cameraController.torchState,
            builder: (context, state, child) {
              return IconButton(
                icon: Icon(
                  state == TorchState.on ? Icons.flash_on : Icons.flash_off,
                  color: state == TorchState.on ? Colors.yellow : Colors.grey,
                ),
                onPressed: () => cameraController.toggleTorch(),
              );
            },
          ),
          
          // Switch camera button
          ValueListenableBuilder<CameraFacing>(
            valueListenable: cameraController.cameraFacingState,
            builder: (context, state, child) {
              return IconButton(
                icon: Icon(
                  state == CameraFacing.front ? Icons.camera_front : Icons.camera_rear,
                ),
                onPressed: () => cameraController.switchCamera(),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _onBarcodeDetected,
          ),
          
          // Scanner overlay
          _buildScannerOverlay(),
          
          // Processing indicator
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10),
                    Text(
                      'Processing...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return Center(
      child: Container(
        width: 250,
        height: 250,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.green,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}