import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muta/src/providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends ConsumerState<ForgotPasswordScreen> {
  final email = TextEditingController();

  Future<void> _reset() async {
    // ✅ 1) Validate email
    final emailText = email.text.trim();
    if (emailText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณากรอกอีเมล")),
      );
      return;
    }

    if (!emailText.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("กรุณากรอกอีเมลที่ถูกต้อง"),
        ),
      );
      return;
    }

    final auth = ref.read(authControllerProvider.notifier);

    // ✅ 2) Call resetPassword
    await auth.resetPassword(emailText);

    // ✅ 3) Wait for state change using watch (rebuilds when state updates)
    if (!mounted) return;

    final state = ref.read(authControllerProvider);

    state.when(
      data: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "ส่งลิงก์รีเซ็ตรหัสผ่านไปที่อีเมลแล้ว",
            ),
          ),
        );
        // ✅ 4) Clear email and optionally navigate back
        email.clear();
      },
      error: (e, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("ส่งลิงก์ล้มเหลว: $e")),
        );
      },
      loading: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final loading = authState.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1123),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              const Text(
                "ลืมรหัสผ่าน",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "กรอกอีเมลของคุณเพื่อรับลิงก์รีเซ็ตรหัสผ่าน",
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              TextField(
                controller: email,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: "อีเมล",
                  labelStyle: const TextStyle(
                    color: Colors.white60,
                  ),
                  prefixIcon: const Icon(
                    Icons.email,
                    color: Colors.white70,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF2A1A3C),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9B32F0),
                  minimumSize: const Size(
                    double.infinity,
                    45,
                  ),
                ),
                onPressed: loading ? null : _reset,
                child: Text(
                  loading ? "กำลังส่ง..." : "ส่งลิงก์",
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
