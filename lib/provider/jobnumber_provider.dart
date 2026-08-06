import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/job_row_model.dart';
import 'package:flutter_provider_data/provider/employee_provider.dart';
import 'package:flutter_provider_data/provider/machine_provider.dart';
import 'package:flutter_provider_data/provider/material_provider.dart';
import 'package:flutter_provider_data/provider/ng_provider.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import '../service/jobnumber_service.dart';
import '../utils/custom_snackbar.dart';
import 'package:provider/provider.dart';

class JobNumberProvider extends ChangeNotifier {
  final JobNumberService _service = JobNumberService();

  //SUBMIT RECORD FINALLY
  String? errorMessage; // ← tambah ini

  String mixLotNo = '';
  String? goldPill;
  String? carbonPill;

  // QR DATA
  String jobNumber = "";
  String batchNumber = "";
  String lotNumber = "";
  String totalLotNumber = "";
  String qtyLot = "";
  String bcode = "";

  String jobDate = ""; // default kosong
  String jobProcess = ""; // default kosong
  // PRODUCT
  String drawNumber = "";
  String customer = "";
  String productType = "";
  String productCategory = "";

  // STATUS
  Map<String, dynamic>? statusData;
  bool isJobNumberScanned = false;
  bool isLoading = false;

  // MACHINE
  String idMachine = "";
  String nameMachine = "";
  String typeMachine = "";
  String areaMachine = "";

  // EMPLOYEE
  String idEmployee = "";
  String fullName = "";
  String nrp = "";
  String division = "";
  String section = "";

  // MOLD
  List<dynamic> molds = [];
  String? selectedMold;
  String cavity = "";

  // SHOOT
  int sisaShoot = 0;
  String totalShoot = "";

  // GOLD & CARBON PILL
  String germanSilverLn = "";
  String uedaUshinLn = "";
  String materialLn = "";
  String carbonLot = "";

  //MATERIAL LOT
  // String mixlotno = "";

  //QTY ACTUAL
  String qtyActual = "";

  //UNTUK CHECK INI START ATAU FINISH RECORD
  bool isAvailable = false; // default false
  String idRecord = ""; // default kosong
  String idProcess = ""; // default kosong

  bool isSubmitting = false;

  // Method untuk update status submitting
  void setSubmitting(bool value) {
    isSubmitting = value;
    notifyListeners(); // agar Consumer rebuild
  }

