import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muta/models/menu_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider to fetch list of menu items
final menuStreamProvider = StreamProvider<List<MenuModel>>((
  ref,
) {
  final supabase = Supabase.instance.client;

  return supabase
      .from('menu_items')
      .stream(primaryKey: ['id'])
      .map((rows) {
        return rows
            .map((e) => MenuModel.fromJson(e))
            .toList();
      });
});


/// Provider to fetch menu items by category
final menuByCategoryProvider = StreamProvider.family<
  List<MenuModel>,
  String
>((ref, category) {
  final supabase = Supabase.instance.client;

  return supabase
      .from('menu_items')
      .stream(primaryKey: ['id'])
      .eq('category', category)
      .map(
        (items) =>
            items.map((e) => MenuModel.fromJson(e)).toList(),
      );
});
