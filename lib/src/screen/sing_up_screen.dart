import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final username = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();

  bool loading = false;
  bool obscure1 = true;
  bool obscure2 = true;

  Future<void> _register() async {
    if (password.text != confirm.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("รหัสผ่านไม่ตรงกัน")),
      );
      return;
    }

    try {
      setState(() => loading = true);

      await Supabase.instance.client.auth.signUp(
        email: email.text.trim(),
        password: password.text.trim(),
        data: {"username": username.text.trim()},
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "สมัครสมาชิกสำเร็จ กรุณายืนยันอีเมล",
          ),
        ),
      );

      context.go('/sign-in');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("สมัครล้มเหลว: $e")),
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
                  child: const Text(
                    "สมัครสมาชิก",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                GestureDetector(
                  onTap: () => context.push('/sign-in'),
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
