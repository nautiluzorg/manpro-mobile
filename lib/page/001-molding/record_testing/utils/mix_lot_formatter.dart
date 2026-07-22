import 'package:flutter/services.dart';

/// Formats mix lot number input: uppercase, strips spaces, caps at 12
/// characters, inserts a space after the 6th character for readability.
///
/// Moved verbatim from record_testing.dart — no logic changed.
class MixLotFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.toUpperCase().replaceAll(' ', '');

    if (text.length > 12) {
      text = text.substring(0, 12);
    }

    if (text.length > 6) {
      text = '${text.substring(0, 6)} ${text.substring(6)}';
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
