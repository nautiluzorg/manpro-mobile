import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StopGridEmptyState extends StatelessWidget {
  const StopGridEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'TIDAK ADA STOP MOLDING.',
        style: GoogleFonts.poppins(
          fontSize: 25,
          fontWeight: FontWeight.w600,
          color: Colors.blueGrey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
