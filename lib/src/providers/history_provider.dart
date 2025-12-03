import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muta/models/history_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final historyProvider = StreamProvider<List<HistoryModel>>((ref) {
  final supabase = Supabase.instance.client;

  return supabase
      .from('history')
      .stream(primaryKey: ['id'])
      .map((rows) {
        return rows
            .map((e) => HistoryModel.fromJson(e))
            .toList();
      });
});
