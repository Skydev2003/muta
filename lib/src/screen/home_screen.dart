import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text('MUTA')),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                ref.context.push('/table');
              },
              child: const Text('เปิดโต๊ะ'),
            ),
          ),
          Center(
            child: ElevatedButton(
              onPressed: () {
                ref.context.push('/history');
              },
              child: const Text('ประวัติ'),
            ),
          ),
        ],
      ),
    );
  }
} 