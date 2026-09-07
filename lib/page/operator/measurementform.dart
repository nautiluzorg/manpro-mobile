import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/master/employee_model.dart';
import 'package:flutter_provider_data/model/machine_model_dropdown.dart';
import 'package:flutter_provider_data/page/menuform.dart';
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

class MeasurementForm extends StatefulWidget {
  final String title;
  final String idProses;

  const MeasurementForm({
    super.key,
    required this.title,
    required this.idProses,
  });

  @override
  State<MeasurementForm> createState() => _MeasurementFormState();
}

class _MeasurementFormState extends State<MeasurementForm> {
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

//FUNGCTION UNTUK MEMERIKSA STATUS DATA NG.
  void printNgTableData() {
    if (ngTableData.isEmpty) {
      logPrint('ngTableData is empty.');
    } else {
      for (var i = 0; i < ngTableData.length; i++) {
        logPrint('${i + 1}. Code: ${ngTableData[i]['code']}, '
            'Name: ${ngTableData[i]['name']}, '
            'Quantity: ${ngTableData[i]['quantity']}');
      }
    }
  }

  //FUNCTION BARU UNTUK MENAMBAHKAN ATAU MEMPERBARUI DATA NG
  void addOrUpdateNG(
      String code,
      String name,
      int quantity,
      String idRecordUpdate,
      String idEmployee,
      String jobNumber,
      int qtyShoot) {
    if (code.isEmpty || quantity <= 0) {
      return;
    }

    final existingIndex = dataNG.indexWhere((row) => row['id_ng'] == code);
    if (existingIndex != -1) {
      // Jika kode NG sudah ada, tambahkan kuantitas
      dataNG[existingIndex]['qty'] += quantity;
      // print('Updated existing item: ${dataNG[existingIndex]}');
    } else {
      // Jika tidak ada, tambahkan data baru ********
      dataNG.add({
        'id_ng': code,
        'ng_name': name,
        'qty': quantity,
        'id_record': idRecordUpdate,
        'id_employee': idEmployee,
        'jobnumber': jobNumber,
        'qty_shoot': qtyShoot
      });
      // print('Added new item: $code, $name, $quantity');
    }

    // Sinkronkan ngTableData dengan dataNG
    setState(() {
      ngTableData = List.from(dataNG);
      // print('Updated ngTableData: $ngTableData');
    });
  }

  void deleteNG(String code) {
    setState(() {
      dataNG.removeWhere((data) => data['id_ng'] == code);
      ngTableData = List.from(dataNG);
    });
  }

  @override
  void initState() {
    idEmployee = "";
    nameEmployee = "";
    nameEmployee2 = "Operator Name";
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
          "${AppConfig.baseUrl}/api/check-proses-jobnumber/$jobnumber/$idProses/");

