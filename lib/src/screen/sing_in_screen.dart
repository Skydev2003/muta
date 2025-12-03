import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool loading = false;
  bool obscure = true;

  Future<void> _login() async {
    try {
      setState(() => loading = true);

      await Supabase.instance.client.auth
          .signInWithPassword(
            email: email.text.trim(),
            password: password.text.trim(),
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("เข้าสู่ระบบสำเร็จ")),
      );

      context.go('/table');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("เข้าสู่ระบบล้มเหลว: $e")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  onTap: () {
                    context.push('/forgot');
                  },
                  child: const Text(
                    "ลืมรหัสผ่าน?",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),

                const SizedBox(height: 40),

                const Text(
                  "ยังไม่มีบัญชี?",
                  style: TextStyle(color: Colors.white60),
                ),

                const SizedBox(height: 10),

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
                  onPressed: () => context.push('/sign-up'),
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
          onPressed: () {
            setState(() => obscure = !obscure);
          },
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
