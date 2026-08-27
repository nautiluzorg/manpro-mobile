import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmployeeInfoSection extends StatelessWidget {
  final String name;
  final String nrp;
  final String division;
  final String section;

  const EmployeeInfoSection({
    super.key,
    required this.name,
    required this.nrp,
    required this.division,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          name,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          nrp,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700),
        ),
        const SizedBox(height: 6),
        Text(
          division,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          section,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }
}
