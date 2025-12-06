import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:muta/models/order_model.dart';
import 'package:muta/models/session_model.dart';
import 'package:muta/src/providers/history_provider.dart';
import 'package:muta/src/providers/order_provider.dart';
import 'package:muta/src/providers/receipt_pdf_provider.dart';
import 'package:muta/src/providers/session_provider.dart';
import 'package:muta/src/providers/session_timer_provider.dart';
import 'package:muta/src/services/logger.dart';
import 'package:printing/printing.dart';

class BillingScreen extends ConsumerStatefulWidget {
  final int tableId;

  const BillingScreen({super.key, required this.tableId});

  @override
  ConsumerState<BillingScreen> createState() =>
      _BillingScreenState();
}

class _BillingScreenState
    extends ConsumerState<BillingScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(
      sessionByTableProvider(widget.tableId),
    );
    final timer = ref.watch(
      sessionTimerProvider(widget.tableId),
    ); // << ใช้ StreamProvider

    return Scaffold(
      backgroundColor: const Color(0xFF1A1123),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "ปิดบิล โต๊ะ ${widget.tableId}",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: sessionAsync.when(
        data: (session) {
          final sessionId = session.id!;

          final ordersAsync = ref.watch(
            loadOrdersBySessionProvider(sessionId),
          );

          return ordersAsync.when(
            data: (orders) {
              final total = orders.fold(
                0,
                (sum, item) =>
                    sum +
                    ((item.price ?? 0) *
                        (item.quantity ?? 0)),
              );

              return Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // =================== TOP INFO ===================
                      Row(
                        children: [
                          Expanded(
                            child: _infoCard(
                              title: "หมายเลขโต๊ะ",
                              value:
                                  "T0${widget.tableId}",
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

                      // =================== TIME USED (REALTIME) ===================
                      timer.when(
                        data: (t) {
                          final left =
                              t.timeLeft ?? Duration.zero;
                          final isOver =
                              left <= Duration.zero;
                          final value =
                              t.timeused ?? "00:00:00";

                          return _infoCard(
                            title: "เวลาที่ใช้งาน",
                            value: value,
                            isAlert: isOver,
                          );
                        },
                        loading:
                            () => _infoCard(
                              title: "เวลาที่ใช้งาน",
                              value: "00:00:00",
                            ),
                        error:
                            (_, __) => _infoCard(
                              title: "เวลาที่ใช้งาน",
                              value: "00:00:00",
                            ),
                      ),

                      const SizedBox(height: 28),

                      // =================== ORDER LIST ===================
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
                                margin:
                                    const EdgeInsets.only(
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
                                      BorderRadius.circular(
                                        12,
                                      ),
                                ),
                                child: Row(
                                  children: [
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
                                        Icons
                                            .restaurant_menu,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 12,
                                    ),

                                    Expanded(
                                      child: Text(
                                        item.name ??
                                            "เมนู #${item.menuId}",
                                        style:
                                            const TextStyle(
                                              color:
                                                  Colors
                                                      .white,
                                              fontSize: 14,
                                            ),
                                      ),
                                    ),

                                    Text(
                                      "x${item.quantity}",
                                      style: const TextStyle(
                                        color:
                                            Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 8,
                                    ),

                                    Text(
                                      "฿$itemTotal",
                                      style:
                                          const TextStyle(
                                            color:
                                                Colors
                                                    .white,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),

                      const SizedBox(height: 20),

                      // =================== SUMMARY ===================
                      _summaryCard(total),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                              0xFF9B32F0,
                            ),
                            padding:
                                const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                          ),
                          onPressed:
                              _isProcessing
                                  ? null
                                  : () => _handlePrintAndClose(
                                        session: session,
                                        orders: orders,
                                        total: total,
                                      ),
                          child: _isProcessing
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child:
                                      CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "ปิดบิล & พิมพ์ใบเสร็จ",
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
                () => Center(
                  child: Lottie.asset(
                    'assets/lottie/Loading.json',
                    width: 300,
                    height: 300,
                    fit: BoxFit.contain,
                  ),
                ),
            error:
                (e, st) => Center(
                  child: Text(
                    "Error: $e",
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
          );
        },
        loading:
            () => Center(
              child: Lottie.asset(
                'assets/lottie/Loading.json',
                width: 300,
                height: 300,
                fit: BoxFit.contain,
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

  Future<void> _handlePrintAndClose({
  required SessionModel session,
  required List<OrderModel> orders,
  required int total,
}) async {
  // กันไม่ให้กดปิดบิลซ้ำเวลายังประมวลผลอยู่
  if (_isProcessing) return;

  setState(() => _isProcessing = true);

  try {
    // 1) สร้าง PDF จากข้อมูล session + orders
    final pdfBytes = await ref.read(
      receiptPdfProvider(
        ReceiptPdfInput(
          session: session,
          orders: orders,
          tableId: widget.tableId,
        ),
      ).future,
    );

    // 2) เปิดหน้า Print Preview ให้ผู้ใช้สั่งพิมพ์
    await Printing.layoutPdf(
      onLayout: (_) async => pdfBytes,
    );

    // 3) บันทึกประวัติลง Supabase (ใช้เป็นรายการย้อนหลัง)
    await ref.read(historyAddProvider).addHistory(
      sessionId: session.id!,
      totalPrice: total,
      items: orders.length,
      tableName: "T${widget.tableId}",
    );

    // 4) ปิด session โต๊ะนี้ (หยุด timer + อัปเดตสถานะโต๊ะ)
    await ref
        .read(sessionTimeProvider.notifier)
        .finishSession(widget.tableId, session.id!);

    // 5) กลับไปหน้าเลือกโต๊ะหลังปิดบิลเสร็จ
    if (mounted) context.go('/table');
  } catch (e, st) {
    // ถ้ามี error ใด ๆ ให้ log รายละเอียด + แจ้งผู้ใช้ด้วย SnackBar
    logger.e('Billing print error', error: e, stackTrace: st);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("พิมพ์หรือปิดบิลไม่สำเร็จ: $e"),
        ),
      );
    }
  } finally {
    // ปลดล็อกปุ่ม กรณีประมวลผลเสร็จหรือ error
    if (mounted) {
      setState(() => _isProcessing = false);
    }
  }
}


// =================== COMPONENTS ===================

/// Widget กล่องข้อมูล (แสดงชื่อ + ค่า)
/// เช่น "เวลาใช้งาน" → "01:23:45"
  Widget _infoCard({
    required String title,
    required String value,
    bool isAlert = false,
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
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isAlert)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                "หมดเวลา",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
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
          _row("ราคารวม", "฿${total.toStringAsFixed(2)}"),
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
