import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService extends GetxController {
  final SupabaseClient _client = Supabase.instance.client;
  late final GoogleSignIn _googleSignIn;
  
  final Rx<User?> currentUser = Rx<User?>(null);
  
  @override
  void onInit() {
    super.onInit();
    currentUser.value = _client.auth.currentUser;
    
    // Initialize Google Sign-In
    _googleSignIn = GoogleSignIn(
      clientId: dotenv.env['GOOGLE_CLIENT_ID'],
      serverClientId: dotenv.env['GOOGLE_CLIENT_ID'],
    );
    
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
      // Sign in with Google
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign-in cancelled');
      }

      // Get Google authentication
      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw Exception('No Access Token found');
      }
      if (idToken == null) {
        throw Exception('No ID Token found');
      }

      // Sign in to Supabase with Google credentials
      final response = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      currentUser.value = response.user;
      Get.log('Signed in with Google: ${response.user?.email}');
    } catch (e) {
      Get.log('Failed to sign in with Google: $e', isError: true);
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
