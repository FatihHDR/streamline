import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/user_profile.dart';
import '../../../services/auth_service.dart';

class ProfileController extends GetxController {
  final _client = Supabase.instance.client;
  final AuthService _authService = Get.find<AuthService>();

  final Rx<UserProfile?> userProfile = Rx<UserProfile?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Load profile when controller initializes or user changes
    ever(_authService.currentUser, (user) {
      if (user != null) {
        loadProfile();
      } else {
        userProfile.value = null;
      }
    });
    
    // Initial load if user is already logged in
    if (_authService.currentUser.value != null) {
      loadProfile();
    }
  }

  Future<void> loadProfile() async {
    final user = _authService.currentUser.value;
    if (user == null) return;

    isLoading.value = true;
    try {
      final data = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (data != null) {
        userProfile.value = UserProfile.fromJson(data);
      } else {
        // If no profile exists (e.g. legacy user), create a basic one in memory
        // or trigger a create if necessary. For now, we'll just show empty.
        userProfile.value = UserProfile(id: user.id);
      }
    } catch (e) {
      Get.log('Error loading profile: $e', isError: true);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile({
    String? fullName,
    String? avatarUrl,
  }) async {
    final user = _authService.currentUser.value;
    if (user == null) return;

    isLoading.value = true;
    try {
      final updates = {
        'id': user.id,
        'updated_at': DateTime.now().toIso8601String(),
        if (fullName != null) 'full_name': fullName,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      };

      final response = await _client
          .from('profiles')
          .upsert(updates)
          .select()
          .single();

      userProfile.value = UserProfile.fromJson(response);
      
      Get.snackbar('Success', 'Profile updated successfully');
    } catch (e) {
      Get.log('Error updating profile: $e', isError: true);
      Get.snackbar('Error', 'Failed to update profile: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }
}
