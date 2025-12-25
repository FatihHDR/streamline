import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:async';

/// Helper class untuk manage System UI seperti navigation bar dan status bar
class SystemUIHelper {
  static const platform = MethodChannel('com.streamline.app/system_ui');
  
  /// Hide navigation bar dengan smooth animation
  /// Animation dimulai dari bottom ke bawah (slide out)
  static Future<void> hideNavigationBar() async {
    try {
      // Set system UI overlay style - hide navigation bar
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [SystemUiOverlay.top], // Only show status bar, hide nav bar
      );
      
      // Try to use Android-specific hiding if available
      try {
        await platform.invokeMethod('hideNavigationBar');
      } catch (e) {
        // Fallback if method not implemented
        debugPrint('Navigation bar hiding not available on this device: $e');
      }
    } catch (e) {
      debugPrint('Error hiding navigation bar: $e');
    }
  }

  /// Show navigation bar with smooth animation
  static Future<void> showNavigationBar() async {
    try {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
      
      try {
        await platform.invokeMethod('showNavigationBar');
      } catch (e) {
        debugPrint('Navigation bar showing not available on this device: $e');
      }
    } catch (e) {
      debugPrint('Error showing navigation bar: $e');
    }
  }

  /// Restore default system UI
  static Future<void> restoreSystemUI() async {
    try {
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } catch (e) {
      debugPrint('Error restoring system UI: $e');
    }
  }

  /// Set landscape orientation with full immersive mode
  static Future<void> setLandscapeImmersive() async {
    try {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      
      // Hide UI elements for landscape
      await SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: [], // Completely hide all overlays
      );
    } catch (e) {
      debugPrint('Error setting landscape immersive: $e');
    }
  }

  /// Reset to default portrait orientation
  static Future<void> setPortraitDefault() async {
    try {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      
      // Restore UI elements
      await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } catch (e) {
      debugPrint('Error setting portrait default: $e');
    }
  }
}
