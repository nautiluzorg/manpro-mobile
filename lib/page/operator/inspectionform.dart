import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/master/employee_model.dart';
import 'package:flutter_provider_data/model/machine_model_dropdown.dart';
import 'package:flutter_provider_data/page/menu.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:flutter_provider_data/utils/mobile_scanner_page.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class InspectionForm extends StatefulWidget {
  final String title;
  final String idProses;

  const InspectionForm({
    super.key,
    required this.title,
    required this.idProses,
  });

  @override
  State<InspectionForm> createState() => _InspectionFormState();
}

class _InspectionFormState extends State<InspectionForm>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  String code = "";
  String getcode = "";
  late String getCodeEmployee;
  late String idEmployee;
  late String nameEmployee;
  late String nameEmployee2;
  late String idMachine;
  late String nameMachine;
  late String areaMachine;
  late String typeMachine;
  late String nrp;
  late String division;
  late String section;
  late String bcodeJobnumber;
  late String jobNumber;
  late String lotNumber;
  late String totalLotNumber;
  late String batchNumber;
  late String drawNumber;
  late String typeProduct;
  late String categoryProduct;
  late String lotQuantity;
  late String customer;
  late String cavity;
  late String photoEmployee;
  late String jobProcess;
  late String totalShootView;
  late String germanSilverLn;
  late String uedaUshinLn;
  late String materialLn;
  late String carbonLot;
  late int totalHalfNg;
  late int totalHalfShoot;
  late int sisaShoot;
  late num totalShot;
  int? goldPill;
  int? carbonPill;
  bool isFinish = false;
  bool isAvailable = false;
  String? idRecUpdate; // taruh ini di dalam State class
  bool isJobNumberScanned = false;
  bool isMixLotScanned = false;
  bool isMachineScanned = false;
  bool isEmployeeScanned = false;
  bool isPillEnabled = false;
  bool isSubmitting = false;
  String jobDate = "";
  String strtotalShot = "";
  String? selectedMoldNumber;
  List<dynamic> molds = [];
  List<Map<String, dynamic>> dataNG = [];
  List<Map<String, dynamic>> ngTableData = [];
  // List untuk menampung employee
  List<EmployeeModel> _employeeList = [];
  bool _isFetchingEmployee = false;
  int selectedShift = 1;
  List<bool> isSelected = [true, false, false];
  // bool isOkMixLotEnabled = false;

  // Employee yang dipilih
  EmployeeModel? selectedEmployeeItem;

  final TextEditingController mixLotNumberController = TextEditingController();
  final TextEditingController idEmployeeController = TextEditingController();
  final TextEditingController goldPillController = TextEditingController();
  final TextEditingController carbonPillController = TextEditingController();
  final TextEditingController idMachineController = TextEditingController();
  final TextEditingController jobNumberController = TextEditingController();
  final TextEditingController drawNumberController = TextEditingController();
  final TextEditingController qtyLotController = TextEditingController();
  final TextEditingController moldNumberController = TextEditingController();
  final TextEditingController moldCavityController = TextEditingController();
  final TextEditingController totalShotController = TextEditingController();
  final TextEditingController qtyActualController = TextEditingController();

  @override
  void initState() {
    idEmployee = "";
    nameEmployee = "";
    nameEmployee2 = "OPERATOR NAME";
    nrp = "NRP";
    division = "Division";
    section = "Section";
    idMachine = "";
    nameMachine = "";
    areaMachine = "";
    typeMachine = "";
    bcodeJobnumber = "";
    jobNumber = "";
    batchNumber = "";
    lotNumber = "";
    totalLotNumber = "";
    drawNumber = "";
    typeProduct = "";
    categoryProduct = "";
    lotQuantity = "";
    customer = "";
    cavity = "";
    totalShootView = "";
    totalHalfNg = 0;
    totalHalfShoot = 0;
    sisaShoot = 0;
    totalShootView = "";
    photoEmployee = "employee.png";
    jobProcess = "";
    jobDate = "";
    goldPill = null;
    germanSilverLn = "";
    uedaUshinLn = "";
    materialLn = "";
    carbonPill = null;
    carbonLot = "";
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    // Dispose semua TextEditingController
    mixLotNumberController.dispose();
    idEmployeeController.dispose();
    goldPillController.dispose();
    carbonPillController.dispose();
    idMachineController.dispose();
    jobNumberController.dispose();
    drawNumberController.dispose();
    qtyLotController.dispose();
    moldNumberController.dispose();
    moldCavityController.dispose();
    totalShotController.dispose();
    qtyActualController.dispose();

    // Kembalikan semua orientasi
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _glowController.dispose();
    super.dispose(); // jangan lupa panggil super.dispose()
  }

  String _formatDateTime(String dateTimeString) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeString)
          .toLocal(); // Parse UTC time and convert to local time

      // Format the DateTime to local Japan Standard Time (JST)
      return DateFormat('yyyy-MM-dd HH:mm')
          .format(dateTime); // Format to desired string format
    } catch (e) {
      return dateTimeString; // Return the original string if parsing fails
    }
  }

  Future<void> scanJobNumber(String idProses) async {
    try {
      final getcode = await Navigator.push<String>(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MobileScannerPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration:
              const Duration(milliseconds: 300), // pop halus
        ),
      );

      if (!mounted) return;
      if (getcode == null || getcode.isEmpty || getcode == "-1") return;

      // Validasi format minimal panjang untuk QR Code
      if (getcode.length < 21) {
        CustomSnackbar.show(
          context,
          "Bukan QRCode Job Number, Qrcode tidak dikenal.",
          isSuccess: false,
        );

        return;
      }

      // Validasi format QR code dengan qty variatif panjangnya
      if (!RegExp(r'^[a-zA-Z0-9]{9}[a-zA-Z0-9]{10}[a-zA-Z0-9]{2}[0-9]+$')
          .hasMatch(getcode)) {
        CustomSnackbar.show(
          context,
          "Invalid QR Code format.",
          isSuccess: false,
        );

        return;
      }

      String bcode = getcode.substring(0, 9); // 9 karakter pertama
      String jobnumber = getcode.substring(9, 19); // 10 karakter berikutnya
      String batchnumber = jobnumber.substring(0, 8); // 8 karakter Batch Number
      String lot = jobnumber
          .substring(jobnumber.length - 2); // 2 digit terakhir jobnumber
      String totallot = getcode.substring(19, 21); // 2 karakter berikutnya
      String qty =
          getcode.substring(21); // Sisa string = qty (bisa panjang variatif)

      // Step 1: Cek status jobnumber
      var statusUrl = Uri.parse(
          "${AppConfig.baseUrl}/api/check-proses-jobnumber-testing/$jobnumber/$idProses/");

      var statusResponse = await http.get(statusUrl).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException("Status request timed out.");
        },
      );

      if (statusResponse.statusCode == 200) {
        Map<String, dynamic> statusData = json.decode(statusResponse.body);

        bool exists = statusData['exists'] ?? false;

        String? idRecordUpdate = statusData['id_record_test'];
        String? mixLotNumber = statusData['mix_lot_no'];
        int totalShoot =
            int.tryParse(statusData['shoot_qty']?.toString() ?? '0') ?? 0;

        isAvailable = exists;

        // Step 2: Ambil detail produk
        var detailUrl =
            Uri.parse("${AppConfig.baseUrl}/api/product-detail/$bcode/");
        var detailResponse = await http.get(detailUrl).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            throw TimeoutException("Product detail request timed out.");
          },
        );

        if (detailResponse.statusCode == 200) {
          Map<String, dynamic> productData = json.decode(detailResponse.body);
          setState(() {
            jobNumberController.text = jobnumber;
            mixLotNumberController.text = mixLotNumber ?? '';
            drawNumberController.text =
                productData['drawing_number'].toString();
            qtyLotController.text = qty;
            qtyActualController.text = qty;
            drawNumber = productData['drawing_number'].toString();
            typeProduct = productData['product_type'].toString();
            categoryProduct = productData['product_category'].toString();
            isPillEnabled = (categoryProduct == "METAL PILL");
            lotQuantity = qty;
            customer = productData['name_company'].toString();
            selectedMoldNumber = statusData['moldnumber']?.toString();
            moldCavityController.text =
                statusData['moldcavity']?.toString() ?? '';
            cavity = statusData['moldcavity']?.toString() ?? '';

            jobProcess = "MOULDING";
            jobDate = DateTime.now().toLocal().toString();
            bcodeJobnumber = bcode;
            jobNumber = jobnumber;
            batchNumber = batchnumber;
            totalLotNumber = totallot;

            idEmployee =
                statusData['employee']?['id_employee']?.toString() ?? '';

            // goldPill = statusData['gold_pill']?['id'] != null ? statusData['gold_pill']['id'] as int : null;
            // carbonPill = statusData['carbon_pill']?['id'] != null ? statusData['carbon_pill']['id'] as int : null;
            goldPill =
                int.tryParse(statusData['gold_pill']?['id']?.toString() ?? '');
            carbonPill = int.tryParse(
                statusData['carbon_pill']?['id']?.toString() ?? '');

            germanSilverLn = statusData['gold_pill']
                        ?['german_silver_lot_number']
                    ?.toString() ??
                '';
            uedaUshinLn =
                statusData['gold_pill']?['ueda_ushin_lot_number']?.toString() ??
                    '';
            materialLn =
                statusData['gold_pill']?['material_lot_number']?.toString() ??
                    '';

            carbonLot =
                statusData['carbon_pill']?['lot_number']?.toString() ?? '';

            goldPillController.text = germanSilverLn;
            carbonPillController.text = carbonLot;

            lotNumber = lot;
            totalHalfNg = int.tryParse(
                    statusData['ng_summary']?['total_qty_ng']?.toString() ??
                        '0') ??
                0;
            totalHalfShoot = int.tryParse(
                    statusData['ng_summary']?['total_shoot_qty']?.toString() ??
                        '0') ??
                0;
            sisaShoot = totalShoot - totalHalfShoot;
            isFinish = false;
            this.isAvailable = isAvailable;
            this.idRecUpdate = idRecordUpdate;

            isJobNumberScanned = true;
            isMixLotScanned = false;
            isMachineScanned = false;
            isEmployeeScanned = false;

            assignEmployee(statusData['employee']);
            assignMachine(statusData['machine']);
          });

          if (drawNumber.isNotEmpty) {
            await fetchMoldsByDrawing(drawNumber);
            calculateTotalShoot();
          }
        } else {
          if (!mounted) return;
          CustomSnackbar.show(
            context,
            "Error: ${detailResponse.statusCode} - ${detailResponse.reasonPhrase}",
            isSuccess: false,
          );
        }
      } else if (statusResponse.statusCode == 404) {
        if (!mounted) return;
        CustomSnackbar.show(
          context,
          "Jobnumber $jobnumber belum terdaftar di sistem.",
          isSuccess: false,
        );

        return;
      }
    } on TimeoutException catch (_) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        "Request timed out. Please try again.",
        isSuccess: false,
      );
    } on SocketException catch (_) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        "No internet connection.",
        isSuccess: false,
      );
    } on FormatException catch (_) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        "Error parsing server response.",
        isSuccess: false,
      );
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        "Unexpected error: $e",
        isSuccess: false,
      );
    }
  }

  void assignEmployee(Map<String, dynamic>? emp) {
    if (emp != null) {
      idEmployeeController.text = emp['id_employee'] ?? '';
      photoEmployee = "${emp['id_employee'] ?? ''}.png";
      nameEmployee = emp['full_name'] ?? '';
      nameEmployee2 = emp['full_name'] ?? '';
      nrp = emp['nrp'] ?? '';
      division = emp['division'] ?? '';
      section = emp['section'] ?? '';
    } else {
      idEmployeeController.text = '';
      photoEmployee = 'employee.png';
      nameEmployee = '';
      nameEmployee2 = 'OPERATOR NAME';
      nrp = 'NRP';
      division = 'Division';
      section = 'Section';
    }
  }

  void assignMachine(Map<String, dynamic>? mc) {
    if (mc != null) {
      idMachineController.text = mc['id_mc'] ?? '';
      nameMachine = mc['nm_mc'] ?? '';
      areaMachine = mc['area_mc'] ?? '';
      typeMachine = mc['type_mc'] ?? '';
    } else {
      idMachineController.text = '';
      nameMachine = '';
      areaMachine = '';
      typeMachine = '';
    }
  }

  Future<void> scanMixLotNumber() async {
    if (!isJobNumberScanned) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        "Mohon Scan Job Number terlebih dahulu.",
        isSuccess: false,
      );

      return;
    }

    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);

    if (pickedImage == null) return;

    final inputImage = InputImage.fromFile(File(pickedImage.path));
    final textRecognizer = TextRecognizer();

    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    // regex: 13 karakter, wajib huruf kapital + angka, boleh ada spasi atau -
    final regex = RegExp(r'^(?=.*[A-Z])(?=.*\d)[A-Z0-9\- ]{13}$');

    for (var block in recognizedText.blocks) {
      for (var line in block.lines) {
        final textLine = line.text.trim();

        if (regex.hasMatch(textLine)) {
          setState(() {
            mixLotNumberController.text = textLine;
            isMixLotScanned = true;
          });
          textRecognizer.close();
          return;
        }
      }
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Tidak ditemukan MIX LOT NUMBER")),
    );

    textRecognizer.close();
  }

  Future<void> scanMachine() async {
    if (!isMixLotScanned) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        "Scan Mixing Lot Number terlebih dahulu.",
        isSuccess: false,
      );

      return;
    }

    try {
      // 📷 Step 1: Scan pakai MobileScannerPage

      final getcode = await Navigator.push<String>(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MobileScannerPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration:
              const Duration(milliseconds: 300), // pop halus
        ),
      );

      if (!mounted) return;
      if (getcode == null || getcode.isEmpty || getcode == "-1") return;

      // 📌 Step 2: Validasi format kode mesin (10 karakter alfanumerik + '-')
      if (!RegExp(r'^[a-zA-Z0-9\-]{10}$').hasMatch(getcode)) {
        if (!mounted) return;
        CustomSnackbar.show(
          context,
          "Invalid QR Code format. Must be 10 characters (letters, numbers, or '-').",
          isSuccess: false,
        );

        return;
      }

      // 🔍 Step 3: Cek status mesin
      final checkStatusUrl =
          Uri.parse("${AppConfig.baseUrl}/api/check-machine-status/$getcode/");
      final checkResponse = await http.get(checkStatusUrl).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException("Check status request timed out.");
        },
      );

      if (checkResponse.statusCode == 400) {
        final data = json.decode(checkResponse.body);

        if (!mounted) return;
        CustomSnackbar.show(
          context,
          data["message"] ?? "Mesin sedang digunakan..",
          isSuccess: false,
        );

        return;
      } else if (checkResponse.statusCode == 404) {
        final data = json.decode(checkResponse.body);

        if (!mounted) return;
        CustomSnackbar.show(
          context,
          data["message"] ?? "Mesin tidak ditemukan.",
          isSuccess: false,
        );
        return;
      }

      // ✅ Step 4: Ambil detail mesin
      final detailUrl =
          Uri.parse("${AppConfig.baseUrl}/api/machine-detail/$getcode/");
      final detailResponse = await http.get(detailUrl).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException("Request timed out. Please try again.");
        },
      );

      if (detailResponse.statusCode == 200) {
        final data = json.decode(detailResponse.body);

        if (!data.containsKey('id_mc')) {
          if (!mounted) return;
          CustomSnackbar.show(
            context,
            "Invalid data from server",
            isSuccess: false,
          );

          return;
        }

        if (data['status'] == "02") {
          if (!mounted) return;
          CustomSnackbar.show(
            context,
            "Employee not Active",
            isSuccess: false,
          );

          return;
        }

        if (!mounted) return;
        setState(() {
          idMachineController.text = data['id_mc'].toString();
          areaMachine = data['area_mc'].toString();
          nameMachine = data['nm_mc'].toString();
          typeMachine = data['type_mc'].toString();
          jobProcess = "MOULDING";
          jobDate = DateTime.now().toLocal().toString();
          isMachineScanned = true;
        });
      } else if (detailResponse.statusCode == 404) {
        if (!mounted) return;
        CustomSnackbar.show(
          context,
          "Machine not found. Please add Machine to Database.",
          isSuccess: false,
        );
      } else {
        if (!mounted) return;
        CustomSnackbar.show(
          context,
          "Error: ${detailResponse.statusCode} - ${detailResponse.reasonPhrase}",
          isSuccess: false,
        );
      }
    } on TimeoutException catch (_) {
      CustomSnackbar.show(
        context,
        "Request timed out. Please try again.",
        isSuccess: false,
      );
    } on SocketException catch (_) {
      CustomSnackbar.show(
        context,
        "No internet connection.",
        isSuccess: false,
      );
    } on FormatException catch (_) {
      CustomSnackbar.show(
        context,
        "Error parsing server response.",
        isSuccess: false,
      );
    } catch (e) {
      CustomSnackbar.show(
        context,
        "Unexpected error: $e",
        isSuccess: false,
      );
    }
  }

  Future<void> scanEmployee() async {
    try {
      final getcode = await Navigator.push<String>(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MobileScannerPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration:
              const Duration(milliseconds: 300), // pop halus
        ),
      );

      if (!mounted) return;
      if (getcode == null || getcode.isEmpty || getcode == "-1") return;

      // 📌 Step 2: Validasi format QRCode Employee (8 digit)
      if (!RegExp(r'^\d{8}$').hasMatch(getcode)) {
        CustomSnackbar.show(
          context,
          "Invalid QR Code format. Must be 8 digits.",
          isSuccess: false,
        );

        return;
      }

      // 🔍 Step 3: Ambil detail employee
      final response = await http
          .get(Uri.parse("${AppConfig.baseUrl}/api/employee-detail/$getcode/"))
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw TimeoutException("Request timed out. Please try again.");
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (!data.containsKey('id_employee')) {
          if (!mounted) return;

          CustomSnackbar.show(
            context,
            "Invalid data from server",
            isSuccess: false,
          );

          return;
        }

        if (data['status'] == "02") {
          if (!mounted) return;
          CustomSnackbar.show(
            context,
            "Employee not Active",
            isSuccess: false,
          );

          return;
        }

        if (!mounted) return;
        setState(() {
          idEmployeeController.text = data['id_employee'].toString();
          photoEmployee = "${data["id_employee"].toString()}.png";
          nameEmployee = data['full_name'].toString();
          nameEmployee2 = data['full_name'].toString();
          nrp = data['nrp'].toString();
          division = data['division'].toString();
          section = data['section'].toString();
          jobProcess = "MOULDING";
          jobDate = DateTime.now().toLocal().toString();
          isEmployeeScanned = true;
        });
      } else if (response.statusCode == 404) {
        if (!mounted) return;
        CustomSnackbar.show(
          context,
          "Employee not found. Please add Employee to Database.",
          isSuccess: false,
        );
      } else {
        if (!mounted) return;
        CustomSnackbar.show(
          context,
          "Error: ${response.statusCode} - ${response.reasonPhrase}",
          isSuccess: false,
        );
      }
    } on TimeoutException catch (_) {
      CustomSnackbar.show(
        context,
        "Request timed out. Please try again.",
        isSuccess: false,
      );
    } on SocketException catch (_) {
      CustomSnackbar.show(
        context,
        "Network error. Please check your internet connection.",
        isSuccess: false,
      );
    } on FormatException catch (_) {
      CustomSnackbar.show(
        context,
        "Error parsing data from server.",
        isSuccess: false,
      );
    } catch (e) {
      CustomSnackbar.show(
        context,
        "Unexpected error: $e",
        isSuccess: false,
      );
    }
  }

  Future<bool> postRecordData(
    BuildContext context, {
    String? idRecordUpdate,
  }) async {
    try {
      // 🔹 Validasi kategori METAL PILL
      if (categoryProduct == "METAL PILL") {
        if (carbonPill == null && goldPill == null) {
          CustomSnackbar.show(
            context,
            "Harap isi Gold Pill atau Carbon Pill.",
            isSuccess: false,
          );
          return false;
        }
      }

      // 🔹 Validasi field penting sebelum kirim
      if (idEmployeeController.text.isEmpty ||
          idMachineController.text.isEmpty) {
        CustomSnackbar.show(
          context,
          "ID Employee dan Machine wajib diisi.",
          isSuccess: false,
        );
        return false;
      }

      // 🔹 Tentukan apakah POST (baru) atau PATCH (update)
      String method =
          (idRecordUpdate == null || idRecordUpdate.isEmpty) ? 'POST' : 'PATCH';

      // 🔹 Tentukan URL endpoint
      var urlString = "${AppConfig.baseUrl}/api/record-testing/";
      if (method == 'PATCH') {
        urlString += "?id_record=$idRecordUpdate";
      }
      var url = Uri.parse(urlString);

      // 🔹 Parsing angka
      var startQty = int.tryParse(qtyActualController.text) ?? 0;
      var moldCavity = int.tryParse(moldCavityController.text) ?? 1;

      // 🔹 Susun payload sesuai format Django
      var bodyData = {
        "id_employee": idEmployeeController.text,
        "id_mc": idMachineController.text,
        "id_proses": widget.idProses,
        "batch_number": batchNumber,
        "total_jobnumber": totalLotNumber,
        "details_record": [
          {
            "bcode": bcodeJobnumber,
            "jobnumber": jobNumberController.text,
            "lotnumber": lotNumber,
            "moldnumber": selectedMoldNumber,
            "moldcavity": moldCavity,
            "shoot_qty": 1, // = start_qty
            "total_shoot_qty": 0, // default awal
            "test_qty": startQty,
            "finish_qty": 0,
            "mix_lot_no": mixLotNumberController.text,
            "gold_pill": goldPill,
            "carbon_pill": carbonPill,
          }
        ]
      };

      // 🔹 Log debug untuk memastikan data yang dikirim
      debugPrint("📤 Sending $method to $url");
      debugPrint("Payload: ${jsonEncode(bodyData)}");

      // 🔹 Eksekusi HTTP request
      late http.Response response;
      if (method == 'POST') {
        response = await http
            .post(
              url,
              headers: {"Content-Type": "application/json"},
              body: jsonEncode(bodyData),
            )
            .timeout(const Duration(seconds: 15));
      } else {
        response = await http
            .patch(
              url,
              headers: {"Content-Type": "application/json"},
              body: jsonEncode(bodyData),
            )
            .timeout(const Duration(seconds: 15));
      }

      // 🔹 Evaluasi hasil response
      debugPrint("Response Code: ${response.statusCode}");
      debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = jsonDecode(response.body);
        CustomSnackbar.show(
          context,
          responseData["message"] ?? "Success",
          isSuccess: true,
        );
        return true;
      } else {
        CustomSnackbar.show(
          context,
          "Gagal (${response.statusCode}): ${response.body}",
          isSuccess: false,
        );
        return false;
      }
    } on TimeoutException {
      CustomSnackbar.show(
        context,
        "Request timeout, periksa koneksi jaringan.",
        isSuccess: false,
      );
      return false;
    } on SocketException {
      CustomSnackbar.show(
        context,
        "Tidak ada koneksi internet.",
        isSuccess: false,
      );
      return false;
    } catch (e, stackTrace) {
      debugPrint("❌ Exception: $e");
      debugPrint("StackTrace: $stackTrace");
      CustomSnackbar.show(
        context,
        "Terjadi kesalahan: $e",
        isSuccess: false,
      );
      return false;
    }
  }

  void resetForm() {
    setState(() {
      idEmployeeController.text = "";
      mixLotNumberController.text = "";
      idMachineController.text = "";
      goldPillController.text = "";
      carbonPillController.text = "";
      jobNumberController.text = "";
      drawNumberController.text = "";
      qtyLotController.text = "";
      qtyActualController.text = "";
      jobNumberController.text = "";
      moldCavityController.text = "";
      totalShotController.text = "";
      moldNumberController.text = "";
      photoEmployee = "employee.png";
      nameEmployee = "";
      nameEmployee2 = "OPERATOR NAME";
      nrp = "NRP";
      division = "Division";
      section = "Section";
      bcodeJobnumber = "";
      jobNumber = "";
      lotNumber = "";
      batchNumber = "";
      categoryProduct = "";
      totalLotNumber = "";
      lotNumber = "";
      drawNumber = "";
      typeProduct = "";
      lotQuantity = "";
      germanSilverLn = "";
      uedaUshinLn = "";
      materialLn = "";
      carbonLot = "";
      customer = "";
      cavity = "";
      totalShot = 0;
      strtotalShot = "";
      jobProcess = "";
      jobDate = "";
      nameMachine = "";
      areaMachine = "";
      typeMachine = "";
      totalShootView = "";
      dataNG.clear();
      ngTableData = List.from(dataNG);
      selectedMoldNumber = null;
      molds = [];
      isJobNumberScanned = false;
      isMixLotScanned = false;
      isMachineScanned = false;
      isEmployeeScanned = false;
    });
  }

  void calculateTotalShoot() {
    final int? cavity = int.tryParse(moldCavityController.text);
    final int? qtyLot = int.tryParse(qtyLotController.text);

    if (cavity != null && cavity > 0 && qtyLot != null) {
      final int totalShoot = (qtyLot / cavity).ceil(); // aman sekarang
      totalShotController.text = totalShoot.toString();
      totalShootView = totalShoot.toString();
      logPrint("Total shoot: $totalShoot");
    } else {
      totalShotController.text = '';
      totalShootView = '';
      logPrint("Cavity atau qtyLot belum valid");
    }
  }

  Future<void> fetchMoldsByDrawing(String drawingNumber) async {
    final url = '${AppConfig.baseUrl}/api/mold-list/by-drawing/$drawingNumber/';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          molds = data['results'];
          if (molds.isNotEmpty) {
            selectedMoldNumber = molds[0]['tool_number'].toString();
            moldCavityController.text =
                molds[0]['cavity'].toString(); // Ini ditambahin
            cavity = molds[0]['cavity'].toString();
          } else {
            selectedMoldNumber = null;
            moldCavityController.text = '';
            cavity = "";
          }
          logPrint("Molds Loaded: $molds");
          logPrint("Selected Mold Number: $selectedMoldNumber");
        });
      } else {
        throw Exception('Failed to load molds');
      }
    } catch (e) {
      logPrint('Error: $e');
    }
  }

  Future<List<MachineModelDropdown>> fetchMachineList() async {
    final response =
        await http.get(Uri.parse('${AppConfig.baseUrl}/api/machine-list-all/'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => MachineModelDropdown.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load machine list');
    }
  }

  Future<void> fetchEmployeeList() async {
    _isFetchingEmployee = true;
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/employee-list-search/'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        setState(() {
          _employeeList =
              jsonList.map((e) => EmployeeModel.fromJson(e)).toList();
        });
      } else {
        debugPrint("Failed to load employee list: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching employee list: $e");
    } finally {
      _isFetchingEmployee = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    double widthApp = MediaQuery.of(context).size.width;
    double heightApp = MediaQuery.of(context).size.height;
    double paddingTop = MediaQuery.of(context).padding.top;
    bool isTablet = widthApp > 600;

    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = kToolbarHeight + MediaQuery.of(context).padding.top;
    final bottomPadding = 16.0; // opsional

    final textStyle = GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );

    // Membuat AppBar dengan gradasi
    final myAppBar = customSubAppBar(
      context: context,
      title: widget.title,
      kode: widget.idProses,
      proses: "MOULDING",
      navigateToBuilder: (kode, proses) => Menu(kode: kode, proses: proses),
    );

    double heightBody = heightApp - paddingTop - myAppBar.preferredSize.height;

    return Scaffold(
      appBar: myAppBar,
      body: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(isTablet ? 5.0 : 3.0),
          scrollDirection: Axis.vertical,
          child: Column(children: [
            _container(
              child: AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText(
                    'Please be carefully for all process record...',
                    textStyle: textStyle.copyWith(
                      foreground: Paint()
                        ..shader = LinearGradient(
                          colors: [Colors.red, Colors.orange, Colors.yellow],
                        ).createShader(Rect.fromLTWH(0.0, 0.0, 300.0, 70.0)),
                    ),
                  ),
                  TyperAnimatedText(
                    'Keep spirit for get good result..',
                    textStyle: textStyle.copyWith(
                      foreground: Paint()
                        ..shader = LinearGradient(
                          colors: [
                            Colors.yellow.shade400, // terang dan kontras
                            Colors.orange.shade300,
                            Colors.red.shade300,
                          ],
                        ).createShader(Rect.fromLTWH(0.0, 0.0, 300.0, 70.0)),
                    ),
                  ),
                  TyperAnimatedText(
                    'Inform to leader if any problem as soon as!',
                    textStyle: textStyle.copyWith(
                      foreground: Paint()
                        ..shader = LinearGradient(
                          colors: [
                            Colors.yellow.shade400,
                            Colors.orange.shade600,
                            Colors.red.shade500,
                          ],
                        ).createShader(Rect.fromLTWH(0.0, 0.0, 300.0, 70.0)),
                    ),
                  ),
                ],
                repeatForever: true,
              ),
            ),

            SizedBox(height: 5.0),

            Container(
              width: widthApp,
              height: heightBody * 0.26,
              decoration: BoxDecoration(
                color: Color(0xFFEFF3FF),
                border: Border.all(
                  color: Colors.grey.shade300, // Warna garis
                  width: 2.0, // Lebar garis
                ),
                borderRadius: BorderRadius.all(Radius.circular(
                    8)), // Sudut container yang melengkung (opsional)
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          margin: EdgeInsets.symmetric(
                              horizontal: 2.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.shade600,
                              width: 0.5,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                flex: 6,
                                child: Container(
                                  margin: EdgeInsets.only(top: 5.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                        color: Colors.white, width: 2.0),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    child: Image.network(
                                      "${AppConfig.baseUrl}/media/img/employee/$photoEmployee",
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              // Container 30%
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: EdgeInsets.all(2.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        nameEmployee2,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade700,
                                          fontSize: isTablet
                                              ? constraints.maxWidth * 0.08
                                              : constraints.maxWidth * 0.08,
                                        ),
                                      ),
                                      SizedBox(height: 1.0),
                                      Text(
                                        nrp,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade700,
                                          fontSize: isTablet
                                              ? constraints.maxWidth * 0.06
                                              : constraints.maxWidth * 0.08,
                                        ),
                                      ),

                                      // <-- ToggleButtons ditambahkan di sini (RESPONSIVE VERSION)
                                    ],
                                  ),
                                ),
                              ),

                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: EdgeInsets.all(1.0),
                                  margin: EdgeInsets.only(bottom: 5.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        division,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w400,
                                          color: Colors.grey.shade700,
                                          fontSize: isTablet
                                              ? constraints.maxWidth * 0.06
                                              : constraints.maxWidth * 0.07,
                                        ),
                                      ),
                                      Text(
                                        section,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w400,
                                          color: Colors.grey.shade700,
                                          fontSize: isTablet
                                              ? constraints.maxWidth * 0.05
                                              : constraints.maxWidth * 0.07,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Container 60%
                  Expanded(
                    flex: 7, // 60%
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // double screenWidth = MediaQuery.of(context).size.width;
                        // double screenHeight = MediaQuery.of(context).size.height;

                        return Container(
                          height: constraints.maxHeight *
                              1, // Harus ada batas tinggi agar bisa scroll
                          margin: EdgeInsets.symmetric(
                              horizontal: isTablet ? 4.0 : 3.0,
                              vertical: isTablet ? 10.0 : 5.0),
                          padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 5.0 : 5.0,
                              vertical: isTablet ? 5.0 : 5.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                                // color: Colors.grey.shade300,
                                color: Colors.grey.shade600,
                                width: 0.5),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Table(
                              border: TableBorder(
                                bottom:
                                    BorderSide(color: Colors.grey, width: 1.0),
                                horizontalInside:
                                    BorderSide(color: Colors.grey, width: 0.5),
                              ),
                              columnWidths: {
                                0: FlexColumnWidth(0.4),
                                1: FlexColumnWidth(0.6),
                              },
                              children: List.generate(10, (index) {
                                final data = [
                                  ["JOB NUMBER", jobNumber],
                                  ["DATE", _formatDateTime(jobDate)],
                                  ["PROCESS", jobProcess],
                                  ["JOBCODE", batchNumber],
                                  ["LOT NUMBER", lotNumber],
                                  ["TOTAL LOT", totalLotNumber],
                                  ["CATEGORY", categoryProduct],
                                  ["TYPE", typeProduct],
                                  [
                                    "GOLD PILL LOT NO",
                                    "$germanSilverLn  $uedaUshinLn  $materialLn"
                                  ],
                                  ["CARBON PILL LOT NO", carbonLot],
                                ];

                                final Color rowColor = index % 2 == 0
                                    ? Colors.grey.shade100
                                    : Colors.white;

                                return TableRow(
                                  children: [
                                    // Kolom label
                                    Container(
                                      color: rowColor,
                                      padding: EdgeInsets.symmetric(
                                        vertical: isTablet ? 8.0 : 4.0,
                                        horizontal: isTablet ? 6.0 : 3.0,
                                      ),
                                      child: Text(
                                        data[index][0],
                                        style: GoogleFonts.poppins(
                                          fontWeight:
                                              data[index][0] == "JOB NUMBER"
                                                  ? FontWeight.bold
                                                  : FontWeight.w600,
                                          fontSize: isTablet
                                              ? constraints.maxWidth * 0.025
                                              : constraints.maxWidth * 0.045,
                                          color: Colors.blue.shade900,
                                        ),
                                      ),
                                    ),

                                    // Kolom value
                                    Container(
                                      color: rowColor,
                                      padding: EdgeInsets.symmetric(
                                        vertical: isTablet ? 8.0 : 4.0,
                                        horizontal: isTablet ? 6.0 : 3.0,
                                      ),
                                      child: Text(
                                        ": ${data[index][1]}",
                                        style: GoogleFonts.poppins(
                                          fontWeight:
                                              data[index][0] == "JOB NUMBER"
                                                  ? FontWeight.bold
                                                  : FontWeight.w500,
                                          fontSize: isTablet
                                              ? constraints.maxWidth * 0.025
                                              : constraints.maxWidth * 0.045,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 5.0),

            Container(
              width: widthApp,
              height: 180,
              // height: conTextfieldHeight,
              padding: EdgeInsets.all(isTablet ? 5.0 : 5.0),
              decoration: BoxDecoration(
                color: Color(0xFFEFF3FF),
                border: Border.all(
                  color: Colors.grey.shade300, // Warna garis
                  width: 2.0, // Lebar garis
                ),
                borderRadius: BorderRadius.all(Radius.circular(
                    8)), // Sudut container yang melengkung (opsional)
              ),
              child: Center(
                child: LayoutBuilder(builder: (context, constraints) {
                  int columnCount = constraints.maxWidth > 600 ? 4 : 2;
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 5),
                    alignment: Alignment.center,
                    width: constraints.maxWidth,
                    height: 150,
                    // height: constraints.maxHeight,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border.all(
                        color: Colors.grey.shade600,
                        width: 0.5, // Lebar garis
                      ),
                      borderRadius: BorderRadius.all(Radius.circular(
                          8)), // Sudut container yang melengkung (opsional)
                    ),
                    child: GridView.count(
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: columnCount,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 3.5,
                      shrinkWrap: true,
                      children: [
                        _buildTextField(
                          controller: jobNumberController,
                          label: "Job Number",
                          hint: "Scan Job Number",
                          icon: Icons.qr_code_scanner,
                          onIconTap: () => scanJobNumber(widget.idProses),
                          readOnly: true,
                        ),
                        _buildTextField(
                          controller: drawNumberController,
                          label: "Draw Number",
                          hint: "Enter Draw No",
                          readOnly: true,
                        ),
                        _buildTextField(
                          controller: moldCavityController,
                          label: "QTY Batch",
                          hint: "QTY Batch",
                          readOnly: true,
                        ),
                        _buildTextField(
                          controller: qtyLotController,
                          label: "QTY Actual",
                          hint: "QTY Actual",
                          readOnly: true,
                        ),
                        _buildTextField(
                          controller: idEmployeeController,
                          label: "Employee",
                          hint: "Scan Employee ID",
                          icon:
                              Icons.qr_code_scanner, // icon kiri untuk scan QR
                          onIconTap: scanEmployee, // aksi scan QR
                          readOnly: true,

                          suffixIcon: IconButton(
                            icon: Icon(Icons.person_search,
                                color: Colors.grey.shade600, size: 24),
                            onPressed: () => _showEmployeeDialog(context),
                          ),
                        ),
                        _buildTextField(
                          controller: totalShotController,
                          label: "Name Employee",
                          hint: "Name Employee",
                          readOnly: true,
                        ),
                        _buildTextField(
                          controller: qtyActualController,
                          label: "Division",
                          hint: "Division",
                          readOnly: true,
                        ),
                        _buildTextField(
                          controller: qtyActualController,
                          label: "Section",
                          hint: "Section",
                          readOnly: true,
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: SUBMIT action
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: Colors.blue.shade800,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'SUBMIT',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: CLEAR action
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        backgroundColor: Colors.red.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'CLEAR',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            //####################BATAS CONTAINER KE 3 DISINI ######################**************************************
            Container(
              padding: const EdgeInsets.all(5),
              color: Colors.grey.shade200,
              // Tinggi container = layar - appBar - padding
              height: screenHeight - appBarHeight - bottomPadding - 200,
              width: widthApp,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      minWidth: MediaQuery.of(context).size.width),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: widthApp,
                      child: DataTable(
                        columnSpacing: 20,
                        dataRowMinHeight: 70, // minimal tinggi row
                        dataRowMaxHeight: 100, // maksimal tinggi row
                        headingRowColor:
                            WidgetStateProperty.all(Colors.blue.shade800),
                        headingTextStyle: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        dataTextStyle: GoogleFonts.poppins(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        columns: const [
                          DataColumn(label: Text('NO')),
                          DataColumn(label: Text('NG NAME')),
                          DataColumn(label: Text('PHOTO')),
                          DataColumn(label: Text('QUANTITY')),
                        ],
                        rows: List<DataRow>.generate(15, (index) {
                          final quantityController =
                              TextEditingController(text: '0');

                          return DataRow(cells: [
                            DataCell(Text('${index + 1}')),
                            DataCell(SizedBox(
                                width: 250, // NG Name lebih lebar
                                child: Text('NG Name ${index + 1}'))),
                            DataCell(
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => Dialog(
                                      backgroundColor: Colors.transparent,
                                      child: InteractiveViewer(
                                        panEnabled: true,
                                        minScale: 0.5,
                                        maxScale: 3.0,
                                        child: Image.network(
                                          'https://picsum.photos/600?random=$index', // lebih besar
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.grey.shade300,
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          'https://picsum.photos/100?random=$index'), // thumbnail lebih besar
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            DataCell(Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove, size: 20),
                                  onPressed: () {
                                    int currentValue =
                                        int.tryParse(quantityController.text) ??
                                            0;
                                    if (currentValue > 0) {
                                      quantityController.text =
                                          (currentValue - 1).toString();
                                    }
                                  },
                                ),
                                SizedBox(
                                  width: 50,
                                  child: TextField(
                                    controller: quantityController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                      contentPadding: EdgeInsets.all(6),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, size: 20),
                                  onPressed: () {
                                    int currentValue =
                                        int.tryParse(quantityController.text) ??
                                            0;
                                    quantityController.text =
                                        (currentValue + 1).toString();
                                  },
                                ),
                              ],
                            )),
                          ]);
                        }),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 5.0),

            Container(
              // padding: EdgeInsets.all(5),
              width: widthApp,
              height: heightBody * 0.2,
              // color: Colors.grey.shade500,

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.grey, blurRadius: 4)],
              ),

              child: LayoutBuilder(builder: (context, constraints) {
                return Container(
                  width: constraints.maxWidth,
                  color: Colors.white,
                  child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Table(
                        border: TableBorder(
                          bottom: BorderSide(color: Colors.grey, width: 1.0),
                          horizontalInside:
                              BorderSide(color: Colors.grey, width: 0.5),
                        ),
                        columnWidths: {
                          0: FlexColumnWidth(
                              constraints.maxWidth * 0.4), // Kolom label
                          1: FlexColumnWidth(
                              constraints.maxWidth * 0.6), // Kolom tanda ":"
                        },
                        children: List.generate(6, (index) {
                          final dataBottom = [
                            ["MACHINE", nameMachine],
                            ["MACHINE AREA", areaMachine],
                            ["CUSTOMER", customer],
                            ["MOLD CAVITY", cavity],
                            ["TOTAL SHOT", totalShootView],
                            ["QTY LOT", lotQuantity],
                          ];

                          // Pastikan menggunakan data.length
                          // Warna selang-seling
                          final Color rowColor =
                              index % 2 == 0 ? Colors.grey[200]! : Colors.white;

                          return TableRow(
                            children: [
                              // Kolom 1: Label
                              Container(
                                color: rowColor,
                                padding: EdgeInsets.symmetric(
                                    vertical: isTablet ? 4.0 : 2.0,
                                    horizontal: isTablet ? 6.0 : 3.0),
                                child: Text(
                                  dataBottom[index]
                                      [0], // Label (misal "PROCESS")
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isTablet
                                        ? widthApp * 0.025
                                        : widthApp * 0.04,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ),
                              // Kolom 2: Tanda ":"

                              // Kolom 3: Isi Data
                              Container(
                                color: rowColor,
                                padding: EdgeInsets.symmetric(
                                    vertical: isTablet ? 4.0 : 2.0,
                                    horizontal: isTablet ? 6.0 : 3.0),
                                child: Text(
                                  ":${dataBottom[index][1]}", // Isi data (misal "MOULDING")
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.normal,
                                    fontSize: isTablet
                                        ? widthApp * 0.025
                                        : widthApp * 0.04,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
                      )),
                );
              }),
            ),
          ]),
        );
      }),
      //SINGLECHILDSCROLLVIEW SAMPAI SINI
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon, // nullable
    bool readOnly = false,
    VoidCallback? onIconTap,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixIcon,
  }) {
    final bool hasPrefixIcon = icon != null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        inputFormatters: inputFormatters,
        keyboardType:
            inputFormatters != null ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(
            fontSize: 14.0,
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
          border: const OutlineInputBorder(),
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: hasPrefixIcon ? 0 : 12,
            vertical: 12,
          ),
          prefixIcon: hasPrefixIcon
              ? Container(
                  width: 36,
                  height: 36,
                  margin:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade300,
                        Colors.blue.shade900,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: Colors.grey.shade500,
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: IconButton(
                    onPressed: onIconTap,
                    icon: Icon(
                      icon,
                      size: 20,
                      color: Colors
                          .white, // biar kontras dengan background gradient
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                )
              : null,
          suffixIcon: suffixIcon != null
              ? Container(
                  width: 36,
                  height: 36,
                  margin:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.grey.shade50,
                        Colors.grey.shade300,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: Colors.grey.shade400,
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: suffixIcon, // langsung panggil widget yang kamu pass
                )
              : null,
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey.shade500,
            fontStyle: FontStyle.italic,
            fontSize: 14.0,
          ),
        ),
        style: GoogleFonts.poppins(
          fontSize: 13.0,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _container({required Widget child, Color? color, double? height}) {
    return Container(
      height: height ?? 80,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color ?? Colors.indigo.shade400,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 5,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }

  void showMixLotDialog(BuildContext context) {
    TextEditingController tempController =
        TextEditingController(text: mixLotNumberController.text);
    bool isOkMixLotEnabled = tempController.text.length == 13;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Transform.translate(
          offset: const Offset(0, -90),
          child: StatefulBuilder(
            builder: (context, localSetState) {
              return Dialog(
                backgroundColor: Colors.blue.shade500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 15),
                    width: MediaQuery.of(context).size.width * 0.95,
                    height: MediaQuery.of(context).size.width * 0.4,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "ADD MIXING LOT NO",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // TextField
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: TextField(
                            controller: tempController,
                            inputFormatters: [MixLotFormatter()],
                            style: GoogleFonts.poppins(
                              fontSize: 14.0,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              hintText: "MIX LOT NO",
                              hintStyle: GoogleFonts.poppins(
                                color: Colors.grey.shade500,
                                fontStyle: FontStyle.italic,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                            onChanged: (value) {
                              localSetState(() {
                                isOkMixLotEnabled = value.length == 13;
                              });
                            },
                          ),
                        ),

                        const SizedBox(height: 20),
                        const Spacer(),

                        // Action Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // CANCEL
                            Expanded(
                              child: SizedBox(
                                height: 70,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: Colors.blue,
                                      width: 1,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(),
                                  child: Text(
                                    "CANCEL",
                                    style: GoogleFonts.poppins(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 16),

                            // OK
                            Expanded(
                              child: Container(
                                height: 70.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  gradient: isOkMixLotEnabled
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFF1976D2),
                                            Color(0xFF0D47A1)
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        )
                                      : const LinearGradient(
                                          colors: [
                                            Color(0xFFB0BEC5),
                                            Color(0xFF78909C)
                                          ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                ),
                                child: TextButton(
                                  onPressed: isOkMixLotEnabled
                                      ? () {
                                          final inputValue =
                                              tempController.text;
                                          Navigator.of(dialogContext).pop();
                                          setState(() {
                                            mixLotNumberController.text =
                                                inputValue;
                                            isMixLotScanned = true;
                                          });
                                        }
                                      : null,
                                  child: Text(
                                    "OK",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _showEmployeeDialog(BuildContext context) async {
    if (_employeeList.isEmpty && !_isFetchingEmployee) {
      await fetchEmployeeList();
    }

    if (_employeeList.isEmpty) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        "Data Employee belum tersedia.",
        isSuccess: false,
      );
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        EmployeeModel? _selectedEmployeeItem;
        bool isOkEmployeeEnabled = false;

        return StatefulBuilder(
          builder: (BuildContext dialogContext, StateSetter localSetState) {
            return Transform.translate(
              offset: const Offset(0, -90),
              child: Dialog(
                backgroundColor: Colors.blue.shade500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: Colors.white,
                  ),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 15),
                    width: MediaQuery.of(context).size.width * 0.95,
                    height: MediaQuery.of(context).size.width * 0.4,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "ADD OPERATOR",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 16),
                        DropdownSearch<EmployeeModel>(
                          items: (f, cs) => _employeeList,
                          itemAsString: (item) => item.fullName,
                          compareFn: (a, b) => a.idEmployee == b.idEmployee,
                          onChanged: (EmployeeModel? selected) {
                            localSetState(() {
                              _selectedEmployeeItem = selected;
                              isOkEmployeeEnabled = selected != null;
                            });
                          },
                          decoratorProps: const DropDownDecoratorProps(
                            decoration: InputDecoration(
                              labelText: "Pilih Operator",
                              hintText: "Nama Operator",
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 12),
                            ),
                          ),
                          popupProps: PopupProps.menu(
                            showSearchBox: true,
                            searchFieldProps: TextFieldProps(
                              inputFormatters: [
                                TextInputFormatter.withFunction(
                                  (oldValue, newValue) => TextEditingValue(
                                    text: newValue.text.toUpperCase(),
                                    selection: newValue.selection,
                                  ),
                                ),
                              ],
                              decoration: InputDecoration(
                                labelText: "Cari Operator",
                                hintText: "Ketik Nama Operator...",
                                prefixIcon: const Icon(Icons.search),
                                border: InputBorder.none,
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 18),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      const BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(
                                      color: Colors.blue, width: 2),
                                ),
                              ),
                            ),
                            itemBuilder: (context, EmployeeModel item,
                                isDisabled, isSelected) {
                              final photoUrl =
                                  '${AppConfig.baseUrl}/media/img/employee/${item.idEmployee}.png';

                              final List<Color> gradientColors = isSelected
                                  ? [
                                      const Color(0xFF1976D2),
                                      const Color(0xFF0D47A1)
                                    ]
                                  : [Colors.white, Colors.blue.shade50];

                              final Color titleColor = isSelected
                                  ? Colors.white
                                  : Colors.blue.shade800;
                              final Color subtitleColor = isSelected
                                  ? Colors.blue.shade200
                                  : Colors.grey.shade600;
                              final double elevation = isSelected ? 8 : 2;

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: isSelected
                                      ? BorderSide(
                                          color: Colors.lightBlue.shade300,
                                          width: 2.5)
                                      : BorderSide(
                                          color: Colors.grey.shade300,
                                          width: 1),
                                ),
                                elevation: elevation,
                                child: InkWell(
                                  onTap: () {
                                    localSetState(() {
                                      _selectedEmployeeItem = item;
                                      isOkEmployeeEnabled = true;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      gradient: LinearGradient(
                                        colors: gradientColors,
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 10),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          boxShadow: const [
                                            BoxShadow(
                                              color:
                                                  Color.fromRGBO(0, 0, 0, 0.3),
                                              blurRadius: 4,
                                              offset: Offset(2, 2),
                                            ),
                                          ],
                                        ),
                                        child: CircleAvatar(
                                          backgroundColor: isSelected
                                              ? Colors.white
                                              : Colors.blue.shade100,
                                          child: ClipOval(
                                            child: Image.network(
                                              photoUrl,
                                              fit: BoxFit.cover,
                                              width: 50,
                                              height: 50,
                                              errorBuilder: (context, error,
                                                      stackTrace) =>
                                                  Icon(
                                                Icons.person,
                                                size: 30,
                                                color: isSelected
                                                    ? Colors.blue.shade800
                                                    : Colors.grey.shade700,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        item.fullName,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16,
                                          color: titleColor,
                                        ),
                                      ),
                                      subtitle: Text(
                                        "NRP: ${item.nrp}",
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: subtitleColor,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                      trailing: isSelected
                                          ? Icon(Icons.check_circle,
                                              color: Colors.amber.shade300,
                                              size: 28)
                                          : null,
                                    ),
                                  ),
                                ),
                              );
                            },
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.8,
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.95,
                              minWidth:
                                  MediaQuery.of(context).size.width * 0.95,
                            ),
                            scrollbarProps: const ScrollbarProps(
                                trackVisibility: true, thumbVisibility: true),
                            menuProps: const MenuProps(
                              margin: EdgeInsets.only(top: 8),
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 70,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        color: Colors.blue, width: 1),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    "CANCEL",
                                    style: GoogleFonts.poppins(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                height: 70,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  gradient: isOkEmployeeEnabled
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFF1976D2),
                                            Color(0xFF0D47A1)
                                          ],
                                        )
                                      : const LinearGradient(
                                          colors: [
                                            Color(0xFFB0BEC5),
                                            Color(0xFF78909C)
                                          ],
                                        ),
                                ),
                                child: TextButton(
                                  onPressed: isOkEmployeeEnabled
                                      ? () {
                                          final selectedItem =
                                              _selectedEmployeeItem;
                                          Navigator.pop(dialogContext);

                                          if (selectedItem != null) {
                                            setState(() {
                                              idEmployeeController.text =
                                                  selectedItem.idEmployee;
                                              photoEmployee =
                                                  "${selectedItem.idEmployee}.png";
                                              nameEmployee =
                                                  selectedItem.fullName;
                                              nameEmployee2 =
                                                  selectedItem.fullName;
                                              nrp = selectedItem.nrp;
                                              division = selectedItem.division;
                                              section = selectedItem.section;
                                              jobProcess = "MOULDING";
                                              jobDate = DateTime.now()
                                                  .toLocal()
                                                  .toString();
                                              isEmployeeScanned = true;
                                            });
                                          }
                                        }
                                      : null,
                                  child: Text(
                                    "OK",
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class MixLotFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Ubah ke huruf besar dan hapus spasi
    String text = newValue.text.toUpperCase().replaceAll(' ', '');

    // Batasi maksimal 12 karakter
    if (text.length > 12) {
      text = text.substring(0, 12);
    }

    // Sisipkan spasi setelah 6 karakter
    if (text.length > 6) {
      text = '${text.substring(0, 6)} ${text.substring(6)}';
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
