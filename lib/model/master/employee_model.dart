import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

@immutable
class EmployeeModel extends Equatable {
  final String idEmployee;
  final String nrp;
  final String fullName;
  final String division;
  final String section;
  final String status;

  const EmployeeModel({
    required this.idEmployee,
    required this.nrp,
    required this.fullName,
    required this.division,
    required this.section,
    required this.status,
  });

  /// Factory untuk memetakan JSON dari API ke Object Flutter
  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      idEmployee: json['id_employee']?.toString() ?? '',
      nrp: json['nrp']?.toString() ?? '',
      fullName: json['full_name']?.toString() ?? '',
      division: json['division']?.toString() ?? '',
      section: json['section']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }

  /// Serialize ke JSON (misalnya untuk payload API atau Local Storage)
  Map<String, dynamic> toJson() {
    return {
      'id_employee': idEmployee,
      'nrp': nrp,
      'full_name': fullName,
      'division': division,
      'section': section,
      'status': status,
    };
  }

  /// Default object untuk inisialisasi awal di Provider (Safe Default)
  static const empty = EmployeeModel(
    idEmployee: '',
    nrp: '',
    fullName: '',
    division: '',
    section: '',
    status: '',
  );

  /// Helper untuk cek apakah data sudah terisi
  bool get isValid => idEmployee.isNotEmpty;

  /// Business Logic: Cek apakah employee aktif (misal status '01' adalah aktif)
  bool get isActive => status == '01';

  /// Update data tanpa merusak object lama (Sangat penting untuk Provider notifyListeners)
  EmployeeModel copyWith({
    String? idEmployee,
    String? nrp,
    String? fullName,
    String? division,
    String? section,
    String? status,
  }) {
    return EmployeeModel(
      idEmployee: idEmployee ?? this.idEmployee,
      nrp: nrp ?? this.nrp,
      fullName: fullName ?? this.fullName,
      division: division ?? this.division,
      section: section ?? this.section,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        idEmployee,
        nrp,
        fullName,
        division,
        section,
        status,
      ];

  @override
  bool get stringify => true; // Otomatis generate toString() yang rapi
}
