import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:muta/models/history_model.dart';

/// ------------------------------------------------------------
/// 🔥 1) Provider สำหรับดึงประวัติทั้งหมด (History Screen ใช้ตัวนี้)
/// ------------------------------------------------------------
final historyProvider = FutureProvider<List<HistoryModel>>((
  ref,
) async {
  final supabase = Supabase.instance.client;

  final data = await supabase
      .from('history')
      .select()
      .order('created_at', ascending: false);

  return data.map((e) => HistoryModel.fromJson(e)).toList();
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
  }) async {
    final supabase = Supabase.instance.client;

    await supabase.from('history').insert({
      'session_id': sessionId,
      'total_price': totalPrice,
      'items': items,
    });
  }
}
