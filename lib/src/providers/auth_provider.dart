import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseAuth = Supabase.instance.client.auth;

/// ฟังสถานะการล็อกอินแบบ real-time
final authStateProvider = StreamProvider<User?>((ref) {
  return supabaseAuth.onAuthStateChange.map((event) {
    return event.session?.user;
  });
});

class AuthController
    extends StateNotifier<AsyncValue<User?>> {
  AuthController() : super(const AsyncValue.data(null));

  /// Login
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      state = const AsyncLoading();
      final response = await supabaseAuth
          .signInWithPassword(
            email: email,
            password: password,
          );
      state = AsyncData(response.user);
    } catch (err, stack) {
      state = AsyncError(err, stack);
    }
  }

  /// Sign up
  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    try {
      state = const AsyncLoading();
      final response = await supabaseAuth.signUp(
        email: email,
        password: password,
      );
      state = AsyncData(response.user);
    } catch (err, stack) {
      state = AsyncError(err, stack);
    }
  }

  /// ส่งลิงก์ Reset Password
  Future<void> resetPassword(String email) async {
    try {
      state = const AsyncLoading();

      await supabaseAuth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.muta://reset-password',
      );

      state = const AsyncData(null);
    } catch (err, stack) {
      state = AsyncError(err, stack);
    }
  }

  /// Update password with token from reset link
  Future<void> updatePassword(String newPassword) async {
    try {
      state = const AsyncLoading();
      await supabaseAuth.updateUser(
        UserAttributes(password: newPassword),
      );
      state = AsyncData(supabaseAuth.currentUser);
    } catch (err, stack) {
      state = AsyncError(err, stack);
    }
  }

  /// Logout
  Future<void> signOut() async {
    try {
      await supabaseAuth.signOut();
      state = const AsyncData(null);
    } catch (err, stack) {
      state = AsyncError(err, stack);
    }
  }
}

/// Provider สำหรับ AuthController
final authControllerProvider = StateNotifierProvider<
  AuthController,
  AsyncValue<User?>
>((ref) => AuthController());
