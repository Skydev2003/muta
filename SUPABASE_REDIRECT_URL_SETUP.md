# การตั้งค่า Password Reset Redirect URL ใน Supabase

## ขั้นตอนที่ 1: ไปที่ Supabase Dashboard

1. เข้า https://app.supabase.com
2. เลือกโปรเจกต์ของคุณ
3. ไปที่ **Authentication** → **URL Configuration**

## ขั้นตอนที่ 2: ตั้งค่า Redirect URLs

### Site URL
- ปล่อยไว้เป็น `https://localhost` (หรือ URL ของเว็บแอปของคุณ)

### Redirect URLs (เพิ่ม URL ใหม่)
เพิ่ม URL เหล่านี้ให้กับรายการ Redirect URLs:

```
io.supabase.muta://reset-password
io.supabase.muta://reset-password/*
```

## ขั้นตอนที่ 3: บันทึกการเปลี่ยนแปลง

1. กดปุ่ม "Save changes"
2. รอให้ระบบบันทึกการเปลี่ยนแปลง

## ทำไมเราต้องตั้งค่านี้?

- **Deep Link Scheme**: `io.supabase.muta://reset-password` เป็น URL scheme ที่ Android และ iOS ใช้เพื่อเปิดแอปของเรา
- เมื่อผู้ใช้คลิกลิงก์รีเซ็ตรหัสผ่านในอีเมล Supabase จะเปลี่ยนเส้นทางไปยัง URL นี้
- แอปจะจับลิงก์นี้และนำผู้ใช้ไปยังหน้าแก้ไขรหัสผ่าน

## การทดสอบ

1. เปิดแอป Flutter
2. ไปที่หน้า "ลืมรหัสผ่าน"
3. ใส่อีเมลของคุณและคลิก "ส่งลิงก์"
4. ตรวจสอบอีเมลของคุณและคลิกลิงก์รีเซ็ต
5. แอปควรเปิดขึ้นมาโดยอัตโนมัติและแสดงหน้าตั้งรหัสผ่านใหม่
