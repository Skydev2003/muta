# MUTA Flowchart (Mermaid)
ภาพรวม flow หลักของแอป ตั้งแต่ Auth → เปิดโต๊ะ → ใช้งาน → ปิดบิล → ทำความสะอาด → ประวัติ

```mermaid
flowchart TD
  A[เปิดแอป] --> B{ล็อกอินแล้ว?}
  B -- ไม่ --> C[/Login/Signup/Forgot/Reset/]
  C --> D[/Home/]
  B -- ใช่ --> D

  subgraph Main
    D -- เปิดโต๊ะ --> E[/TableScreen/]
    E --> F{สถานะโต๊ะ}
    F -- available --> G[/OpenTable:id/]
    G --> H[สร้าง session<br/>update table = using]
    H --> I[/TableDetail:id/]
    F -- using --> I
    F -- dirty --> Q[/CleanTable:id/]

    I --> J[เลือกเมนู → orderProvider]
    I --> K[ดูตะกร้า] --> L[/Cart:id/]
    L --> M[ปรับจำนวน/ลบรายการ]
    M --> N[ไปปิดบิล] --> O[/Billing:id/]

    O --> P[ปิดบิล & เคลียร์โต๊ะ<br/>addHistory + finishSession]
    P --> E

    Q --> R[ทำความสะอาดเสร็จ<br/>update table = available]
    R --> E
  end

  D -- ประวัติ --> S[/History/]
  S --> T[/HistoryDetail:id/]
```

## หมายเหตุจุดสำคัญ
- `sessionTimerProvider` แสดงเวลาใช้งาน/เหลือแบบเรียลไทม์ใน TableScreen, TableDetail, Billing
- `sessionTimeProvider.finishSession` ปิดบิล: บันทึก `timeused`, set `status=finished`, เปลี่ยนโต๊ะเป็น `dirty`
- `historyAddProvider` บันทึกประวัติบิลเพื่อดูใน History/HistoryDetail
