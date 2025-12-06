import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muta/models/order_model.dart';
import 'package:muta/models/session_model.dart';
import 'package:muta/src/services/receipt_pdf.dart';

class ReceiptPdfInput {
  final SessionModel session;
  final List<OrderModel> orders;
  final int tableId;

  const ReceiptPdfInput({
    required this.session,
    required this.orders,
    required this.tableId,
  });

  @override
  bool operator ==(Object other) {
    return other is ReceiptPdfInput &&
        other.tableId == tableId &&
        other.session.id == session.id &&
        other.orders.length == orders.length;
  }

  @override
  int get hashCode =>
      Object.hash(tableId, session.id, orders.length);
}

/// สร้าง PDF ใบเสร็จจากข้อมูลจริงของ session + orders
final receiptPdfProvider =
    FutureProvider.family<Uint8List, ReceiptPdfInput>((
      ref,
      input,
    ) async {
      return ReceiptPdfService.generate(
        session: input.session,
        orders: input.orders,
        tableId: input.tableId,
      );
    });
