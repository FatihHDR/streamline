import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'screens/home_screen.dart';
import 'utils/app_theme.dart';
import 'providers/inventory_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Load environment variables from .env if present. Falls back silently if not.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // ignore: avoid_print
    print('No .env file found — using defaults');
  }
  runApp(const StreamlineApp());
}

class StreamlineApp extends StatelessWidget {
  const StreamlineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InventoryProvider(),
      child: GetMaterialApp(
        title: 'Streamline - Manajemen Stok Gudang',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        home: const HomeScreen(),
      ),
    );
  }
}
