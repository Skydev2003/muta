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
