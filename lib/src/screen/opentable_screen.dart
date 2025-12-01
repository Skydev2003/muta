import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muta/src/providers/session_provider.dart';

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

  void _startSession() async {
    final sessionData = {
      "table_id": widget.id,
      "customer_count": customerCount,
      "start_time": DateTime.now().toIso8601String(),
      "end_time":
          DateTime.now()
              .add(const Duration(minutes: 90))
              .toIso8601String(),
      "status": "using",
    };

    final sessionId = await ref.read(
      openTableProvider(sessionData).future,
    );

    if (!mounted) return;

    // ไป table_detail พร้อม sessionId
    ref.context.push('/table_detail$sessionId');

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1123),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'เปิดโต๊ะ',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "โต๊ะ ${widget.id}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "จำนวนลูกค้า",
            style: TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 40),

          // เลือกจำนวนลูกค้า
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
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() => customerCount++);
                },
                icon: const Icon(
                  Icons.add,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const Spacer(),

          // ปุ่มเริ่มจับเวลา
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9B32F0),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                  ),
                ),
                onPressed: _startSession,
                child: const Text(
                  "เริ่มจับเวลา",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
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
