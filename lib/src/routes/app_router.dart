import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:muta/src/screen/billing_screen.dart';
import 'package:muta/src/screen/cart_screen.dart';
import 'package:muta/src/screen/clean_table_screen.dart';
import 'package:muta/src/screen/forgot_screen.dart';
import 'package:muta/src/screen/history_detail_screen.dart';
import 'package:muta/src/screen/history_screen.dart';
import 'package:muta/src/screen/home_screen.dart';
import 'package:muta/src/screen/opentable_screen.dart';
import 'package:muta/src/screen/profile_screen.dart';
import 'package:muta/src/screen/reset_password_screen.dart';
import 'package:muta/src/screen/sing_in_screen.dart';
import 'package:muta/src/screen/sing_up_screen.dart';
import 'package:muta/src/screen/table_detail_screen.dart';
import 'package:muta/src/screen/table_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ใช้สำหรับ refresh UI เมื่อ Auth เปลี่ยนสถานะ
final _authRefreshNotifier = ValueNotifier<bool>(false);

void initAuthStateListener() {
  Supabase.instance.client.auth.onAuthStateChange.listen((
    _,
  ) {
    _authRefreshNotifier.value =
        !_authRefreshNotifier.value;
  });
}

final router = GoRouter(
  initialLocation: '/login',
  refreshListenable: _authRefreshNotifier,

  redirect: (context, state) {
    final user = Supabase.instance.client.auth.currentUser;
    final location = state.matchedLocation;
    final uri = state.uri;

    // ถ้ามี code/token = ลิงก์ reset password
    final code = uri.queryParameters['code'];
    final token = uri.queryParameters['token'];

    if (code != null || token != null) {
      return '/reset-password?${uri.query}';
    }

    // หน้าที่เข้าได้โดยไม่ต้องล็อกอิน
    final isAuthPage =
        location == '/login' ||
        location == '/signup' ||
        location == '/forgot' ||
        location.startsWith('/reset-password');

    if (user == null) {
      return isAuthPage ? null : '/login';
    }

    // ถ้าล็อกอินแล้ว ห้ามกลับไปหน้า login/signup/forgot
    if (isAuthPage &&
        !location.startsWith('/reset-password')) {
      return '/';
    }

    return null;
  },

  routes: [
    GoRoute(
      path: '/login',
      builder: (_, __) => const SignInScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (_, __) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/forgot',
      builder: (_, __) => const ForgotPasswordScreen(),
    ),

    GoRoute(
      path: '/reset-password',
      builder: (_, state) {
        final code = state.uri.queryParameters['code'];
        final token = state.uri.queryParameters['token'];
        return ResetPasswordScreen(token: token ?? code);
      },
    ),

    GoRoute(
      path: '/',
      builder: (_, __) => const HomeScreen(),
    ),
    GoRoute(
      path: '/table',
      builder: (_, __) => const TableScreen(),
    ),

    GoRoute(
      path: '/openTable/:id',
      builder:
          (_, state) => OpenTableScreen(
            id: int.parse(state.pathParameters['id']!),
          ),
    ),

    GoRoute(
      path: '/table_detail/:id',
      builder:
          (_, state) => TableDetailScreen(
            id: int.parse(state.pathParameters['id']!),
          ),
    ),

    GoRoute(
      path: '/cart/:id',
      builder:
          (_, state) => CartScreen(
            tableId: int.parse(state.pathParameters['id']!),
          ),
    ),

    GoRoute(
      path: '/billing/:id',
      builder:
          (_, state) => BillingScreen(
            tableId: int.parse(state.pathParameters['id']!),
          ),
    ),

    GoRoute(
      path: '/history',
      builder: (_, __) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/history_detail/:id',
      builder:
          (_, state) => HistoryDetailScreen(
            id: int.parse(state.pathParameters['id']!),
          ),
    ),
    GoRoute(
      path: '/cleanTable/:id',
      builder:
          (_, state) => CleanTableScreen(
            tableId: int.parse(state.pathParameters['id']!),
          ),
    ),
    GoRoute(
      path: '/profile',
      builder: (_, __) => const ProfileScreen(),
    ),
  ],
);