      var statusResponse = await http.get(statusUrl).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException("Status request timed out.");
        },
      );

      if (statusResponse.statusCode == 200) {
        Map<String, dynamic> statusData = json.decode(statusResponse.body);

        bool exists = statusData['exists'] ?? false;
        String? runStatus = statusData['run_status'];
        String? idRecordUpdate = statusData['id_record'];
        String? mixLotNumber = statusData['mix_lot_no'];
        int totalShoot =
            int.tryParse(statusData['shoot_qty']?.toString() ?? '0') ?? 0;

        isAvailable = exists;

        if (runStatus == "completed") {
          if (!mounted) return;
          CustomSnackbar.show(
            context,
            "Jobnumber $jobnumber sudah finish.",
            isSuccess: false,
          );
          return;
        } else if (runStatus == "pending") {
          if (!mounted) return;
          CustomSnackbar.show(
            context,
            "Jobnumber $jobnumber masih kondisi Stop.",
            isSuccess: false,
          );
          return;
        }

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
                statusData['employee_finish']?['id_employee']?.toString() ?? '';

            goldPill = statusData['gold_pill']?['id'] != null
                ? statusData['gold_pill']['id'] as int
                : null;
            carbonPill = statusData['carbon_pill']?['id'] != null
                ? statusData['carbon_pill']['id'] as int
                : null;

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

            assignEmployee(statusData['employee_finish']);
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
      nameEmployee2 = 'Operator Name';
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
    if (!isMachineScanned) {
      CustomSnackbar.show(
        context,
        "Scan Machine terlebih dahulu.",
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

  Future<void> scanQRGoldPill() async {
    if (!isEmployeeScanned) {
      CustomSnackbar.show(
        context,
        "Scan Employee terlebih dahulu.",
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

      // 🔍 Step 2: Parsing JSON dari QRCode
      final decoded = json.decode(getcode);

      if (decoded is! Map<String, dynamic>) {
        CustomSnackbar.show(
          context,
          "QRCode salah, bukan QRCode Label Gold Pill.",
          isSuccess: false,
        );

        return;
      }

      // 📌 Step 3: Validasi type
      if (decoded['type'] != 'gold pill') {
        CustomSnackbar.show(
          context,
          "QR Code ini bukan untuk Gold Pill.",
          isSuccess: false,
        );

        return;
      }

      // 📌 Step 4: Validasi field penting
      if (!decoded.containsKey('id') || decoded['id'] == null) {
        CustomSnackbar.show(
          context,
          "QR Code tidak valid (missing ID).",
          isSuccess: false,
        );

        return;
      }

      if (decoded['id'] is! int) {
        CustomSnackbar.show(
          context,
          "QR Code ID tidak valid.",
          isSuccess: false,
        );

        return;
      }

      // ✅ Step 5: Set nilai ke state
      if (!mounted) return;
      setState(() {
        goldPill = decoded['id'];
        germanSilverLn = decoded['german_silver'] ?? "-";
        uedaUshinLn = decoded['ueda_ushin'] ?? "-";
        materialLn = decoded['material'] ?? "-";
        goldPillController.text = germanSilverLn;
      });

      logPrint('german silver : $germanSilverLn');
      logPrint('ueda ushin : $uedaUshinLn');
      logPrint('material : $materialLn');
    } on FormatException {
      CustomSnackbar.show(
        context,
        "Format QR Code salah.",
        isSuccess: false,
      );
    } catch (e) {
      CustomSnackbar.show(
        context,
        "Terjadi kesalahan: $e",
        isSuccess: false,
      );
    }
  }

  Future<void> scanQRCarbonPill() async {
    if (!isEmployeeScanned) {
      CustomSnackbar.show(
        context,
        "Scan Employee terlebih dahulu",
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

      // 🔍 Step 2: Parsing JSON dari QRCode
      final decoded = json.decode(getcode);

      if (decoded is! Map<String, dynamic>) {
        CustomSnackbar.show(
          context,
          "QRCode salah, bukan QRCode Carbon Pill.",
          isSuccess: false,
        );

        return;
      }

      // 📌 Step 3: Validasi type
      if (decoded['type'] != 'carbon pill') {
        CustomSnackbar.show(
          context,
          "QR Code ini bukan untuk Carbon Pill.",
          isSuccess: false,
        );

        return;
      }

      // 📌 Step 4: Validasi field penting
      if (!decoded.containsKey('id') || decoded['id'] == null) {
        CustomSnackbar.show(
          context,
          "QR Code tidak valid (missing ID).",
          isSuccess: false,
        );

        return;
      }

      if (decoded['id'] is! int) {
        CustomSnackbar.show(
          context,
          "QR Code ID tidak valid.",
          isSuccess: false,
        );

        return;
      }

      // ✅ Step 5: Set nilai ke state
      if (!mounted) return;
      setState(() {
        carbonPill = decoded['id'];
        carbonLot = decoded['carbon_lot'] ?? "-";
        carbonPillController.text = carbonLot;
      });

      logPrint('Carbon Lot       : $carbonLot');
    } on FormatException {
      CustomSnackbar.show(
        context,
        "Format QR Code salah..",
        isSuccess: false,
      );
    } catch (e) {
      CustomSnackbar.show(
        context,
        "Terjadi kesalahan: $e",
        isSuccess: false,
      );
    }
  }

  Future<bool> postRecordData(
    BuildContext context, {
    String? idRecordUpdate,
  }) async {
    try {
      //Validasi untuk category  METAL PILL
      if (categoryProduct == "METAL PILL") {
        if (carbonPill == null && goldPill == null) {
          CustomSnackbar.show(
            context,
            "Harap isi Gold Pill atau Carbon Pill.",
            isSuccess: false,
          );

          return false; // stop eksekusi function
        }
      }

      // Tentukan method berdasarkan apakah idRecordUpdate null atau tidak
      String method =
          (idRecordUpdate == null || idRecordUpdate.isEmpty) ? 'POST' : 'PATCH';

      // Siapkan URL endpoint
      var urlString = "${AppConfig.baseUrl}/api/record-create/";
      if (method == 'PATCH') {
        urlString += "?id_record=$idRecordUpdate";
      }

      var url = Uri.parse(urlString);

      var startQty = int.tryParse(qtyActualController.text) ?? 0;
      var moldCavity = int.tryParse(moldCavityController.text) ?? 1;

      // Buat body data
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
            "start_qty": startQty,
            "moldnumber": selectedMoldNumber,
            "moldcavity": moldCavity,
            "mix_lot_no": mixLotNumberController.text,
            "gold_pill": goldPill,
            "carbon_pill": carbonPill
          }
        ]
      };

// Optional: Jika kamu tetap ingin menyertakan ng_data hanya kalau isinya ada
      if (dataNG.isNotEmpty) {
        bodyData["ng_data"] = dataNG.map((item) {
          return {
            "id_ng": item["id_ng"],
            "qty": item["qty"],
            "id_record": item["id_record"],
            "id_employee_finish": item["id_employee"],
            "jobnumber": item["jobnumber"],
            "qty_shoot": item["qty_shoot"]
          };
        }).toList();
      }

      late http.Response response;
      if (method == 'POST') {
        response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(bodyData),
        );
      } else {
        response = await http.patch(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(bodyData),
        );
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseData = jsonDecode(response.body);

        CustomSnackbar.show(
          context,
          responseData["message"],
          isSuccess: true,
        );

        return true;
      } else {
        CustomSnackbar.show(
          context,
          "Failed: ${response.body}",
          isSuccess: false,
        );

        return false;
      }
    } catch (e) {
      CustomSnackbar.show(
        context,
        "An error occurred: $e",
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
      nameEmployee2 = "Operator Name";
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
    // double screenWidth = MediaQuery.of(context).size.width;

    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = kToolbarHeight + MediaQuery.of(context).padding.top;
    final bottomPadding = 16.0; // opsional

    // Membuat AppBar dengan gradasi
    final myAppBar = PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight), // Ukuran AppBar
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.blue.shade800], // Gradasi warna
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: AppBar(
          title: Text(
            'MEASUREMENT RECORD',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 26.0,
              fontWeight: FontWeight.w600, // bisa bold atau semi-bold
            ),
          ),

          leading: IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) =>
                      MenuForm(title: "FORM RECORD", idProses: "001"),
                  transitionsBuilder: (_, animation, __, child) =>
                      FadeTransition(opacity: animation, child: child),
                  transitionDuration: const Duration(milliseconds: 800),
                ),
              );
            },
          ),
          centerTitle: true,
          backgroundColor:
              Colors.transparent, // Menjadikan background AppBar transparan
        ),
      ),
    );

    double heightBody = heightApp - paddingTop - myAppBar.preferredSize.height;

    // double conTextfieldHeight = isTablet ? heightBody * 0.2 : heightBody * 0.55;

