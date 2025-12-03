import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muta/src/providers/table_provider.dart';

class CleanTableScreen extends ConsumerWidget {
  final int tableId;

  const CleanTableScreen({
    super.key,
    required this.tableId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Color(0xFF1A1123),
      appBar: AppBar(title: const Text("ทำความสะอาดโต๊ะ")),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await ref
                .read(tableProvider.notifier)
                .updateStatus(tableId, "available");

            context.pop(); // กลับไปหน้า table list
          },
          child: const Text("ทำความสะอาดเรียบร้อย"),
        ),
      ),
    );
  }
}
