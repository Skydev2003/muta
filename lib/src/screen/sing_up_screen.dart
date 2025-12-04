import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:muta/src/providers/auth_provider.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() =>
      _SignUpScreenState();
}

class _SignUpScreenState
    extends ConsumerState<SignUpScreen> {
  final username = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();

  bool obscure1 = true;
  bool obscure2 = true;

  Future<void> _register() async {
    if (password.text != confirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("รหัสผ่านไม่ตรงกัน")),
      );
      return;
    }

    final auth = ref.read(authControllerProvider.notifier);

    await auth.signUp(
      email: email.text.trim(),
      password: password.text.trim(),
    );

    final state = ref.read(authControllerProvider);

    state.when(
      data: (_) async {
        // ⭐ 1) บังคับ logout หลังสมัครสมาชิก
        await auth.signOut();

        // ⭐ 2) แจ้งเตือนผู้ใช้
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "สมัครสมาชิกสำเร็จ! กรุณาเข้าสู่ระบบ",
            ),
          ),
        );

        // ⭐ 3) กลับหน้า login แบบไม่มีปัญหา redirect
        context.go('/login');
      },
      error: (e, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("สมัครล้มเหลว: $e")),
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Icon(
                  Icons.person,
                  size: 60,
                  color: Colors.white70,
                ),
                const SizedBox(height: 10),

                const Text(
                  "สร้างบัญชีพนักงาน",
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 40),

                _input(
                  username,
                  "ชื่อผู้ใช้",
                  Icons.person,
                ),
                const SizedBox(height: 14),

                _input(email, "อีเมล", Icons.email),
                const SizedBox(height: 14),

                _password(password, "รหัสผ่าน", () {
                  setState(() => obscure1 = !obscure1);
                }, obscure1),

                const SizedBox(height: 14),

                _password(confirm, "ยืนยันรหัสผ่าน", () {
                  setState(() => obscure2 = !obscure2);
                }, obscure2),

                const SizedBox(height: 25),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF9B32F0,
                    ),
                    minimumSize: const Size(
                      double.infinity,
                      50,
                    ),
                  ),
                  onPressed: loading ? null : _register,
                  child: Text(
                    loading
                        ? "กำลังสมัครสมาชิก..."
                        : "สมัครสมาชิก",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                GestureDetector(
                  onTap: () => context.push('/login'),
                  child: const Text(
                    "มีบัญชีอยู่แล้ว? เข้าสู่ระบบ",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController c,
    String label,
    IconData icon,
  ) {
    return TextField(
      controller: c,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF2A1A3C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget _password(
    TextEditingController c,
    String label,
    VoidCallback toggle,
    bool obs,
  ) {
    return TextField(
      controller: c,
      obscureText: obs,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: const Icon(
          Icons.lock,
          color: Colors.white70,
        ),
        suffixIcon: IconButton(
          onPressed: toggle,
          icon: Icon(
            obs ? Icons.visibility_off : Icons.visibility,
            color: Colors.white70,
          ),
        ),
        filled: true,
        fillColor: const Color(0xFF2A1A3C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
