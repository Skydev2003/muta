import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// -------- STREAM ตาราง (แสดงโต๊ะทั้งหมด) --------
final tableStreamProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
      final supabase = Supabase.instance.client;

      return supabase
          .from('tables')
          .stream(primaryKey: ['id']);
    });

/// -------- STATE NOTIFIER สำหรับ updateStatus --------
class TableNotifier extends StateNotifier<void> {
  TableNotifier() : super(null);

  Future<void> updateStatus(
    int tableId,
    String newStatus,
  ) async {
    final supabase = Supabase.instance.client;

    await supabase
        .from('tables')
        .update({'status': newStatus})
        .eq('id', tableId);
  }
}

/// Provider ให้ CleanTableScreen ใช้
final tableProvider =
    StateNotifierProvider<TableNotifier, void>(
      (ref) => TableNotifier(),
    );
