import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:muta/src/providers/auth_provider.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() =>
      _SignInScreenState();
}

class _SignInScreenState
    extends ConsumerState<SignInScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool obscure = true;

  Future<void> _login() async {
    final auth = ref.read(authControllerProvider.notifier);

    await auth.signIn(
      email: email.text,
      password: password.text,
    );

    final state = ref.read(authControllerProvider);

    state.when(
      data: (user) {
        if (user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("เข้าสู่ระบบสำเร็จ"),
            ),
          );
          context.go('/');
        }
      },
      error: (e, _) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("เข้าสู่ระบบล้มเหลว: $e")),
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
              children: [
                const Text(
                  "MUTA",
                  style: TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "เข้าสู่ระบบสำหรับพนักงาน",
                  style: TextStyle(color: Colors.white70),
                ),

                const SizedBox(height: 40),

                _input(email, "อีเมล", Icons.person),
                const SizedBox(height: 16),
                _passwordInput(),

                const SizedBox(height: 20),

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
                  onPressed: loading ? null : _login,
                  child: Text(
                    loading
                        ? "กำลังเข้าสู่ระบบ..."
                        : "เข้าสู่ระบบ",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                GestureDetector(
                  onTap: () => context.push('/forgot'),
                  child: const Text(
                    "ลืมรหัสผ่าน?",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),

                const SizedBox(height: 40),

                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFF9B32F0),
                    ),
                    minimumSize: const Size(
                      double.infinity,
                      50,
                    ),
                  ),
                  onPressed: () => context.push('/signup'),
                  child: const Text(
                    "สร้างบัญชีใหม่",
                    style: TextStyle(
                      color: Color(0xFF9B32F0),
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

  Widget _passwordInput() {
    return TextField(
      controller: password,
      style: const TextStyle(color: Colors.white),
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: "รหัสผ่าน",
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: const Icon(
          Icons.lock,
          color: Colors.white70,
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscure
                ? Icons.visibility_off
                : Icons.visibility,
            color: Colors.white70,
          ),
          onPressed:
              () => setState(() => obscure = !obscure),
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
