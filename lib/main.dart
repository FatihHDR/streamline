import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
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
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  // Initialize Firebase with options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Set up Firebase Messaging background handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(StockItemAdapter());
  Hive.registerAdapter(StockTransactionAdapter());
  Hive.registerAdapter(TransactionTypeAdapter());
  Hive.registerAdapter(PendingOperationAdapter());
  Hive.registerAdapter(LocationDataAdapter());
  Hive.registerAdapter(LocationExperimentAdapter());
  Hive.registerAdapter(NotificationItemAdapter());
  
  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  
  // Initialize auth service (no auto sign-in anymore)
  Get.put(AuthService());
  
  // Initialize preferences service
  final prefsService = Get.put(PreferencesService());
  await prefsService.onInit();
  
  // Initialize sync queue service
  final syncQueueService = Get.put(SyncQueueService());
  await syncQueueService.init();
  
  // Initialize FCM notification service
  final fcmNotificationService = Get.put(FCMNotificationService());
  await fcmNotificationService.init();
  
  runApp(const StreamlineApp());
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
