import 'package:flutter/services.dart';

/// TextInputFormatter yang mencegah input dimulai dengan angka 0.
class NoLeadingZeroFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Kalau kosong, boleh
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Cek karakter pertama, kalau 0, kembalikan oldValue (batalkan input)
    if (newValue.text.startsWith('0')) {
      return oldValue;
    }

    return newValue;
  }
}
