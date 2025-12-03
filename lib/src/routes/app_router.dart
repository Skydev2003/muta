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

  // หน้า public ที่ไม่ต้องล็อคอิน
  final isAuthPage = state.matchedLocation == '/login' ||
      state.matchedLocation == '/signup' ||
      state.matchedLocation == '/forgot';

  // ยังไม่ล็อคอิน → เข้าได้เฉพาะหน้า auth
  if (user == null) {
    return isAuthPage ? null : '/login';
  }

  // ถ้าล็อคอินแล้ว ไม่ต้องกลับหน้า login/signup/forgot อีก
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
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/table',
      builder: (context, state) => const TableScreen(),
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
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return CartScreen(tableId: id);
      },
    ),

    GoRoute(
      path: '/billing/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return BillingScreen(tableId: id);
      },
    ),

    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),

    GoRoute(
      path: '/cleanTable/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return CleanTableScreen(tableId: id);
      },
    ),
  ],
);

