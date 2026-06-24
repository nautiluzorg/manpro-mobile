import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_provider_data/service/material_service.dart';
import 'package:flutter_provider_data/model/goldpill_model.dart';
import 'package:flutter_provider_data/model/carbonpill_model.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class MaterialProvider extends ChangeNotifier {
  final MaterialService _materialService = MaterialService();

  // ================= STATE VARIABLES =================
  String? fetchError;
  bool isLoading = false;
  bool isFetchingDetail = false;

  // MIX LOT
  String mixLotNumber = "";
  bool isMixLotScanned = false;

  // GOLD PILL
  GoldPillModel goldPillData = GoldPillModel.empty;
  bool isPillScanned = false;

  // CARBON PILL (REVISI: Menggunakan Object Model sesuai standar baru)
  CarbonPillModel carbonPillData = CarbonPillModel.empty;

  final RegExp _mixlotRegex = RegExp(r'^(?=.*[A-Z])(?=.*\d)[A-Z0-9\- ]{13}$');

  // ================= MIX LOT FUNCTIONS =================
  // (Tetap sama, tidak ada perubahan)
  Future<String?> scanMixLotNumber() async {
    try {
      final picker = ImagePicker();
      final pickedImage = await picker.pickImage(source: ImageSource.camera);
      if (pickedImage == null) return null;

      final inputImage = InputImage.fromFile(File(pickedImage.path));
      final textRecognizer = TextRecognizer();
      final RecognizedText recognizedText =
          await textRecognizer.processImage(inputImage);

      for (var block in recognizedText.blocks) {
        for (var line in block.lines) {
          final textLine = line.text.trim();
          if (_mixlotRegex.hasMatch(textLine)) {
            mixLotNumber = textLine;
            isMixLotScanned = true;
            notifyListeners();
            textRecognizer.close();
            return textLine;
          }
        }
      }
      textRecognizer.close();
      return null;
    } catch (e) {
      return null;
    }
  }

  void clearMixLot() {
    mixLotNumber = "";
    isMixLotScanned = false;
    notifyListeners();
  }

  void setManualMixLot(String value) {
    mixLotNumber = value;
    isMixLotScanned = true;
    notifyListeners();
  }

  // ================= GOLD PILL FUNCTIONS =================
  // (Tetap sama, sudah direvisi sebelumnya)
  Future<void> fetchGoldPillDetail() async {
    if (!goldPillData.isValid) {
      fetchError = 'Invalid GoldPill ID';
      notifyListeners();
      return;
    }
    try {
      isFetchingDetail = true;
      fetchError = null;
      notifyListeners();
      final data = await _materialService.getGoldPillDetail(goldPillData.id);
      goldPillData = GoldPillModel.fromJson(data);
      isPillScanned = true;
      notifyListeners();
    } catch (e) {
      fetchError = e.toString();
      logPrint('GoldPill fetch error: $e');
    } finally {
      isFetchingDetail = false;
      notifyListeners();
    }
  }

  Future<void> scanGoldPillFromCode(String qrCode) async {
    try {
      print("DEBUG: RAW QR CODE: '$qrCode'");

      // 1. Bersihkan state lama
      clearGoldPill();

      // 2. Karena isi QR cuma angka "21", kita ubah string ke integer
      final id = int.tryParse(qrCode.trim());

      if (id == null) {
        // Jika hasil scan bukan angka (misal scan teks sembarangan)
        throw Exception("Format QR Code salah, ID harus berupa angka");
      }

      // 3. Masukkan ID ke model sementara (untuk keperluan fetch detail)
      goldPillData = GoldPillModel.empty.copyWith(id: id);

      isPillScanned = true;
      notifyListeners();

      // 4. Panggil API untuk ambil data JSON yang lengkap (id 21, lot number, dll)
      await fetchGoldPillDetail();

      print("DEBUG: Sukses memuat data untuk ID: $id");
    } catch (e) {
      print("DEBUG: CATCH ERROR - $e");
      clearGoldPill();
      rethrow;
    }
  }

  void clearGoldPill() {
    goldPillData = GoldPillModel.empty;
    isPillScanned = false;
    notifyListeners();
  }

  // ================= CARBON PILL FUNCTIONS (REVISED) =================

  /// Ambil detail lengkap Carbon Pill dari API berdasarkan ID
  Future<void> fetchCarbonPillDetail() async {
    if (!carbonPillData.isValid) {
      fetchError = 'Invalid CarbonPill ID';
      notifyListeners();
      return;
    }

    try {
      isFetchingDetail = true;
      fetchError = null;
      notifyListeners();

      final data =
          await _materialService.getCarbonPillDetail(carbonPillData.id);

      // Update state dengan model lengkap hasil fetch API
      carbonPillData = CarbonPillModel.fromJson(data);
      isPillScanned = true;
      notifyListeners();
    } catch (e) {
      fetchError = e.toString();
      logPrint('CarbonPill fetch error: $e');
    } finally {
      isFetchingDetail = false;
      notifyListeners();
    }
  }

  /// Proses scan QR Code Carbon Pill (Input dari String/Raw)
  Future<void> scanCarbonPillFromCode(String qrCode) async {
    try {
      print("DEBUG: RAW QR CODE: '$qrCode'");

      // 1. Bersihkan state lama
      clearCarbonPill();

      // 2. Karena isi QR cuma angka "21", kita ubah string ke integer
      final id = int.tryParse(qrCode.trim());

      if (id == null) {
        // Jika hasil scan bukan angka (misal scan teks sembarangan)
        throw Exception("Format QR Code salah, ID harus berupa angka");
      }

      // 3. Masukkan ID ke model sementara (untuk keperluan fetch detail)
      carbonPillData = CarbonPillModel.empty.copyWith(id: id);

      isPillScanned = true;
      notifyListeners();

      // 4. Panggil API untuk ambil data JSON yang lengkap (id 21, lot number, dll)
      await fetchCarbonPillDetail();

      print("DEBUG: Sukses memuat data Carbon Pill untuk ID: $id");
    } catch (e) {
      print("DEBUG: CATCH ERROR - $e");
      clearCarbonPill();
      rethrow;
    }
  }

  /// Scan Carbon Pill menggunakan Scanner Page (Kamera)

  /// Reset data Carbon Pill ke kondisi kosong
  void clearCarbonPill() {
    carbonPillData = CarbonPillModel.empty;
    isPillScanned = false;
    fetchError = null;
    notifyListeners();
  }

  // ================= UTILITY FUNCTIONS =================

  void setMaterialFromJobNumber({
    required String mixLot,
    required int goldId, // ← tambah
    required String goldGerman,
    required String goldUeda,
    required String goldMaterial,
    required int carbonId, // ← tambah
    required String carbon,
  }) {
    mixLotNumber = mixLot;

    if (goldGerman.isNotEmpty ||
        goldUeda.isNotEmpty ||
        goldMaterial.isNotEmpty) {
      goldPillData = goldPillData.copyWith(
        id: goldId, // ← pakai id dari API
        germanSilverLotNumber: goldGerman,
        uedaUshinLotNumber: goldUeda,
        materialLotNumber: goldMaterial,
      );
      isPillScanned = true;
    }

    if (carbon.isNotEmpty) {
      carbonPillData = carbonPillData.copyWith(
        id: carbonId, // ← pakai id dari API
        carbonLotNumber: carbon,
      );
      isPillScanned = true;
    }

    notifyListeners();
  }

  void clearFetchError() {
    fetchError = null;
    isFetchingDetail = false;
    notifyListeners();
  }
}
