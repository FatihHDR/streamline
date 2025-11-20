import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService extends GetxController {
  final SupabaseClient _client = Supabase.instance.client;
  
  final Rx<User?> currentUser = Rx<User?>(null);
  
  @override
  void onInit() {
    super.onInit();
    currentUser.value = _client.auth.currentUser;
    
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
      );
      currentUser.value = response.user;
      Get.log('Signed up: ${response.user?.email}');
    } catch (e) {
      Get.log('Failed to sign up: $e', isError: true);
      rethrow;
    }
  }
  
  /// Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      currentUser.value = null;
      Get.log('Signed out');
    } catch (e) {
      Get.log('Failed to sign out: $e', isError: true);
      rethrow;
    }
  }
}
