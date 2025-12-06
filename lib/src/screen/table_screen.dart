import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:muta/src/providers/session_timer_provider.dart';
import 'package:muta/src/providers/table_provider.dart';
import 'package:muta/src/theme/app_theme.dart';

class TableScreen extends ConsumerWidget {
  const TableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableStream = ref.watch(tableStreamProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        elevation: 0,
        title: const Text(
          "รายการโต๊ะ",
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          onPressed: () {
            context.go('/'); // กลับหน้า Home
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // ไว้สำหรับเพิ่มโต๊ะในอนาคต
            },
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ],
      ),

      // -------------------- BODY --------------------
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: tableStream.when(
          data: (tables) {
            // 1) ก็อป list มาก่อนกัน side-effect
            final sorted = [...tables];

            // 2) เรียงตามชื่อโต๊ะ (T01, T02, T03...)
            sorted.sort((a, b) {
              return a['name'].toString().compareTo(
                b['name'].toString(),
              );
            });

            // 3) แสดงผลแบบ Grid
            return GridView.builder(
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.95,
                  ),
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                final t = sorted[index];

                final status = t["status"] as String;
                final name = t["name"] as String? ?? "";
                final timeLeft =
                    t["time_left"]; // int? นาที หรือ null
                final tableId = t["id"] as int;

                // onTap แยกตามสถานะโต๊ะ
                VoidCallback onTap;
                if (status == "available") {
                  onTap =
                      () => context.push(
                        '/openTable/$tableId',
                      );
                } else if (status == "dirty") {
                  onTap =
                      () => context.push(
                        '/cleanTable/$tableId',
                      );
                } else {
                  onTap =
                      () => context.push(
                        '/table_detail/$tableId',
                      );
                }

                return _tableCard(
                  tableId: tableId,
                  name: name,
                  status: status,
                  timeLeft: timeLeft,
                  onTap: onTap,
                );
              },
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
        ),
      ),
    );
  }

  // ===================== TABLE CARD =====================
  Widget _tableCard({
  required int tableId,
  required String name,
  required String status,
  required int? timeLeft,
  required VoidCallback onTap,
}) {
  return Consumer(
    builder: (context, ref, _) {
      final timer = ref.watch(
        sessionTimerProvider(tableId),
      );

      // สีพื้นหลังตามสถานะ
      Color cardColor = const Color(0xFF2C2633);
      Color badgeColor;
      String badgeText;

      if (status == "using") {
        badgeColor = const Color(0xFFFFA726); // เหลือง
        badgeText = "ใช้งานอยู่";
      } else if (status == "dirty") {
        badgeColor = const Color(0xFFE53935); // แดง
        badgeText = "ทำความสะอาด";
      } else {
        badgeColor = const Color(0xFF43A047); // เขียว
        badgeText = "พร้อมใช้งาน";
      }

      // ไอคอนด้านขวาบน
      IconData icon;
      if (status == "using") {
        icon = Icons.hourglass_bottom;
      } else if (status == "dirty") {
        icon = Icons.cleaning_services;
      } else {
        icon = Icons.restaurant;
      }

      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ไอคอนมุมขวาบน
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "โต๊ะ $name",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(icon, color: Colors.white70),
                ],
              ),

              const SizedBox(height: 12),

              if (status == "using")
                timer.when(
                  data: (session) {
                    final left =
                        session.timeLeft ?? Duration.zero;
                    final mm = left.inMinutes;
                    final ss = (left.inSeconds % 60)
                        .toString()
                        .padLeft(2, '0');

                    return Text(
                      "เหลือเวลา $mm:$ss นาที",
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    );
                  },
                  loading: () => const Text(
                    "เหลือเวลา ...",
                    style: TextStyle(color: Colors.white70),
                  ),
                  error: (_, __) => const Text(
                    "เหลือเวลา -",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),

              const Spacer(),

              // ปุ่มสถานะ
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
}
