import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../utils/app_theme.dart';
import '../widgets/animation_mode_selector.dart';
import '../widgets/sync_status_indicator.dart';
import '../services/preferences_service.dart';
import '../experiments/controllers/experiment_controller.dart';
import '../widgets/network_mode_selector.dart';
import '../modules/inventory/controllers/inventory_controller.dart';
import '../modules/location/bindings/location_binding.dart';
import '../modules/location/controllers/location_controller.dart';
import '../modules/location/views/location_dashboard_view.dart';
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

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  AnimationMode _animationMode = AnimationMode.animationController;
  NetworkMode _networkMode = NetworkMode.dio;
  late final InventoryController _inventoryController;
  late final PreferencesService _prefsService;
  late AnimationController _fabAnimationController;

  Future<void> _onAnimationModeChanged(AnimationMode mode) async {
    setState(() {
      _animationMode = mode;
    });
    
    final modeString = mode == AnimationMode.animatedContainer 
        ? 'animated_container' 
        : 'animation_controller';
    await _prefsService.setAnimationMode(modeString);
  }

  Future<void> _testNetworkMode() async {
    final expC = ExperimentController();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Testing ${_networkMode.name}...')),
    );
    try {
      final res = _networkMode == NetworkMode.http
          ? await expC.httpService.fetchPost(1)
          : await expC.dioService.fetchPost(1);
      if (!mounted) return;
      final statusMsg = res.success ? 'OK' : 'ERR';
      final errPart = res.error != null && res.error!.isNotEmpty ? ' — ${res.error}' : '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_networkMode.name}: $statusMsg ${res.statusCode} in ${res.durationMs}ms$errPart'),
        ),
      );

      if (_networkMode == NetworkMode.dio && mounted) {
        showModalBottomSheet(
          context: context,
          builder: (_) => Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Dio logs (recent)', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (res.error != null && res.error!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text('Error: ${res.error}', style: const TextStyle(color: Colors.redAccent)),
                  ),
                if (expC.dioLogs.isEmpty) const Text('No logs'),
                ...expC.dioLogs.reversed.take(20).map((e) => Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Text(e),
                    )),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
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
      case 3:
        return const LocationDashboardView();
      default:
        return const DashboardAnimatedContainer();
    }
  }

  @override
  void initState() {
    super.initState();
    _inventoryController = Get.find<InventoryController>();
    _prefsService = Get.find<PreferencesService>();
    
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    if (!Get.isRegistered<LocationController>()) {
      LocationBinding().dependencies();
    }
    
    final savedMode = _prefsService.getAnimationMode();
    if (savedMode == 'animated_container') {
      _animationMode = AnimationMode.animatedContainer;
    } else {
      _animationMode = AnimationMode.animationController;
    }
    
    Future.microtask(() => _inventoryController.initializeData());
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        bottom: !isLandscape, // Remove bottom safe area in landscape
        child: isLandscape ? _buildLandscapeLayout() : _buildPortraitLayout(),
      ),
      bottomNavigationBar: !isLandscape ? _buildPremiumBottomNav() : null,
      extendBody: !isLandscape,
    );
  }

  /// Portrait layout
  Widget _buildPortraitLayout() {
    return Column(
      children: [
        // Premium App Bar
        _buildPremiumAppBar(),
        // Content
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: Padding(
              key: ValueKey(_selectedIndex),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: _getSelectedScreen(),
            ),
          ),
        ),
      ],
    );
  }

  /// Landscape layout
  Widget _buildLandscapeLayout() {
    return Row(
      children: [
        // Compact side navigation
        Container(
          width: 80,
          color: AppTheme.cardColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLandscapeNavItem(0, Icons.home, 'Dashboard'),
                    _buildLandscapeNavItem(1, Icons.inventory_2, 'Stock'),
                    _buildLandscapeNavItem(2, Icons.history, 'History'),
                    _buildLandscapeNavItem(3, Icons.location_on, 'Location'),
                  ],
                ),
              ),
              // Profile button at bottom
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Material(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Get.toNamed('/profile');
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.account_circle,
                        size: 20,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Main content
        Expanded(
          child: Column(
            children: [
              // Compact app bar for landscape
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Logo
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        gradient: AppTheme.accentGradient,
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 28,
                            height: 28,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Title
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Streamline',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            _getScreenTitle(),
                            style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Sync indicator
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const SyncStatusIndicator(),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: Padding(
                    key: ValueKey(_selectedIndex),
                    padding: const EdgeInsets.all(16),
                    child: _getSelectedScreen(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build landscape navigation item
  Widget _buildLandscapeNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedIndex == index;
    
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _selectedIndex = index);
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.all(4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo with gradient border
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              gradient: AppTheme.accentGradient,
              shape: BoxShape.circle,
            ),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 34,
                  height: 34,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Streamline',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: AppTheme.accentGradient,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'PRO',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _getScreenTitle(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          // Sync indicator
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const SyncStatusIndicator(),
          ),
          const SizedBox(width: 8),
          // Profile button
          Material(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                HapticFeedback.lightImpact();
                Get.toNamed('/profile');
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(
                  Icons.account_circle,
                  size: 20,
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textMuted.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pengaturan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSettingsSection(
                    title: 'Mode Animasi',
                    subtitle: 'Pilih jenis animasi yang digunakan',
                    child: AnimationModeSelector(
                      currentMode: _animationMode,
                      onModeChanged: (mode) {
                        Navigator.pop(context);
                        _onAnimationModeChanged(mode);
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildSettingsSection(
                    title: 'Mode Network',
                    subtitle: 'Pilih library untuk HTTP request',
                    child: NetworkModeSelector(
                      currentMode: _networkMode,
                      onModeChanged: (m) {
                        Navigator.pop(context);
                        setState(() => _networkMode = m);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _testNetworkMode();
                      },
                      icon: const Icon(Icons.speed_rounded, size: 20),
                      label: const Text('Test Network'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildPremiumBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.1),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.grid_view_outlined, Icons.grid_view_rounded, 'Home'),
            Obx(() => _buildNavItemWithBadge(
              1, 
              Icons.inventory_2_outlined, 
              Icons.inventory_2_rounded, 
              'Stok',
              _inventoryController.lowStockItems.length,
            )),
            _buildFAB(),
            _buildNavItem(2, Icons.receipt_long_outlined, Icons.receipt_long_rounded, 'Riwayat'),
            _buildNavItem(3, Icons.location_on_outlined, Icons.location_on_rounded, 'Lokasi'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _selectedIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _selectedIndex = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                size: 22,
                color: isSelected ? AppTheme.primaryColor : AppTheme.textMuted,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppTheme.primaryColor : AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItemWithBadge(int index, IconData icon, IconData activeIcon, String label, int badgeCount) {
    final isSelected = _selectedIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _selectedIndex = index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    isSelected ? activeIcon : icon,
                    size: 22,
                    color: isSelected ? AppTheme.primaryColor : AppTheme.textMuted,
                  ),
                  if (badgeCount > 0)
                    Positioned(
                      right: -8,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppTheme.dangerColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        constraints: const BoxConstraints(minWidth: 16),
                        child: Text(
                          badgeCount > 99 ? '99+' : '$badgeCount',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppTheme.primaryColor : AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return GestureDetector(
      onTap: () async {
        HapticFeedback.mediumImpact();
        _fabAnimationController.forward().then((_) => _fabAnimationController.reverse());
        
        final result = await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: const AddItemModal(),
          ),
        );
        if (result == true) {
          setState(() => _selectedIndex = 1);
        }
      },
      child: AnimatedBuilder(
        animation: _fabAnimationController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (_fabAnimationController.value * 0.1),
            child: Container(
              width: 52,
              height: 52,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          );
        },
      ),
    );
  }

  String _getScreenTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'Ringkasan inventaris hari ini';
      case 1:
        return 'Kelola stok barang';
      case 2:
        return 'Riwayat transaksi';
      case 3:
        return 'Eksperimen lokasi GPS';
      default:
        return 'Dashboard';
    }
  }
}
