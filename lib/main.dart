import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'utils/theme.dart';
import 'screens/login_screen.dart';
import 'controllers/auth_controller.dart';
import 'controllers/product_controller.dart';
import 'controllers/cart_controller.dart';
import 'controllers/order_controller.dart';
import 'controllers/category_controller.dart';
import 'controllers/chat_controller.dart';
import 'services/stripe_service.dart';
import 'services/firebase_auth_service.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'utils/logger.dart';
import 'screens/web_responsive_example.dart';
// import 'widgets/app_logo.dart'; // Unused import
import 'screens/admin/category_management_screen.dart';
// ChatController is imported with other controllers

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    
    try {
      Logger.info('Starting app initialization');
      
      // Initialize Firebase with error handling
      Logger.info('Initializing Firebase');
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        Logger.info('Firebase initialized successfully');
        
        // Temporarily enable offline persistence for Firestore
        FirebaseFirestore.instance.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
        
        // Initialize Firebase Auth Service - must be after Firestore settings
        Logger.info('Initializing Firebase Auth Service');
        await FirebaseAuthService.initialize();
        Logger.info('Firebase Auth Service initialized successfully');
        
        Logger.info('Firestore settings configured');
      } catch (e) {
        Logger.error('Firebase initialization failed', error: e);
        // Continue without Firebase in web for debugging
        if (!kIsWeb) {
          throw Exception('Firebase initialization failed. Please check your configuration.');
        }
      }
      
      // Initialize Stripe with error handling
      Logger.info('Initializing Stripe');
      try {
        // We'll try to initialize Stripe but have a proper fallback if it fails
        StripeService().init();
        Logger.info('Stripe initialized successfully');
      } catch (e) {
        Logger.error('Stripe initialization failed (this is expected if stripe is disabled): $e');
        Logger.info('Continuing without Stripe - payment functionality will be limited');
        // Continue without Stripe
      }
      
      // Initialize controllers
      Logger.info('Initializing controllers');
      try {
        Get.put(AuthController());
        Get.put(ProductController());
        Get.put(CartController());
        Get.put(OrderController());
        
        // Also initialize the category controller
        try {
          Get.put(CategoryController());
          Logger.info('CategoryController initialized');
        } catch (e) {
          Logger.error('Error initializing CategoryController', error: e);
        }
        
        // Initialize chat controller
        try {
          final chatController = ChatController();
          Get.put(chatController);
          Logger.info('ChatController initialized');
        } catch (e) {
          Logger.error('Error initializing ChatController', error: e);
        }
        
        Logger.info('Controllers initialized successfully');
      } catch (e) {
        Logger.error('Controller initialization failed', error: e);
        // Continue with minimal functionality
      }
      
      
      Logger.info('App initialization completed, running app');
      runApp(const CamoraApp());
    } catch (error) {
      Logger.error('Error during app startup: $error', error: error);
      // Run a minimal fallback app
      runApp(MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error starting app: $error'),
          ),
        ),
      ));
    }
  }, (error, stack) {
    Logger.error('Uncaught exception in app', error: error);
  });
}

class CamoraApp extends StatefulWidget {
  const CamoraApp({super.key});

  @override
  State<CamoraApp> createState() => _CamoraAppState();
}

class _CamoraAppState extends State<CamoraApp> {
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Minimal delay for web - everything is already initialized in main()
      await Future.delayed(kIsWeb ? const Duration(milliseconds: 100) : const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      Logger.error('Error during app initialization', error: e);
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error initializing app: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Camora',
      theme: AppTheme.lightTheme,
      // Skip internal loading screen on web - HTML handles it
      home: kIsWeb
          ? (_errorMessage.isNotEmpty 
              ? _ErrorScreen(errorMessage: _errorMessage) 
              : const LoginScreen())
          : (_isLoading 
              ? const _LoadingScreen() 
              : (_errorMessage.isNotEmpty 
                  ? _ErrorScreen(errorMessage: _errorMessage) 
                  : const LoginScreen())),
      routes: {
        '/web-example': (context) => const WebResponsiveExample(),
        '/admin/categories': (context) => const CategoryManagementScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/icons/camora icon 300.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 20),
            const Text(
              'Camora',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  final String errorMessage;
  
  const _ErrorScreen({required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.black,
                size: 80,
              ),
              const SizedBox(height: 24),
              const Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  // Restart app
                  Get.offAll(() => const CamoraApp());
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
