import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/app_theme.dart';
import '../models/stock_item.dart';
import '../modules/inventory/controllers/inventory_controller.dart';
import '../widgets/stat_card_animated.dart';
import '../widgets/stock_chart_animated.dart';
import '../widgets/low_stock_alert_animated.dart';

class DashboardAnimatedContainer extends StatefulWidget {
  const DashboardAnimatedContainer({super.key});

  @override
  State<DashboardAnimatedContainer> createState() =>
      _DashboardAnimatedContainerState();
}

class _DashboardAnimatedContainerState
    extends State<DashboardAnimatedContainer> {
  late final InventoryController _inventoryController;

  @override
  void initState() {
    super.initState();
    _inventoryController = Get.find<InventoryController>();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset =
        MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight + 32;

    return RefreshIndicator(
      onRefresh: () async {
        await _inventoryController.refreshAll();
      },
      color: AppTheme.primaryColor,
      child: Obx(
        () {
          final items = _inventoryController.items;
          final totalItems = items.length;
          final totalQuantity =
              items.fold(0, (sum, item) => sum + item.quantity);
          final List<StockItem> lowStockList =
              _inventoryController.lowStockItems;
          final lowStockItems = lowStockList.length;
          final outOfStockItems = _inventoryController.outOfStockCount;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(bottom: bottomInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Card
                _buildWelcomeCard(),
                const SizedBox(height: 20),

                // Quick Stats Section
                _buildSectionTitle('Ringkasan', Icons.analytics_outlined),
                const SizedBox(height: 12),
                
                // Statistik Cards
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    StatCardAnimated(
                      title: 'Total Item',
                      value: totalItems.toString(),
                      icon: Icons.inventory_2_rounded,
                      color: AppTheme.infoColor,
                      trend: '+5%',
                    ),
                    StatCardAnimated(
                      title: 'Kuantitas',
                      value: _formatNumber(totalQuantity),
                      icon: Icons.all_inbox_rounded,
                      color: AppTheme.successColor,
                      trend: '+12%',
                    ),
                    StatCardAnimated(
                      title: 'Stok Menipis',
                      value: lowStockItems.toString(),
                      icon: Icons.warning_amber_rounded,
                      color: AppTheme.warningColor,
                      trend: lowStockItems > 0 ? '!' : '✓',
                    ),
                    StatCardAnimated(
                      title: 'Stok Habis',
                      value: outOfStockItems.toString(),
                      icon: Icons.error_outline_rounded,
                      color: AppTheme.dangerColor,
                      trend: outOfStockItems > 0 ? '!!' : '✓',
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Chart Section
                _buildSectionTitle('Grafik Stok', Icons.bar_chart_rounded),
                const SizedBox(height: 12),
                const StockChartAnimated(),
                const SizedBox(height: 24),

                // Low Stock Alerts
                if (lowStockList.isNotEmpty) ...[
                  _buildSectionTitle('Peringatan Stok', Icons.notification_important_rounded),
                  const SizedBox(height: 12),
                  LowStockAlertAnimated(lowStockItems: lowStockList),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeCard() {
    final hour = DateTime.now().hour;
    String greeting;
    IconData greetingIcon;
    
    if (hour < 12) {
      greeting = 'Selamat Pagi';
      greetingIcon = Icons.wb_sunny_rounded;
    } else if (hour < 17) {
      greeting = 'Selamat Siang';
      greetingIcon = Icons.light_mode_rounded;
    } else {
      greeting = 'Selamat Malam';
      greetingIcon = Icons.nightlight_round;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(greetingIcon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Dashboard Inventaris',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.tips_and_updates_rounded, color: Colors.white70, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Mode animasi: AnimatedContainer - Kelola stok dengan mudah',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor.withOpacity(0.15),
                AppTheme.accentColor.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.15),
              width: 1,
            ),
          ),
          child: Icon(icon, size: 18, color: AppTheme.primaryColor),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          height: 1,
          width: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor.withOpacity(0.3),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
