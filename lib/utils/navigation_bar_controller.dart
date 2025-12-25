import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Controller untuk manage navigation bar visibility dan animasi
class NavigationBarAnimationController {
  static const platform = MethodChannel('com.streamline.app/system_ui');
  
  /// Hide navigation bar dengan smooth animation
  static Future<bool> hideNavigationBar({
    Duration animationDuration = const Duration(milliseconds: 400),
  }) async {
    try {
      // Set system UI overlay
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [SystemUiOverlay.top], // Only show status bar
      );
      
      // Try to call native Android method for smooth animation
      try {
        final result = await platform.invokeMethod<bool>(
          'hideNavigationBar',
          {'duration': animationDuration.inMilliseconds},
        );
        return result ?? true;
      } catch (e) {
        debugPrint('Navigation bar hide not available on this device: $e');
        return true;
      }
    } catch (e) {
      debugPrint('Error hiding navigation bar: $e');
      return false;
    }
  }

  /// Show navigation bar dengan smooth animation
  static Future<bool> showNavigationBar({
    Duration animationDuration = const Duration(milliseconds: 400),
  }) async {
    try {
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
      
      try {
        final result = await platform.invokeMethod<bool>(
          'showNavigationBar',
          {'duration': animationDuration.inMilliseconds},
        );
        return result ?? true;
      } catch (e) {
        debugPrint('Navigation bar show not available on this device: $e');
        return true;
      }
    } catch (e) {
      debugPrint('Error showing navigation bar: $e');
      return false;
    }
  }

  /// Toggle navigation bar visibility
  static Future<bool> toggleNavigationBar({
    Duration animationDuration = const Duration(milliseconds: 400),
  }) async {
    try {
      final result = await platform.invokeMethod<bool>(
        'toggleNavigationBar',
        {'duration': animationDuration.inMilliseconds},
      );
      return result ?? true;
    } catch (e) {
      debugPrint('Navigation bar toggle not available: $e');
      return false;
    }
  }

  /// Get current navigation bar visibility status
  static Future<bool> isNavigationBarVisible() async {
    try {
      final result = await platform.invokeMethod<bool>(
        'isNavigationBarVisible',
      );
      return result ?? true;
    } catch (e) {
      debugPrint('Could not get navigation bar visibility: $e');
      return true;
    }
  }

  /// Set immersive fullscreen mode (hide all system UI)
  static Future<bool> setImmersiveFullscreen() async {
    try {
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [], // Hide everything
      );
      
      try {
        final result = await platform.invokeMethod<bool>('setImmersiveFullscreen');
        return result ?? true;
      } catch (e) {
        debugPrint('Immersive fullscreen not available: $e');
        return true;
      }
    } catch (e) {
      debugPrint('Error setting immersive fullscreen: $e');
      return false;
    }
  }

  /// Restore normal system UI
  static Future<bool> restoreSystemUI() async {
    try {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      return true;
    } catch (e) {
      debugPrint('Error restoring system UI: $e');
      return false;
    }
  }
}
