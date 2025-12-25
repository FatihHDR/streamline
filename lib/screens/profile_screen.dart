import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../services/preferences_service.dart';
import '../utils/app_theme.dart';
import '../widgets/animation_mode_selector.dart';
import '../widgets/network_mode_selector.dart';
import '../experiments/controllers/experiment_controller.dart';
import '../modules/profile/controllers/profile_controller.dart';
import 'edit_profile_screen.dart';

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
    // Set system UI style for transparent status bar
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    final authService = Get.find<AuthService>();
    final prefsService = Get.find<PreferencesService>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Obx(() {
        final user = authService.currentUser.value;
        final isAnonymous = user?.isAnonymous ?? true;

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // Premium Header
              _buildPremiumHeader(context, user, isAnonymous),
              
              const SizedBox(height: 20),

              // Account Section
              _buildSection(
                'Account',
                [
                  if (isAnonymous)
                    _buildListTile(
                      icon: Icons.person_add_rounded,
                      iconColor: Colors.blue,
                      title: 'Create Account',
                      subtitle: 'Sign up to save your data',
                      onTap: () {
                        HapticFeedback.lightImpact();
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
                  if (!isAnonymous) ...[
                    _buildListTile(
                      icon: Icons.edit_rounded,
                      iconColor: AppTheme.primaryColor,
                      title: 'Edit Profil',
                      subtitle: 'Ubah nama dan avatar',
                      onTap: () {
                         HapticFeedback.lightImpact();
                         Get.to(() => const EditProfileScreen());
                      },
                    ),
                    _buildListTile(
                      icon: Icons.email_rounded,
                      iconColor: Colors.blue,
                      title: 'Email',
                      subtitle: user?.email ?? 'Not set',
                      onTap: null,
                    ),
                  ],
                  _buildListTile(
                    icon: Icons.badge_rounded,
                    iconColor: Colors.purple,
                    title: 'User ID',
                    subtitle: () {
                      final userId = user?.id ?? 'Unknown';
                      return userId.length > 8 ? '${userId.substring(0, 8)}...' : userId;
                    }(),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Get.snackbar(
                        'User ID',
                        user?.id ?? 'Unknown',
                        snackPosition: SnackPosition.BOTTOM,
                        duration: const Duration(seconds: 3),
                        backgroundColor: AppTheme.surfaceColor,
                        colorText: AppTheme.textPrimary,
                        margin: const EdgeInsets.all(16),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Preferences Section
              _buildSection(
                'Preferences',
                [
                  Obx(() => _buildListTile(
                        icon: Icons.animation_rounded,
                        iconColor: Colors.orange,
                        title: 'Animation Mode',
                        subtitle: prefsService.animationMode.value == 'animated_container'
                            ? 'AnimatedContainer'
                            : 'AnimationController',
                        trailing: Switch(
                          value: prefsService.animationMode.value == 'animation_controller',
                          onChanged: (value) {
                            HapticFeedback.lightImpact();
                            prefsService.setAnimationMode(
                              value ? 'animation_controller' : 'animated_container',
                            );
                          },
                          activeColor: AppTheme.primaryColor,
                        ),
                        onTap: () {
                          HapticFeedback.lightImpact();
                          prefsService.setAnimationMode(
                            prefsService.animationMode.value == 'animated_container'
                                ? 'animation_controller'
                                : 'animated_container',
                          );
                        },
                      )),
                  Obx(() {
                    final lastSync = prefsService.lastSyncTime.value;
                    return _buildListTile(
                      icon: Icons.sync_rounded,
                      iconColor: Colors.teal,
                      title: 'Last Sync',
                      subtitle: lastSync != null
                          ? prefsService.getTimeSinceLastSync()
                          : 'Never synced',
                      onTap: null,
                    );
                  }),
                ],
              ),

              const SizedBox(height: 16),

              // Settings Section
              _buildSection(
                'Settings',
                [
                  _buildListTile(
                    icon: Icons.tune_rounded,
                    iconColor: Colors.indigo,
                    title: 'Animation Settings',
                    subtitle: 'Configure animation details',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showAnimationSettings(context);
                    },
                  ),
                  _buildListTile(
                    icon: Icons.network_check_rounded,
                    iconColor: Colors.green,
                    title: 'Network Test',
                    subtitle: 'Test HTTP request performance',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showNetworkSettings(context);
                    },
                  ),
                  _buildListTile(
                    icon: Icons.bug_report_rounded,
                    iconColor: Colors.red,
                    title: 'Debug Supabase Sync',
                    subtitle: 'Diagnose sync issues',
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Get.toNamed('/debug-sync');
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // About Section
              _buildSection(
                'About',
                [
                  _buildListTile(
                    icon: Icons.info_outline_rounded,
                    iconColor: Colors.blueGrey,
                    title: 'App Version',
                    subtitle: '1.0.0',
                    onTap: null,
                  ),
                  _buildListTile(
                    icon: Icons.code_rounded,
                    iconColor: Colors.blueGrey,
                    title: 'Built with',
                    subtitle: 'Flutter & Supabase',
                    onTap: null,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Logout Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Get.dialog(
                        AlertDialog(
                          title: const Text('Logout'),
                          content: const Text('Are you sure you want to logout?'),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.dangerColor,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: AppTheme.dangerColor.withOpacity(0.2)),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout_rounded, color: AppTheme.dangerColor),
                        const SizedBox(width: 8),
                        Text(
                          'Log Out',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.dangerColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Logo Footer
              Opacity(
                opacity: 0.5,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 24,
                            height: 24,
                            fit: BoxFit.cover,
                            errorBuilder: (c, o, s) => const Icon(Icons.grid_view_rounded, size: 24, color: AppTheme.primaryColor),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Streamline v1.0.0',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPremiumHeader(BuildContext context, dynamic user, bool isAnonymous) {
    // Inject controller if not already
    final ProfileController profileController = Get.put(ProfileController());
    final bool canPop = Navigator.canPop(context);

    return Obx(() {
      final profile = profileController.userProfile.value;
      final displayName = profile?.fullName ?? user?.email?.split('@')[0] ?? 'User';
      final avatarUrl = profile?.avatarUrl;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            if (canPop)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    onTap: () => Get.back(),
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: AppTheme.textPrimary,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            // Avatar with gradient border
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: AppTheme.accentGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: AppTheme.surfaceColor,
                  backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty) 
                      ? NetworkImage(avatarUrl) 
                      : null,
                  child: (isAnonymous || (avatarUrl == null || avatarUrl.isEmpty))
                      ? (isAnonymous
                          ? const Icon(
                              Icons.person_rounded,
                              size: 45,
                              color: AppTheme.textMuted,
                            )
                          : Text(
                              (displayName.isNotEmpty ? displayName[0] : 'U').toUpperCase(),
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryColor,
                              ),
                            ))
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Name and Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isAnonymous ? 'Guest User' : displayName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 8),
                if (!isAnonymous)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'PRO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                if (isAnonymous)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.textMuted.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'GUEST',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              isAnonymous ? 'Sign in to sync your data' : (user?.email ?? ''),
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppTheme.textMuted.withOpacity(0.7),
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
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
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing,
              if (trailing == null && onTap != null)
                Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted.withOpacity(0.5)),
            ],
          ),
        ),
      ),
    );
  }

  void _showAnimationSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
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
                        const Text(
                          'Mode Animasi',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNetworkSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Network Settings',
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
                        const Text(
                          'Mode Network',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
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
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

