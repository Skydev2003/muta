import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muta/models/menu_model.dart';
import 'package:muta/models/order_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class OrderNotifier
    extends StateNotifier<List<OrderModel>> {
  OrderNotifier(this.ref) : super([]);

  final Ref ref;

  void addItem(MenuModel menu) {
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

    final newOrder = OrderModel(
      id: null,
      sessionId: null,
      menuId: menu.id.toString(),
      quantity: 1,
      price: menu.price ?? 0,
      createdAt: null,
      name: menu.name, // *** NEW ***
      image: menu.imageUrl, // *** NEW ***
    );

    state = [...state, newOrder];
  }

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

  void remove(int index) {
    final list = [...state]..removeAt(index);
    state = list;
  }

  void clear() {
    state = [];
  }

  int get totalPrice {
    return state.fold(
      0,
      (sum, item) =>
          sum + ((item.price ?? 0) * (item.quantity ?? 0)),
    );
  }

  /// ส่งขึ้น Supabase
  Future<void> submitOrders(int sessionId) async {
    final supabase = Supabase.instance.client;

    for (var o in state) {
      await supabase.from('orders').insert({
        'session_id': sessionId,
        'menu_id': o.menuId,
        'quantity': o.quantity,
        'price': o.price,

        // เพิ่มเพื่อให้บันทึก snapshot ของเมนูลง orders
        'name': o.name,
        'image': o.image,
      });
    }

    clear();
  }
}

final orderProvider =
    StateNotifierProvider<OrderNotifier, List<OrderModel>>(
      (ref) => OrderNotifier(ref),
    );
