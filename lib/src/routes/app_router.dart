import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:muta/src/screen/billing_screen.dart';
import 'package:muta/src/screen/cart_screen.dart';
import 'package:muta/src/screen/clean_table_screen.dart';
import 'package:muta/src/screen/forgot_screen.dart';
import 'package:muta/src/screen/history_screen.dart';
import 'package:muta/src/screen/home_screen.dart';
import 'package:muta/src/screen/opentable_screen.dart';
import 'package:muta/src/screen/reset_password_screen.dart';
import 'package:muta/src/screen/sing_in_screen.dart';
import 'package:muta/src/screen/sing_up_screen.dart';
import 'package:muta/src/screen/table_detail_screen.dart';
import 'package:muta/src/screen/table_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  debugLogDiagnostics: true,
  refreshListenable: _authRefreshNotifier,
  redirect: (context, state) {
    final user = Supabase.instance.client.auth.currentUser;
    final location = state.matchedLocation;
    final fullUri = state.uri;
    final queryParams = fullUri.queryParametersAll;

    print('🔀 Redirect Debug:');
    print('  - location: $location');
    print('  - uri.path: ${fullUri.path}');
    print('  - uri.host: ${fullUri.host}');
    print('  - uri.scheme: ${fullUri.scheme}');
    print('  - query params: $queryParams');
    print('  - user: ${user?.id}');

    // Check for reset-password in the URI path or host (from deep link)
    final isResetPasswordDeepLink = fullUri.host == 'reset-password' ||
        fullUri.path.contains('reset-password');

    // Always allow reset-password, regardless of auth state
    if (location.startsWith('/reset-password') || isResetPasswordDeepLink) {
      print('✅ Allowing reset-password (location or deep link detected)');
      // If this is a deep link, ensure it gets routed to /reset-password
      if (isResetPasswordDeepLink && !location.startsWith('/reset-password')) {
        final code = queryParams['code']?.first;
        print('🔗 Routing deep link to /reset-password with code=$code');
        return '/reset-password${fullUri.query.isEmpty ? '' : '?${fullUri.query}'}';
      }
      return null;
    }

    // Check if we have a code parameter and route to reset-password
    if (queryParams.containsKey('code') && fullUri.scheme == 'io.supabase.muta') {
      print('🔗 Deep link with code detected, routing to /reset-password');
      return '/reset-password${fullUri.query.isEmpty ? '' : '?${fullUri.query}'}';
    }

    // Allow these pages without authentication
    final isAuthPage =
        location == '/login' ||
        location == '/signup' ||
        location == '/forgot';

    if (user == null) {
      print('❌ No user, isAuthPage=$isAuthPage');
      return isAuthPage ? null : '/login';
    }

    // If user is logged in and tries to access auth pages, redirect to home
    if (isAuthPage) {
      print('✅ User logged in on auth page, redirecting to /');
      return '/';
    }

    print('✅ User logged in, allowing normal routing');
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
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return OpenTableScreen(id: id);
      },
    ),
    GoRoute(
      path: '/table_detail/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return TableDetailScreen(id: id);
      },
    ),
    GoRoute(
      path: '/cart/:id',
      builder: (_, state) {
        final id = int.parse(state.pathParameters['id']!);
        return CartScreen(tableId: id);
      },
    ),
    GoRoute(
      path: '/billing/:id',
      builder: (_, state) {
        final id = int.parse(state.pathParameters['id']!);
        return BillingScreen(tableId: id);
      },
    ),
    GoRoute(
      path: '/history',
      builder: (_, __) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/cleanTable/:id',
      builder: (_, state) {
        final id = int.parse(state.pathParameters['id']!);
        return CleanTableScreen(tableId: id);
      },
    ),
  ],
);
