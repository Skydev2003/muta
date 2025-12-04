# คำแนะนำการทดสอบ Deep Links ใน Android

## วิธีทดสอบ Deep Link ผ่าน ADB (Android Debug Bridge)

### ขั้นตอนที่ 1: เตรียมพร้อม
```bash
# เนื่องจากแอปของคุณกำลัง run อยู่
# เปิด Terminal ใหม่และ navigate ไปยังโฟลเดอร์โปรเจกต์
cd c:\Users\thiti\projects\muta
```

### ขั้นตอนที่ 2: ส่ง Deep Link จาก ADB
```bash
# ทดสอบ Deep Link ไปยังหน้า reset-password
adb shell am start -a android.intent.action.VIEW \
  -d "io.supabase.muta://reset-password" \
  com.example.muta

# หรือ (ลองทั้งสองแบบ)
flutter run --dart-define=DEEP_LINK=io.supabase.muta://reset-password
```

### ขั้นตอนที่ 3: ทดสอบด้วย Intent ที่สมบูรณ์
```bash
# ทดสอบกับ query parameter
adb shell am start -a android.intent.action.VIEW \
  -d "io.supabase.muta://reset-password?token=test123" \
  com.example.muta
```

## วิธีทดสอบโดยใช้อีเมลจริง

### สำหรับการพัฒนา
1. ตั้งค่า Supabase อีเมล ให้ส่งไปยัง mailbox จริงของคุณ
2. ส่งคำขอ reset password จากแอป
3. ตรวจสอบอีเมลของคุณ (Gmail, Outlook, etc.)
4. คลิกลิงก์ใน email - ระบบควรเปิดแอปโดยอัตโนมัติ

### ถ้าใช้ Supabase Local Development
```bash
# ในกรณีที่ใช้ supabase local emulator
# ให้ดูที่ docker logs
docker logs supabase_db
```

## การแก้ไขปัญหา

### ปัญหา: Deep Link ไม่ทำงาน
**วิธีแก้**:
1. ตรวจสอบ AndroidManifest.xml มี intent-filter ถูกต้อง
2. ตรวจสอบ scheme: `io.supabase.muta` (ไม่ใช่ `io.supabase.flutter`)
3. ตรวจสอบ Supabase Dashboard มี URL นี้อยู่ใน Redirect URLs

### ปัญหา: ได้รับข้อผิดพลาด "No Activity found to handle Intent"
**วิธีแก้**:
1. ตรวจสอบ package name ใน AndroidManifest.xml
2. ตรวจสอบ activity มี `android:exported="true"`
3. ลองรันแอปใหม่: `flutter clean && flutter pub get && flutter run`

### ปัญหา: Android Studio ไม่รู้จัก URI scheme
**วิธีแก้**:
1. ตรวจสอบ intent-filter ใน AndroidManifest.xml
2. Invalidate Caches → Restart Android Studio
3. ลองรันแอปจาก Terminal แทน

## วิธีเช็คว่าแอปได้รับ Deep Link หรือไม่

### โดยใช้ flutter logs
```bash
# เปิด Terminal แล้วรัน
flutter logs

# ในแอป ให้ดู print statements จากหน้า ResetPasswordScreen
print('Received token: $token');
```

## การทดสอบบน iOS

### ใช้ xcrun
```bash
# ลอง URI scheme บน iOS simulator
xcrun simctl openurl booted "io.supabase.muta://reset-password?token=test123"
```

## เคล็ดลับ

- ถ้าแอปไม่เปิดจาก Deep Link ให้อ่านใน Android Logcat เพื่อหา error:
  ```bash
  adb logcat | grep "muta\|intent\|resolve"
  ```

- สำหรับการทดสอบที่สมบูรณ์ ให้ใช้อีเมลจริงจาก Supabase Production
- ในการพัฒนา สามารถใช้ `flutter pub get && flutter run --debug` เพื่อให้ Deep Link ทำงานได้ดี
