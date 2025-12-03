import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muta/models/history_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final historyProvider = FutureProvider<List<HistoryModel>>((
  ref,
) async {
  final supabase = Supabase.instance.client;

  final data = await supabase
      .from('history')
      .select()
      .order('id', ascending: false);

  return (data as List)
      .map((e) => HistoryModel.fromJson(e))
      .toList();
});
