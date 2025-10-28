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
      // Custom modern header
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(84),
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.backgroundColor, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              // subtle bottom border radius to blend into content
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                ClipOval(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Streamline', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    SizedBox(height: 2),
                    Text('Dashboard', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                  ],
                ),
                const SizedBox(width: 18),
                // Search / quick filter
                Expanded(
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Cari produk, kode, atau kategori',
                        prefixIcon: const Icon(Icons.search),
                        isDense: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                AnimationModeSelector(
                  currentMode: _animationMode,
                  onModeChanged: _onAnimationModeChanged,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: _getSelectedScreen(),
      ),
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
