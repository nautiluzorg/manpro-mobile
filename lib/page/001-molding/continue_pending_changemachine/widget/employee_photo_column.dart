import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_provider_data/config/app_config.dart';

class EmployeePhotoColumn extends StatelessWidget {
  final String idEmployee;
  final String employeeName;
  final String nrp;
  final String section;
  final String division;

  const EmployeePhotoColumn({
    super.key,
    required this.idEmployee,
    required this.employeeName,
    required this.nrp,
    required this.section,
    required this.division,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.20,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.18,
                height: MediaQuery.of(context).size.width * 0.18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.green.shade100.withValues(alpha: 0.3),
                      Colors.white.withValues(alpha: 0.1),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withValues(alpha: 0.2),
                      spreadRadius: 4,
                      blurRadius: 14,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                ),
                child: ClipOval(
                  child: Image.network(
                    "${AppConfig.baseUrl}/media/img/employee/$idEmployee.png",
                    width: MediaQuery.of(context).size.width * 0.16,
                    height: MediaQuery.of(context).size.width * 0.16,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.person, size: 70, color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            employeeName,
            style:
                GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            nrp,
            style:
                GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          Text(
            section.toUpperCase(),
            style:
                GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          Text(
            division,
            style:
                GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                // TODO: aksi scan QR / buka scanner
              },
              child: Container(
                width: 100,
                height: 100,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.indigoAccent, Colors.indigo.shade900],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.qr_code_scanner,
                  color: Colors.white,
                  size: 48,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
