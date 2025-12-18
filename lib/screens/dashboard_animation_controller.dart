import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/app_theme.dart';
import '../models/stock_item.dart';
import '../widgets/stat_card_controller.dart';
import '../widgets/stock_chart_controller.dart';
import '../widgets/low_stock_alert_controller.dart';
import '../modules/inventory/controllers/inventory_controller.dart';

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
  late final InventoryController _inventoryController;

  int get totalItems => _inventoryController.items.length;
  int get totalQuantity =>
    _inventoryController.items.fold(0, (sum, item) => sum + item.quantity);
  int get lowStockItems => _inventoryController.lowStockItems.length;
  int get outOfStockItems => _inventoryController.outOfStockCount;

  List<StockItem> get lowStockList => _inventoryController.lowStockItems;

  @override
  void initState() {
    super.initState();
    _inventoryController = Get.find<InventoryController>();
    
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerController,
      curve: Curves.easeOutCubic,
    ));

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
    final bottomInset = MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight + 32;

    return RefreshIndicator(
      onRefresh: () async {
        await _inventoryController.refreshAll();
        _refreshDashboard();
      },
      color: AppTheme.primaryColor,
      child: Obx(() {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Animated Welcome Card
              SlideTransition(
                position: _slideAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: _buildWelcomeCard(),
                ),
              ),
              const SizedBox(height: 20),

              // Quick Stats Section
              FadeTransition(
                opacity: _fadeAnimation,
                child: _buildSectionTitle('Ringkasan', Icons.analytics_outlined),
              ),
              const SizedBox(height: 12),
              
              // Statistik Cards
              FadeTransition(
                opacity: _fadeAnimation,
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    StatCardController(
                      title: 'Total Item',
                      value: totalItems.toString(),
                      icon: Icons.inventory_2_rounded,
                      color: AppTheme.infoColor,
                      trend: '+5%',
                      delay: 0,
                    ),
                    StatCardController(
                      title: 'Kuantitas',
                      value: _formatNumber(totalQuantity),
                      icon: Icons.all_inbox_rounded,
                      color: AppTheme.successColor,
                      trend: '+12%',
                      delay: 100,
                    ),
                    StatCardController(
                      title: 'Stok Menipis',
                      value: lowStockItems.toString(),
                      icon: Icons.warning_amber_rounded,
                      color: AppTheme.warningColor,
                      trend: lowStockItems > 0 ? '!' : '✓',
                      delay: 200,
                    ),
                    StatCardController(
                      title: 'Stok Habis',
                      value: outOfStockItems.toString(),
                      icon: Icons.error_outline_rounded,
                      color: AppTheme.dangerColor,
                      trend: outOfStockItems > 0 ? '!!' : '✓',
                      delay: 300,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Chart Section
              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Grafik Stok', Icons.bar_chart_rounded),
                    const SizedBox(height: 12),
                    const StockChartController(),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Low Stock Alerts
              if (lowStockList.isNotEmpty)
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Peringatan Stok', Icons.notification_important_rounded),
                      const SizedBox(height: 12),
                      LowStockAlertController(lowStockItems: lowStockList),
                    ],
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildWelcomeCard() {
    final hour = DateTime.now().hour;
    String greeting;
    IconData greetingIcon;
    Color accentColor;
    
    if (hour < 12) {
      greeting = 'Selamat Pagi';
      greetingIcon = Icons.wb_sunny_rounded;
      accentColor = const Color(0xFFFFA726);
    } else if (hour < 17) {
      greeting = 'Selamat Siang';
      greetingIcon = Icons.light_mode_rounded;
      accentColor = const Color(0xFF42A5F5);
    } else {
      greeting = 'Selamat Malam';
      greetingIcon = Icons.nightlight_round;
      accentColor = const Color(0xFF7E57C2);
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            left: -30,
            bottom: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.03),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
              RotationTransition(
                turns: Tween(begin: 0.0, end: 0.05).animate(_headerController),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        accentColor.withOpacity(0.8),
                        accentColor,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Icon(greetingIcon, color: Colors.white, size: 28),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Dashboard Inventaris',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),

            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.flutter_dash_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AnimationController Mode',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Kontrol presisi untuk animasi kompleks',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ]),
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
