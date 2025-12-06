import 'dart:typed_data';
import 'package:muta/models/order_model.dart';
import 'package:muta/models/session_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ReceiptPdfService {
  static Future<Uint8List> generate({
    required SessionModel session,
    required List<OrderModel> orders,
    required int tableId,
  }) async {
    // ใช้ฟอนต์ที่รองรับภาษาไทย
    final baseFont = await PdfGoogleFonts.notoSansThaiRegular();
    final boldFont = await PdfGoogleFonts.notoSansThaiBold();
    final pdf = pw.Document();
    final now = DateTime.now();

    final total = orders.fold<double>(
      0,
      (sum, o) =>
          sum +
          ((o.price ?? 0).toDouble() *
              (o.quantity ?? 0).toDouble()),
    );

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: baseFont,
          bold: boldFont,
        ),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'MUTA - ใบเสร็จ',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'โต๊ะ T${tableId.toString().padLeft(2, '0')}',
                style: pw.TextStyle(fontSize: 14),
              ),
              pw.Text(
                'เวลาใช้งาน: ${session.timeused ?? '-'}',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.Text(
                'พิมพ์เมื่อ: ${now.toLocal()}',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.SizedBox(height: 16),
              pw.Divider(),

              // หัวตาราง
              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 4,
                    child: pw.Text(
                      'รายการ',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      'จำนวน',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      'ราคา',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),

              // รายการอาหาร
              ...orders.map((o) {
                final qty = o.quantity ?? 0;
                final price = o.price ?? 0;
                final lineTotal = qty * price;
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(
                    bottom: 6,
                  ),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 4,
                        child: pw.Text(
                          o.name ?? 'เมนู #${o.menuId}',
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          'x$qty',
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          _formatCurrency(lineTotal),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              pw.Divider(),
              pw.SizedBox(height: 6),
              pw.Row(
                mainAxisAlignment:
                    pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'รวมทั้งหมด',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  pw.Text(
                    _formatCurrency(total),
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 16,
                      color: PdfColors.deepPurple,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static String _formatCurrency(num value) {
    return '฿${value.toStringAsFixed(2)}';
  }
}
