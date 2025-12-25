package com.example.streamline

import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.View
import android.view.WindowInsetsController
import android.view.WindowManager
import androidx.annotation.NonNull
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.common.api.ApiException
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    // Channel names
    private companion object {
        const val SYSTEM_UI_CHANNEL = "com.streamline.app/system_ui"
        const val GOOGLE_SIGN_IN_CHANNEL = "com.example.streamline/google_sign_in"
        const val RC_SIGN_IN = 1001
    }

    // Google Sign-In
    private var pendingResult: MethodChannel.Result? = null
    private var googleSignInClient: GoogleSignInClient? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Setup System UI Channel
        setupSystemUIChannel(flutterEngine)
        
        // Setup Google Sign-In Channel
        setupGoogleSignInChannel(flutterEngine)
    }

    // ==================== System UI Channel ====================
    private fun setupSystemUIChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SYSTEM_UI_CHANNEL)
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

    // ==================== Google Sign-In Channel ====================
    private fun setupGoogleSignInChannel(flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, GOOGLE_SIGN_IN_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "signIn" -> {
                        val serverClientId = call.argument<String>("serverClientId")
                        if (serverClientId.isNullOrEmpty()) {
                            result.error("MISSING_CLIENT_ID", "serverClientId is required", null)
                            return@setMethodCallHandler
                        }
                        if (pendingResult != null) {
                            result.error("ALREADY_IN_PROGRESS", "A sign-in is already in progress", null)
                            return@setMethodCallHandler
                        }
                        pendingResult = result
                        startSignIn(serverClientId)
                    }
                    "signOut" -> {
                        googleSignInClient?.signOut()?.addOnCompleteListener {
                            result.success(true)
                        } ?: result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun startSignIn(serverClientId: String) {
        val gso = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
            .requestEmail()
            .requestIdToken(serverClientId)
            .build()

        googleSignInClient = GoogleSignIn.getClient(this, gso)
        val signInIntent: Intent = googleSignInClient!!.signInIntent
        startActivityForResult(signInIntent, RC_SIGN_IN)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == RC_SIGN_IN) {
            try {
                val task = GoogleSignIn.getSignedInAccountFromIntent(data)
                val account = task.getResult(ApiException::class.java)
                val resMap = HashMap<String, Any?>()
                resMap["idToken"] = account?.idToken
                resMap["email"] = account?.email
                resMap["displayName"] = account?.displayName
                resMap["givenName"] = account?.givenName
                resMap["familyName"] = account?.familyName
                resMap["photoUrl"] = account?.photoUrl?.toString()

                pendingResult?.success(resMap)
            } catch (e: ApiException) {
                Log.w("MainActivity", "signInResult:failed code=" + e.statusCode)
                pendingResult?.error("SIGN_IN_FAILED", "${e.statusCode}", e.message)
            } finally {
                pendingResult = null
            }
        }
    }
}