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
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.add_circle_outline,
              color: Colors.white,
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: tableStream.when(
          data: (tables) {
            return GridView.builder(
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.95,
                  ),
              itemCount: tables.length,
              itemBuilder: (context, index) {
                final t = tables[index];

                final status = t["status"];
                final name = t["name"] ?? "";
                final timeLeft = t["time_left"]; // optional

                return _tableCard(
                  context,
                  name,
                  status,
                  timeLeft,
                  () =>
                      context.push('/openTable/${t["id"]}'),
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
  Widget _tableCard(
    BuildContext context,
    String name,
    String status,
    dynamic timeLeft,
    VoidCallback onTap,
  ) {
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

      default:
        icon = Icons.restaurant_menu;
        iconColor = Colors.greenAccent;
        badgeColor = Colors.green;
        badgeText = "พร้อมใช้งาน";
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF251832),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row
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

            // Time left (เฉพาะ using)
            if (status == "using" && timeLeft != null)
              Text(
                "เหลือ $timeLeft นาที",
                style: const TextStyle(
                  color: Colors.white70,
                ),
              ),

            const Spacer(),

            // STATUS BADGE
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badgeText,
                style: TextStyle(
                  color: badgeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
