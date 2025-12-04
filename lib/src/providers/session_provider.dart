import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muta/models/session_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final sessionByTableProvider =
    FutureProvider.family<SessionModel, int>((
      ref,
      tableId,
    ) async {
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

      if (response == null) throw "ไม่พบ Session";

      final session = SessionModel.fromJson(response);

      // ⭐ แก้ตรงนี้: ใช้ UTC ทั้งหมด
      if (session.startTime != null) {
        final start =
            DateTime.parse(session.startTime!).toUtc();
        final now = DateTime.now().toUtc();
        final diff = now.difference(start);

        final hh = diff.inHours.toString().padLeft(2, '0');
        final mm = diff.inMinutes
            .remainder(60)
            .toString()
            .padLeft(2, '0');
        final ss = diff.inSeconds
            .remainder(60)
            .toString()
            .padLeft(2, '0');

        return session.copyWith(timeused: "$hh:$mm:$ss");
      }

      return session;
    });

  
// Provider สำหรับคำนวณเวลาที่ใช้ในโต๊ะนั้น ๆ
final timeUsedProvider = StreamProvider.family<String, int>(
  (ref, tableId) async* {
    final supabase = Supabase.instance.client;

    // ดึง session ล่าสุดของโต๊ะ
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
      yield "00:00:00";
      return;
    }

    final start = DateTime.parse(response['start_time']);

    // เดินเวลาเองทุก 1 วินาที
    yield* Stream.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final diff = now.difference(start);
      return diff.toString().split('.').first; // HH:mm:ss
    });
  },
);

