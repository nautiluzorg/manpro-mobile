import 'package:flutter/material.dart';
import 'package:flutter_provider_data/page/001-molding/record_process/record_process.dart';
import 'package:flutter_provider_data/utils/page_transition_helper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:flutter_provider_data/model/record_running_model.dart';
// import 'package:flutter_provider_data/page/001-molding/recordprocess.dart';
import 'package:flutter_provider_data/page/001-molding/reason_dialog/reason_dialog.dart';
import 'package:flutter_provider_data/provider/running_provider.dart';
import 'package:provider/provider.dart';

class RunningMoldingCard extends StatelessWidget {
  final RecordRunningModel item;
  final bool isSelected;
  final VoidCallback onTapCard;

  const RunningMoldingCard({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTapCard,
  });

  @override
  Widget build(BuildContext context) {
    final prov = context.read<RunningProvider>();

    return GestureDetector(
      onTap: onTapCard,
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        Colors.indigo.shade200.withValues(alpha: 0.6),
                        Colors.indigo.shade100.withValues(alpha: 0.3),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.grey.shade50,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? Colors.indigo.shade300.withValues(alpha: 0.3)
                      : Colors.grey.shade300.withValues(alpha: 0.2),
                  blurRadius: isSelected ? 14 : 6,
                  spreadRadius: isSelected ? 3 : 1,
                  offset: const Offset(0, 3),
                ),
              ],
              border: Border.all(
                color: isSelected ? Colors.indigo.shade500 : Colors.transparent,
                width: isSelected ? 3 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  item.detailsRecord.isNotEmpty
                      ? item.detailsRecord[0].jobNumber
                      : '-',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.indigo.shade800
                        : Colors.blueGrey.shade600,
                    letterSpacing: 1.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),

                // Photo Operator
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 30),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                        BoxShadow(
                          color: Colors.blueAccent.withValues(alpha: 40),
                          blurRadius: 15,
                          spreadRadius: 3,
                        ),
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 15),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 55,
                      backgroundImage: NetworkImage(
                        "${AppConfig.baseUrl}/media/img/employee/${item.activeEmployee?.idEmployee}.png",
                      ),
                      onBackgroundImageError: (_, __) => const Icon(
                        Icons.person,
                        size: 28,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                Text(
                  item.activeEmployee?.fullName ?? '-',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.indigo.shade700 : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),

                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 2.0, vertical: 2),
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1),
                      1: FlexColumnWidth(1),
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      TableRow(
                        children: [
                          Text(
                            'MACHINE',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          Text(
                            ':${item.activeMachine?.nmMc ?? '-'}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey.shade900,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: const [
                          SizedBox(height: 4),
                          SizedBox(height: 2),
                        ],
                      ),
                      TableRow(
                        children: [
                          Text(
                            'DRAW NO:',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Text(
                              item.detailsRecord.isNotEmpty
                                  ? ':${item.detailsRecord[0].bcode.drawingNumber}'
                                  : '-',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey.shade900,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: const [
                          SizedBox(height: 4),
                          SizedBox(height: 2),
                        ],
                      ),
                      TableRow(
                        children: [
                          Text(
                            'QTY:',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          Text(
                            item.detailsRecord.isNotEmpty
                                ? ':${item.detailsRecord[0].startQty}'
                                : '-',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey.shade900,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      TableRow(
                        children: const [
                          SizedBox(height: 4),
                          SizedBox(height: 2),
                        ],
                      ),
                      TableRow(
                        children: [
                          Text(
                            'START TIME:',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          Text(
                            item.startTime != null
                                ? ':${formatDateTime(item.startTime!)}'
                                : '-',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.grey.shade900,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final result = await Navigator.of(context).push<bool>(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) {
                                // Note: idProses berasal dari provider
                                return Dialog.fullscreen(
                                  backgroundColor: Colors.transparent,
                                  child: FadeTransition(
                                    opacity: animation,
                                    child: ReasonSelectDialog(
                                      idRecord: item.idRecord,
                                      onSuccess: () async {
                                        await prov.refresh(item.idProses);
                                      },
                                    ),
                                  ),
                                );
                              },
                              transitionDuration:
                                  const Duration(milliseconds: 400),
                              transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) =>
                                  FadeTransition(
                                      opacity: animation, child: child),
                            ),
                          );

                          if (!context.mounted) return;
                          if (result == true) {
                            await prov.refresh(item.idProses);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 6,
                          backgroundColor: Colors.transparent,
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    colors: [
                                      Colors.grey.shade400,
                                      Colors.grey.shade600,
                                    ],
                                  )
                                : LinearGradient(
                                    colors: [
                                      Colors.redAccent,
                                      Colors.red.shade600,
                                      Colors.red.shade900,
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 14),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                FaIcon(
                                  FontAwesomeIcons.hand,
                                  color: Colors.white,
                                  size: 25,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'STOP',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isSelected
                            ? null
                            : () {
                                PageTransitionHelper
                                    .navigateReplaceWithTransition(
                                  context,
                                  RecordProcess(
                                    title: "Molding",
                                    idProses: item.idProses,
                                  ),
                                  type: PageTransitionType.fade,
                                  duration: 1200,
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 6,
                          backgroundColor: Colors.transparent,
                        ),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    colors: [
                                      Colors.grey.shade400,
                                      Colors.grey.shade600,
                                    ],
                                  )
                                : LinearGradient(
                                    colors: [
                                      Colors.blueAccent,
                                      Colors.blue.shade600,
                                      Colors.blue.shade900,
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 14),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                FaIcon(
                                  FontAwesomeIcons.flagCheckered,
                                  color: Colors.white,
                                  size: 25,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'FINISH',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isSelected)
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
        ],
      ),
    );
  }

  String formatDateTime(dynamic dt) {
    if (dt == null) return '-';

    DateTime dateTime;

    if (dt is String) {
      dateTime = DateTime.parse(dt).toLocal();
    } else if (dt is DateTime) {
      dateTime = dt.toLocal();
    } else {
      return dt.toString();
    }

    return '${dateTime.day.toString().padLeft(2, '0')}-'
        '${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.year} '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
