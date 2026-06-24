import 'package:flutter/material.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:flutter_provider_data/model/record_running_detail_model.dart';
import 'package:google_fonts/google_fonts.dart';

class EmployeeInfoSection extends StatelessWidget {
  final List<RecordRunningDetailModel> data;

  const EmployeeInfoSection({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox();

    final employee = data[0].activeEmployee;

    return Expanded(
      flex: 3,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// 🔵 FOTO BESAR (circle & dominan)
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.network(
                "${AppConfig.baseUrl}/media/img/employee/${employee.idEmployee}.png",
                width: 150, // 🔥 lebih besar
                height: 150,
                fit: BoxFit.cover,

                /// loading
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return SizedBox(
                    width: 150,
                    height: 150,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },

                /// fallback
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 150,
                    height: 150,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.person, size: 60),
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          /// 🧑 NAMA
          Text(
            employee.fullName,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey.shade600, // 🔥 aksen utama
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 6),

          /// 🆔 NRP
          Text(
            employee.nrp,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.blueGrey.shade600,
            ),
          ),

          const SizedBox(height: 10),

          /// 📌 SECTION
          Text(
            employee.section.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.blueGrey.shade700,
            ),
          ),

          const SizedBox(height: 4),

          /// 📌 DIVISION
          Text(
            employee.division.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}
