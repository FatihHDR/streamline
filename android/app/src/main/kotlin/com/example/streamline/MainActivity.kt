package com.example.streamline

import android.content.Intent
import android.util.Log
import androidx.annotation.NonNull
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.common.api.ApiException
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
	private val CHANNEL = "com.example.streamline/google_sign_in"
	private val RC_SIGN_IN = 1001
	private var pendingResult: MethodChannel.Result? = null
	private var googleSignInClient: GoogleSignInClient? = null

	override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
		super.configureFlutterEngine(flutterEngine)

		MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
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
