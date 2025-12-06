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
  return HistoryRepository(ref);
});

class HistoryRepository {
  final Ref ref;

  HistoryRepository(this.ref);

  Future<void> addHistory({
    required int sessionId,
    required int totalPrice,
    required int items,
    required String tableName,
  }) async {
    final supabase = Supabase.instance.client;
    final authUser = supabase.auth.currentUser;

    if (authUser == null) {
      throw "ยังไม่ได้ล็อกอิน";
    }

    // ⭐ โหลดข้อมูล user จาก table users
    final userData = await supabase
        .from('users')
        .select()
        .eq('user_id', authUser.id)
        .maybeSingle();

    if (userData == null) {
      throw "ไม่พบข้อมูลผู้ใช้ใน table users";
    }

    final userName = userData['user_name'];
    final userEmail = userData['user_email'];

    await supabase.from('history').insert({
      'session_id': sessionId,
      'total_price': totalPrice,
      'items': items,
      'table_name': "T${tableName.replaceAll('T', '').padLeft(2, '0')}",

      // ⭐ บันทึกจาก table users แทนการใช้ metadata
      'user_id': authUser.id,
      'user_email': userEmail,
      'user_name': userName,
    });
  }
}



//history detail 
final historyDetailProvider = FutureProvider.family<HistoryModel, int>(
  (ref, historyId) async {
    final supabase = Supabase.instance.client;

    final response = await supabase
        .from('history')
        .select()
        .eq('id', historyId)
        .single();

    return HistoryModel.fromJson(response);
  },
);

 