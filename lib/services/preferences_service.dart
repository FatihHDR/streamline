import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service untuk menyimpan preferensi user sederhana
/// Contoh: animation mode, theme preference, last sync time, dll
class PreferencesService extends GetxController {
  static const String _keyAnimationMode = 'animation_mode';
  static const String _keyLastSyncTime = 'last_sync_time';
  
  SharedPreferences? _prefs;
  
  final RxString animationMode = 'animated_container'.obs;
  final Rxn<DateTime> lastSyncTime = Rxn<DateTime>();

  /// Initialize the service
  Future<void> init() async {
    await _initPreferences();
    await _loadPreferences();
  }

  Future<void> _initPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _loadPreferences() async {
    if (_prefs == null) await _initPreferences();
    
    // Load animation mode preference
    animationMode.value = _prefs?.getString(_keyAnimationMode) ?? 'animated_container';
    
    // Load last sync time
    final syncTimeMs = _prefs?.getInt(_keyLastSyncTime);
    if (syncTimeMs != null) {
      lastSyncTime.value = DateTime.fromMillisecondsSinceEpoch(syncTimeMs);
    }
    
    Get.log('Preferences loaded: animationMode=${animationMode.value}');
  }

  // ==================== ANIMATION MODE ====================

  /// Get current animation mode
  String getAnimationMode() {
    return animationMode.value;
  }

  /// Save animation mode preference
  Future<void> setAnimationMode(String mode) async {
    if (_prefs == null) await _initPreferences();
    
    await _prefs?.setString(_keyAnimationMode, mode);
    animationMode.value = mode;
    Get.log('Animation mode saved: $mode');
  }

  /// Check if using AnimationController mode
  bool get isUsingAnimationController {
    return animationMode.value == 'animation_controller';
  }

  // ==================== SYNC TIME ====================

  /// Update last sync timestamp
  Future<void> updateLastSyncTime() async {
    if (_prefs == null) await _initPreferences();
    
    final now = DateTime.now();
    await _prefs?.setInt(_keyLastSyncTime, now.millisecondsSinceEpoch);
    lastSyncTime.value = now;
    Get.log('Last sync time updated: $now');
  }

  /// Get last sync time
  DateTime? getLastSyncTime() {
    return lastSyncTime.value;
  }

  /// Get time since last sync in human-readable format
  String getTimeSinceLastSync() {
    if (lastSyncTime.value == null) return 'Belum pernah sync';
    
    final now = DateTime.now();
    final difference = now.difference(lastSyncTime.value!);
    
    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} jam yang lalu';
    } else {
      return '${difference.inDays} hari yang lalu';
    }
  }

  // ==================== UTILITY ====================

  /// Clear all preferences (useful for logout/reset)
  Future<void> clearAll() async {
    if (_prefs == null) await _initPreferences();
    
    await _prefs?.clear();
    animationMode.value = 'animated_container';
    lastSyncTime.value = null;
    Get.log('All preferences cleared');
  }

  /// Check if this is first app launch
  Future<bool> isFirstLaunch() async {
    if (_prefs == null) await _initPreferences();
    
    const key = 'is_first_launch';
    final isFirst = _prefs?.getBool(key) ?? true;
    
    if (isFirst) {
      await _prefs?.setBool(key, false);
    }
    
    return isFirst;
  }
}
