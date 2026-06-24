import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/record_running_detail_model.dart';
import 'package:google_fonts/google_fonts.dart';

/// Header dialog dengan gradient biru menampilkan idRecord, company, category, product.
class ReasonDialogHeader extends StatelessWidget {
  final String idRecord;
  final List<RecordRunningDetailModel> data;

  const ReasonDialogHeader({
    super.key,
    required this.idRecord,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blueAccent,
            Colors.blue.shade900,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            idRecord,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          _buildText(
            data.isNotEmpty && data[0].detailsRecord.isNotEmpty
                ? data[0].detailsRecord[0].bcode.companyName
                : 'Customer',
          ),
          _buildText(
            data.isNotEmpty && data[0].detailsRecord.isNotEmpty
                ? data[0].detailsRecord[0].bcode.productCategory
                : 'No Category',
          ),
          _buildText(
            data.isNotEmpty && data[0].detailsRecord.isNotEmpty
                ? data[0].detailsRecord[0].bcode.productType
                : 'No product type',
          ),
        ],
      ),
    );
  }

  Widget _buildText(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}
