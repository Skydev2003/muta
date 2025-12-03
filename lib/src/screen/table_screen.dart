import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
                  // เปิดโต๊ะใหม่
                  onTap =
                      () => context.push(
                        '/openTable/$tableId',
                      );
                } else if (status == "dirty") {
                  // หน้าเคลียร์โต๊ะ
                  onTap =
                      () => context.push(
                        '/cleanTable/$tableId',
                      );
                } else {
                  // using → หน้ารายการอาหารของโต๊ะ
                  onTap =
                      () => context.push(
                        '/table_detail/$tableId',
                      );
                }

                return _tableCard(
                  name: name,
                  status: status,
                  timeLeft: timeLeft,
                  onTap: onTap,
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
    required String name,
    required String status,
    required dynamic timeLeft,
    required VoidCallback onTap,
  }) {
    // ICON CONFIG
    IconData icon;
    Color iconColor;
    Color badgeColor;
    String badgeText;

    switch (status) {
      case "using":
        icon = Icons.hourglass_bottom;
        iconColor = Colors.orangeAccent;
        badgeColor = Colors.orange;
        badgeText = "ใช้งานอยู่";
        break;

      case "dirty":
        icon = Icons.cleaning_services;
        iconColor = Colors.redAccent;
        badgeColor = Colors.red;
        badgeText = "รอทำความสะอาด";
        break;

      default: // available
        icon = Icons.restaurant_menu;
        iconColor = Colors.greenAccent;
        badgeColor = Colors.green;
        badgeText = "พร้อมใช้งาน";
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------- แถวบน: ชื่อโต๊ะ + ไอคอน ----------
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(icon, color: iconColor, size: 26),
              ],
            ),

            const SizedBox(height: 4),

            // ---------- เวลาเหลือ (เฉพาะ using) ----------
            if (status == "using" && timeLeft != null)
              Text(
                "เหลือ $timeLeft นาที",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),

            const Spacer(),

            // ---------- Badge สถานะ ----------
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  color: badgeColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
