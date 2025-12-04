import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muta/src/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "MUTA",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
        ),
        centerTitle: true,

        actions: [
          Consumer(
            builder: (context, ref, child) {
              return IconButton(
                onPressed: () async {
                  await ref
                      .read(authControllerProvider.notifier)
                      .signOut();

                  // เมื่อ signOut จะเป็น null แล้ว redirect กลับ /login
                  context.go('/login');
                },
                icon: const Icon(
                  Icons.logout,
                  color: Colors.white,
                ),
              );
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // โลโก้หรือไอคอนร้าน
            Icon(
              Icons.local_fire_department,
              size: 80,
              color: theme.colorScheme.secondary,
            ),

            const SizedBox(height: 40),

            // ปุ่มเปิดโต๊ะ
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => ref.context.go('/table'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                  ),
                  backgroundColor:
                      theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "เปิดโต๊ะ",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ปุ่มดูประวัติ
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed:
                    () => ref.context.push('/history'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                  ),
                  foregroundColor: Colors.white,
                  side: const BorderSide(
                    color: Colors.white70,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  "ประวัติ",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
