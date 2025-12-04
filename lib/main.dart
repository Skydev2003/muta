import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muta/src/routes/app_router.dart'
    show router, initAuthStateListener;
import 'package:muta/src/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://vdhaeocpcxiefuzetikh.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZkaGFlb2NwY3hpZWZ1emV0aWtoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ1MTg2MjUsImV4cCI6MjA4MDA5NDYyNX0.l6FNEKc9IgtCWWe4tHT9ycm1LNsWPDCxEOL6GjlWho4',
  );

  initAuthStateListener();

  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Muta',
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
