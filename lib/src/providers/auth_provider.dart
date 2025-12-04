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

  /// 🔐 LOGIN
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

  /// 🆕 SIGNUP — เพิ่ม username ลง metadata
  Future<void> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      state = const AsyncLoading();

      final response = await supabaseAuth.signUp(
        email: email,
        password: password,
        data: {
          "username":
              username, // ← บันทึก user_name ใน metadata
        },
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

  /// ตั้งรหัสผ่านใหม่หลังคลิกลิงก์ reset
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

  /// 🚪 LOGOUT
  Future<void> signOut() async {
    try {
      await supabaseAuth.signOut();
      state = const AsyncData(null);
    } catch (err, stack) {
      state = AsyncError(err, stack);
    }
  }
}

final authControllerProvider = StateNotifierProvider<
  AuthController,
  AsyncValue<User?>
>((ref) => AuthController());
