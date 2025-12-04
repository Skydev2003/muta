import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:muta/models/history_model.dart';
import 'package:muta/src/providers/history_provider.dart';
import 'package:muta/src/services/logger.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() =>
      _HistoryScreenState();
}

class _HistoryScreenState
    extends ConsumerState<HistoryScreen> {
  String filter = "all"; // today | week | month
  String keyword = "";

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(historyProvider);
    logger.i('open history screen');
    logger.d(historyAsync);
    return Scaffold(
      backgroundColor: const Color(0xFF1A1123),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "ประวัติ",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Column(
        children: [
          // ---------------- SEARCH ----------------
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    onChanged:
                        (v) => setState(
                          () => keyword = v.trim(),
                        ),
                    decoration: InputDecoration(
                      hintText: "ค้นหาด้วยหมายเลขโต๊ะ...",
                      hintStyle: const TextStyle(
                        color: Colors.white54,
                      ),
                      filled: true,
                      fillColor: const Color(0xFF251832),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          14,
                        ),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF251832),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: IconButton(
                    onPressed: () {
                      //go to date filter dialog
                    },
                    icon: const Icon(
                      Icons.calendar_month,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ---------------- FILTER ----------------
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              children: [
                _filterChip("ทั้งหมด", "all"),
                _filterChip("วันนี้", "today"),
                _filterChip("สัปดาห์นี้", "week"),
                _filterChip("เดือนนี้", "month"),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ---------------- LIST ----------------
          Expanded(
            child: historyAsync.when(
              data: (list) {
                // 1) filter keyword
                var result =
                    list.where((h) {
                      if (keyword.isEmpty) return true;

                      return h.sessionId
                          .toString()
                          .contains(keyword);
                    }).toList();

                // 2) filter by date
                result = _applyDateFilter(result);

                if (result.isEmpty) {
                  return const Center(
                    child: Text(
                      "ไม่พบประวัติ",
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  itemCount: result.length,
                  itemBuilder: (context, index) {
                    final h = result[index];

                    if (h.createdAt == null) {
                      return const SizedBox();
                    }

                    final dt =
                        DateTime.tryParse(h.createdAt!) ??
                        DateTime.now();

                    final dateText =
                        "${dt.day}/${dt.month}/${dt.year}, "
                        "${dt.hour}:${dt.minute.toString().padLeft(2, "0")}";

                    return GestureDetector(
                      onTap:
                          () => context.push(
                            '/history_detail/${h.id}',
                          ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(
                          bottom: 14,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF251832),
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            // LEFT
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    "โต๊ะ ${h.tableName ?? h.sessionId}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight:
                                          FontWeight.bold,
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

                            // RIGHT
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
                      "$e",
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- FILTER CHIP ----------------
  Widget _filterChip(String label, String value) {
    final isSelected = filter == value;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color:
                isSelected ? Colors.white : Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
        selected: isSelected,
        selectedColor: Colors.purple,
        backgroundColor: const Color(0xFF251832),
        onSelected: (_) => setState(() => filter = value),
      ),
    );
  }

  // ---------------- DATE FILTER LOGIC ----------------
  List<HistoryModel> _applyDateFilter(
    List<HistoryModel> list,
  ) {
    if (filter == "all") return list;

    final now = DateTime.now();

    return list.where((h) {
      if (h.createdAt == null) return false;

      final d = DateTime.tryParse(h.createdAt!) ?? now;

      if (filter == "today") {
        return d.year == now.year &&
            d.month == now.month &&
            d.day == now.day;
      }

      if (filter == "week") {
        return d.isAfter(
          now.subtract(const Duration(days: 7)),
        );
      }

      if (filter == "month") {
        return d.isAfter(
          now.subtract(const Duration(days: 30)),
        );
      }

      return true;
    }).toList();
  }
}
