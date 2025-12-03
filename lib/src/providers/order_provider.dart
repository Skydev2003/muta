import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muta/models/menu_model.dart';
import 'package:muta/models/order_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrderNotifier
    extends StateNotifier<List<OrderModel>> {
  OrderNotifier(this.ref) : super([]);

  final Ref ref;
// เพิ่มรายการอาหารลงในออเดอร์
  void addItem(MenuModel menu) {
    final index = state.indexWhere(
      (o) => o.menuId == menu.id,
    );

    if (index != -1) {
      final updated = state[index].copyWith(
        quantity: (state[index].quantity ?? 0) + 1,
      );

      state = [
        ...state.sublist(0, index),
        updated,
        ...state.sublist(index + 1),
      ];
      return;
    }

    final newOrder = OrderModel(
      menuId: menu.id, 
      quantity: 1,
      price: menu.price ?? 0,
      name: menu.name,
      image: menu.imageUrl,
    );

    state = [...state, newOrder];
  }

// เพิ่มจำนวนรายการ
  void increase(int index) {
    final currentQuantity = state[index].quantity ?? 0;

    final updated = state[index].copyWith(
      quantity: currentQuantity + 1,
    );

    state = [
      ...state.sublist(0, index),
      updated,
      ...state.sublist(index + 1),
    ];
  }
  // ลดจำนวนรายการ
  void decrease(int index) {
    final currentQuantity = state[index].quantity ?? 0;

    if (currentQuantity > 1) {
      final updated = state[index].copyWith(
        quantity: currentQuantity - 1,
      );

      state = [
        ...state.sublist(0, index),
        updated,
        ...state.sublist(index + 1),
      ];
    } else {
      state = [
        ...state.sublist(0, index),
        ...state.sublist(index + 1),
      ];
    }
  }


// ล้างออเดอร์ทั้งหมด
  void clear() => state = [];

  int get totalPrice => state.fold(
    0,
    (sum, o) => sum + ((o.price ?? 0) * (o.quantity ?? 0)),
  );

  Future<void> submitOrders(int sessionId) async {
    final supabase = Supabase.instance.client;

    for (var o in state) {
      await supabase.from('orders').insert({
        'session_id': sessionId,
        'menu_id': o.menuId,
        'quantity': o.quantity,
        'price': o.price,
        'name': o.name,
        'image': o.image,
      });
    }

    clear();
  }
}

// Provider สำหรับจัดการออเดอร์
final orderProvider =
    StateNotifierProvider<OrderNotifier, List<OrderModel>>(
  (ref) => OrderNotifier(ref),
);