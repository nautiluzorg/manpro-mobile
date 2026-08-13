import 'package:flutter/services.dart';

/// TextInputFormatter khusus qty:
/// - kosong boleh
/// - tidak boleh diawali angka 0
/// - hanya menerima digit
class NoLeadingZeroFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // Kosong — boleh
    if (text.isEmpty) return newValue;

    // Tidak boleh mulai dari 0
    if (text.startsWith('0')) return oldValue;

    // Hanya angka
    if (!RegExp(r'^[0-9]+$').hasMatch(text)) return oldValue;

    return newValue;
  }
}
