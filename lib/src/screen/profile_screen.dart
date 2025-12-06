import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(); // ยังไม่เซ็ตค่า
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('โปรไฟล์ผู้ใช้')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text(err.toString())),
        data: (profile) {
          // ⭐ เซ็ตค่าให้ controller แค่เมื่อโหลดข้อมูลครั้งแรก
          if (controller.text.isEmpty) {
            controller.text = profile.userName ?? "";
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("อีเมล",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(profile.userEmail ?? "-"),
                const SizedBox(height: 20),

                const Text("ชื่อผู้ใช้",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "กรอกชื่อผู้ใช้",
                  ),
                ),
                const SizedBox(height: 20),

                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      await ref
                          .read(profileUpdateProvider(controller.text).future);

                      ref.invalidate(profileProvider); // refresh

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("บันทึกสำเร็จ")),
                      );
                    },
                    child: const Text("บันทึก"),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
