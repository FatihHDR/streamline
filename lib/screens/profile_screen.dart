import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../services/preferences_service.dart';
import '../utils/app_theme.dart';
import '../widgets/animation_mode_selector.dart';
import '../widgets/network_mode_selector.dart';
import '../experiments/controllers/experiment_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  NetworkMode _networkMode = NetworkMode.dio;

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

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final prefsService = Get.find<PreferencesService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        final user = authService.currentUser.value;
        final isAnonymous = user?.isAnonymous ?? true;

        return SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.05),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Avatar
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2), width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.white,
                        child: isAnonymous
                            ? const Icon(
                                Icons.person_outline,
                                size: 50,
                                color: AppTheme.primaryColor,
                              )
                            : Text(
                                (user?.email ?? 'U')[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // User Name/Email
                    Text(
                      isAnonymous ? 'Guest User' : user?.email ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isAnonymous ? AppTheme.textMuted : AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        isAnonymous ? 'Anonymous' : 'Registered',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Account Section
              _buildSection(
                'Account',
                [
                  if (isAnonymous)
                    _buildListTile(
                      icon: Icons.person_add,
                      title: 'Create Account',
                      subtitle: 'Sign up to save your data',
                      onTap: () {
                        Get.dialog(
                          AlertDialog(
                            title: const Text('Create Account'),
                            content: const Text(
                              'To create an account, please log out and register from the login screen.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Get.back(),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  await authService.signOut();
                                  Get.offAllNamed('/login');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                ),
                                child: const Text('Go to Login'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  if (!isAnonymous)
                    _buildListTile(
                      icon: Icons.email,
                      title: 'Email',
                      subtitle: user?.email ?? 'Not set',
                      onTap: null,
                    ),
                  _buildListTile(
                    icon: Icons.badge,
                    title: 'User ID',
                    subtitle: (user?.id ?? 'Unknown').substring(0, 8) + '...',
                    onTap: () {
                      Get.snackbar(
                        'User ID',
                        user?.id ?? 'Unknown',
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 3),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Preferences Section
              _buildSection(
                'Preferences',
                [
                  Obx(() => _buildListTile(
                        icon: Icons.animation,
                        title: 'Animation Mode',
                        subtitle: prefsService.animationMode.value == 'animated_container'
                            ? 'AnimatedContainer'
                            : 'AnimationController',
                        trailing: Switch(
                          value: prefsService.animationMode.value == 'animation_controller',
                          onChanged: (value) {
                            prefsService.setAnimationMode(
                              value ? 'animation_controller' : 'animated_container',
                            );
                          },
                          activeColor: AppTheme.primaryColor,
                        ),
                        onTap: null,
                      )),
                  Obx(() {
                    final lastSync = prefsService.lastSyncTime.value;
                    return _buildListTile(
                      icon: Icons.sync,
                      title: 'Last Sync',
                      subtitle: lastSync != null
                          ? prefsService.getTimeSinceLastSync()
                          : 'Never synced',
                      onTap: null,
                    );
                  }),
                ],
              ),

              const SizedBox(height: 8),

              // Settings Section
              _buildSection(
                'Settings',
                [
                  _buildListTile(
                    icon: Icons.tune_rounded,
                    title: 'Animation Mode',
                    subtitle: 'Configure animation settings',
                    onTap: () {
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
                                      'Animation Settings',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppTheme.surfaceColor,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Mode Animasi',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Pilih jenis animasi yang digunakan',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.textMuted,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Obx(() {
                                            final prefsService = Get.find<PreferencesService>();
                                            final currentMode = prefsService.animationMode.value == 'animated_container'
                                                ? AnimationMode.animatedContainer
                                                : AnimationMode.animationController;
                                            return AnimationModeSelector(
                                              currentMode: currentMode,
                                              onModeChanged: (mode) async {
                                                Navigator.pop(context);
                                                final modeString = mode == AnimationMode.animatedContainer
                                                    ? 'animated_container'
                                                    : 'animation_controller';
                                                await prefsService.setAnimationMode(modeString);
                                              },
                                            );
                                          }),
                                        ],
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
                    },
                  ),
                  _buildListTile(
                    icon: Icons.network_check,
                    title: 'Network Test',
                    subtitle: 'Test HTTP request performance',
                    onTap: () {
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
                                      'Network Test',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppTheme.surfaceColor,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Mode Network',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Pilih library untuk HTTP request',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.textMuted,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          NetworkModeSelector(
                                            currentMode: _networkMode,
                                            onModeChanged: (m) {
                                              setState(() => _networkMode = m);
                                            },
                                          ),
                                        ],
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
                    },
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // About Section
              _buildSection(
                'About',
                [
                  _buildListTile(
                    icon: Icons.info_outline,
                    title: 'App Version',
                    subtitle: '1.0.0',
                    onTap: null,
                  ),
                  _buildListTile(
                    icon: Icons.code,
                    title: 'Built with',
                    subtitle: 'Flutter & Supabase',
                    onTap: null,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Get.dialog(
                        AlertDialog(
                          title: const Text('Logout'),
                          content: const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                await authService.signOut();
                                Get.offAllNamed('/login');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Logo Footer
              ClipOval(
                child: Image.asset(
                  'lib/widgets/assets/streamline_logo.png',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Streamline',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 13,
        ),
      ),
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
    );
  }
}
