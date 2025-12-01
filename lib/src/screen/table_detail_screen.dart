import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muta/models/menu_model.dart';
import 'package:muta/src/providers/menu_provider.dart';
import 'package:muta/src/providers/order_provider.dart';
import 'package:muta/src/providers/session_timer_provider.dart';

class TableDetailScreen extends ConsumerStatefulWidget {
  const TableDetailScreen({super.key, required this.id});
  final int id;

  @override
  ConsumerState<TableDetailScreen> createState() =>
      _TableDetailScreenState();
}

class _TableDetailScreenState
    extends ConsumerState<TableDetailScreen> {
  int _selectedIndex = 0;

  final _categories = [
    "หมู",
    "ผัก",
    "เครื่องดื่ม",
    "อื่นๆ",
  ];

  @override
  Widget build(BuildContext context) {
    final timer = ref.watch(
      sessionTimerProvider(widget.id),
    );
    final menuAsync = ref.watch(menuStreamProvider);

    final cartItems = ref.watch(
      orderProvider,
    ); // list<OrderItem>

    return Scaffold(
      backgroundColor: const Color(0xFF1A1123),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          timer.maybeWhen(
            data:
                (timeLeft) =>
                    "โต๊ะ ${widget.id} | เวลาคงเหลือ ${timeLeft.inMinutes} นาที",
            orElse: () => "โต๊ะ ${widget.id}",
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // ---------------- Tab Category ----------------
          SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly,
              children: List.generate(_categories.length, (
                index,
              ) {
                final isSelected = _selectedIndex == index;

                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedIndex = index);
                  },
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Text(
                        _categories[index],
                        style: TextStyle(
                          color:
                              isSelected
                                  ? Colors.white
                                  : Colors.white54,
                          fontWeight:
                              isSelected
                                  ? FontWeight.bold
                                  : null,
                        ),
                      ),
                      if (isSelected)
                        Container(
                          margin: const EdgeInsets.only(
                            top: 4,
                          ),
                          height: 3,
                          width: 35,
                          color: Colors.purpleAccent,
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 10),

          // ---------------- Menu List ----------------
          Expanded(
            child: menuAsync.when(
              data: (menus) {
                final filtered =
                    menus
                        .where(
                          (m) =>
                              m.category ==
                              _categories[_selectedIndex],
                        )
                        .toList();

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder:
                      (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    final item = filtered[index];

                    return _menuItemCard(item);
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
                  (err, stack) => Center(
                    child: Text(
                      "Error: $err",
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
            ),
          ),

          // ---------------- Cart Button ----------------
          if (cartItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF9B32F0,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ),
                  ),
                  icon: const Icon(
                    Icons.shopping_bag,
                    color: Colors.white,
                  ),
                  label: Text(
                    "ดูตะกร้า (${cartItems.length} รายการ)",
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    context.push('/cart/${widget.id}');
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------- Menu Card Widget ----------------
  Widget _menuItemCard(MenuModel item) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF251832),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            item.imageUrl ?? "",
            height: 50,
            width: 50,
            fit: BoxFit.cover,
            errorBuilder:
                (_, __, ___) => const Icon(
                  Icons.image_not_supported,
                  color: Colors.white70,
                ),
          ),
        ),
        title: Text(
          item.name ?? "ไม่มีชื่อ",
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          "${item.price ?? 0}฿",
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.purple.shade400,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              ref
                  .read(orderProvider.notifier)
                  .addItem(item);
            },
          ),
        ),
      ),
    );
  }
}
