import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:muta/src/providers/auth_provider.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String? token;

  const ResetPasswordScreen({super.key, this.token});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState
    extends ConsumerState<ResetPasswordScreen> {
  final newPassword = TextEditingController();
  final confirmPassword = TextEditingController();
  bool obscure1 = true;
  bool obscure2 = true;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _updatePassword() async {
    final pwd = newPassword.text.trim();
    final confirm = confirmPassword.text.trim();

    if (pwd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("กรุณากรอกรหัสผ่านใหม่"),
        ),
      );
      return;
    }

    if (pwd.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "รหัสผ่านต้องมีความยาวอย่างน้อย 6 ตัวอักษร",
          ),
        ),
      );
      return;
    }

    if (pwd != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("รหัสผ่านไม่ตรงกัน")),
      );
      return;
    }

    final auth = ref.read(authControllerProvider.notifier);
    await auth.updatePassword(pwd);

    if (!mounted) return;

    final state = ref.read(authControllerProvider);

    state.when(
      data: (_) async {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("อัปเดตรหัสผ่านสำเร็จ"),
          ),
        );

        // 🔥 ต้อง logout ไม่งั้นจะ redirect ไปหน้า Home
        await auth.signOut();

        // ไปหน้า Login
        context.go('/login');
      },
      error: (e, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("อัปเดตล้มเหลว: $e")),
        );
      },
      loading: () {
        Center(
          child: Lottie.asset(
            'assets/lottie/Loading.json',
            width: 300,
            height: 300,
            fit: BoxFit.contain,
          ),
        );
      },
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                const Text(
                  "ตั้งรหัสผ่านใหม่",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "กรุณากรอกรหัสผ่านใหม่ของคุณ",
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                // New Password Field
                TextField(
                  controller: newPassword,
                  obscureText: obscure1,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    labelText: "รหัสผ่านใหม่",
                    labelStyle: const TextStyle(
                      color: Colors.white60,
                    ),
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: Colors.white70,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscure1
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        setState(() {
                          obscure1 = !obscure1;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: const Color(0xFF2A1A3C),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                // Confirm Password Field
                TextField(
                  controller: confirmPassword,
                  obscureText: obscure2,
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    labelText: "ยืนยันรหัสผ่าน",
                    labelStyle: const TextStyle(
                      color: Colors.white60,
                    ),
                    prefixIcon: const Icon(
                      Icons.lock,
                      color: Colors.white70,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscure2
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white70,
                      ),
                      onPressed: () {
                        setState(() {
                          obscure2 = !obscure2;
                        });
                      },
                    ),
                    filled: true,
                    fillColor: const Color(0xFF2A1A3C),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF9B32F0,
                    ),
                    minimumSize: const Size(
                      double.infinity,
                      45,
                    ),
                  ),
                  onPressed:
                      loading ? null : _updatePassword,
                  child: Text(
                    loading
                        ? "กำลังอัปเดต..."
                        : "อัปเดตรหัสผ่าน",
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    newPassword.dispose();
    confirmPassword.dispose();
    super.dispose();
  }
}
