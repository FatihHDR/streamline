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

    // navigation icon helper removed — custom BottomAppBar is used instead
    return Scaffold(
      extendBody: true,
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
      bottomNavigationBar: BottomAppBar(
        color: AppTheme.cardColor,
        elevation: 8,
        child: SafeArea(
          child: SizedBox(
            height: kBottomNavigationBarHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Dashboard
                _buildNavItem(
                  index: 0,
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  label: 'Dashboard',
                ),

                // Stok Barang (with badge)
                _buildNavItem(
                  index: 1,
                  icon: Icons.inventory_2_outlined,
                  activeIcon: Icons.inventory_2,
                  label: 'Stok',
                  badgeCount: lowStockCount,
                ),

                // Center add button as part of the nav bar
                SizedBox(
                  width: 80,
                  child: Center(
                    child: InkWell(
                      onTap: () async {
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
                      borderRadius: BorderRadius.circular(28),
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.14), blurRadius: 8)],
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 28),
                      ),
                    ),
                  ),
                ),

                // Riwayat
                _buildNavItem(
                  index: 2,
                  icon: Icons.history_outlined,
                  activeIcon: Icons.history,
                  label: 'Riwayat',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

    Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    int? badgeCount,
  }) {
    final selected = _selectedIndex == index;
    final color = selected ? AppTheme.primaryColor : Colors.grey.shade600;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedIndex = index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with optional badge
              badgeCount == null || badgeCount == 0
                  ? Icon(selected ? activeIcon : icon, color: color)
                  : Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(selected ? activeIcon : icon, color: color),
                        Positioned(
                          right: -6,
                          top: -6,
                          child: Container(
                            padding: badgeCount > 1 ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2) : const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppTheme.warningColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 4)],
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
                    ),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(fontSize: 11, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
