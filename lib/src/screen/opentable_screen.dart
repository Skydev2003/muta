import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muta/src/providers/open_table_provider.dart';

class OpenTableScreen extends ConsumerStatefulWidget {
  const OpenTableScreen({super.key, required this.id});
  final int id;

  @override
  ConsumerState<OpenTableScreen> createState() =>
      _OpenTableScreenState();
}

class _OpenTableScreenState
    extends ConsumerState<OpenTableScreen> {
  int customerCount = 1;

  Future<void> _start() async {
    final sessionId = await ref.read(
      openTableProvider((widget.id, customerCount)).future,
    );

    if (!mounted) return;

    context.go('/table_detail/${widget.id}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1123),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "เปิดโต๊ะ",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "โต๊ะ ${widget.id}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "จำนวนลูกค้า",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 30),

          // ================ เลือกจำนวนลูกค้า ================
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  if (customerCount > 1) {
                    setState(() => customerCount--);
                  }
                },
                icon: const Icon(
                  Icons.remove,
                  color: Colors.white,
                ),
              ),
              Text(
                "$customerCount",
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed:
                    () => setState(() => customerCount++),
                icon: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const Spacer(),

          // ================ ปุ่มเริ่มจับเวลา ================
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9B32F0),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                ),
                onPressed: _start,
                child: const Text(
                  "เริ่มจับเวลา",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
