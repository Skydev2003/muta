import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muta/models/session_model.dart';
import 'package:muta/src/providers/session_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider สำหรับจับเวลา session ของโต๊ะ
final sessionTimerProvider = StreamProvider.family<
  SessionModel,
  int
>((ref, tableId) async* {
  final session = await ref.watch(
    sessionByTableProvider(tableId).future,
  );

  if (session.startTime == null) {
    yield session;
    return;
  }

  final start = DateTime.parse(session.startTime!).toUtc();
  const duration = Duration(minutes: 90);

  while (true) {
    final now = DateTime.now().toUtc();
    final used = now.difference(start);
    final left = duration - used;

    final safeLeft = left.isNegative ? Duration.zero : left;

    final hh = used.inHours.toString().padLeft(2, '0');
    final mm = used.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final ss = used.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    yield session.copyWith(
      timeused: "$hh:$mm:$ss",
      timeLeft: safeLeft,
    );

    await Future.delayed(Duration(seconds: 1));
  }
});


class SessionController extends StateNotifier<bool> {
  SessionController(this.ref) : super(false);

  final Ref ref;

  Future<void> finishSession(
    int tableId,
    int sessionId,
  ) async {
    final supabase = Supabase.instance.client;

    // ดึง session เพื่อคำนวณ timeused ครั้งสุดท้าย
    final session =
        await supabase
            .from('table_sessions')
            .select()
            .eq('id', sessionId)
            .single();

    final start =
        DateTime.parse(session['start_time']).toLocal();
    final end = DateTime.now().toLocal();
    final diff = end.difference(start);

    final hh = diff.inHours.toString().padLeft(2, '0');
    final mm = (diff.inMinutes % 60).toString().padLeft(
      2,
      '0',
    );
    final ss = (diff.inSeconds % 60).toString().padLeft(
      2,
      '0',
    );
    final timeused = "$hh:$mm:$ss";

    // ⛔ตรงนี้ต้องเป็น update
    await supabase
        .from('table_sessions')
        .update({
          'end_time': end.toUtc().toIso8601String(),
          'status': 'finished',
          'timeused': timeused, // ⬅️ บันทึกจริง
        })
        .eq('id', sessionId);

    // อัปเดตสถานะโต๊ะ
    await supabase
        .from('tables')
        .update({'status': 'dirty'})
        .eq('id', tableId);

    state = true;
  }
}
final sessionTimeProvider =
    StateNotifierProvider<SessionController, bool>(
  (ref) => SessionController(ref),
);
