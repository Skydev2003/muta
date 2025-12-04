import 'package:go_router/go_router.dart';
import 'package:muta/src/screen/billing_screen.dart';
import 'package:muta/src/screen/cart_screen.dart';
import 'package:muta/src/screen/clean_table_screen.dart';
import 'package:muta/src/screen/forgot_screen.dart';
import 'package:muta/src/screen/history_screen.dart';
import 'package:muta/src/screen/home_screen.dart';
import 'package:muta/src/screen/opentable_screen.dart';
import 'package:muta/src/screen/sing_in_screen.dart';
import 'package:muta/src/screen/sing_up_screen.dart';
import 'package:muta/src/screen/table_detail_screen.dart';
import 'package:muta/src/screen/table_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final router = GoRouter(
  initialLocation: '/login',

  redirect: (context, state) {
    final user = Supabase.instance.client.auth.currentUser;

    final isAuthPage =
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/signup' ||
        state.matchedLocation == '/forgot';

    if (user == null) {
      return isAuthPage ? null : '/login';
    }

    if (isAuthPage) return '/';

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
