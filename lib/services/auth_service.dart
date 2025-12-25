import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends GetxController {
  final SupabaseClient _client = Supabase.instance.client;
  late final GoogleSignIn _googleSignIn;
  
  final Rx<User?> currentUser = Rx<User?>(null);
  
  @override
  void onInit() {
    super.onInit();
    currentUser.value = _client.auth.currentUser;
    
    // Initialize GoogleSignIn (optional, only if you need signOut)
    _googleSignIn = GoogleSignIn();
    
    // Listen to auth state changes
    _client.auth.onAuthStateChange.listen((data) {
      currentUser.value = data.session?.user;
    });
  }
  
  bool get isAuthenticated => currentUser.value != null;
  
  /// Sign in anonymously for quick testing
  Future<void> signInAnonymously() async {
    try {
      final response = await _client.auth.signInAnonymously();
      currentUser.value = response.user;
      Get.log('Signed in anonymously: ${response.user?.id}');
    } catch (e) {
      Get.log('Failed to sign in anonymously: $e', isError: true);
      rethrow;
    }
  }
  
  /// Sign in with email and password
  Future<void> signInWithEmail(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      currentUser.value = response.user;
      Get.log('Signed in: ${response.user?.email}');
    } catch (e) {
      Get.log('Failed to sign in: $e', isError: true);
      rethrow;
    }
  }
  
  /// Sign up with email and password
  Future<void> signUpWithEmail(String email, String password) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'com.example.streamline://login-callback',
      );
      currentUser.value = response.user;
      Get.log('Signed up: ${response.user?.email}');
      
      // Show message to check email
      if (response.user != null && response.user!.emailConfirmedAt == null) {
        Get.snackbar(
          'Verify Email',
          'Please check your email to verify your account',
          duration: const Duration(seconds: 5),
        );
      }
    } catch (e) {
      Get.log('Failed to sign up: $e', isError: true);
      rethrow;
    }
  }
  
  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      // Use Supabase hosted OAuth flow
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,  // ✅ Perbaikan: OAuthProvider bukan Provider
        redirectTo: 'com.example.streamline://login-callback',  // ✅ Perbaikan: redirectTo langsung sebagai parameter
      );

      // If a session is returned immediately (web), update the user.
      currentUser.value = _client.auth.currentSession?.user;
      Get.log('Triggered Supabase hosted Google OAuth');
    } catch (e) {
      Get.log('Failed to trigger Supabase hosted Google OAuth: $e', isError: true);
      rethrow;
    }
  }
  
  /// Sign out
  Future<void> signOut() async {
    try {
      // Sign out from Google if signed in with Google
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      
      await _client.auth.signOut();
      currentUser.value = null;
      Get.log('Signed out');
    } catch (e) {
      Get.log('Failed to sign out: $e', isError: true);
      rethrow;
    }
  }
  
  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: 'com.example.streamline://reset-password',
      );
      Get.snackbar(
        'Password Reset',
        'Check your email for password reset instructions',
        duration: const Duration(seconds: 5),
      );
    } catch (e) {
      Get.log('Failed to send reset email: $e', isError: true);
      rethrow;
    }
  }
}