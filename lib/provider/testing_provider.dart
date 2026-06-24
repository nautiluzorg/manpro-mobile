import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/carbonpill_model.dart';
import 'package:flutter_provider_data/model/master/employee_model.dart';
import 'package:flutter_provider_data/model/goldpill_model.dart';
import 'package:flutter_provider_data/model/master/machine_model.dart';
import 'package:flutter_provider_data/model/master/mold_model.dart';
import 'package:flutter_provider_data/model/monitor_testing_model.dart';
import 'package:flutter_provider_data/model/master/product_model.dart';
import 'package:flutter_provider_data/model/check_proses_testing_model.dart';
import 'package:flutter_provider_data/model/record_testing_detail_response.dart';
import 'package:flutter_provider_data/service/testing_service.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class TestingProvider extends ChangeNotifier {
  final TestingService service;
  TestingProvider(this.service);

  // ================= STATE =================
  bool isLoading = false;
  bool isAvailable = false;

  // ================= STATE VALIDASI =================

  bool isJobNumberScanned = false;
  bool isMixLotScanned = false;

  // ================= JOB / QR DATA =================
  String jobNumber = '';
  String mixLotNo = '';
  String bcode = '';
  String batchNumber = '';
  String nmProses = '';
  String lotNumber = '';
  String totalLotNumber = '';
  String qty = '';
  String idProses = '';

  // ================= CHECK LIST MOLD & VACUM JIG =================
  static const int moldChecklistCount = 10;
  static const int vacumChecklistCount = 5;

  bool checklistConfirmedMoldSetup = false;
  bool checklistConfirmedVacumjigSetup = false;

// ================= VALUE TEXTFIELD MACHINE =================
  String mcTempUpper = '';
  String mcTempLower = '';
  String mcCuring = '';
  String mcPressure = '';
  String mcSettings = '';

  // ================= NOTE =================
  String notes = '';
  void setNotes(String value) {
    notes = value;
    notifyListeners();
  }

  // ================= PRODUCT DATA =================
  String drawNumber = '';
  String productType = '';
  String productCategory = '';
  String company = '';
  EmployeeModel employee = EmployeeModel.empty;
  MachineModel machine = MachineModel.empty;

  CheckProsesTestingModel? currentJob;

  GoldPillModel? get goldPill => currentJob?.goldPill;
  CarbonPillModel? get carbonPill => currentJob?.carbonPill;

  int get testQty {
    return currentJob?.testQty ?? 0;
  }

  int get shootQty {
    return currentJob?.shootQty ?? 0;
  }

  int get finishQty {
    return currentJob?.finishQty ?? 0;
  }

  String get testQtyText => testQty.toString();
  String get shootQtyText => shootQty.toString();
  String get finishQtyText => finishQty.toString();

