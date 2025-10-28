import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../data/dummy_data.dart';
import '../models/stock_item.dart';
import '../widgets/stat_card_animated.dart';
import '../widgets/stock_chart_animated.dart';
import '../widgets/low_stock_alert_animated.dart';

class DashboardAnimatedContainer extends StatefulWidget {
  const DashboardAnimatedContainer({super.key});

  @override
  State<DashboardAnimatedContainer> createState() => _DashboardAnimatedContainerState();
}

class _DashboardAnimatedContainerState extends State<DashboardAnimatedContainer> {
  bool _isExpanded = false;

  int get totalItems => DummyData.stockItems.length;
  int get totalQuantity => DummyData.stockItems.fold(0, (sum, item) => sum + item.quantity);
  int get lowStockItems => DummyData.stockItems.where((item) => item.isLowStock).length;
  int get outOfStockItems => DummyData.stockItems.where((item) => item.isOutOfStock).length;
  
  List<StockItem> get lowStockList => DummyData.stockItems
      .where((item) => item.isLowStock)
      .toList();

  @override
  Widget build(BuildContext context) {
  final bottomInset = MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight;

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
  // Add extra buffer to ensure content doesn't overflow under the bottom nav
  padding: EdgeInsets.fromLTRB(16, 16, 16, bottomInset + 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dengan animasi
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              padding: EdgeInsets.all(_isExpanded ? 20 : 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.primaryVariant],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(_isExpanded ? 20 : 12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: _isExpanded ? 20 : 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        padding: EdgeInsets.all(_isExpanded ? 12 : 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(_isExpanded ? 12 : 8),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: _isExpanded ? 32 : 24,
                            height: _isExpanded ? 32 : 24,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dashboard Gudang',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: _isExpanded ? 24 : 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Mode: AnimatedContainer',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        icon: AnimatedRotation(
                          turns: _isExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: const Icon(Icons.expand_more, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  if (_isExpanded) ...[
                    const SizedBox(height: 16),
                    AnimatedOpacity(
                      opacity: _isExpanded ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        'Kelola stok barang gudang Anda dengan mudah dan efisien',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Statistik Cards dengan AnimatedContainer
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.4,
              children: [
                StatCardAnimated(
                  title: 'Total Item',
                  value: totalItems.toString(),
                  icon: Icons.inventory_2,
                  color: AppTheme.infoColor,
                  trend: '+5%',
                ),
                StatCardAnimated(
                  title: 'Total Kuantitas',
                  value: totalQuantity.toString(),
                  icon: Icons.all_inbox,
                  color: AppTheme.successColor,
                  trend: '+12%',
                ),
                StatCardAnimated(
                  title: 'Stok Menipis',
                  value: lowStockItems.toString(),
                  icon: Icons.warning_amber,
                  color: AppTheme.warningColor,
                  trend: '-3%',
                ),
                StatCardAnimated(
                  title: 'Stok Habis',
                  value: outOfStockItems.toString(),
                  icon: Icons.error_outline,
                  color: AppTheme.dangerColor,
                  trend: '0%',
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Chart Section
            const StockChartAnimated(),
            const SizedBox(height: 24),

            // Low Stock Alerts
            LowStockAlertAnimated(lowStockItems: lowStockList),
          ],
        ),
      ),
    );
  }
}
