import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/record_running_model.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:google_fonts/google_fonts.dart';
import 'mass_info_line.dart';

class MassEmployeeCard extends StatelessWidget {
  final RecordRunningModel record;

  const MassEmployeeCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final employeeId = record.activeEmployee?.idEmployee ?? '';
    final imageUrl = "${AppConfig.baseUrl}/media/img/employee/$employeeId.png";

    return Container(
      height: 60,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.blue.shade900],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // 🔥 PHOTO (EXACT original)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 80,
                  height: 80,
                  color: Colors.white24,
                  alignment: Alignment.center,
                  child:
                      const Icon(Icons.person, size: 38, color: Colors.white),
                ),
              ),
            ),
          ),

          const SizedBox(width: 18),

          // 🔥 INFO SECTION (EXACT original)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.activeEmployee?.fullName ?? '-',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                MassInfoLine(
                  label: "Job Number",
                  value: record.detailsRecord.first.jobNumber,
                  labelColor: Colors.white70,
                  valueColor: Colors.white,
                ),
                const SizedBox(height: 6),
                MassInfoLine(
                  label: "Machine",
                  value: record.activeMachine?.nmMc ?? "No Machine",
                  labelColor: Colors.white70,
                  valueColor: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