// ================= GOLD & CARBON PILL GETTERS =================

  String get goldPillLot {
    return currentJob?.goldPill?.germanSilverLotNumber ?? '';
  }

  String get carbonPillLot {
    return currentJob?.carbonPill?.carbonLotNumber ?? '';
  }

  DateTime? jobDate;

  // ================= CHECKLIST STATE CHECKBOX MOLD SETUP =================
  List<bool> checkedListMold = List.generate(10, (_) => false);

  /// Getter untuk satu item
  bool isCheckedMold(int index) => checkedListMold[index];

  /// Update satu item
  void updateCheckMold(int index, bool value) {
    checkedListMold[index] = value;
    notifyListeners();
  }

  /// Reset semua checklist
  void resetChecklistMold() {
    checkedListMold = List.generate(10, (_) => false);
    notifyListeners();
  }

  // ================= CHECKLIST STATE CHECKBOX VACUM JIG SETUP =================
  List<bool> checkedListVacum = List.generate(5, (_) => false);

  /// Getter untuk satu item
  bool isCheckedVacum(int index) => checkedListVacum[index];

  /// Update satu item
  void updateCheckVacum(int index, bool value) {
    checkedListVacum[index] = value;
    notifyListeners();
  }

  /// Reset semua checklist
  void resetChecklistVacum() {
    checkedListVacum = List.generate(vacumChecklistCount, (_) => false);
    notifyListeners();
  }

  // ================= SCAN JOB NUMBER =================
  Future<void> scanJobNumber({
    required String qrCode,
    required String idProses,
  }) async {
    _resetState();
    isLoading = true;
    notifyListeners();

    try {
      debugPrint("=== SCAN START ===");

      _validateQr(qrCode);
      _parseQr(qrCode);

      logPrint("QR Parsed:");
      logPrint("  jobNumber : $jobNumber");
      logPrint("  bcode     : $bcode");

      final job = await service.checkJobNumber(
        jobNumber: jobNumber,
        idProses: idProses,
      );

      logPrint("Job fetched:");
      logPrint("  exists     : ${job.exists}");
      logPrint("  moldNumber : ${job.moldNumber}");
      logPrint("  idProses   : ${job.idProses}");

      final product = await service.fetchProductDetail(bcode);

      logPrint("Product fetched:");
      logPrint("  drawingNumber : ${product.drawingNumber}");

      _assignJob(job);
      _assignProduct(product);
      applyChecklistFromJob();
      setJobDate(DateTime.now());
      await fetchMoldsByDrawing(drawNumber);
      calculateTotalShoot(); //Tambahan Baru.

      if (job.exists) {
        logPrint("Fetching molds by drawing...");
        logPrint("  drawingNumber = $drawNumber");

        await fetchMoldsByDrawing(drawNumber);

        logPrint("Fetch molds finished.");
        logPrint("  molds length : ${molds.length}");

        for (final m in molds) {
          logPrint(
              "  mold -> toolNumber=${m.toolNumber}, cavity=${m.cavityValue}");
        }

        logPrint("Selected mold after fetch:");
        logPrint(
            "  toolNumber=${selectedMold.toolNumber}, cavity=${selectedMold.cavityValue}");
      } else {
        logPrint("Job does NOT exist, skip fetch molds.");
      }
      isJobNumberScanned = true;
      logPrint("=== SCAN END ===");
    } catch (e, s) {
      logPrint("SCAN ERROR: $e");
      debugPrintStack(stackTrace: s);
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // ================= QR VALIDATION =================
  void _validateQr(String qr) {
    if (qr.length < 21) {
      throw Exception("QR terlalu pendek dan bukan format yang valid");
    }

    if (!RegExp(r'^[a-zA-Z0-9]{9}[a-zA-Z0-9]{10}[a-zA-Z0-9]{2}[0-9]+$')
        .hasMatch(qr)) {
      throw Exception("Format QR tidak valid");
    }
  }

  // ================= QR PARSE =================
  void _parseQr(String qr) {
    bcode = qr.substring(0, 9);
    jobNumber = qr.substring(9, 19);
    batchNumber = jobNumber.substring(0, 8);
    lotNumber = jobNumber.substring(8, 10);
    totalLotNumber = qr.substring(19, 21);
    qty = qr.substring(21);
  }

  // ================= ASSIGN JOB DATA =================
  void _assignJob(CheckProsesTestingModel job) {
    currentJob = job;
    isAvailable = job.exists;
    mixLotNo = job.mixLotNo ?? '';
    idProses = job.idProses;
    nmProses = job.nmProses ?? '';
    employee = job.employee;
    machine = job.machine;

    checklistConfirmedMoldSetup = job.checklistConfirmedMoldSetup;
    checklistConfirmedVacumjigSetup = job.checklistConfirmedVacumjigSetup;

    mcTempUpper = job.mcTempUpper ?? '';
    mcTempLower = job.mcTempLower ?? '';
    mcCuring = job.mcCuring ?? '';
    mcPressure = job.mcPressure ?? '';
    mcSettings = job.mcSettings ?? '';
    notes = job.notes ?? '';
  }

  // ================= ASSIGN PRODUCT DATA =================
  void _assignProduct(ProductModel product) {
    bcode = product.bcode;
    drawNumber = product.drawingNumber;
    productType = product.productType;
    productCategory = product.productCategory;
    company = product.companyName;
  }

  void setJobDate(DateTime date) {
    jobDate = date;
    notifyListeners();
  }

  void applyChecklistFromJob() {
    // Reset dulu semua checklist
    resetChecklistMold();
    resetChecklistVacum();

    // Ambil nilai dari job
    final moldConfirmed = currentJob?.checklistConfirmedMoldSetup ?? false;
    final vacumConfirmed = currentJob?.checklistConfirmedVacumjigSetup ?? false;

    // Jika moldConfirmed true, centang semua checklist mold
    if (moldConfirmed) {
      for (int i = 0; i < checkedListMold.length; i++) {
        checkedListMold[i] = true;
      }
    }

    // Jika vacumConfirmed true, centang semua checklist vacum
    if (vacumConfirmed) {
      for (int i = 0; i < checkedListVacum.length; i++) {
        checkedListVacum[i] = true;
      }
    }

    // Update state provider agar UI rebuild
    notifyListeners();
  }

  // ================= RESET STATE =================
  void _resetState() {
    // currentJob = null;
    currentJob = CheckProsesTestingModel.empty;
    isJobNumberScanned = false;
    isMixLotScanned = false;
    mixLotNo = '';
    bcode = '';
    jobNumber = '';
    jobDate = null;
    batchNumber = '';
    lotNumber = '';
    totalLotNumber = '';
    qty = '';
    nmProses = '';
    checklistConfirmedMoldSetup = false;
    checklistConfirmedVacumjigSetup = false;
    mcTempUpper = '';
    mcTempLower = '';
    mcCuring = '';
    mcPressure = '';
    mcSettings = '';
    drawNumber = '';
    productType = '';
    productCategory = '';
    company = '';
    employee = EmployeeModel.empty;
    machine = MachineModel.empty;
    isAvailable = false;
    molds = [];
    selectedMold = MoldModel.empty;
    checkedListMold = List.generate(moldChecklistCount, (_) => false);
    checkedListVacum = List.generate(vacumChecklistCount, (_) => false);
    notes = '';
  }

  /// ============ CLEAR FORM MACHINE PARAMETER ================
  bool shouldClearMachineForm = false;

  void requestClearMachineForm() {
    shouldClearMachineForm = true;
    notifyListeners();
  }

  void acknowledgeClearMachineForm() {
    shouldClearMachineForm = false;
  }

  /// Dipanggil dari tombol CANCEL
  void resetAll() {
    _resetState();
    requestClearMachineForm();
    notifyListeners();
  }

  Future<void> scanMixLotNumberFromCamera({
    required BuildContext context,
  }) async {
    // 1️⃣ Validasi urutan
    if (!isJobNumberScanned) {
      throw Exception("Mohon Scan Job Number terlebih dahulu.");
    }

    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);

    if (pickedImage == null) return;

    final inputImage = InputImage.fromFile(File(pickedImage.path));
    final textRecognizer = TextRecognizer();

    try {
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      final regex = RegExp(r'^(?=.*[A-Z])(?=.*\d)[A-Z0-9\- ]{13}$');

      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          final textLine = line.text.trim();

          if (regex.hasMatch(textLine)) {
            mixLotNo = textLine;
            isMixLotScanned = true;
            notifyListeners();
            return;
          }
        }
      }

      throw Exception("Tidak ditemukan MIX LOT NUMBER");
    } finally {
      textRecognizer.close();
    }
  }

  void setMixLotNo(String value) {
    mixLotNo = value;
    isMixLotScanned = true;
    notifyListeners();
  }

  // ================= STATE MOLDS =================
  List<MoldModel> molds = [];
  MoldModel selectedMold = MoldModel.empty;

  int? get selectedMoldCavity => selectedMold.cavityValue;

  // ================= FETCH MOLDS =================
  Future<void> fetchMoldsByDrawing(String drawingNumber) async {
    debugPrint("=== FETCH MOLDS START ===");
    debugPrint("drawingNumber = $drawingNumber");

    isLoading = true;
    notifyListeners();

    try {
      final result = await service.fetchMoldsByDrawing(drawingNumber);

      debugPrint("Service returned molds: ${result.length}");

      molds = result;

      if (molds.isNotEmpty) {
        selectedMold = molds.first;
        calculateTotalShoot(); // 🔥 TAMBAHAN BARU
        debugPrint("Default selected mold: ${selectedMold.toolNumber}");
      } else {
        selectedMold = MoldModel.empty;
        debugPrint("No molds found.");
      }

      applyMoldFromScan();
    } catch (e, s) {
      debugPrint("FETCH MOLDS ERROR: $e");
      debugPrintStack(stackTrace: s);
      molds = [];
      selectedMold = MoldModel.empty;
    } finally {
      isLoading = false;
      notifyListeners();
      debugPrint("=== FETCH MOLDS END ===");
    }
  }

  // ================= STATE =================

  void applyMoldFromScan() {
    final moldNoFromApi = currentJob?.moldNumber;

    if (moldNoFromApi == null || moldNoFromApi.isEmpty) return;

    selectedMold = molds.firstWhere(
      (m) => m.toolNumber == moldNoFromApi,
      orElse: () => MoldModel.empty,
    );

    calculateTotalShoot(); // ✔
  }

  void selectMold(String toolNumber) {
    selectedMold = molds.firstWhere(
      (m) => m.toolNumber == toolNumber,
      orElse: () => MoldModel.empty,
    );

    calculateTotalShoot(); // ✔
    notifyListeners();
  }

  // ================= CALCULATE =================

  int get totalShootQty => currentJob?.totalShootQty ?? 0;

  void calculateTotalShoot() {
    final int? cavity = selectedMold.cavityValue;
    final int? qtyInt = int.tryParse(qty);

    if (cavity != null && cavity > 0 && qtyInt != null) {
      currentJob = currentJob?.copyWith(
        totalShootQty: (qtyInt / cavity).ceil(),
      );
    } else {
      currentJob = currentJob?.copyWith(
        totalShootQty: 0,
      );
    }

    notifyListeners();
  }

