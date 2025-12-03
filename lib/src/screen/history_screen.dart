import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muta/src/providers/history_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1123),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          "ประวัติ",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: historyAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Text(
                "ยังไม่มีประวัติ",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final h = list[index];

              final dt = DateTime.parse(h.createdAt!);
              final dateText =
                  "${dt.day}/${dt.month}/${dt.year}, ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";

              return GestureDetector(
                onTap:
                    () => context.push(
                      "/history_detail/${h.id}",
                    ),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF251832),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      // LEFT SIDE
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              "โต๊ะ ${h.sessionId}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              dateText,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // RIGHT SIDE
                      Text(
                        "${h.totalPrice} ฿",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading:
            () => const Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
        error:
            (e, st) => Center(
              child: Text(
                "$e",
                style: const TextStyle(color: Colors.white),
              ),
            ),
      ),
    );
  }
}
