import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muta/models/menu_model.dart';
import 'package:muta/models/order_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// State = List<OrderModel> (ตะกร้าอาหารของโต๊ะ)
class OrderNotifier
    extends StateNotifier<List<OrderModel>> {
  OrderNotifier(this.ref) : super([]);

  final Ref ref;

  /// เพิ่มเมนูเข้าไปในตะกร้า
  void addItem(MenuModel menu) {
    // ถ้ารายการมีอยู่แล้ว → เพิ่มจำนวน
    final index = state.indexWhere(
      (o) => o.menuId == menu.id.toString(),
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

    // ถ้าไม่เคยมี → เพิ่มใหม่
    final newOrder = OrderModel(
      id: null,
      menuId: menu.id.toString(),
      quantity: 1,
      price: menu.price ?? 0,
      sessionId: null, // จะใส่ตอนกดบันทึกจริง
      createdAt: null,
    );

    state = [...state, newOrder];
  }

  /// เพิ่มจำนวน
  void increase(int index) {
    final updated = state[index].copyWith(
      quantity: (state[index].quantity ?? 0) + 1,
    );
    state = [
      ...state.sublist(0, index),
      updated,
      ...state.sublist(index + 1),
    ];
  }

  /// ลดจำนวน
  void decrease(int index) {
    final qty = state[index].quantity ?? 0;

    if (qty <= 1) {
      remove(index);
      return;
    }

    final updated = state[index].copyWith(
      quantity: qty - 1,
    );

    state = [
      ...state.sublist(0, index),
      updated,
      ...state.sublist(index + 1),
    ];
  }

  /// ลบทิ้งทั้งรายการ
  void remove(int index) {
    final newList = [...state]..removeAt(index);
    state = newList;
  }

  /// เคลียร์ตะกร้า
  void clear() {
    state = [];
  }

  /// รวมราคา
  int get totalPrice {
    return state.fold(
      0,
      (sum, item) =>
          sum + ((item.price ?? 0) * (item.quantity ?? 0)),
    );
  }

  /// บันทึกลง Supabase (ตอนปิดบิล)
  Future<void> submitOrders(int sessionId) async {
    final supabase = Supabase.instance.client;

    for (var o in state) {
      await supabase.from('orders').insert({
        'session_id': sessionId,
        'menu_id': o.menuId,
        'quantity': o.quantity,
        'price': o.price,
      });
    }

    clear();
  }
}

/// Provider
final orderProvider =
    StateNotifierProvider<OrderNotifier, List<OrderModel>>(
      (ref) => OrderNotifier(ref),
    );
