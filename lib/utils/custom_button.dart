import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

//Custom OUTLINED button
Widget customOutlinedButton({
  required String text,
  required VoidCallback onPressed,
  Color borderColor = Colors.red,
  Color textColor = Colors.red,
  double fontSize = 25,
  double borderRadius = 6,
  double height = 80,
}) {
  return OutlinedButton(
    onPressed: onPressed,
    style: OutlinedButton.styleFrom(
      side: BorderSide(color: borderColor, width: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      minimumSize: Size.fromHeight(height),
    ),
    child: Text(
      text,
      style: GoogleFonts.poppins(
        color: textColor,
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

//BUTTON BUILD CUSTOM

Widget buildCustomButton({
  required String text,
  IconData? icon,
  Color? color, // Warna solid jika gradient tidak dipakai
  Gradient? gradient,
  double height = 50,
  double fontSize = 14,
  FontWeight fontWeight = FontWeight.normal,
  VoidCallback? onPressed,
}) {
  final bool isEnabled = onPressed != null;

  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      padding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
    ),
    child: Ink(
      decoration: BoxDecoration(
        // jika tombol disable, ubah warna menjadi abu-abu
        color: isEnabled
            ? (gradient == null ? color ?? Colors.blue : null)
            : Colors.grey.shade400,
        gradient: isEnabled ? gradient : null,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Container(
        alignment: Alignment.center,
        height: height,
        width: double.infinity,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null)
              Icon(
                icon,
                color: isEnabled ? Colors.white : Colors.grey.shade700,
                size: fontSize,
              ),
            if (icon != null) const SizedBox(width: 8),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: isEnabled ? Colors.white : Colors.grey.shade700,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
