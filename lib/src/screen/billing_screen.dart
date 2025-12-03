import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muta/src/providers/history_provider.dart';
import 'package:muta/src/providers/order_provider.dart';
import 'package:muta/src/providers/session_provider.dart';

class BillingScreen extends ConsumerWidget {
  final int tableId;

  const BillingScreen({super.key, required this.tableId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(
      sessionByTableProvider(tableId),
    );
    final orders = ref.watch(orderProvider);
    final total =
        ref.watch(orderProvider.notifier).totalPrice;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1123),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "ปิดบิล โต๊ะ $tableId",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: sessionAsync.when(
        data: (session) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // =============== TOP INFO ROW ===============
                  Row(
                    children: [
                      Expanded(
                        child: _infoCard(
                          title: "หมายเลขโต๊ะ",
                          value: "A$tableId",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _infoCard(
                          title: "จำนวนลูกค้า",
                          value:
                              "${session.customerCount} คน",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // =============== TIME USED ===============
                  _infoCard(
                    title: "เวลาที่ใช้งาน",
                    value: session.timeused ?? "00:00:00",
                  ),

                  const SizedBox(height: 28),

                  // =============== ORDER LIST ===============
                  const Text(
                    "รายการอาหาร",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Column(
                    children:
                        orders.map((item) {
                          final itemTotal =
                              (item.price ?? 0) *
                              (item.quantity ?? 0);

                          return Container(
                            margin: const EdgeInsets.only(
                              bottom: 12,
                            ),
                            padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF251832,
                              ),
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                // icon or image
                                Container(
                                  padding:
                                      const EdgeInsets.all(
                                        8,
                                      ),
                                  decoration: BoxDecoration(
                                    color:
                                        Colors
                                            .purple
                                            .shade400,
                                    borderRadius:
                                        BorderRadius.circular(
                                          8,
                                        ),
                                  ),
                                  child: const Icon(
                                    Icons.restaurant_menu,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // name
                                Expanded(
                                  child: Text(
                                    item.name ??
                                        "เมนู #${item.menuId}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),

                                // qty
                                Text(
                                  "x${item.quantity}",
                                  style: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // price
                                Text(
                                  "฿$itemTotal",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // =============== PRICE SUMMARY ===============
                  _summaryCard(total),

                  const SizedBox(height: 30),

                  // =============== BUTTON ===============
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFF9B32F0,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                      ),
                      onPressed: () async {
                        final sessionId = session.id!;

                        // 1) save orders
                        await ref
                            .read(historyAddProvider)
                            .addHistory(
                              sessionId: sessionId,
                              totalPrice: total,
                              items: orders.length,
                            );

                        // 2) close session
                        await ref
                            .read(sessionProvider.notifier)
                            .finishSession(
                              tableId,
                              sessionId,
                            );

                        // 3) back to table screen (clear stack)
                        context.go('/');
                      },
                      child: const Text(
                        "ปิดบิล & เคลียร์โต๊ะ",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
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
                "Error: $e",
                style: const TextStyle(color: Colors.white),
              ),
            ),
      ),
    );
  }

  // ===================== COMPONENTS =====================
  Widget _infoCard({
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF251832),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(int total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF251832),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _row(
            "ราคารวม",
            "฿${(total.toDouble()).toStringAsFixed(2)}",
          ),
          const SizedBox(height: 6),
          _row("ส่วนลด", "-฿0.00"),
          const Divider(color: Colors.white24, height: 24),
          _row(
            "ยอดชำระสุทธิ",
            "฿${total.toStringAsFixed(2)}",
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _row(
    String left,
    String right, {
    bool isTotal = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          left,
          style: TextStyle(
            color: isTotal ? Colors.white : Colors.white70,
            fontSize: isTotal ? 18 : 14,
            fontWeight:
                isTotal
                    ? FontWeight.bold
                    : FontWeight.normal,
          ),
        ),
        Text(
          right,
          style: TextStyle(
            color:
                isTotal
                    ? Colors.purpleAccent
                    : Colors.white,
            fontSize: isTotal ? 20 : 16,
            fontWeight:
                isTotal
                    ? FontWeight.bold
                    : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
