import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Gradient title banner used above each table section.
/// Was previously duplicated 3x inline (MOLD SETUP, VACUM JIG SETUP,
/// MACHINE PARAMETER) with identical styling.
class SectionHeader extends StatelessWidget {
  final String title;
  final double width;

  const SectionHeader({
    super.key,
    required this.title,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.indigoAccent, Colors.indigo.shade900],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: Center(
        child: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: width * 0.025,
          ),
        ),
      ),
    );
  }
}
