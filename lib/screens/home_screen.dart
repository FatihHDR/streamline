import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../data/dummy_data.dart';
import '../widgets/animation_mode_selector.dart';
import 'dashboard_animated_container.dart';
import 'dashboard_animation_controller.dart';
import 'stock_list_screen.dart';
import 'add_item_modal.dart';
import 'transaction_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  AnimationMode _animationMode = AnimationMode.animationController;

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
    final lowStockCount = DummyData.stockItems.where((i) => i.isLowStock).length;

    Widget _navIcon(IconData icon, {int? badgeCount}) {
      if (badgeCount == null || badgeCount == 0) return Icon(icon);
      return Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon),
          Positioned(
            right: -6,
            top: -6,
            child: Container(
              padding: badgeCount > 1 ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2) : const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: badgeCount > 0 ? AppTheme.warningColor : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 4),
                ],
              ),
              constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
              child: Center(
                child: Text(
                  badgeCount > 1 ? '$badgeCount' : '',
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      );
    }
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Open modal bottom sheet to add item. If an item was added (true), switch to stock list.
          final result = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (ctx) => const AddItemModal(),
          );
          if (result == true) {
            setState(() {
              _selectedIndex = 1;
            });
          }
        },
        label: const Text('Tambah Barang'),
        icon: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
        destinations: [
          NavigationDestination(
            icon: _navIcon(Icons.dashboard_outlined),
            selectedIcon: _navIcon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: _navIcon(Icons.inventory_2_outlined, badgeCount: lowStockCount),
            selectedIcon: _navIcon(Icons.inventory_2, badgeCount: lowStockCount),
            label: 'Stok Barang',
          ),
          NavigationDestination(
            icon: _navIcon(Icons.history_outlined),
            selectedIcon: _navIcon(Icons.history),
            label: 'Riwayat',
          ),
        ],
      ),
    );
  }
}
