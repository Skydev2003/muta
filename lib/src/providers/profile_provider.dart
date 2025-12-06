import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muta/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


final profileProvider = FutureProvider<UserModel>((ref) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) throw "ยังไม่ได้เข้าสู่ระบบ";

  final data = await supabase
      .from('users')
      .select()
      .eq('user_id', user.id)
      .maybeSingle();

  if (data == null) throw "ไม่พบข้อมูลผู้ใช้";

  return UserModel.fromJson(data);
});


/// อัปเดต user_name
final profileUpdateProvider =
    FutureProvider.family<bool, String>((ref, newName) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;

  if (user == null) throw "ยังไม่ได้เข้าสู่ระบบ";

  await supabase.from('users').update({
  'user_name': newName,
}).eq('user_id', user.id);


  return true;
});