//SET UNTUK DATA MACHINE
  void setMachine(MachineModel machine) {
    this.machine = machine;
    notifyListeners();
  }

//SET UNTUK DATA EMPLOYEE
  void setEmployee(EmployeeModel employee) {
    this.employee = employee;
    notifyListeners();
  }

//SET DATA GOLD PILL
  void setGoldPill(GoldPillModel pill) {
    currentJob ??= CheckProsesTestingModel.empty;
    currentJob = currentJob!.copyWith(goldPill: pill);
    notifyListeners();
  }

  void setCarbonPill(CarbonPillModel pill) {
    currentJob ??= CheckProsesTestingModel.empty;
    currentJob = currentJob!.copyWith(carbonPill: pill);
    notifyListeners();
  }

//=============== HANDLE CHECKLIST CHECKBOX=====================================

  bool get isRequiredTextFilled =>
      mixLotNo.isNotEmpty &&
      employee.idEmployee.isNotEmpty &&
      machine.idMc.isNotEmpty &&
      jobNumber.isNotEmpty &&
      selectedMold.toolNumber.isNotEmpty &&
      qty.isNotEmpty;

  bool get isMachineParameterFilled =>
      mcTempUpper.isNotEmpty &&
      mcTempLower.isNotEmpty &&
      mcCuring.isNotEmpty &&
      mcPressure.isNotEmpty &&
      mcSettings.isNotEmpty;

  bool get isMetalPill => productCategory.trim().toUpperCase() == "METAL PILL";

  bool get isVacumChecklistValid {
    if (!isMetalPill) return true;
    return checkedListVacum.isNotEmpty && checkedListVacum.every((v) => v);
  }

  bool get isMoldChecklistConfirmed =>
      checkedListMold.isNotEmpty &&
      checkedListMold.every((item) => item == true);

  bool get isPillValid {
    if (productCategory != "METAL PILL") return true;
    return goldPill != null || carbonPill != null;
  }

  bool get canSubmit {
    final result = !isSubmitting &&
        isRequiredTextFilled &&
        isMachineParameterFilled &&
        isMoldChecklistConfirmed &&
        isVacumChecklistValid &&
        isPillValid;

    logPrint("===== CAN SUBMIT DEBUG =====");
    logPrint("canSubmit = $result");
    logPrint("isRequiredTextFilled = $isRequiredTextFilled");
    logPrint("isMachineParameterFilled = $isMachineParameterFilled");
    logPrint("isVacumChecklistValid = $isVacumChecklistValid");
    logPrint("isMoldChecklistConfirmed = $isMoldChecklistConfirmed");
    logPrint("isMetalPill = $isMetalPill");
    logPrint("isSubmitting = $isSubmitting");
    logPrint("isPillValid = $isPillValid");
    logPrint("goldPill = ${goldPill?.germanSilverLotNumber}");
    logPrint("carbonPill = ${carbonPill?.carbonLotNumber}");

    logPrint("============================");

    return result;
  }

  void validateBeforeScanMachine() {
    if (!isJobNumberScanned) {
      throw ("Mohon Scan Job Number terlebih dahulu.");
    }

    if (!isMixLotScanned) {
      throw ("Mohon Scan Mix Lot No terlebih dahulu.");
    }
  }

  void validateBeforeScanEmployee() {
    if (!isJobNumberScanned) {
      throw ("Mohon Scan Job Number terlebih dahulu.");
    }

    if (!machine.isValid) {
      throw ("Mohon Scan QRCode Machine terlebih dahulu.");
    }
  }

