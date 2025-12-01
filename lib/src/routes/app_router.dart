import 'package:go_router/go_router.dart';
import 'package:muta/src/screen/history_screen.dart';
import 'package:muta/src/screen/home_screen.dart';
import 'package:muta/src/screen/opentable_screen.dart';
import 'package:muta/src/screen/table_detail_screen.dart';
import 'package:muta/src/screen/table_screen.dart';

final router = GoRouter(
  routes: [
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
      path: '/table_detail:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return TableDetailScreen(id: id);
      },
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
  ],
);
