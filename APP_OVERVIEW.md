# ภาพรวมแอป MUTA

เอกสารสรุปฟีเจอร์และโมดูลหลักของแอปจัดการโต๊ะ/ออเดอร์ร้านอาหาร (Flutter + Supabase)

## เทคโนโลยีที่ใช้
- Flutter, Dart, Riverpod (state management), GoRouter (navigation)
- Supabase (Auth + Realtime Database/Storage)
- Freezed สำหรับโมเดล `SessionModel`
- Lottie สำหรับแอนิเมชันโหลดและโลโก้

## โฟลว์ผู้ใช้
- Auth: หน้า `SignIn`, `SignUp`, `Forgot`, `ResetPassword` พร้อม redirect ด้วย `GoRouter` ถ้าไม่ได้ล็อกอิน
- Home: ปุ่มไปหน้าจัดการโต๊ะ (`/table`) และดูประวัติ (`/history`)
- จัดการโต๊ะ (`TableScreen`):
  - แสดงสถานะโต๊ะ: `available`, `using`, `dirty`
  - โต๊ะที่กำลังใช้งานแสดงเวลาคงเหลือแบบเรียลไทม์ (90 นาที) ผ่าน `sessionTimerProvider`
  - แตะเพื่อไปเปิดโต๊ะ/ทำความสะอาด/ดูรายละเอียดตามสถานะ
- เปิดโต๊ะ (`OpenTableScreen`): ตั้งจำนวนลูกค้า สร้าง session ใหม่ เปลี่ยนสถานะโต๊ะเป็น `using`
- รายละเอียดโต๊ะ (`TableDetailScreen`):
  - แสดงเวลาเหลือที่แอปบาร์ (ใช้งาน `sessionTimerProvider`)
  - เลือกเมนูตามหมวด เพิ่มเข้า `orderProvider` (ตะกร้า)
  - ปุ่มไปตะกร้า `/cart/:id`
- ตะกร้า (`CartScreen`): แก้จำนวน/ลบรายการก่อนส่งบิล
- ปิดบิล (`BillingScreen`):
  - โหลดออเดอร์จาก session, คำนวณยอดรวม
  - แสดงเวลาที่ใช้จริงจาก `sessionTimerProvider`
  - กด “ปิดบิล & เคลียร์โต๊ะ” → บันทึกประวัติ (`historyAddProvider`), ปิด session (`finishSession`), เปลี่ยนสถานะโต๊ะเป็น `dirty`
- ประวัติ (`HistoryScreen`, `HistoryDetailScreen`): ดูรายการบิลย้อนหลัง
- โปรไฟล์ (`ProfileScreen`): เข้าถึงจากไอคอนโปรไฟล์ใน Home

## โมดูล/Providers สำคัญ
- `tableStreamProvider`: ดึงรายการโต๊ะแบบ realtime
- `sessionByTableProvider`: ดึง session ที่กำลังใช้งานของโต๊ะ
- `sessionTimerProvider`: สตรีมเวลาที่ใช้/เหลือ (duration 90 นาที) ให้ทุกหน้าที่ต้องแสดงเวลา
- `sessionTimeProvider.finishSession(...)`: ปิด session, บันทึก `timeused`, อัปเดตสถานะโต๊ะเป็น `dirty`
- `orderProvider`: จัดการตะกร้า/ออเดอร์ของโต๊ะ
- `historyAddProvider`: บันทึกข้อมูลปิดบิลลงประวัติ

## เส้นทางหลัก (GoRouter)
- `/login`, `/signup`, `/forgot`, `/reset-password`
- `/` (Home)
- `/table` (รายการโต๊ะ)
- `/openTable/:id`, `/table_detail/:id`, `/cart/:id`, `/billing/:id`, `/cleanTable/:id`
- `/history`, `/history_detail/:id`
- `/profile`

## โครงสร้างข้อมูลหลัก (Supabase)
- `tables`: `{ id, name, status }` สถานะใช้ควบคุม flow เปิด/ปิด/ทำความสะอาด
- `table_sessions`: `{ id, table_id, customer_count, start_time, end_time, status, timeused }`
- รายการออเดอร์/ประวัติ: ใช้ผ่าน `orderProvider` และ `history_provider` เพื่อสรุปยอดตอนปิดบิล
