import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ใช้ tuple เพื่อส่ง tableId + customerCount
final openTableProvider = FutureProvider.family<
  int,
  (int tableId, int customerCount)
>((ref, params) async {
  final supabase = Supabase.instance.client;

  final tableId = params.$1;
  final customerCount = params.$2;

  // STEP 1: create session
  final nowUtc = DateTime.now().toUtc();

  final session =
      await supabase
          .from('table_sessions')
          .insert({
            'table_id': tableId,
            'customer_count': customerCount,
            'start_time': nowUtc.toIso8601String(),
            'end_time':
                nowUtc
                    .add(const Duration(minutes: 90))
                    .toIso8601String(),
            'status': 'using',
          })
          .select()
          .single();


  // STEP 2: update table status
  await supabase
      .from('tables')
      .update({'status': 'using'})
      .eq('id', tableId);

  return session['id'] as int;
});