// Deklarasi controller satu per satu

    return Scaffold(
      appBar: myAppBar,
      body: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(isTablet ? 5.0 : 3.0),
          scrollDirection: Axis.vertical,
          child: Column(children: [
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
                                horizontal: isTablet ? 5.0 : 3.0,
                                vertical: isTablet ? 10.0 : 5.0),
                            padding: EdgeInsets.all(isTablet ? 5.0 : 3.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey.shade600, // Warna garis
                                width: 0.5, // Lebar garis
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(
                                  5)), // Sudut container yang melengkung (opsional)
                            ),
                            child: Column(
                              children: [
                                // Container 70%
                                Expanded(
                                  flex: 6, // 70% dari parent
                                  child: Container(
                                    height: constraints.maxHeight * 0.70,
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
                                  flex: 4, // 30% dari parent
                                  child: Container(
                                    padding: EdgeInsets.all(5.0),
                                    height: constraints.maxHeight * 0.30,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          nameEmployee2,
                                          style: TextStyle(
                                            fontSize: isTablet
                                                ? constraints.maxWidth * 0.08
                                                : constraints.maxWidth * 0.08,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        SizedBox(height: 1.0),
                                        Text(
                                          nrp,
                                          style: TextStyle(
                                            fontSize: isTablet
                                                ? constraints.maxWidth * 0.06
                                                : constraints.maxWidth * 0.08,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        SizedBox(height: 1.0),
                                        Text(
                                          division,
                                          style: TextStyle(
                                            fontSize: isTablet
                                                ? constraints.maxWidth * 0.05
                                                : constraints.maxWidth * 0.07,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        Text(
                                          section,
                                          style: TextStyle(
                                            fontSize: isTablet
                                                ? constraints.maxWidth * 0.05
                                                : constraints.maxWidth * 0.07,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ));
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
                              children: List.generate(7, (index) {
                                final data = [
                                  ["PROCESS", jobProcess],
                                  ["DATE", _formatDateTime(jobDate)],
                                  ["MACHINE OVEN", jobNumber],
                                  ["TOTAL JOBNUMBER", totalLotNumber],
                                  ["TEMPERATURE", categoryProduct],
                                  ["OVEN DURATION", typeProduct],
                                  ["PRESSURE", carbonLot],
                                ];

                                final Color rowColor = index % 2 == 0
                                    ? Colors.grey.shade100
                                    // ? Color.fromARGB(255, 207, 228, 247)
                                    : Colors.white;

                                return TableRow(
                                  children: [
                                    // Kolom label
                                    Container(
                                      color: rowColor,
                                      padding: EdgeInsets.symmetric(
                                          vertical: isTablet ? 8.0 : 4.0,
                                          horizontal: isTablet ? 6.0 : 3.0),
                                      child: Text(
                                        data[index][0],
                                        style: TextStyle(
                                          fontWeight:
                                              data[index][0] == "JOB NUMBER"
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                          fontSize: isTablet
                                              ? constraints.maxWidth * 0.025
                                              : constraints.maxWidth * 0.045,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                    // Kolom value
                                    Container(
                                      color: rowColor,
                                      padding: EdgeInsets.symmetric(
                                          vertical: isTablet ? 8.0 : 4.0,
                                          horizontal: isTablet ? 6.0 : 3.0),
                                      child: Text(
                                        ":${data[index][1]}",
                                        style: TextStyle(
                                          fontWeight: data[index][0] ==
                                                  "JOB NUMBER"
                                              ? FontWeight
                                                  .bold // ✅ value jobNumber juga bold
                                              : FontWeight.normal,
                                          fontSize: isTablet
                                              ? constraints.maxWidth * 0.025
                                              : constraints.maxWidth * 0.045,
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
                    padding: EdgeInsets.all(5.0),
                    alignment: Alignment.center,
                    // color: Colors.grey.shade200,
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
                          onIconTap: () => scanJobNumber('001'),
                          readOnly: true,
                        ),
                        _buildTextField(
                          controller: idMachineController,
                          label: "Machine",
                          hint: "Scan Machine ID",
                          icon:
                              Icons.qr_code_scanner, // icon kiri untuk scan QR
                          onIconTap: scanMachine, // aksi scan QR
                          readOnly: true,
                          suffixIcon: IconButton(
                            icon: Icon(Icons.search,
                                color: Colors.grey.shade600,
                                size: 24), // icon kanan untuk input manual

                            onPressed: () async {
                              if (!isMixLotScanned) {
                                if (!mounted) return;
                                CustomSnackbar.show(
                                  context,
                                  "Mohon Input Mix Lot No terlebih dahulu.",
                                  isSuccess: false,
                                );
                                return; // keluar, dialog tidak dibuka
                              }

                              List<MachineModelDropdown> machineList = [];
                              // bool _isSelectingMachine = false;
                              MachineModelDropdown? selectedMachineItem;

                              try {
                                machineList = await fetchMachineList();
                              } catch (e) {
                                logPrint("Error fetching machines: $e");
                              }

                              if (!mounted) return;

                              // ... (Bagian sebelum showDialog)

                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => StatefulBuilder(
                                  builder: (BuildContext dialogContext,
                                      StateSetter localSetState) {
                                    // PENTING: Gunakan _selectedMachineItem (variabel lokal) di sini.

                                    return Transform.translate(
                                      offset: const Offset(0, -90),
                                      child: Dialog(
                                        child: Container(
                                          padding: EdgeInsets.all(5),

                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.95,

                                          // >> REVISI TINGGI DI SINI: Tingkatkan tinggi menjadi 50% atau lebih dari lebar layar
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.4,
                                          child: Container(
                                            padding: EdgeInsets.all(10),
                                            // ... (Padding & Column)
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // ... (Text "CHOOSE MACHINE")
                                                const SizedBox(height: 16),

                                                // ... (Kode Anda sebelum DropdownSearch)

                                                DropdownSearch<
                                                    MachineModelDropdown>(
                                                  items: (f, cs) => machineList,
                                                  itemAsString: (item) =>
                                                      item.nmMc,
                                                  compareFn: (a, b) =>
                                                      a.idMc == b.idMc,

                                                  onChanged:
                                                      (MachineModelDropdown?
                                                          selected) {
                                                    if (selected != null) {
                                                      localSetState(() {
                                                        selectedMachineItem =
                                                            selected;
                                                      });
                                                    }
                                                  },

                                                  // START: REVISI UI DECORATION
                                                  decoratorProps:
                                                      const DropDownDecoratorProps(
                                                    decoration: InputDecoration(
                                                      labelText:
                                                          "Pilih Machine",
                                                      hintText: "Nama Machine",
                                                      border:
                                                          OutlineInputBorder(
                                                        borderRadius: BorderRadius
                                                            .all(Radius.circular(
                                                                10.0)), // Sudut membulat
                                                        borderSide: BorderSide(
                                                            color: Colors
                                                                .blueAccent,
                                                            width:
                                                                2), // Garis tebal
                                                      ),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10.0)),
                                                        borderSide: BorderSide(
                                                            color: Colors.grey,
                                                            width: 1.0),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    10.0)),
                                                        borderSide: BorderSide(
                                                            color: Colors.blue,
                                                            width:
                                                                2.0), // Fokus warna biru
                                                      ),
                                                      isDense: true,
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 16,
                                                              vertical:
                                                                  12), // Padding lebih besar
                                                    ),
                                                  ),
                                                  // END: REVISI UI DECORATION

                                                  popupProps: PopupProps.menu(
                                                    showSearchBox: true,
                                                    // UI Search Field juga dibuat lebih keren
                                                    searchFieldProps:
                                                        TextFieldProps(
                                                      decoration:
                                                          InputDecoration(
                                                        labelText:
                                                            "Cari Machine",
                                                        hintText:
                                                            "Ketik nama Machine...",
                                                        prefixIcon: const Icon(
                                                            Icons.search,
                                                            color: Colors
                                                                .blueAccent),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                        ),
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 16,
                                                                vertical: 10),
                                                      ),
                                                      textCapitalization:
                                                          TextCapitalization
                                                              .characters,
                                                      keyboardType:
                                                          TextInputType.text,
                                                    ),

                                                    // START: REVISI ITEM BUILDER (Paling Penting untuk tampilan list)
                                                    itemBuilder: (context,
                                                        MachineModelDropdown
                                                            item,
                                                        bool isSelected,
                                                        bool isDisabled) {
                                                      return Container(
                                                        margin: const EdgeInsets
                                                            .symmetric(
                                                            vertical: 4.0,
                                                            horizontal: 8.0),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: isSelected
                                                              ? Colors
                                                                  .blue.shade50
                                                              : Colors
                                                                  .white, // Warna latar belakang saat dipilih
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors.grey
                                                                  .shade200,
                                                              spreadRadius: 1,
                                                              blurRadius: 3,
                                                              offset:
                                                                  const Offset(
                                                                      0, 2),
                                                            ),
                                                          ],
                                                          border: isSelected
                                                              ? Border.all(
                                                                  color: Colors
                                                                      .blueAccent,
                                                                  width: 2)
                                                              : null, // Border saat terpilih
                                                        ),
                                                        child: ListTile(
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      16,
                                                                  vertical: 8),
                                                          leading: CircleAvatar(
                                                            backgroundColor: Colors
                                                                .blueAccent, // Warna biru modern
                                                            child: Text(
                                                              item.idMc.length >=
                                                                      2
                                                                  ? item.idMc
                                                                      .substring(
                                                                          item.idMc.length -
                                                                              2)
                                                                  : item.idMc,
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ),
                                                          title: Text(
                                                            item.nmMc,
                                                            style:
                                                                const TextStyle(
                                                              fontSize: 16,
                                                              fontWeight: FontWeight
                                                                  .w600, // Lebih tebal
                                                              color: Colors
                                                                  .black87,
                                                            ),
                                                          ),
                                                          subtitle: Text(
                                                            "ID: ${item.idMc}",
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Colors.grey
                                                                  .shade600,
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic,
                                                            ),
                                                          ),
                                                          trailing: isSelected
                                                              ? const Icon(
                                                                  Icons
                                                                      .check_circle_rounded,
                                                                  color: Colors
                                                                      .green)
                                                              : null,
                                                          // Hapus onTap
                                                        ),
                                                      );
                                                    },
                                                    // END: REVISI ITEM BUILDER

                                                    // Perbaikan: Konstrain agar list item terlihat

                                                    constraints: BoxConstraints(
                                                      // Atur tinggi seperti sebelumnya
                                                      maxHeight:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.7,

                                                      // **Mengatur Lebar Maksimum (Misalnya 80% dari lebar layar)**
                                                      maxWidth:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.90,

                                                      // Mengatur Lebar Minimum (Jika diperlukan)
                                                      // minWidth: 300,
                                                    ),

                                                    scrollbarProps:
                                                        const ScrollbarProps(
                                                      trackVisibility: true,
                                                      thumbVisibility: true,
                                                      thickness:
                                                          6, // Thumb lebih tebal
                                                      radius:
                                                          Radius.circular(3),
                                                    ),

                                                    menuProps: MenuProps(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              top: 10),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12), // Sudut lebih membulat
                                                              side: BorderSide(
                                                                  color: Colors
                                                                      .grey
                                                                      .shade300)),
                                                      elevation:
                                                          8, // Bayangan lebih jelas
                                                    ),
                                                  ),
                                                ),

                                                const SizedBox(height: 20),
                                                // ... (Lanjutan kode Anda setelah DropdownSearch)

                                                const SizedBox(height: 20),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween, // Pastikan ada jarak antara tombol
                                                  children: [
                                                    // START: TOMBOL CANCEL (Revisi/Penambahan)
                                                    Expanded(
                                                      child: Container(
                                                        height: 70.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  10), // Sudut membulat
                                                          // Gunakan warna abu-abu/netral untuk Cancel
                                                          gradient:
                                                              const LinearGradient(
                                                            colors: [
                                                              Color(0xFFB0BEC5),
                                                              Color(0xFF78909C)
                                                            ], // Abu-abu netral
                                                            begin: Alignment
                                                                .topCenter,
                                                            end: Alignment
                                                                .bottomCenter,
                                                          ),
                                                        ),
                                                        child: TextButton(
                                                          // Hanya menutup dialog tanpa menyimpan perubahan
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                  dialogContext),
                                                          child: const Text(
                                                            "Cancel",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),

                                                    const SizedBox(
                                                        width:
                                                            16), // Tambahkan jarak yang bagus

                                                    // START: TOMBOL OK
                                                    Expanded(
                                                      child: Container(
                                                        height: 70.0,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                  10), // Sudut membulat
                                                          // Gunakan warna biru/primer Anda
                                                          gradient:
                                                              const LinearGradient(
                                                            colors: [
                                                              Color(0xFF1976D2),
                                                              Color(0xFF0D47A1)
                                                            ],
                                                            begin: Alignment
                                                                .topCenter,
                                                            end: Alignment
                                                                .bottomCenter,
                                                          ),
                                                        ),
                                                        child: TextButton(
                                                          onPressed: () {
                                                            if (selectedMachineItem !=
                                                                null) {
                                                              // Panggil setState() dari State Class untuk memperbarui UI utama
                                                              setState(() {
                                                                idMachineController
                                                                        .text =
                                                                    selectedMachineItem!
                                                                        .idMc;
                                                                areaMachine =
                                                                    selectedMachineItem!
                                                                        .areaMc;
                                                                typeMachine =
                                                                    selectedMachineItem!
                                                                        .categoryMc;
                                                                jobProcess =
                                                                    "MOULDING";
                                                                jobDate = DateTime
                                                                        .now()
                                                                    .toLocal()
                                                                    .toString();
                                                                isMachineScanned =
                                                                    true;
                                                              });
                                                            }
                                                            // Tutup Dialog setelah tombol OK ditekan
                                                            Navigator.pop(
                                                                dialogContext);
                                                          },
                                                          child: const Text(
                                                            "OK",
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    // END: TOMBOL OK
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
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
                                color: Colors.grey.shade600,
                                size: 24), // icon kanan untuk input manual
                            onPressed: () async {
                              if (!isMachineScanned) {
                                if (!mounted) return;
                                CustomSnackbar.show(
                                  context,
                                  "Mohon Input Machine terlebih dahulu.",
                                  isSuccess: false,
                                );
                                return; // keluar, dialog tidak dibuka
                              }

                              // buka dialog input manual

                              if (_employeeList.isEmpty &&
                                  !_isFetchingEmployee) {
                                await fetchEmployeeList(); // tunggu data muncul dulu
                              }

                              if (!mounted) return;

                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (_) => Transform.translate(
                                  offset:
                                      const Offset(0, -90), // naikkan dialog
                                  child: Dialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.white,
                                      ),
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 20, 20, 10),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text(
                                            "Pilih Employee",
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          DropdownSearch<EmployeeModel>(
                                            items: (f, cs) => _employeeList,
                                            itemAsString:
                                                (EmployeeModel? item) =>
                                                    item?.fullName ?? '',
                                            compareFn: (EmployeeModel? a,
                                                    EmployeeModel? b) =>
                                                a?.idEmployee == b?.idEmployee,
                                            onChanged:
                                                (EmployeeModel? selected) {
                                              if (selected != null) {
                                                setState(() {
                                                  selectedEmployeeItem =
                                                      selected;
                                                });
                                              }
                                            },
                                            decoratorProps:
                                                const DropDownDecoratorProps(
                                              decoration: InputDecoration(
                                                labelText: "Pilih Employee",
                                                hintText: "Nama Employee",
                                                border: OutlineInputBorder(),
                                                isDense: true,
                                                contentPadding: EdgeInsets.only(
                                                    left: 5,
                                                    top: 10,
                                                    bottom: 10,
                                                    right: 8),
                                              ),
                                            ),
                                            popupProps: PopupProps.menu(
                                              showSearchBox: true,
                                              searchFieldProps: TextFieldProps(
                                                decoration: InputDecoration(
                                                  labelText: "Cari Operator",
                                                  hintText:
                                                      "Ketik nama Operator...",
                                                  prefixIcon:
                                                      const Icon(Icons.search),
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                              itemBuilder: (context,
                                                  EmployeeModel item,
                                                  isDisabled,
                                                  isSelected) {
                                                final photoUrl =
                                                    '${AppConfig.baseUrl}/media/img/employee/${item.idEmployee}.png';
                                                return Card(
                                                  margin: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 4,
                                                      horizontal: 10),
                                                  shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  elevation: 2,
                                                  child: ListTile(
                                                    leading: CircleAvatar(
                                                      backgroundColor:
                                                          Colors.blue.shade200,
                                                      backgroundImage:
                                                          NetworkImage(
                                                              photoUrl),
                                                      onBackgroundImageError:
                                                          (_, __) {
                                                        // fallback jika image gagal
                                                      },
                                                    ),
                                                    title: Text(
                                                      item.fullName,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.blueGrey,
                                                      ),
                                                    ),
                                                    subtitle: Text(
                                                      item.nrp,
                                                      style: const TextStyle(
                                                          color:
                                                              Colors.blueGrey),
                                                    ),
                                                    onTap: () {
                                                      if (!mounted) return;
                                                      setState(() {
                                                        selectedEmployeeItem =
                                                            item;
                                                      });
                                                    },
                                                  ),
                                                );
                                              },
                                              constraints: BoxConstraints(
                                                maxHeight:
                                                    MediaQuery.of(context)
                                                            .size
                                                            .height *
                                                        0.8,
                                                maxWidth: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.95,
                                                minWidth: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.95,
                                              ),
                                              scrollbarProps:
                                                  const ScrollbarProps(
                                                trackVisibility: true,
                                                thumbVisibility: true,
                                              ),
                                              menuProps: const MenuProps(
                                                margin: EdgeInsets.only(top: 8),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(5)),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              // Tombol Close
                                              Expanded(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    gradient:
                                                        const LinearGradient(
                                                      colors: [
                                                        Color(0xFFE53935),
                                                        Color(0xFFB71C1C)
                                                      ],
                                                    ),
                                                  ),
                                                  child: TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: const Text(
                                                      "Close",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              // Tombol OK
                                              Expanded(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                    gradient:
                                                        const LinearGradient(
                                                      colors: [
                                                        Color(0xFF1976D2),
                                                        Color(0xFF0D47A1)
                                                      ],
                                                    ),
                                                  ),
                                                  child: TextButton(
                                                    onPressed: () {
                                                      if (selectedEmployeeItem !=
                                                          null) {
                                                        // setState sama seperti scan QR employee
                                                        setState(() {
                                                          idEmployeeController
                                                                  .text =
                                                              selectedEmployeeItem!
                                                                  .idEmployee;
                                                          photoEmployee =
                                                              "${selectedEmployeeItem!.idEmployee}.png";
                                                          nameEmployee =
                                                              selectedEmployeeItem!
                                                                  .fullName;
                                                          nameEmployee2 =
                                                              selectedEmployeeItem!
                                                                  .fullName;
                                                          nrp =
                                                              selectedEmployeeItem!
                                                                  .nrp;
                                                          division =
                                                              selectedEmployeeItem!
                                                                  .division;
                                                          section =
                                                              selectedEmployeeItem!
                                                                  .section;
                                                          jobProcess =
                                                              "MOULDING";
                                                          jobDate =
                                                              DateTime.now()
                                                                  .toLocal()
                                                                  .toString();
                                                          isEmployeeScanned =
                                                              true;
                                                        });
                                                      }
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Text(
                                                      "OK",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
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
                          ),
                        ),
                        _buildTextField(
                          controller: drawNumberController,
                          label: "Draw Number",
                          hint: "Enter Draw No",
                          readOnly: true,
                        ),
                        _buildTextField(
                          controller: qtyLotController,
                          label: "Qty",
                          hint: "Enter Qty",
                          readOnly: true,
                        ),
                        _buildTextField(
                          controller: moldCavityController,
                          label: "Curing Time",
                          hint: "Enter Curing Time",
                          readOnly: true,
                        ),
                        _buildTextField(
                          controller: totalShotController,
                          label: "Temperature",
                          hint: "Enter Temperature",
                          readOnly: true,
                        ),
                        _buildTextField(
                          controller: totalShotController,
                          label: "Pressure",
                          hint: "Enter Pressure",
                          readOnly: true,
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: 5.0),
            //####################BATAS CONTAINER KE 3 DISINI ######################**************************************

            Container(
                width: widthApp,
                height: heightBody * 0.1,
                color: Colors.grey,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        flex: 6,
                        child: LayoutBuilder(builder: (context, constraints) {
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 2.0, vertical: 2.0),
                                width: constraints.maxWidth * 0.5,
                                height: constraints.maxHeight * 0.9,
                                color: Colors.white,
                                child: SizedBox.expand(
                                    // Mengisi seluruh container
                                    child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.blue,
                                        Colors.blue.shade800
                                      ], // Gradasi biru
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        15), // Radius untuk sudut tombol
                                    border: Border.all(
                                      color: Colors
                                          .transparent, // Tidak ada border solid langsung di Container
                                      width: 1, // Ketebalan border
                                    ),
                                  ),
                                  child:
                                      // Tambahkan di class widget

                                      // Button Submit
                                      Ink(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: OutlinedButton.icon(
                                      label: Text(
                                        isSubmitting
                                            ? "SUBMITTING..."
                                            : "SUBMIT", // feedback ke user
                                        style: TextStyle(
                                          color: isSubmitting
                                              ? Colors.grey[400]
                                              : Colors.white, // beda warna
                                          fontSize: isTablet ? 25.0 : 16.0,
                                        ),
                                      ),
                                      onPressed: isSubmitting
                                          ? null // disable button saat submit
                                          : () async {
                                              if (idEmployeeController
                                                      .text.isEmpty ||
                                                  idMachineController
                                                      .text.isEmpty ||
                                                  mixLotNumberController
                                                      .text.isEmpty) {
                                                CustomSnackbar.show(
                                                  context,
                                                  "Please complete QRCode Scanning.",
                                                  isSuccess: false,
                                                );

                                                return;
                                              }

                                              setState(() {
                                                isSubmitting =
                                                    true; // mulai submit
                                              });

                                              bool isSuccess =
                                                  await postRecordData(
                                                context,
                                                idRecordUpdate: idRecUpdate,
                                              );

                                              if (isSuccess) {
                                                resetForm(); // reset hanya jika submit berhasil
                                                setState(() {
                                                  idRecUpdate = null;
                                                });
                                              }

                                              setState(() {
                                                isSubmitting =
                                                    false; // selesai submit, enable button lagi
                                              });
                                            },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        side: BorderSide(
                                          color: Colors.transparent,
                                          width: 0,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                      ),
                                    ),
                                  ),
                                )),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 2.0, vertical: 2.0),
                                width: constraints.maxWidth * 0.5,
                                height: constraints.maxHeight * 0.9,
                                color: Colors.white,
                                child: SizedBox.expand(
                                  child: OutlinedButton.icon(
                                    label: Text(
                                      "CLEAR",
                                      style: TextStyle(
                                        color: Colors.blue
                                            .shade800, // Bisa diganti sesuai selera
                                        fontSize: isTablet ? 25.0 : 16.0,
                                      ),
                                    ),
                                    onPressed: () {
                                      resetForm();
                                    },
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(
                                        color: Colors
                                            .blue.shade600, // Warna border
                                        width: 2,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.redAccent,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        })),
                    Expanded(
                        flex: 4,
                        child: LayoutBuilder(builder: (context, constraints) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 2.0, vertical: 2.0),
                            width: constraints.maxWidth,
                            height: constraints.maxHeight * 0.9,
                            color: Colors.white,
                            child: SizedBox.expand(
                                // Mengisi seluruh container
                                child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.green.shade400,
                                    Colors.green.shade800
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(
                                    15), // Radius untuk sudut tombol
                                border: Border.all(
                                  color: Colors
                                      .transparent, // Tidak ada border solid langsung di Container
                                  width: 1, // Ketebalan border
                                ),
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      15), // Sudut melengkung pada border
                                ),
                                child: OutlinedButton.icon(
                                  label: Text(
                                    "CALCULATE",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isTablet ? 45.0 : 16.0,
                                    ),
                                  ),
                                  onPressed: () {
                                    if (bcodeJobnumber.isEmpty) {
                                      // Menampilkan snackbar jika _bcodeControllers.text kosong

                                      CustomSnackbar.show(
                                        context,
                                        "PLEASE SCAN JOBNUMBER FIRST!.",
                                        isSuccess: false,
                                      );
                                    } else {
                                      if (isAvailable) {
                                        // Jika _isFinish true, buka dialog full screen
                                      } else {
                                        // Jika _isFinish false, tampilkan snackbar

                                        CustomSnackbar.show(
                                          context,
                                          "START PROSES TIDAK BISA MENAMBAHKAN DATA NG.",
                                          isSuccess: false,
                                        );
                                      }
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    // Menghilangkan background yang solid karena sudah menggunakan gradasi dari Container
                                    foregroundColor: Colors.white,
                                    side: BorderSide(
                                      color: Colors
                                          .transparent, // Border tidak terlihat di OutlinedButton
                                      width:
                                          0, // Border normal tidak diperlukan
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          15), // Sudut melengkung pada border
                                    ),
                                  ),
                                ),
                              ),
                            )),
                          );
                        }))
                  ],
                )),

            SizedBox(height: 5.0),
            Container(
              padding: const EdgeInsets.all(5),
              color: Colors.grey.shade200,
              height: screenHeight - appBarHeight - bottomPadding - 200,
              width: widthApp,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: widthApp,
                  child: Column(
                    children: [
                      // Header
                      Table(
                        border: TableBorder.all(color: Colors.grey),
                        columnWidths: const {
                          0: FixedColumnWidth(40),
                          1: FlexColumnWidth(),
                          2: FixedColumnWidth(80),
                          3: FixedColumnWidth(80),
                          4: FixedColumnWidth(80),
                          5: FixedColumnWidth(75),
                        },
                        children: [
                          TableRow(
                            decoration:
                                BoxDecoration(color: Colors.blue.shade800),
                            children: const [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('NO',
                                    style: TextStyle(color: Colors.white)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('MEASUREMENT CHECK POINT',
                                    style: TextStyle(color: Colors.white)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'SPEC HIGH',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'SPEC LOW',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('ACTUAL',
                                    style: TextStyle(color: Colors.white)),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('RESULT',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Rows
                      Column(
                        children: List.generate(10, (index) {
                          final actualController =
                              TextEditingController(text: '');
                          final resultDummy = index % 2 == 0 ? 'OK' : 'NO';
                          return Table(
                            border:
                                TableBorder.all(color: Colors.grey.shade300),
                            columnWidths: const {
                              0: FixedColumnWidth(40),
                              1: FlexColumnWidth(),
                              2: FixedColumnWidth(80),
                              3: FixedColumnWidth(80),
                              4: FixedColumnWidth(80),
                              5: FixedColumnWidth(75),
                            },
                            children: [
                              TableRow(children: [
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text('${index + 1}'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text('Measurement ${index + 1}'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text('${100 + index}'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text('${90 + index}'),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: SizedBox(
                                    width: 60,
                                    child: TextField(
                                      controller: actualController,
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                        contentPadding: EdgeInsets.all(6),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Center(
                                    child: Text(
                                      resultDummy,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: resultDummy == 'OK'
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ]),
                            ],
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            )
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
    IconData? icon, // ubah jadi nullable
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
          labelStyle: const TextStyle(fontSize: 14.0, color: Colors.black),
          border: const OutlineInputBorder(),
          isDense: true,
          // 💡 Padding dinamis: tambah padding kiri jika tidak ada prefixIcon
          contentPadding: EdgeInsets.symmetric(
            horizontal: hasPrefixIcon ? 0 : 12,
            vertical: 12,
          ),
          // prefixIcon hanya ditampilkan jika ada icon
          prefixIcon: hasPrefixIcon
              ? IconButton(
                  onPressed: onIconTap,
                  icon: Icon(icon, size: 22),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                )
              : null,
          suffixIcon: suffixIcon != null
              ? ConstrainedBox(
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                  child: suffixIcon,
                )
              : null,
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontStyle: FontStyle.italic,
            fontSize: 14.0,
          ),
        ),
        style: const TextStyle(fontSize: 12.0),
      ),
    );
  }
}
