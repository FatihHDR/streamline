import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'utils/navigation_bar_controller.dart';
import 'models/stock_item.dart';
import 'models/stock_transaction.dart';
import 'models/pending_operation.dart';
import 'models/notification_item.dart';
import 'modules/location/models/location_data.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/home_screen.dart';
import 'utils/app_theme.dart';
import 'modules/inventory/bindings/inventory_binding.dart';
import 'modules/notification/bindings/notification_binding.dart';
import 'modules/notification/views/notification_list_screen.dart';
import 'modules/notification/views/notification_detail_screen.dart';
import 'services/auth_service.dart';
import 'services/preferences_service.dart';
import 'services/sync_queue_service.dart';
import 'services/fcm_notification_service.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    debugPrint('🚀 [MAIN] Starting app initialization...');
    
    // Hide navigation bar at startup with animation
    debugPrint('📱 [MAIN] Hiding navigation bar with animation...');
    await NavigationBarAnimationController.hideNavigationBar(
      animationDuration: const Duration(milliseconds: 400),
    );
    
    try {
      // Load environment variables
      debugPrint('📦 [MAIN] Loading environment variables...');
      await dotenv.load(fileName: '.env');
      
      // Initialize Firebase with options
      debugPrint('🔥 [MAIN] Initializing Firebase...');
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      
      // Set up Firebase Messaging background handler
      debugPrint('📩 [MAIN] Setting up FCM background handler...');
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      
      // Initialize Hive for local storage
      debugPrint('💾 [MAIN] Initializing Hive...');
      await Hive.initFlutter();
      
      // Register Hive adapters
      debugPrint('🔌 [MAIN] Registering Hive adapters...');
      Hive.registerAdapter(StockItemAdapter());
      Hive.registerAdapter(StockTransactionAdapter());
      Hive.registerAdapter(TransactionTypeAdapter());
      Hive.registerAdapter(PendingOperationAdapter());
      Hive.registerAdapter(OperationTypeAdapter());
      Hive.registerAdapter(LocationDataAdapter());
      Hive.registerAdapter(LocationExperimentAdapter());
      Hive.registerAdapter(NotificationItemAdapter());
      
      // Initialize Supabase
      debugPrint('⚡ [MAIN] Initializing Supabase...');
      await Supabase.initialize(
        url: dotenv.env['SUPABASE_URL']!,
        anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
      );
      
      // Initialize auth service (no auto sign-in anymore)
      debugPrint('🔐 [MAIN] Initializing AuthService...');
      Get.put(AuthService());
      
      // Initialize preferences service
      debugPrint('⚙️ [MAIN] Initializing PreferencesService...');
      final prefsService = Get.put(PreferencesService());
      await prefsService.init().timeout(const Duration(seconds: 5), onTimeout: () {
        debugPrint('⚠️ [MAIN] PreferencesService init timed out!');
        return;
      });
      
      // Initialize sync queue service
      debugPrint('🔄 [MAIN] Initializing SyncQueueService...');
      final syncQueueService = Get.put(SyncQueueService());
      await syncQueueService.init().timeout(const Duration(seconds: 5), onTimeout: () {
        debugPrint('⚠️ [MAIN] SyncQueueService init timed out!');
        return;
      });
      
      // Initialize FCM notification service
      debugPrint('🔔 [MAIN] Initializing FCMNotificationService...');
      final fcmNotificationService = Get.put(FCMNotificationService());
      // Don't let notification service block app startup if it fails/timeouts
      try {
        await fcmNotificationService.init().timeout(const Duration(seconds: 5));
      } catch (e) {
        debugPrint('⚠️ [MAIN] FCM Service failed to init: $e');
      }
      
      debugPrint('✅ [MAIN] Initialization complete. Running app...');
      runApp(const StreamlineApp());
      
    } catch (e, stack) {
      debugPrint('❌ [MAIN] Fatal initialization error: $e');
      debugPrint(stack.toString());
      runApp(ErrorApp(error: e.toString(), stack: stack.toString()));
    }
  }, (error, stack) {
    debugPrint('❌ [MAIN] Uncaught error in zone: $error');
    debugPrint(stack.toString());
  });
}

class ErrorApp extends StatelessWidget {
  final String error;
  final String stack;

  const ErrorApp({super.key, required this.error, required this.stack});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.red.shade50,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Initialization Failed',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  height: 200,
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: Text(
                      'Error: $error\n\nStack: $stack',
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class StreamlineApp extends StatelessWidget {
  const StreamlineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Streamline - Manajemen Stok Gudang',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialBinding: InventoryBinding(),
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/register', page: () => const RegisterScreen()),
        GetPage(name: '/home', page: () => const HomeScreen()),
        GetPage(name: '/profile', page: () => const ProfileScreen()),
        GetPage(
          name: '/notifications',
          page: () => const NotificationListScreen(),
          binding: NotificationBinding(),
        ),
        GetPage(
          name: '/notifications/detail',
          page: () {
            final args = Get.arguments as Map<String, dynamic>;
            final notification = args['notification'] as NotificationItem;
            return NotificationDetailScreen(notification: notification);
          },
        ),
      ],
    );
  }
}
