import 'package:flutter/material.dart';
import 'package:flutter_provider_data/page/001-molding/record_process/record_process.dart';
import 'package:flutter_provider_data/utils/page_transition_helper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_provider_data/model/record_running_model.dart';
// import 'package:flutter_provider_data/page/001-molding/recordprocess.dart';

class RunningListButtons extends StatelessWidget {
  final RecordRunningModel record;
  final String idProses;
  final Future<void> Function(String idRecord) onStopDialog;

  const RunningListButtons({
    super.key,
    required this.record,
    required this.idProses,
    required this.onStopDialog,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: Row(
        children: [
          // STOP
          Expanded(
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    Colors.redAccent,
                    Colors.red.shade600,
                    Colors.red.shade900
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.shade200.withValues(alpha: 0.5),
                    offset: const Offset(2, 3),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: OutlinedButton.icon(
                icon: const Icon(FontAwesomeIcons.hand,
                    color: Colors.white, size: 30),
                label: Text(
                  "STOP",
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600),
                ),
                onPressed: () => onStopDialog(record.idRecord),
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // FINISH
          Expanded(
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    Colors.blueAccent,
                    Colors.blue.shade600,
                    Colors.blue.shade900
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade200.withValues(alpha: 0.5),
                    offset: const Offset(2, 3),
                    blurRadius: 5,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: OutlinedButton.icon(
                icon: const Icon(FontAwesomeIcons.flagCheckered,
                    color: Colors.white, size: 25),
                label: Text(
                  "FINISH",
                  style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600),
                ),
                onPressed: () {
                  PageTransitionHelper.navigateReplaceWithTransition(
                    context,
                    RecordProcess(
                      title: "Molding",
                      idProses: record.idProses,
                    ),
                    type: PageTransitionType.fade,
                    duration: 1200,
                  );
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  side: BorderSide.none,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