//=================================== SUBMIT TESTING MOLDING ===================
  bool isSubmitting = false; // untuk menandai proses submit

  Future<bool> submitRecordData({
    String? idRecordUpdate,
    required String batchNumber,
    required String totalLotNumber,
    required String notes,
    required String bcode,
    required String jobNumber,
    required String lotNumber,
    required String selectedMoldNumber,
    required String idEmployee,
    required String idMachine,
    required int startQty,
    required int moldCavity,
    required String mixLotNumber,
  }) async {
    if (idEmployee.isEmpty || idMachine.isEmpty) {
      throw Exception("ID Employee dan Machine wajib diisi.");
    }

    if (bcode.trim().isEmpty) {
      throw Exception("BCODE tidak valid atau belum terisi.");
    }

    if (productCategory == "METAL PILL" &&
        goldPill == null &&
        carbonPill == null) {
      throw Exception("Harap isi Gold Pill atau Carbon Pill.");
    }

    final payload = {
      if (idRecordUpdate != null) "id_record_test": idRecordUpdate,
      "id_employee": idEmployee,
      "id_mc": idMachine,
      "id_proses": idProses,
      "batch_number": batchNumber,
      "total_jobnumber": totalLotNumber,
      "notes": notes,
      "details_record": [
        {
          "bcode": bcode,
          "jobnumber": jobNumber,
          "lotnumber": lotNumber,
          "moldnumber": selectedMoldNumber,
          "moldcavity": moldCavity,
          "qty": startQty,
          "total_shoot_qty": totalShootQty,
          "test_qty": moldCavity,
          "finish_qty": idRecordUpdate != null ? moldCavity : 0,
          "mix_lot_no": mixLotNumber,
          "gold_pill": goldPill?.id,
          "carbon_pill": carbonPill?.id,
          "checklist_confirmed_mold_setup": isMoldChecklistConfirmed,
          "checklist_confirmed_vacumjig_setup":
              checkedListVacum.every((v) => v),
          "mc_temp_upper": mcTempUpper,
          "mc_temp_lower": mcTempLower,
          "mc_curing": mcCuring,
          "mc_pressure": mcPressure,
          "mc_settings": mcSettings,
        }
      ]
    };

    final bool isPatch = idRecordUpdate != null;

    final bool success = isPatch
        ? await service.patchRecordTesting(payload)
        : await service.postRecordTesting(payload);

    if (!success) {
      throw Exception("Gagal mengirim data testing");
    }

// ✅ LOGGING STATE UI (BENAR DI PROVIDER)
    logPrint("SUBMIT RECORD SUCCESS");
    logPrint("MOLD CHECKLIST: $checkedListMold");
    logPrint("VACUM CHECKLIST: $checkedListVacum");
    logPrint("TOTAL SHOOT QTY: $totalShootQty");

    notifyListeners();
    return true;
  }

  Future<bool> submitRecordWithLoading({
    String? idRecordUpdate,
    required String batchNumber,
    required String totalLotNumber,
    required String notes,
    required String bcode,
    required String jobNumber,
    required String lotNumber,
    required String selectedMoldNumber,
    required String idEmployee,
    required String idMachine,
    required int startQty,
    required int moldCavity,
    required String mixLotNumber,
  }) async {
    isSubmitting = true;
    notifyListeners();

    try {
      bool result = await submitRecordData(
        idRecordUpdate: idRecordUpdate,
        batchNumber: batchNumber,
        totalLotNumber: totalLotNumber,
        notes: notes,
        bcode: bcode,
        jobNumber: jobNumber,
        lotNumber: lotNumber,
        selectedMoldNumber: selectedMoldNumber,
        idEmployee: idEmployee,
        idMachine: idMachine,
        startQty: startQty,
        moldCavity: moldCavity,
        mixLotNumber: mixLotNumber,
      );

      return result;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  // ================= FETCH TESTING DETAIL =================
  bool isTestingLoading = false;
  RecordTestingDetailResponse? detail;
  String? error;

  Future<void> fetchTestingDetail(String idRecordTest) async {
    isTestingLoading = true;
    error = null;
    notifyListeners();

    try {
      detail = await service.getTestingDetail(idRecordTest);
    } catch (e) {
      error = e.toString();
    }

    isTestingLoading = false;
    notifyListeners();
  }

// ====================== LIST TESTING ==========================

// ================= MONITOR TESTING =================
  MonitorTestingModel? onProgressTesting;
  bool isOnProgressLoading = false;
  String? onProgressError;

  Future<void> fetchOnProgressTesting() async {
    isOnProgressLoading = true;
    onProgressError = null;
    notifyListeners();

    try {
      onProgressTesting = await service.fetchOnProgressTesting();
    } catch (e) {
      onProgressError = e.toString();
    } finally {
      isOnProgressLoading = false;
      notifyListeners();
    }
  }
}
