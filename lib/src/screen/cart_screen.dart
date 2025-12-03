import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:muta/src/providers/order_provider.dart';
import 'package:muta/src/providers/session_provider.dart';
import 'package:muta/src/services/logger.dart';

class CartScreen extends ConsumerWidget {
  final int tableId;

  const CartScreen({super.key, required this.tableId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(orderProvider);
    final total =
        ref.watch(orderProvider.notifier).totalPrice;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1123),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "ตะกร้า",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // ------------- CART LIST -------------
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: cart.length,
              separatorBuilder:
                  (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = cart[index];

                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF251832),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        8,
                      ),
                      child: Image.network(
                        item.image ?? "",
                        height: 50,
                        width: 50,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (_, __, ___) => const Icon(
                              Icons.image,
                              color: Colors.white54,
                            ),
                      ),
                    ),
                    title: Text(
                      item.name ?? "ไม่พบชื่อเมนู",
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Text(
                      "${item.price ?? 0}฿",
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ----- decrease -----
                        _circleButton(
                          icon: Icons.remove,
                          onTap:
                              () => ref
                                  .read(
                                    orderProvider.notifier,
                                  )
                                  .decrease(index),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "${item.quantity}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // ----- increase -----
                        _circleButton(
                          icon: Icons.add,
                          onTap:
                              () => ref
                                  .read(
                                    orderProvider.notifier,
                                  )
                                  .increase(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ------------- TOTAL PRICE -------------
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "ยอดรวม",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                Text(
                  "฿$total",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),
          // ------------- CONFIRM BUTTON -------------
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9B32F0),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                ),
                onPressed: () async {
                  try {
                    // ป้องกันกดซ้ำ
                    if (ref.read(orderProvider).isEmpty) {
                      logger.w(
                        "⛔ ไม่มีรายการอาหารในตะกร้า",
                      );
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "ไม่มีรายการอาหารในตะกร้า",
                          ),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                      return;
                    }

                    // โหลด session แบบ refresh
                    final session = await ref.refresh(
                      sessionByTableProvider(
                        tableId,
                      ).future,
                    );

                    final sessionId = session.id;
                    if (sessionId == null) {
                      logger.e(
                        "❌ sessionId = null (ไม่พบ session)",
                      );
                      return;
                    }

                    logger.i(
                      "➡ กำลังบันทึก order (sessionId: $sessionId)",
                    );

                    // บันทึกทั้งหมด
                    await ref
                        .read(orderProvider.notifier)
                        .submitOrders(sessionId);

                    logger.i("✅ บันทึกออเดอร์สำเร็จ");

                    // เคลียร์ตะกร้า
                    ref
                        .read(orderProvider.notifier)
                        .clear();

                    // ------ แสดงป๊อปอัพแจ้งเตือน ------
                    if (context.mounted) {
                      await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: const Color(
                              0xFF251832,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(16),
                            ),
                            title: const Text(
                              "สั่งอาหารสำเร็จ",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                            content: const Text(
                              "ออเดอร์ถูกบันทึกเรียบร้อยแล้ว!",
                              style: TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed:
                                    () => Navigator.pop(
                                      context,
                                    ),
                                child: const Text(
                                  "โอเค",
                                  style: TextStyle(
                                    color:
                                        Colors.purpleAccent,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    }

                    // กลับหน้าโต๊ะหลังป๊อปอัพปิด
                    if (context.mounted) {
                      context.go('/table');
                    }
                  } catch (err) {
                    logger.e("❌ Submit order failed: $err");

                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        SnackBar(
                          content: Text(
                            "เกิดข้อผิดพลาด: $err",
                          ),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  }
                },
                child: const Text(
                  "ยืนยันการสั่งอาหาร",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // ------------- CANCEL ALL BUTTON -------------
          TextButton(
            onPressed: () {
              ref.read(orderProvider.notifier).clear();
            },
            child: const Text(
              "ยกเลิกรายการทั้งหมด",
              style: TextStyle(color: Colors.redAccent),
            ),
          ),

          const SizedBox(height: 14),
        ],
      ),
    );
  }

  // ------------------------ WIDGET: (+) (-) ------------------------
  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.purple.shade400,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
