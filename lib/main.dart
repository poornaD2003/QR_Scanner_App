
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './providers/auth_provider.dart';
import './providers/cart_provider.dart';
import './screens/login_screen.dart';
import './screens/admin_home_screen.dart';
import './screens/customer_home_screen.dart';
import './screens/cart_screen.dart';
import './screens/unknown_barcodes_screen.dart';
import './screens/qr_scanner_screen.dart';
import './screens/signUP.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'QR Scanner App',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
        routes: {
          '/login': (context) => const LoginScreen(),
          '/admin-home': (context) => const AdminHomeScreen(),
          '/customer-home': (context) => const CustomerHomeScreen(),
          '/scanner': (context) => QRScannerScreen(),
          '/cart': (context) => CartScreen(),
          '/unknown-barcodes': (context) => UnknownBarcodesScreen(),
          '/signup': (context) => const SignUpPage(),
        },
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Small delay to show splash screen
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Navigate directly to login screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 21, 192, 55),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Icon(
                    Icons.shopping_cart,
                    size: 60,
                    color: const Color.fromARGB(255, 13, 175, 37),
                  ),
                ),
                 Text(
              'QR Scanner System',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 20),
            
                                                           
          ],
        ),
      ),
    );
  }
}