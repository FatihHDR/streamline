package com.example.streamline

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.view.View
import android.view.WindowManager
import android.view.WindowInsetsController
import android.os.Build
import android.os.Handler
import android.os.Looper

class MainActivity : FlutterActivity() {
    private companion object {
        const val CHANNEL = "com.streamline.app/system_ui"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hideNavigationBar" -> {
                        val duration = call.argument<Int>("duration") ?: 400
                        hideNavigationBarAnimated(duration)
                        result.success(true)
                    }
                    "showNavigationBar" -> {
                        val duration = call.argument<Int>("duration") ?: 400
                        showNavigationBarAnimated(duration)
                        result.success(true)
                    }
                    "toggleNavigationBar" -> {
                        val duration = call.argument<Int>("duration") ?: 400
                        toggleNavigationBarAnimated(duration)
                        result.success(true)
                    }
                    "isNavigationBarVisible" -> {
                        val isVisible = (window.decorView.systemUiVisibility and View.SYSTEM_UI_FLAG_HIDE_NAVIGATION) == 0
                        result.success(isVisible)
                    }
                    "setImmersiveFullscreen" -> {
                        setImmersiveFullscreen()
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun hideNavigationBarAnimated(duration: Int) {
        val decorView = window.decorView
        val flags = View.SYSTEM_UI_FLAG_HIDE_NAVIGATION or 
                   View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION or
                   View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
        
        // Animate with fade effect
        decorView.animate()
            .alpha(0.5f)
            .setDuration(duration.toLong())
            .withStartAction {
                decorView.systemUiVisibility = flags
            }
            .withEndAction {
                decorView.animate().alpha(1f).setDuration(200).start()
            }
            .start()
    }

    private fun showNavigationBarAnimated(duration: Int) {
        val decorView = window.decorView
        val flags = View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION or
                   View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
        
        decorView.animate()
            .alpha(0.5f)
            .setDuration(duration.toLong())
            .withStartAction {
                decorView.systemUiVisibility = flags
            }
            .withEndAction {
                decorView.animate().alpha(1f).setDuration(200).start()
            }
            .start()
    }

    private fun toggleNavigationBarAnimated(duration: Int) {
        val isVisible = (window.decorView.systemUiVisibility and View.SYSTEM_UI_FLAG_HIDE_NAVIGATION) == 0
        if (isVisible) {
            hideNavigationBarAnimated(duration)
        } else {
            showNavigationBarAnimated(duration)
        }
    }

    private fun setImmersiveFullscreen() {
        val decorView = window.decorView
        decorView.systemUiVisibility = (View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY or
                View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION or
                View.SYSTEM_UI_FLAG_HIDE_NAVIGATION or
                View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN or
                View.SYSTEM_UI_FLAG_FULLSCREEN)
    }
}
