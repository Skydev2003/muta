import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muta/models/session_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// เวลาให้แต่ละโต๊ะ = 90 นาที
const Duration totalDuration = Duration(minutes: 100);

final sessionByTableProvider = FutureProvider.family<
  SessionModel,
  int
>((ref, tableId) async {
  final supabase = Supabase.instance.client;

  final response =
      await supabase
          .from('table_sessions')
          .select()
          .eq('table_id', tableId)
          .eq('status', 'using')
          .order('id', ascending: false)
          .limit(1)
          .maybeSingle();

  if (response == null) {
    throw "ไม่พบ Session ของโต๊ะนี้";
  }

  final session = SessionModel.fromJson(response);

  // ใช้ end_time ในการคำนวณเวลาคงเหลือ
  if (session.endTime != null) {
    final endUtc = DateTime.parse(session.endTime!).toUtc();
    final nowUtc = DateTime.now().toUtc();

    final remaining = endUtc.difference(nowUtc);

    return session.copyWith(
      timeLeft:
          remaining.isNegative ? Duration.zero : remaining,
    );
  }

  // fallback ถ้าไม่มี end_time
  if (session.startTime != null) {
    final startUtc =
        DateTime.parse(session.startTime!).toUtc();
    final nowUtc = DateTime.now().toUtc();

    final used = nowUtc.difference(startUtc);
    final remaining = totalDuration - used;

    return session.copyWith(
      timeLeft:
          remaining.isNegative ? Duration.zero : remaining,
    );
  }

  return session.copyWith(timeLeft: Duration.zero);
});

class SessionController extends StateNotifier<bool> {
  SessionController(this.ref) : super(false);

  final Ref ref;

  Future<void> finishSession(
    int tableId,
    int sessionId,
  ) async {
    final client = Supabase.instance.client;

    // 1) ปิด session
    await client
        .from('table_sessions')
        .update({
          'end_time': DateTime.now().toIso8601String(),
          'status': 'finished',
        })
        .eq('id', sessionId);

    // 2) อัปเดตสถานะโต๊ะ → dirty
    await client
        .from('tables')
        .update({'status': 'dirty'})
        .eq('id', tableId);

    // 3) แจ้ง UI ว่าทำสำเร็จ
    state = true;
  }
}

final sessionProvider =
    StateNotifierProvider<SessionController, bool>(
      (ref) => SessionController(ref),
    );
