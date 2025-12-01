import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muta/src/providers/menu_provider.dart';
import 'package:muta/src/providers/table_provider.dart';

class TableDetailScreen extends ConsumerWidget {
  const TableDetailScreen({super.key, required this.id});
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tableAsyncValue = ref.watch(
      tableDetailProvider(id),
    );
    final menu = ref.watch(menuStreamProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Table Detail')),
      body: tableAsyncValue.when(
        data: (table) {
          return Column(
            children: [
              Text('Table Name: ${table['name']}'),
              Text('Status: ${table['status']}'),
              const SizedBox(height: 20),
              Expanded(
                child: menu.when(
                  data: (menuItems) {
                    return ListView.builder(
                      itemCount: menuItems.length,
                      itemBuilder: (context, index) {
                        final menuItem = menuItems[index];
                        return ListTile(
                          title: Text(menuItem['name']),
                          subtitle: Text('Price: ${menuItem['price']}'),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, stack) =>
                      Center(child: Text('Error: $error')),
                ),
              ),
            ],
          );
        },
        loading:
            () => const Center(
              child: CircularProgressIndicator(),
            ),
        error:
            (error, stack) =>
                Center(child: Text('Error: $error')),
      ),
    );
  }
}
