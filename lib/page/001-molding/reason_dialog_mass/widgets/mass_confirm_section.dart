import 'package:flutter/material.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../helpers/mass_reason_controller.dart';

class MassConfirmSection extends StatelessWidget {
  const MassConfirmSection({super.key}); // tidak perlu parameter controller

  // ===== Design tokens =====
  static const double _photoSize = 64;
  static const double _photoRadius = 12;

  @override
  Widget build(BuildContext context) {
    // ambil dari context, otomatis rebuild saat notifyListeners()
    final controller = context.watch<MassReasonController>();
    final confirmed = controller.isEmployeeConfirmed;

    final imageUrl =
        "${AppConfig.baseUrl}/media/img/employee/${controller.photoEmployeeConfirm}";

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: confirmed ? Colors.green.shade50 : const Color(0xFFF9FAFB),
        border: Border.all(
          color: confirmed ? Colors.green.shade300 : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // PHOTO
          Container(
            width: _photoSize,
            height: _photoSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_photoRadius),
              color: Colors.grey.shade200,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_photoRadius),
              child: confirmed
                  ? Image.network(
                      imageUrl,
                      cacheWidth: 128,
                      cacheHeight: 128,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person,
                        size: 36,
                        color: Colors.grey,
                      ),
                    )
                  : const Icon(
                      Icons.qr_code_scanner,
                      size: 32,
                      color: Colors.grey,
                    ),
            ),
          ),

          const SizedBox(width: 14),

          // INFO
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "CONFIRMED BY",
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  confirmed
                      ? controller.nameEmployeeConfirm
                      : "BELUM DIKONFIRMASI",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: confirmed ? Colors.black87 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // STATUS
          if (confirmed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified_rounded,
                      color: Colors.green.shade700, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    "Confirmed",
                    style: GoogleFonts.poppins(
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          else
            const Icon(Icons.info_outline_rounded,
                color: Colors.grey, size: 24),
        ],
      ),
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../helpers/mass_reason_controller.dart';

class MassConfirmSection extends StatelessWidget {
  const MassConfirmSection({super.key}); // ← tidak perlu parameter controller

  @override
  Widget build(BuildContext context) {
    // ← ambil dari context, otomatis rebuild saat notifyListeners()
    final controller = context.watch<MassReasonController>();

    final imageUrl =
        "${AppConfig.baseUrl}/media/img/employee/${controller.photoEmployeeConfirm}";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // PHOTO
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.grey.shade200,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: controller.isEmployeeConfirmed
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.grey,
                      ),
                    )
                  : const Icon(
                      Icons.qr_code_scanner,
                      size: 36,
                      color: Colors.grey,
                    ),
            ),
          ),

          const SizedBox(width: 18),

          // INFO
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "CONFIRMED BY",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  controller.isEmployeeConfirmed
                      ? controller.nameEmployeeConfirm
                      : "BELUM DIKONFIRMASI",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: controller.isEmployeeConfirmed
                        ? Colors.black87
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // STATUS
          if (controller.isEmployeeConfirmed)
            Row(
              children: const [
                Icon(Icons.verified_rounded, color: Colors.green, size: 28),
                SizedBox(width: 6),
                Text(
                  "Confirmed",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            )
          else
            const Icon(Icons.info_outline_rounded,
                color: Colors.grey, size: 28),
        ],
      ),
    );
  }
}
*/
