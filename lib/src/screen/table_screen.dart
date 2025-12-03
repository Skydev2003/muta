import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muta/src/providers/table_provider.dart';
import 'package:muta/src/theme/app_theme.dart';

class TableScreen extends ConsumerWidget {
  const TableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final table = ref.watch(tableStreamProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.bgDark,
        title: Text('Table Screen'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.add_circle_outlined),
          ),
        ],
      ),
      body: table.when(
        data: (tables) {
          return GridView.builder(
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.0,
                ),
            itemCount: tables.length,
            itemBuilder: (context, index) {
              final table = tables[index];
              return InkWell(
                onTap: () {
                  ref.context.push(
                    '/openTable/${table['id']}',
                  );
                },

                child: Card(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.start,
                    children: [
                      Text('${table['name']}'),
                      Text('${table['status']}'),
                    ],
                  ),
                ),
              );
            },
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
