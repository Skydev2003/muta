import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muta/src/providers/history_provider.dart';
import 'package:muta/src/providers/order_provider.dart';

class HistoryDetailScreen extends ConsumerWidget {
  final int id;
  const HistoryDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(
      historyDetailProvider(id),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("รายละเอียดบิล")),
      body: historyAsync.when(
        data: (h) {
          final created = DateTime.parse(h.createdAt!);

          // โหลดรายการอาหารด้วย session_id
          final ordersAsync = ref.watch(
            loadOrdersBySessionProvider(h.sessionId!),
          );

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                // โต๊ะ + เวลาการใช้งาน
                Card(
                  child: ListTile(
                    title: Text(
                      "โต๊ะ ${h.tableName}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // จำนวนลูกค้า
                Card(
                  child: ListTile(
                    title: const Text("จำนวนลูกค้า"),
                    trailing: Text(
                      "${h.items} รายการ",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ยอดรวมทั้งหมด
                Card(
                  child: ListTile(
                    title: const Text("ยอดรวมทั้งหมด"),
                    trailing: Text(
                      "${h.totalPrice} บาท",
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // พนักงาน
                Card(
                  child: ListTile(
                    title: const Text("พนักงานที่ปิดบิล"),
                    subtitle: Text(
                      "${h.userName ?? "-"}\n${h.userEmail ?? "-"}",
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  "รายการอาหาร",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // 🔥 แสดงรายการอาหารจาก provider
                ordersAsync.when(
                  data: (orders) {
                    if (orders.isEmpty) {
                      return const Text(
                        "ไม่มีข้อมูลรายการอาหาร",
                        style: TextStyle(
                          color: Colors.white54,
                        ),
                      );
                    }

                    return Column(
                      children:
                          orders.map((o) {
                            return Card(
                              child: ListTile(
                                leading: const Icon(
                                  Icons.fastfood,
                                ),
                                title: Text('${o.name}'),
                                subtitle: Text(
                                  "จำนวน: ${o.quantity}",
                                ),
                                trailing: Text(
                                  "${o.price} บาท",
                                  style: const TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    );
                  },
                  loading:
                      () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                  error:
                      (e, _) => Text(
                        "โหลดรายการอาหารไม่ได้: $e",
                        style: const TextStyle(
                          color: Colors.redAccent,
                        ),
                      ),
                ),
              ],
            ),
          );
        },
        loading:
            () => const Center(
              child: CircularProgressIndicator(),
            ),
        error:
            (e, _) => Center(
              child: Text("โหลดประวัติไม่ได้: $e"),
            ),
      ),
    );
  }
}
