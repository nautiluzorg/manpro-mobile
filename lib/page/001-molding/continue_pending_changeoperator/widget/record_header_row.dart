import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecordHeaderRow extends StatelessWidget {
  final String idRecord;
  final String customer;
  final String productCategory;
  final String productType;

  const RecordHeaderRow({
    super.key,
    required this.idRecord,
    required this.customer,
    required this.productCategory,
    required this.productType,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.blue.shade900],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(idRecord, style: textStyle),
          Text(customer, style: textStyle),
          Text(productCategory, style: textStyle),
          Text(productType, style: textStyle),
        ],
      ),
    );
  }
}
