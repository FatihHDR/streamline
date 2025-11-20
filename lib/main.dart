import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/stock_item.dart';
import 'models/stock_transaction.dart';
import 'screens/home_screen.dart';
import 'utils/app_theme.dart';
import 'modules/inventory/bindings/inventory_binding.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: '.env');
  
  // Initialize Hive for local storage
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(StockItemAdapter());
  Hive.registerAdapter(StockTransactionAdapter());
  Hive.registerAdapter(TransactionTypeAdapter());
  
  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  
  // Initialize auth service and sign in anonymously for testing
  final authService = Get.put(AuthService());
  try {
    await authService.signInAnonymously();
  } catch (e) {
    debugPrint('Auto sign-in failed: $e');
  }
  
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
      home: const HomeScreen(),
    );
  }
}
