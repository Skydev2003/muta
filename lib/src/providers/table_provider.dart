import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muta/models/table_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ---------------- TABLE STREAM ----------------
final tableStreamProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
      final supabase = Supabase.instance.client;
      return supabase
          .from('tables')
          .stream(primaryKey: ['id'])
          .map((data) => data.cast<Map<String, dynamic>>());
    });

// ---------------- ADD TABLE ----------------
class AddTableNotifier extends StateNotifier<void> {
  AddTableNotifier() : super(null);

  Future<void> addTable(
    Map<String, dynamic> tableData,
  ) async {
    final supabase = Supabase.instance.client;
    await supabase.from('tables').insert(tableData);
  }
}

final addTableProvider =
    StateNotifierProvider<AddTableNotifier, void>((ref) {
      return AddTableNotifier();
    });

// ---------------- TABLE DETAIL ----------------
final tableDetailProvider =
    FutureProvider.family<TableModel, int>((ref, id) async {
      final supabase = Supabase.instance.client;

      final data =
          await supabase
              .from('tables')
              .select()
              .eq('id', id)
              .maybeSingle();

      if (data == null) {
        throw Exception("ไม่พบข้อมูลโต๊ะ ID $id");
      }

      return TableModel.fromJson(data);
    });
