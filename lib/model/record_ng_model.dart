// record_ng_model.dart
class RecordNgModel {
  final String idNg;
  final String ngName;
  final int qty;
  final String idEmployeeFinish;
  final String employeeName;
  final String jobnumber;
  final String batchNumber;
  final String idMcFinish;
  final String mcName;
  final String startDate;

  RecordNgModel({
    required this.idNg,
    required this.ngName,
    required this.qty,
    required this.idEmployeeFinish,
    required this.employeeName,
    required this.jobnumber,
    required this.batchNumber,
    required this.idMcFinish,
    required this.mcName,
    required this.startDate,
  });

  // Factory method untuk parse dari JSON
  factory RecordNgModel.fromJson(Map<String, dynamic> json) {
    return RecordNgModel(
      idNg: json['id_ng'] ?? '',
      ngName: json['ng_name'] ?? '',
      qty: json['qty'] ?? 0,
      idEmployeeFinish: json['id_employee_finish'] ?? '',
      employeeName: json['employee_name'] ?? '',
      jobnumber: json['jobnumber'] ?? '',
      batchNumber: json['batch_number'] ?? '',
      idMcFinish: json['id_mc_finish'] ?? '',
      mcName: json['mc_name'] ?? '',
      startDate: json['start_date'] ?? '',
    );
  }

  // Convert ke JSON
  Map<String, dynamic> toJson() {
    return {
      'id_ng': idNg,
      'ng_name': ngName,
      'qty': qty,
      'id_employee_finish': idEmployeeFinish,
      'employee_name': employeeName,
      'jobnumber': jobnumber,
      'batch_number': batchNumber,
      'id_mc_finish': idMcFinish,
      'mc_name': mcName,
      'start_date': startDate,
    };
  }
}

// Model untuk menampung seluruh response paginated dari API
class RecordNgPaginatedResponse {
  final int count;
  final String? next;
  final String? previous;
  final List<RecordNgModel> results;

  RecordNgPaginatedResponse({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  factory RecordNgPaginatedResponse.fromJson(Map<String, dynamic> json) {
    var list = json['results'] as List;
    List<RecordNgModel> recordList =
        list.map((i) => RecordNgModel.fromJson(i)).toList();

    return RecordNgPaginatedResponse(
      count: json['count'] ?? 0,
      next: json['next'],
      previous: json['previous'],
      results: recordList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'next': next,
      'previous': previous,
      'results': results.map((e) => e.toJson()).toList(),
    };
  }
}
