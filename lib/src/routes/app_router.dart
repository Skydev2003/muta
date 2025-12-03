
import 'package:go_router/go_router.dart';

// ===== Screens =====
import 'package:muta/src/screen/home_screen.dart';
import 'package:muta/src/screen/table_screen.dart';
import 'package:muta/src/screen/opentable_screen.dart';
import 'package:muta/src/screen/table_detail_screen.dart';
import 'package:muta/src/screen/history_screen.dart';
import 'package:muta/src/screen/cart_screen.dart';
import 'package:muta/src/screen/billing_screen.dart';

final router = GoRouter(
  routes: [
    // -------- HOME --------
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),

    // -------- TABLE LIST --------
    GoRoute(
      path: '/table',
      builder: (context, state) => const TableScreen(),
    ),

    // -------- OPEN TABLE --------
    GoRoute(
      path: '/openTable/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return OpenTableScreen(id: id);
      },
    ),

    // -------- TABLE DETAIL --------
    GoRoute(
      path: '/table_detail/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return TableDetailScreen(id: id);
      },
    ),

    // -------- CART SCREEN --------
    GoRoute(
      path: '/cart/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return CartScreen(tableId: id);
      },
    ),

    // -------- BILLING SCREEN --------
    GoRoute(
      path: '/billing/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return BillingScreen(tableId: id);
      },
    ),

    // -------- HISTORY --------
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
  ],
);
