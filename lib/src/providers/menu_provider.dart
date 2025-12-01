import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Provider to fetch list of menu items
final menuStreamProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
      final supabase = Supabase.instance.client;
      return supabase
          .from('menu_items')
          .stream(primaryKey: ['id']);
    });
