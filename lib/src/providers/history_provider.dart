import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:muta/models/history_model.dart';

/// ------------------------------------------------------------
/// 🔥 1) Provider สำหรับดึงประวัติทั้งหมด (History Screen ใช้ตัวนี้)
/// ------------------------------------------------------------
final historyProvider = StreamProvider<List<HistoryModel>>((
  ref,
) {
  final supabase = Supabase.instance.client;

  // ใช้ stream = realtime + subscribe อัปเดตอัตโนมัติ
  final stream = supabase
      .from('history')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false);

  // map → แปลง json
  return stream.map(
    (rows) =>
        rows.map((e) => HistoryModel.fromJson(e)).toList(),
  );
});

/// ------------------------------------------------------------
/// 🔥 2) Provider สำหรับเพิ่มประวัติ (ใช้ตอนปิดบิล)
/// ------------------------------------------------------------
final historyAddProvider = Provider((ref) {
  return HistoryRepository();
});

class HistoryRepository {
  Future<void> addHistory({
    required int sessionId,
    required int totalPrice,
    required int items,
    required String tableName,
  }) async {
    final supabase = Supabase.instance.client;

    // ดึงข้อมูล user ที่ล็อกอินอยู่
    final user = supabase.auth.currentUser;

    await supabase.from('history').insert({
      'session_id': sessionId,
      'total_price': totalPrice,
      'items': items,
      'table_name': tableName,

      // 🟣 เพิ่ม 2 ค่านี้
      'user_id': user?.id,
      'user_email': user?.email,
    });
  }
}
