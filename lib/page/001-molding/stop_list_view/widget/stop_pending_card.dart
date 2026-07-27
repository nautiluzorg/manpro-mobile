import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:flutter_provider_data/provider/pending_provider.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:flutter_provider_data/page/001-molding/show_running_dialog.dart';

class StopPendingCard extends StatelessWidget {
  final dynamic pending;
  final String idProses;

  const StopPendingCard({
    super.key,
    required this.pending,
    required this.idProses,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CardHeader(pending: pending),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _OperatorPhotoInfo(pending: pending),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoTable(pending: pending),
                        const SizedBox(height: 12),
                        _ContinueButton(pending: pending, idProses: idProses),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  final dynamic pending;

  const _CardHeader({required this.pending});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
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
          Text(
            pending.idRecord,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          Text(
            pending.customer,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          Text(
            pending.productCategory,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          Flexible(
            child: Text(
              pending.productType,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _OperatorPhotoInfo extends StatelessWidget {
  final dynamic pending;

  const _OperatorPhotoInfo({required this.pending});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return SizedBox(
      width: width * 0.20,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: width * 0.18,
                height: width * 0.18,
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
                      color: Colors.green.shade300.withValues(alpha: 0.4),
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
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: ClipOval(
                  child: Image.network(
                    "${AppConfig.baseUrl}/media/img/employee/${pending.idEmployee}.png",
                    width: width * 0.16,
                    height: width * 0.16,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.person,
                      size: 70,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            pending.employeeName,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            pending.nrp,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            pending.section.toUpperCase(),
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            pending.division,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _InfoTable extends StatelessWidget {
  final dynamic pending;

  const _InfoTable({required this.pending});

  @override
  Widget build(BuildContext context) {
    final labels = [
      'JOB NUMBER',
      'DRAW NO',
      'MACHINE',
      'QTY SHOOT',
      'REASON STOP',
      'TIME STOP',
      'STOP DURATION',
    ];

    final values = [
      ": ${pending.jobnumber}",
      ": ${pending.drawingNumber}",
      ": ${pending.machineName}",
      ": ${pending.qty}",
      ": ${pending.reason}",
      ": ${formatDateTime(pending.startPending)}",
      ": ${getStopDuration(pending.startPending)}",
    ];

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(4),
        1: FlexColumnWidth(6),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        for (int i = 0; i < labels.length; i++)
          TableRow(
            decoration: BoxDecoration(
              color: i.isEven ? Colors.grey.shade200 : Colors.white,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(
                  labels[i],
                  style: GoogleFonts.poppins(
                    fontWeight: i == 0 ? FontWeight.bold : FontWeight.normal,
                    fontSize: 15,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(
                  values[i],
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: i == 0 ? FontWeight.bold : FontWeight.normal,
                    color: i == 4 ? Colors.red : Colors.black,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _ContinueButton extends StatelessWidget {
  final dynamic pending;
  final String idProses;

  const _ContinueButton({required this.pending, required this.idProses});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        gradient: LinearGradient(
          colors: [Colors.greenAccent, Colors.green.shade900],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ElevatedButton(
        onPressed: () async {
          final pendingProvider = context.read<PendingProvider>();
          final overlay = Overlay.of(context, rootOverlay: true);

          try {
            final result = await showRunningDialog(
              context,
              pending.idPending.toString(),
              pending.idReason.toString(),
              idProses,
              pending.productType,
            );

            if (!context.mounted) return;

            if (result == true) {
              pendingProvider.fetchPending(idProses);
            }
          } catch (e) {
            if (!context.mounted) return;
            CustomSnackbar.showWithOverlay(
              overlay,
              "Terjadi kesalahan: $e",
              isSuccess: false,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          "CONTINUE",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
