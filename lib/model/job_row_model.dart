import 'package:flutter/foundation.dart';

@immutable
class JobRowModel {
  final String no;
  final String jobNumber;
  final String lot;
  final String drawingNo;
  final String qtyLot;
  final String quantity;
  final String status;
  final String date;
  final String category;
  final String type;
  final String customer;

  const JobRowModel({
    required this.no,
    required this.jobNumber,
    required this.lot,
    required this.drawingNo,
    required this.qtyLot,
    required this.quantity,
    required this.status,
    required this.date,
    required this.category,
    required this.type,
    required this.customer,
  });

  /// ================== FACTORY ==================
  /// Factory dari API / Map / Dummy
  factory JobRowModel.fromJson(Map<String, dynamic> json) {
    return JobRowModel(
      no: json['no']?.toString() ?? '',
      jobNumber: json['jobNumber']?.toString() ?? '',
      lot: json['lot']?.toString() ?? '',
      drawingNo: json['drawingNo']?.toString() ?? '',
      qtyLot: json['qtyLot']?.toString() ?? '',
      quantity: json['quantity']?.toString() ?? '',
      status: json['proses']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      customer: json['customer']?.toString() ?? '',
    );
  }

  /// ================== SERIALIZATION ==================
  Map<String, dynamic> toJson() {
    return {
      'no': no,
      'jobNumber': jobNumber,
      'lot': lot,
      'drawingNo': drawingNo,
      'qtyLot': qtyLot,
      'quantity': quantity,
      'proses': status,
      'date': date,
      'category': category,
      'type': type,
      'customer': customer,
    };
  }

  /// ================== SAFE DEFAULT ==================
  static const empty = JobRowModel(
    no: '',
    jobNumber: '',
    lot: '',
    drawingNo: '',
    qtyLot: '',
    quantity: '',
    status: '',
    date: '',
    category: '',
    type: '',
    customer: '',
  );

  /// ================== DOMAIN LOGIC ==================

  /// Apakah job valid (sudah discan)
  bool get isValid => jobNumber.isNotEmpty && lot.isNotEmpty;

  /// Quantity actual (int safe)
  int get quantityInt => int.tryParse(quantity) ?? 0;

  int get qtyLotInt => int.tryParse(qtyLot) ?? 0;

  /// ================== IMMUTABLE UPDATE ==================
  JobRowModel copyWith({
    String? no,
    String? jobNumber,
    String? lot,
    String? drawingNo,
    String? qtyLot,
    String? quantity,
    String? proses,
    String? date,
    String? category,
    String? type,
    String? customer,
  }) {
    return JobRowModel(
      no: no ?? this.no,
      jobNumber: jobNumber ?? this.jobNumber,
      lot: lot ?? this.lot,
      drawingNo: drawingNo ?? this.drawingNo,
      qtyLot: qtyLot ?? this.qtyLot,
      quantity: quantity ?? this.quantity,
      status: status,
      date: date ?? this.date,
      category: category ?? this.category,
      type: type ?? this.type,
      customer: customer ?? this.customer,
    );
  }

  @override
  String toString() {
    return 'JobRowModel(jobNumber: $jobNumber, lot: $lot, status: $status)';
  }
}
