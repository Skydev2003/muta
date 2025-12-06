# ระบบพิมพ์ใบเสร็จ (Billing & Printing)
สรุปการทำงานตั้งแต่โหลดข้อมูลบิล → สร้าง PDF → เปิด Print Preview → ปิดบิล/เคลียร์โต๊ะ พร้อมอธิบายแต่ละฟังก์ชัน/โปรไวเดอร์

## Flow คร่าว ๆ
1) พนักงานเปิดหน้าปิดบิล `/billing/:id`
2) หน้าดึง session + orders ของโต๊ะ
3) กด “ปิดบิล & พิมพ์ใบเสร็จ”
4) ระบบสร้าง PDF จากข้อมูลจริง → เปิด Print Preview (package `printing`)
5) พิมพ์เสร็จ → บันทึกประวัติ, ปิด session, เคลียร์โต๊ะ → กลับหน้า `/table`

## จุดสำคัญในโค้ด
- **หน้าปิดบิล**: `lib/src/screen/billing_screen.dart`
  - แสดง session, รายการอาหาร, ยอดรวม
  - ปุ่ม `ปิดบิล & พิมพ์ใบเสร็จ` → `_handlePrintAndClose(...)`
  - ใช้ `sessionTimerProvider` เพื่อแสดงเวลาที่ใช้งานแบบ real-time
- **สร้าง PDF**: `lib/src/services/receipt_pdf.dart`
  - `ReceiptPdfService.generate(...)` รับ `session`, `orders`, `tableId`
  - ใช้ฟอนต์ `PdfGoogleFonts.notoSansThaiRegular/Bold` รองรับภาษาไทย
  - สร้างหัวบิล, รายการเมนู (ชื่อ, จำนวน, ราคา), ยอดรวม
- **Provider PDF**: `lib/src/providers/receipt_pdf_provider.dart`
  - `receiptPdfProvider(ReceiptPdfInput(...))` คืนค่า `Uint8List` PDF bytes
  - เก็บ input (session, orders, tableId) เพื่อสร้าง PDF ในปุ่ม
- **ปิด session + ประวัติ**:
  - `historyAddProvider.addHistory(...)` บันทึกลงตาราง `history`
  - `sessionTimeProvider.finishSession(...)` อัปเดต session: `end_time`, `status=finished`, `timeused`, เปลี่ยนโต๊ะเป็น `dirty`

## ลำดับในปุ่ม `_handlePrintAndClose`
1) เรียก `receiptPdfProvider` สร้างไฟล์ PDF จากข้อมูลจริง
2) เปิด Print Preview ด้วย `Printing.layoutPdf(...)`
3) เมื่อการพิมพ์สำเร็จ:
   - `historyAddProvider.addHistory(...)`
   - `sessionTimeProvider.finishSession(...)`
   - `context.go('/table')`
4) ถ้ามี error: log ด้วย `logger`, แจ้ง snackbar

## Dependencies ที่เกี่ยวข้อง
- `pdf`: สร้างเอกสาร PDF
- `printing`: เปิด print preview / สั่งพิมพ์
- `pdf/widgets.dart show PdfGoogleFonts`: ดึงฟอนต์ Noto Sans Thai (ดาวน์โหลดครั้งแรกต้องมีเน็ต)

## ข้อมูลที่ใช้ในบิล
- `SessionModel`: id, table_id, customer_count, timeused ฯลฯ
- `OrderModel`: menu_id, name, quantity, price
- `tableId`: ใช้แสดงเลขโต๊ะ (format Txx)
- เวลาปัจจุบัน: `DateTime.now()` สำหรับ “พิมพ์เมื่อ”

## การใช้งาน
- ติดตั้ง dependency แล้ว `flutter pub get`
- กดปุ่มใน `BillingScreen` → ระบบจะทำครบทุกขั้นตอนอัตโนมัติ
