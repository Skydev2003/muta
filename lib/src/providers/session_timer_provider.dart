import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muta/models/session_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final sessionTimerProvider = StreamProvider.family<
  Duration,
  int
>((ref, tableId) async* {
  final supabase = Supabase.instance.client;

  // 1) ดึง session ล่าสุดของโต๊ะนี้ (status = using)
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
    yield const Duration(minutes: 0); // ไม่มี session
    return;
  }

  final session = SessionModel.fromJson(response);

  if (session.endTime == null) {
    yield const Duration(minutes: 0);
    return;
  }

  final end =
      DateTime.tryParse(session.endTime!) ?? DateTime.now();

  // 2) stream ทุก 1 วินาที
  yield* Stream.periodic(const Duration(seconds: 1), (_) {
    final now = DateTime.now();
    final remaining = end.difference(now);

    if (remaining.isNegative) {
      return Duration.zero; // หมดเวลาแล้ว
    }

    return remaining;
  });
});
