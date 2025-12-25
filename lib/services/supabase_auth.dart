import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService {
  final SupabaseClient _client = Supabase.instance.client;

  /// Trigger Supabase hosted Google OAuth sign-in.
  ///
  /// `redirectTo` should be your Supabase callback (e.g.
  /// `https://<project>.supabase.co/auth/v1/callback`). If omitted, Supabase's
  /// default will be used.
  Future<AuthResponse> signInWithGoogleHosted({String? redirectTo}) async {
    final res = await _client.auth.signInWithOAuth(
      Provider.google,
      options: AuthOptions(redirectTo: redirectTo),
    );
    return res;
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}

/// Small example widget that triggers hosted Google sign-in.
class GoogleSignInButton extends StatelessWidget {
  final String? redirectTo;
  final VoidCallback? onSignedIn;

  const GoogleSignInButton({Key? key, this.redirectTo, this.onSignedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Image.asset('assets/images/logo.png', width: 20, height: 20),
      label: const Text('Sign in with Google'),
      onPressed: () async {
        try {
          final svc = SupabaseAuthService();
          final res = await svc.signInWithGoogleHosted(redirectTo: redirectTo);
          // On mobile this opens the browser and returns to the redirect.
          // If the flow completes, Supabase client auth state will update.
          if (res.session != null) {
            onSignedIn?.call();
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sign in failed: $e')));
        }
      },
    );
  }
}
