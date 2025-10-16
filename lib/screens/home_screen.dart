import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../widgets/animation_mode_selector.dart';
import 'dashboard_animated_container.dart';
import 'dashboard_animation_controller.dart';
import 'stock_list_screen.dart';
import 'transaction_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  AnimationMode _animationMode = AnimationMode.animatedContainer;

  void _onAnimationModeChanged(AnimationMode mode) {
    setState(() {
      _animationMode = mode;
    });
  }

  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return _animationMode == AnimationMode.animatedContainer
            ? const DashboardAnimatedContainer()
            : const DashboardAnimationController();
      case 1:
        return StockListScreen(animationMode: _animationMode);
      case 2:
        return TransactionHistoryScreen(animationMode: _animationMode);
      default:
        return const DashboardAnimatedContainer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: Image.asset(
                'assets/images/logo.png',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Streamline'),
          ],
        ),
        actions: [
          AnimationModeSelector(
            currentMode: _animationMode,
            onModeChanged: _onAnimationModeChanged,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _getSelectedScreen(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: AppTheme.cardColor,
        indicatorColor: AppTheme.primaryColor.withOpacity(0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Stok Barang',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'Riwayat',
          ),
        ],
      ),
    );
  }
}
