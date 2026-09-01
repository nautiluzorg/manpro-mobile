import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MachineHeaderRow extends StatelessWidget {
  final String idRecord;
  final String customer;
  final String productCategory;
  final String productType;

  const MachineHeaderRow({
    super.key,
    required this.idRecord,
    required this.customer,
    required this.productCategory,
    required this.productType,
  });

  Widget _headerText(String text) => Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          decoration: TextDecoration.none,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blueAccent,
            Colors.blue.shade900,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _headerText(idRecord),
          _headerText(customer),
          _headerText(productCategory),
          _headerText(productType),
        ],
      ),
    );
  }
}