  Future<bool> scanJobNumber(
    String qrCode,
    String idProses, {
    required void Function(Map<String, dynamic> data) onEmployeeFound,
    required void Function(Map<String, dynamic> data) onMachineFound,
    required void Function({
      required String mixLot,
      required int goldId,
      required String goldGerman,
      required String goldUeda,
      required String goldMaterial,
      required int carbonId,
      required String carbon,
    }) onMaterialFound,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      _clearBasicJobNumber();

      // 1. Validate QR
      if (!_service.isValidQR(qrCode)) {
        errorMessage = "Invalid QR Code.";
        return false;
      }

      // 2. Parse QR
      final parsed = _service.parseQR(qrCode);
      bcode = parsed["bcode"] ?? "";
      jobNumber = parsed["jobnumber"] ?? "";
      batchNumber = parsed["batchnumber"] ?? "";
      lotNumber = parsed["lot"] ?? "";
      totalLotNumber = parsed["totallot"] ?? "";
      qtyLot = parsed["qty"] ?? "";
      jobDate = DateTime.now().toLocal().toString();
      jobProcess = "MOLDING";

      if (qtyActual.isEmpty) {
        qtyActual = qtyLot;
      }

      // 3. Status API
      statusData = await _service.checkJobNumberStatus(jobNumber, idProses);

      final runStatus = statusData?["run_status"];
      isAvailable = statusData?['exists'] ?? false;
      idRecord = statusData?['id_record']?.toString() ?? "";
      idProcess = statusData?['id_proses']?.toString() ?? "";

      if (runStatus == "completed") {
        _clearBasicJobNumber();
        errorMessage = "Jobnumber sudah finish.";
        return false;
      }

      if (runStatus == "pending") {
        _clearBasicJobNumber();
        errorMessage = "Jobnumber masih Pending.";
        return false;
      }

      // 4. Product Detail
      final product = await _service.getProductDetail(bcode);
      drawNumber = product["drawing_number"]?.toString() ?? "";
      productType = product["product_type"]?.toString() ?? "";
      productCategory = product["product_category"]?.toString() ?? "";
      customer = product["name_company"]?.toString() ?? "";

      // 5. Employee
      final employeeData = statusData?["employee"];
      if (employeeData != null) {
        _assignEmployee(employeeData);
        onEmployeeFound(employeeData);
      }

      // 6. Machine
      final machineData = statusData?["machine"];
      if (machineData != null) {
        _assignMachine(machineData);
        onMachineFound(machineData);
      }

      // 7. Material
      final mix = statusData?["mix_lot_no"]?.toString() ?? "";
      final goldId = statusData?['gold_pill']?['id'] as int? ?? 0;
      final goldGerman =
          statusData?['gold_pill']?['german_silver_lot_number']?.toString() ??
              "";
      final goldUeda =
          statusData?['gold_pill']?['ueda_ushin_lot_number']?.toString() ?? "";
      final goldMaterial =
          statusData?['gold_pill']?['material_lot_number']?.toString() ?? "";
      final carbonId = statusData?['carbon_pill']?['id'] as int? ?? 0;
      final carbon =
          statusData?['carbon_pill']?['lot_number']?.toString() ?? "";

      mixLotNo = mix;
      germanSilverLn = goldGerman;
      uedaUshinLn = goldUeda;
      materialLn = goldMaterial;
      carbonLot = carbon;

      onMaterialFound(
        mixLot: mix,
        goldId: goldId,
        goldGerman: goldGerman,
        goldUeda: goldUeda,
        goldMaterial: goldMaterial,
        carbonId: carbonId,
        carbon: carbon,
      );

      // 8. Mold List
      final encodedDrawNumber = Uri.encodeComponent(drawNumber);
      molds = await _service.getMoldsByDrawing(encodedDrawNumber);

      if (molds.isNotEmpty) {
        selectedMold = molds[0]["tool_number"].toString();
        cavity = molds[0]["cavity"].toString();
        _calculateShoot();
      } else {
        selectedMold = null;
        cavity = "";
      }

      isJobNumberScanned = true;
      return true;
    } catch (e) {
      logPrint("processJobNumber error: $e");
      errorMessage = "Error: $e";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ------------------------
  // Helper assign
  // ------------------------
  void _assignEmployee(Map<String, dynamic>? data) {
    if (data == null) return;
    idEmployee = data["id_employee"]?.toString() ?? "";
    fullName = data["full_name"]?.toString() ?? "";
    nrp = data["nrp"]?.toString() ?? "";
    division = data["division"]?.toString() ?? "";
    section = data["section"]?.toString() ?? "";
  }

  void _assignMachine(Map<String, dynamic>? data) {
    if (data == null) return;
    idMachine = data["id_mc"]?.toString() ?? "";
    nameMachine = data["nm_mc"]?.toString() ?? "";
    typeMachine = data["type_mc"]?.toString() ?? "";
    areaMachine = data["area_mc"]?.toString() ?? "";
  }

  void _calculateShoot() {
    // Convert cavity & qtyLot ke int
    final cavityInt = int.tryParse(cavity);
    final qtyInt = int.tryParse(qtyLot);

    if (cavityInt != null && qtyInt != null && cavityInt > 0) {
      final total = (qtyInt / cavityInt).ceil();

      // Simpan ke provider sebagai String
      totalShoot = total.toString();
    } else {
      totalShoot = ""; // kosongkan jika tidak valid
    }
    notifyListeners();
  }

  // tambah setter khusus
  void setSelectedMold(String? value, String cavityValue) {
    selectedMold = value;
    cavity = cavityValue;
    notifyListeners();
  }

  void _clearBeforeScan(BuildContext context) {
    // JobNumberProvider fields
    bcode = "";
    jobNumber = "";
    batchNumber = "";
    lotNumber = "";
    totalLotNumber = "";
    qtyLot = "";
    qtyActual = "";
    totalShoot = "";
    jobDate = "";
    jobProcess = "";
    // mixlotno = "";

    drawNumber = "";
    productType = "";
    productCategory = "";
    customer = "";

    selectedMold = null;
    molds = [];
    cavity = "";

    germanSilverLn = "";
    uedaUshinLn = "";
    materialLn = "";
    carbonLot = "";

    statusData = null;
    isJobNumberScanned = false;

    // MACHINE
    idMachine = "";
    nameMachine = "";
    typeMachine = "";
    areaMachine = "";

    // Reset MachineProvider
    final machineProvider =
        Provider.of<MachineProvider>(context, listen: false);
    machineProvider.clearMachine();

    // EMPLOYEE
    idEmployee = "";
    fullName = "";
    nrp = "";
    division = "";
    section = "";

    // Reset EmployeeProvider
    final employeeProvider =
        Provider.of<EmployeeProvider>(context, listen: false);
    employeeProvider.clearEmployee();

    final materialProvider =
        Provider.of<MaterialProvider>(context, listen: false);
    materialProvider.clearMixLot();
    materialProvider.clearGoldPill();
    materialProvider.clearCarbonPill();
  }

  void clearAll(
      BuildContext context, TextEditingController qtyActualController) {
    // Reset semua data dulu
    _clearBeforeScan(context);

    // Kosongkan nilai & controller
    qtyActual = "";
    qtyActualController.text = "";

    // Notify setelah SEMUA selesai
    notifyListeners();
  }

// Method untuk reset atau load jobnumber
  void setQtyLot(String value) {
    qtyLot = value;

    // Set qtyActual sama dengan qtyLot saat pertama kali
    if (qtyActual.isEmpty) {
      qtyActual = value;
    }

    notifyListeners();
  }

  void setQtyActual(String value) {
    // hilangkan angka 0 di depan, contoh "012" -> "12"
    value = value.replaceFirst(RegExp(r'^0+'), '');

    qtyActual = value;
    notifyListeners();
  }

  void updateQtyActualBasedOnNG(int totalNG) {
    final qtyLotInt = int.tryParse(qtyLot) ?? 0;
    qtyActual = (qtyLotInt - totalNG).toString();
    notifyListeners();
  }

  Future<bool> submitRecord(NGProvider ngProvider, BuildContext context) async {
    try {
      logPrint("Submitting record...");

      // assign gold & carbon pill
      goldPill ??= "";
      carbonPill ??= "";

      final response = await _service
          .submitRecord(
            idEmployee: idEmployee,
            idMachine: idMachine,
            idProcess: idProcess,
            batchNumber: batchNumber,
            totalJobNumber: totalLotNumber,
            bcode: bcode,
            jobNumber: jobNumber,
            lotNumber: lotNumber,
            startQty: int.tryParse(qtyActual) ?? 0,
            selectedMold: selectedMold,
            moldCavity: int.tryParse(cavity) ?? 1,
            mixLotNo: mixLotNo,
            goldPill: goldPill,
            carbonPill: carbonPill,
            idRecordUpdate: idRecord,
            ngData: ngProvider.dataNG,
          )
          .timeout(const Duration(seconds: 10)); // pakai timeout

      if (!context.mounted) return false;

      logPrint("Response: $response");

      ngProvider.clearAll();

      final qtyActualController = TextEditingController(text: qtyActual);
      clearAll(context, qtyActualController);
      qtyActualController.clear();
      setQtyActual('');

      return true;
    } catch (e) {
      logPrint("Submit record error: $e");
      if (context.mounted) {
        CustomSnackbar.show(context, "Submit failed: $e", isSuccess: false);
      }
      return false;
    }
  }

  Future<void> scanJobNumberSimple({
    required String qrCode,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      // 🔹 reset data dasar dulu
      _clearBasicJobNumber();

      // ============================
      // 1. VALIDASI & PARSE QR
      // ============================
      if (!_service.isValidQR(qrCode)) {
        throw Exception("Invalid QR Code");
      }

      final parsed = _service.parseQR(qrCode);

      bcode = parsed["bcode"] ?? "";
      jobNumber = parsed["jobnumber"] ?? "";
      lotNumber = parsed["lot"] ?? "";
      qtyLot = parsed["qty"] ?? "";

      if (jobNumber.isEmpty) {
        throw Exception("Job Number tidak valid");
      }

      if (bcode.isEmpty) {
        throw Exception("BCode tidak ditemukan");
      }

      if (qtyLot.isEmpty) {
        throw Exception("Qty tidak ditemukan");
      }

      // ============================
      // 2. PRODUCT DETAIL (🔥 SAMA SEPERTI scanJobNumber)
      // ============================
      final product = await _service.getProductDetail(bcode);

      drawNumber = product["drawing_number"]?.toString() ?? "";
      productType = product["product_type"]?.toString() ?? "";
      productCategory = product["product_category"]?.toString() ?? "";
      customer = product["name_company"]?.toString() ?? "";

      // ============================
      // 3. DEFAULT QTY ACTUAL
      // ============================
      if (qtyActual.isEmpty) {
        qtyActual = qtyLot;
      }

      // ============================
      // 4. DONE
      // ============================
      isJobNumberScanned = true;
    } catch (e) {
      // rollback jika gagal
      _clearBasicJobNumber();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _clearBasicJobNumber() {
    bcode = "";
    jobNumber = "";
    batchNumber = "";
    drawNumber = "";
    lotNumber = "";
    totalLotNumber = "";
    qtyLot = "";
    qtyActual = "";

    isJobNumberScanned = false;
  }

  final List<JobRowModel> _rows = [];

  List<JobRowModel> get rows => List.unmodifiable(_rows);

  void addJobRow(JobRowModel row) {
    _rows.add(row);
    notifyListeners();
  }

  void removeRowAt(int index) {
    if (index < 0 || index >= _rows.length) return;
    _rows.removeAt(index);
    notifyListeners(); // ✅ TEMPAT YANG BENAR
  }

  void removeByJobNumber(String jobNumber) {
    _rows.removeWhere((e) => e.jobNumber == jobNumber);
    notifyListeners();
  }

  void setQtyActualBatch(String value) {
    if (value.isEmpty) {
      qtyActual = "";
    } else {
      // 🔥 safety: angka & tidak boleh mulai 0
      if (!RegExp(r'^[1-9][0-9]*$').hasMatch(value)) return;
      qtyActual = value;
    }
    notifyListeners();
  }

  bool _isJobNumberExists(String jobNumber) {
    return _rows.any((row) => row.jobNumber == jobNumber);
  }

  void addCurrentJobToTable() {
    if (!isJobNumberScanned) {
      throw Exception('Job belum discan');
    }

    if (qtyActual.isEmpty) {
      throw Exception('QTY belum diisi');
    }

    if (_isJobNumberExists(jobNumber)) {
      throw Exception('Job Number tidak boleh sama');
    }

    final row = JobRowModel(
      no: (_rows.length + 1).toString(),
      jobNumber: jobNumber,
      lot: lotNumber,
      drawingNo: drawNumber,
      qtyLot: qtyLot,
      quantity: qtyActual,
      status: 'START',
      date: DateTime.now().toString().substring(0, 10),
      category: productCategory,
      type: productType,
      customer: customer,
    );

    _rows.add(row);
    notifyListeners();

    // optional: reset form
    _clearBasicJobNumber();
  }
}


















/*
import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/job_row_model.dart';
import 'package:flutter_provider_data/provider/employee_provider.dart';
import 'package:flutter_provider_data/provider/machine_provider.dart';
import 'package:flutter_provider_data/provider/material_provider.dart';
import 'package:flutter_provider_data/provider/ng_provider.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import '../service/jobnumber_service.dart';
import '../utils/custom_snackbar.dart';
import 'package:provider/provider.dart';

class JobNumberProvider extends ChangeNotifier {
  final JobNumberService _service = JobNumberService();

  //SUBMIT RECORD FINALLY
  String? errorMessage; // ← tambah ini

  String mixLotNo = '';
  String? goldPill;
  String? carbonPill;

  // QR DATA
  String jobNumber = "";
  String batchNumber = "";
  String lotNumber = "";
  String totalLotNumber = "";
  String qtyLot = "";
  String bcode = "";

  String jobDate = ""; // default kosong
  String jobProcess = ""; // default kosong
  // PRODUCT
  String drawNumber = "";
  String customer = "";
  String productType = "";
  String productCategory = "";

  // STATUS
  Map<String, dynamic>? statusData;
  bool isJobNumberScanned = false;
  bool isLoading = false;

  // MACHINE
  String idMachine = "";
  String nameMachine = "";
  String typeMachine = "";
  String areaMachine = "";

  // EMPLOYEE
  String idEmployee = "";
  String fullName = "";
  String nrp = "";
  String division = "";
  String section = "";

  // MOLD
  List<dynamic> molds = [];
  String? selectedMold;
  String cavity = "";

  // SHOOT
  int sisaShoot = 0;
  String totalShoot = "";

  // GOLD & CARBON PILL
  String germanSilverLn = "";
  String uedaUshinLn = "";
  String materialLn = "";
  String carbonLot = "";

  //MATERIAL LOT
  // String mixlotno = "";

  //QTY ACTUAL
  String qtyActual = "";

  //UNTUK CHECK INI START ATAU FINISH RECORD
  bool isAvailable = false; // default false
  String idRecord = ""; // default kosong
  String idProcess = ""; // default kosong

  bool isSubmitting = false;

  // Method untuk update status submitting
  void setSubmitting(bool value) {
    isSubmitting = value;
    notifyListeners(); // agar Consumer rebuild
  }

  Future<bool> scanJobNumber(
    String qrCode,
    String idProses, {
    required void Function(Map<String, dynamic> data) onEmployeeFound,
    required void Function(Map<String, dynamic> data) onMachineFound,
    required void Function({
      required String mixLot,
      required int goldId,
      required String goldGerman,
      required String goldUeda,
      required String goldMaterial,
      required int carbonId,
      required String carbon,
    }) onMaterialFound,
  }) async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      _clearBasicJobNumber();

      // 1. Validate QR
      if (!_service.isValidQR(qrCode)) {
        errorMessage = "Invalid QR Code.";
        return false;
      }

      // 2. Parse QR
      final parsed = _service.parseQR(qrCode);
      bcode = parsed["bcode"] ?? "";
      jobNumber = parsed["jobnumber"] ?? "";
      batchNumber = parsed["batchnumber"] ?? "";
      lotNumber = parsed["lot"] ?? "";
      totalLotNumber = parsed["totallot"] ?? "";
      qtyLot = parsed["qty"] ?? "";
      jobDate = DateTime.now().toLocal().toString();
      jobProcess = "MOLDING";

      if (qtyActual.isEmpty) {
        qtyActual = qtyLot;
      }

      // 3. Status API
      statusData = await _service.checkJobNumberStatus(jobNumber, idProses);

      final runStatus = statusData?["run_status"];
      isAvailable = statusData?['exists'] ?? false;
      idRecord = statusData?['id_record']?.toString() ?? "";
      idProcess = statusData?['id_proses']?.toString() ?? "";

      if (runStatus == "completed") {
        _clearBasicJobNumber();
        errorMessage = "Jobnumber sudah finish.";
        return false;
      }

      if (runStatus == "pending") {
        _clearBasicJobNumber();
        errorMessage = "Jobnumber masih Pending.";
        return false;
      }

      // 4. Product Detail
      final product = await _service.getProductDetail(bcode);
      drawNumber = product["drawing_number"]?.toString() ?? "";
      productType = product["product_type"]?.toString() ?? "";
      productCategory = product["product_category"]?.toString() ?? "";
      customer = product["name_company"]?.toString() ?? "";

      // 5. Employee
      final employeeData = statusData?["employee"];
      if (employeeData != null) {
        _assignEmployee(employeeData);
        onEmployeeFound(employeeData);
      }

      // 6. Machine
      final machineData = statusData?["machine"];
      if (machineData != null) {
        _assignMachine(machineData);
        onMachineFound(machineData);
      }

      // 7. Material
      final mix = statusData?["mix_lot_no"]?.toString() ?? "";
      final goldId = statusData?['gold_pill']?['id'] as int? ?? 0;
      final goldGerman =
          statusData?['gold_pill']?['german_silver_lot_number']?.toString() ??
              "";
      final goldUeda =
          statusData?['gold_pill']?['ueda_ushin_lot_number']?.toString() ?? "";
      final goldMaterial =
          statusData?['gold_pill']?['material_lot_number']?.toString() ?? "";
      final carbonId = statusData?['carbon_pill']?['id'] as int? ?? 0;
      final carbon =
          statusData?['carbon_pill']?['lot_number']?.toString() ?? "";

      mixLotNo = mix;
      germanSilverLn = goldGerman;
      uedaUshinLn = goldUeda;
      materialLn = goldMaterial;
      carbonLot = carbon;

      onMaterialFound(
        mixLot: mix,
        goldId: goldId,
        goldGerman: goldGerman,
        goldUeda: goldUeda,
        goldMaterial: goldMaterial,
        carbonId: carbonId,
        carbon: carbon,
      );

      // 8. Mold List
      final encodedDrawNumber = Uri.encodeComponent(drawNumber);
      molds = await _service.getMoldsByDrawing(encodedDrawNumber);

      if (molds.isNotEmpty) {
        selectedMold = molds[0]["tool_number"].toString();
        cavity = molds[0]["cavity"].toString();
        _calculateShoot();
      } else {
        selectedMold = null;
        cavity = "";
      }

      isJobNumberScanned = true;
      return true;
    } catch (e) {
      logPrint("processJobNumber error: $e");
      errorMessage = "Error: $e";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

/*
  Future<bool> scanJobNumber(
    String qrCode,
    String idProses, {
    required void Function(Map<String, dynamic> data) onEmployeeFound,
    required void Function(Map<String, dynamic> data) onMachineFound,
    required void Function({
      required String mixLot,
      required String goldGerman,
      required String goldUeda,
      required String goldMaterial,
      required String carbon,
    }) onMaterialFound,
  }) async {
    try {
      isLoading = true;
      errorMessage = null; // ← reset error
      notifyListeners();

      _clearBasicJobNumber();

      // 1. Validate QR
      if (!_service.isValidQR(qrCode)) {
        errorMessage = "Invalid QR Code.";
        return false;
      }

      // 2. Parse QR
      final parsed = _service.parseQR(qrCode);
      bcode = parsed["bcode"] ?? "";
      jobNumber = parsed["jobnumber"] ?? "";
      batchNumber = parsed["batchnumber"] ?? "";
      lotNumber = parsed["lot"] ?? "";
      totalLotNumber = parsed["totallot"] ?? "";
      qtyLot = parsed["qty"] ?? "";
      jobDate = DateTime.now().toLocal().toString();
      jobProcess = "MOLDING";

      if (qtyActual.isEmpty) {
        qtyActual = qtyLot;
      }

      // 3. Status API
      statusData = await _service.checkJobNumberStatus(jobNumber, idProses);

      final runStatus = statusData?["run_status"];
      isAvailable = statusData?['exists'] ?? false;
      idRecord = statusData?['id_record']?.toString() ?? "";
      idProcess = statusData?['id_proses']?.toString() ?? "";

      if (runStatus == "completed") {
        _clearBasicJobNumber();
        errorMessage = "Jobnumber sudah finish.";
        return false;
      }

      if (runStatus == "pending") {
        _clearBasicJobNumber();
        errorMessage = "Jobnumber masih Pending.";
        return false;
      }

      // 4. Product Detail
      final product = await _service.getProductDetail(bcode);
      drawNumber = product["drawing_number"]?.toString() ?? "";
      productType = product["product_type"]?.toString() ?? "";
      productCategory = product["product_category"]?.toString() ?? "";
      customer = product["name_company"]?.toString() ?? "";

      // 5. Employee
      final employeeData = statusData?["employee"];
      if (employeeData != null) {
        _assignEmployee(employeeData);
        onEmployeeFound(employeeData);
      }

      // 6. Machine
      final machineData = statusData?["machine"];
      if (machineData != null) {
        _assignMachine(machineData);
        onMachineFound(machineData);
      }

      // 7. Material
      final mix = statusData?["mix_lot_no"]?.toString() ?? "";
      final goldId = statusData?['gold_pill']?['id'] as int? ?? 0;
      final goldGerman =
          statusData?['gold_pill']?['german_silver_lot_number']?.toString() ??
              "";
      final goldUeda =
          statusData?['gold_pill']?['ueda_ushin_lot_number']?.toString() ?? "";
      final goldMaterial =
          statusData?['gold_pill']?['material_lot_number']?.toString() ?? "";
      final carbonId = statusData?['carbon_pill']?['id'] as int? ?? 0;  // ← tambah
      final carbon =
          statusData?['carbon_pill']?['lot_number']?.toString() ?? "";

      mixLotNo = mix;
      germanSilverLn = goldGerman;
      uedaUshinLn = goldUeda;
      materialLn = goldMaterial;
      carbonLot = carbon;

      onMaterialFound(
        mixLot: mix,
        goldId: goldId, 
        goldGerman: goldGerman,
        goldUeda: goldUeda,
        goldMaterial: goldMaterial,
         carbonId: carbonId,   //
        carbon: carbon,
      );

      // 8. Mold List
      final encodedDrawNumber = Uri.encodeComponent(drawNumber);
      molds = await _service.getMoldsByDrawing(encodedDrawNumber);

      if (molds.isNotEmpty) {
        selectedMold = molds[0]["tool_number"].toString();
        cavity = molds[0]["cavity"].toString();
        _calculateShoot();
      } else {
        selectedMold = null;
        cavity = "";
      }

      isJobNumberScanned = true;
      return true; // ✅ sukses
    } catch (e) {
      logPrint("processJobNumber error: $e");
      errorMessage = "Error: $e";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
  */

  // ------------------------
  // Helper assign
  // ------------------------
  void _assignEmployee(Map<String, dynamic>? data) {
    if (data == null) return;
    idEmployee = data["id_employee"]?.toString() ?? "";
    fullName = data["full_name"]?.toString() ?? "";
    nrp = data["nrp"]?.toString() ?? "";
    division = data["division"]?.toString() ?? "";
    section = data["section"]?.toString() ?? "";
  }

  void _assignMachine(Map<String, dynamic>? data) {
    if (data == null) return;
    idMachine = data["id_mc"]?.toString() ?? "";
    nameMachine = data["nm_mc"]?.toString() ?? "";
    typeMachine = data["type_mc"]?.toString() ?? "";
    areaMachine = data["area_mc"]?.toString() ?? "";
  }

  void _calculateShoot() {
    // Convert cavity & qtyLot ke int
    final cavityInt = int.tryParse(cavity);
    final qtyInt = int.tryParse(qtyLot);

    if (cavityInt != null && qtyInt != null && cavityInt > 0) {
      final total = (qtyInt / cavityInt).ceil();

      // Simpan ke provider sebagai String
      totalShoot = total.toString();
    } else {
      totalShoot = ""; // kosongkan jika tidak valid
    }
    notifyListeners();
  }

  // tambah setter khusus
  void setSelectedMold(String? value, String cavityValue) {
    selectedMold = value;
    cavity = cavityValue;
    notifyListeners();
  }

  void _clearBeforeScan(BuildContext context) {
    // JobNumberProvider fields
    bcode = "";
    jobNumber = "";
    batchNumber = "";
    lotNumber = "";
    totalLotNumber = "";
    qtyLot = "";
    qtyActual = "";
    totalShoot = "";
    jobDate = "";
    jobProcess = "";
    // mixlotno = "";

    drawNumber = "";
    productType = "";
    productCategory = "";
    customer = "";

    selectedMold = null;
    molds = [];
    cavity = "";

    germanSilverLn = "";
    uedaUshinLn = "";
    materialLn = "";
    carbonLot = "";

    statusData = null;
    isJobNumberScanned = false;

    // MACHINE
    idMachine = "";
    nameMachine = "";
    typeMachine = "";
    areaMachine = "";

    // Reset MachineProvider
    final machineProvider =
        Provider.of<MachineProvider>(context, listen: false);
    machineProvider.clearMachine();

    // EMPLOYEE
    idEmployee = "";
    fullName = "";
    nrp = "";
    division = "";
    section = "";

    // Reset EmployeeProvider
    final employeeProvider =
        Provider.of<EmployeeProvider>(context, listen: false);
    employeeProvider.clearEmployee();

    final materialProvider =
        Provider.of<MaterialProvider>(context, listen: false);
    materialProvider.clearMixLot();
    materialProvider.clearGoldPill();
    materialProvider.clearCarbonPill();
  }

  void clearAll(
      BuildContext context, TextEditingController qtyActualController) {
    // Reset semua data dulu
    _clearBeforeScan(context);

    // Kosongkan nilai & controller
    qtyActual = "";
    qtyActualController.text = "";

    // Notify setelah SEMUA selesai
    notifyListeners();
  }

// Method untuk reset atau load jobnumber
  void setQtyLot(String value) {
    qtyLot = value;

    // Set qtyActual sama dengan qtyLot saat pertama kali
    if (qtyActual.isEmpty) {
      qtyActual = value;
    }

    notifyListeners();
  }

  void setQtyActual(String value) {
    // hilangkan angka 0 di depan, contoh "012" -> "12"
    value = value.replaceFirst(RegExp(r'^0+'), '');

    qtyActual = value;
    notifyListeners();
  }

  void updateQtyActualBasedOnNG(int totalNG) {
    final qtyLotInt = int.tryParse(qtyLot) ?? 0;
    qtyActual = (qtyLotInt - totalNG).toString();
    notifyListeners();
  }

  Future<bool> submitRecord(NGProvider ngProvider, BuildContext context) async {
    try {
      logPrint("Submitting record...");

      // assign gold & carbon pill
      goldPill ??= "";
      carbonPill ??= "";

      final response = await _service
          .submitRecord(
            idEmployee: idEmployee,
            idMachine: idMachine,
            idProcess: idProcess,
            batchNumber: batchNumber,
            totalJobNumber: totalLotNumber,
            bcode: bcode,
            jobNumber: jobNumber,
            lotNumber: lotNumber,
            startQty: int.tryParse(qtyActual) ?? 0,
            selectedMold: selectedMold,
            moldCavity: int.tryParse(cavity) ?? 1,
            mixLotNo: mixLotNo,
            goldPill: goldPill,
            carbonPill: carbonPill,
            idRecordUpdate: idRecord,
            ngData: ngProvider.dataNG,
          )
          .timeout(const Duration(seconds: 10)); // pakai timeout

      logPrint("Response: $response");

      ngProvider.clearAll();

      final qtyActualController = TextEditingController(text: qtyActual);
      clearAll(context, qtyActualController);
      qtyActualController.clear();
      setQtyActual('');

      return true;
    } catch (e) {
      logPrint("Submit record error: $e");
      CustomSnackbar.show(context, "Submit failed: $e", isSuccess: false);
      return false;
    }
  }

  Future<void> scanJobNumberSimple({
    required String qrCode,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      // 🔹 reset data dasar dulu
      _clearBasicJobNumber();

      // ============================
      // 1. VALIDASI & PARSE QR
      // ============================
      if (!_service.isValidQR(qrCode)) {
        throw Exception("Invalid QR Code");
      }

      final parsed = _service.parseQR(qrCode);

      bcode = parsed["bcode"] ?? "";
      jobNumber = parsed["jobnumber"] ?? "";
      lotNumber = parsed["lot"] ?? "";
      qtyLot = parsed["qty"] ?? "";

      if (jobNumber.isEmpty) {
        throw Exception("Job Number tidak valid");
      }

      if (bcode.isEmpty) {
        throw Exception("BCode tidak ditemukan");
      }

      if (qtyLot.isEmpty) {
        throw Exception("Qty tidak ditemukan");
      }

      // ============================
      // 2. PRODUCT DETAIL (🔥 SAMA SEPERTI scanJobNumber)
      // ============================
      final product = await _service.getProductDetail(bcode);

      drawNumber = product["drawing_number"]?.toString() ?? "";
      productType = product["product_type"]?.toString() ?? "";
      productCategory = product["product_category"]?.toString() ?? "";
      customer = product["name_company"]?.toString() ?? "";

      // ============================
      // 3. DEFAULT QTY ACTUAL
      // ============================
      if (qtyActual.isEmpty) {
        qtyActual = qtyLot;
      }

      // ============================
      // 4. DONE
      // ============================
      isJobNumberScanned = true;
    } catch (e) {
      // rollback jika gagal
      _clearBasicJobNumber();
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _clearBasicJobNumber() {
    bcode = "";
    jobNumber = "";
    batchNumber = "";
    drawNumber = "";
    lotNumber = "";
    totalLotNumber = "";
    qtyLot = "";
    qtyActual = "";

    isJobNumberScanned = false;
  }

  final List<JobRowModel> _rows = [];

  List<JobRowModel> get rows => List.unmodifiable(_rows);

  void addJobRow(JobRowModel row) {
    _rows.add(row);
    notifyListeners();
  }

  void removeRowAt(int index) {
    if (index < 0 || index >= _rows.length) return;
    _rows.removeAt(index);
    notifyListeners(); // ✅ TEMPAT YANG BENAR
  }

  void removeByJobNumber(String jobNumber) {
    _rows.removeWhere((e) => e.jobNumber == jobNumber);
    notifyListeners();
  }

  void setQtyActualBatch(String value) {
    if (value.isEmpty) {
      qtyActual = "";
    } else {
      // 🔥 safety: angka & tidak boleh mulai 0
      if (!RegExp(r'^[1-9][0-9]*$').hasMatch(value)) return;
      qtyActual = value;
    }
    notifyListeners();
  }

  bool _isJobNumberExists(String jobNumber) {
    return _rows.any((row) => row.jobNumber == jobNumber);
  }

  void addCurrentJobToTable() {
    if (!isJobNumberScanned) {
      throw Exception('Job belum discan');
    }

    if (qtyActual.isEmpty) {
      throw Exception('QTY belum diisi');
    }

    if (_isJobNumberExists(jobNumber)) {
      throw Exception('Job Number tidak boleh sama');
    }

    final row = JobRowModel(
      no: (_rows.length + 1).toString(),
      jobNumber: jobNumber,
      lot: lotNumber,
      drawingNo: drawNumber,
      qtyLot: qtyLot,
      quantity: qtyActual,
      status: 'START',
      date: DateTime.now().toString().substring(0, 10),
      category: productCategory,
      type: productType,
      customer: customer,
    );

    _rows.add(row);
    notifyListeners();

    // optional: reset form
    _clearBasicJobNumber();
  }
}
*/