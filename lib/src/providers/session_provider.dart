import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muta/models/session_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



/// Provider to fetch sessions by table ID
final sessionStreamProvider = StreamProvider.family<
  List<SessionModel>,
  int
>((ref, tableId) {
  final client = Supabase.instance.client;

  return client
      .from('table_sessions')
      .stream(primaryKey: ['id'])
      .eq('table_id', tableId)
      .map(
        (rows) => rows.map(SessionModel.fromJson).toList(),
      );
});

/// Provider to open a new session
final openTableProvider =
    FutureProvider.family<int, Map<String, dynamic>>((
      ref,
      data,
    ) async {
      final supabase = Supabase.instance.client;

      final res =
          await supabase
              .from('table_sessions')
              .insert(data)
              .select('id')
              .single();

      // set table status = using
      await supabase
          .from('tables')
          .update({'status': 'using'})
          .eq('id', data['table_id']);

      return res['id'] as int;
    });
