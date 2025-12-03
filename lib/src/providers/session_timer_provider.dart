import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muta/models/session_model.dart';
import 'package:muta/src/providers/session_provider.dart';

/// Provider สำหรับจับเวลา session ของโต๊ะ

final sessionTimerProvider =
    StreamProvider.family<SessionModel, int>((
      ref,
      tableId,
    ) async* {
      final session = await ref.watch(
        sessionByTableProvider(tableId).future,
      );

      if (session.startTime == null) {
        yield session;
        return;
      }

      final start =
          DateTime.parse(session.startTime!).toLocal();
      const duration = Duration(minutes: 90);

      while (true) {
        final now = DateTime.now().toLocal();
        final used = now.difference(start);
        final left = duration - used;

        yield session.copyWith(timeLeft: left);

        await Future.delayed(const Duration(seconds: 1));
      }
    });
