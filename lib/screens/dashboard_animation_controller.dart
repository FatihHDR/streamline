import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../data/dummy_data.dart';
import '../models/stock_item.dart';
import '../widgets/stat_card_controller.dart';
import '../widgets/stock_chart_controller.dart';
import '../widgets/low_stock_alert_controller.dart';

class DashboardAnimationController extends StatefulWidget {
  const DashboardAnimationController({super.key});

  @override
  State<DashboardAnimationController> createState() => _DashboardAnimationControllerState();
}

class _DashboardAnimationControllerState extends State<DashboardAnimationController>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int get totalItems => DummyData.stockItems.length;
  int get totalQuantity => DummyData.stockItems.fold(0, (sum, item) => sum + item.quantity);
  int get lowStockItems => DummyData.stockItems.where((item) => item.isLowStock).length;
  int get outOfStockItems => DummyData.stockItems.where((item) => item.isOutOfStock).length;
  
  List<StockItem> get lowStockList => DummyData.stockItems
      .where((item) => item.isLowStock)
      .toList();

  @override
  void initState() {
    super.initState();
    
    // Header animation controller
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Fade animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Scale animation untuk header
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.elasticOut,
    ));

    // Fade animation untuk konten
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    // Slide animation untuk header
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _fadeController.forward();
      }
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _refreshDashboard() {
    _headerController.reset();
    _fadeController.reset();
    _headerController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _fadeController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          _refreshDashboard();
        });
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Animated Header dengan AnimationController
            SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.primaryDark,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      RotationTransition(
                        turns: _headerController,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.dashboard_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Dashboard Gudang',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: Text(
                                'Mode: AnimationController',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Statistik Cards dengan AnimationController
            FadeTransition(
              opacity: _fadeAnimation,
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.4,
                children: [
                  StatCardController(
                    title: 'Total Item',
                    value: totalItems.toString(),
                    icon: Icons.inventory_2,
                    color: AppTheme.infoColor,
                    trend: '+5%',
                    delay: 0,
                  ),
                  StatCardController(
                    title: 'Total Kuantitas',
                    value: totalQuantity.toString(),
                    icon: Icons.all_inbox,
                    color: AppTheme.successColor,
                    trend: '+12%',
                    delay: 100,
                  ),
                  StatCardController(
                    title: 'Stok Menipis',
                    value: lowStockItems.toString(),
                    icon: Icons.warning_amber,
                    color: AppTheme.warningColor,
                    trend: '-3%',
                    delay: 200,
                  ),
                  StatCardController(
                    title: 'Stok Habis',
                    value: outOfStockItems.toString(),
                    icon: Icons.error_outline,
                    color: AppTheme.dangerColor,
                    trend: '0%',
                    delay: 300,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Chart Section
            FadeTransition(
              opacity: _fadeAnimation,
              child: const StockChartController(),
            ),
            const SizedBox(height: 24),

            // Low Stock Alerts
            FadeTransition(
              opacity: _fadeAnimation,
              child: LowStockAlertController(lowStockItems: lowStockList),
            ),
          ],
        ),
      ),
    );
  }
}
