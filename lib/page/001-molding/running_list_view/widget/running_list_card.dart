import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:flutter_provider_data/model/record_running_model.dart';
import 'running_list_buttons.dart';

class RunningListCard extends StatelessWidget {
  final RecordRunningModel record;
  final String idProses;
  final Future<void> Function(String idRecord) onStopDialog;

  const RunningListCard({
    super.key,
    required this.record,
    required this.idProses,
    required this.onStopDialog,
  });

  @override
  Widget build(BuildContext context) {
    final widthApp = MediaQuery.of(context).size.width;

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 16.0),
            _buildBody(context, widthApp),
            const SizedBox(height: 2.0),
            _buildFooterDivider(),
          ],
        ),
      ),
    );
  }

  // ── HEADER ────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 4),
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
          Text(record.idRecord,
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white)),
          const SizedBox(width: 20.0),
          Text(
            record.detailsRecord.isNotEmpty
                ? record.detailsRecord[0].bcode.companyName
                : '',
            style: GoogleFonts.poppins(
                fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          const SizedBox(width: 20.0),
          Text(
            record.detailsRecord.isNotEmpty
                ? record.detailsRecord[0].bcode.bcode
                : '',
            style: GoogleFonts.poppins(
                fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          const SizedBox(width: 20.0),
          Flexible(
            child: Text(
              record.detailsRecord.isNotEmpty
                  ? record.detailsRecord[0].bcode.productCategory
                  : '',
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 20.0),
          Text(
            record.detailsRecord.isNotEmpty
                ? record.detailsRecord[0].bcode.productType
                : '',
            style: GoogleFonts.poppins(
                fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ── BODY ──────────────────────────────────────────────────────────────
  Widget _buildBody(BuildContext context, double widthApp) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOperatorPhoto(widthApp),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoTable(),
                const SizedBox(height: 6.0),
                RunningListButtons(
                  record: record,
                  idProses: idProses,
                  onStopDialog: onStopDialog,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── OPERATOR PHOTO ────────────────────────────────────────────────────
  Widget _buildOperatorPhoto(double widthApp) {
    return SizedBox(
      width: widthApp * 0.20,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: widthApp * 0.18,
                height: widthApp * 0.18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.grey.withValues(alpha: 0.4),
                      Colors.white.withValues(alpha: 0.1),
                    ],
                    stops: const [0.5, 1.0],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.5),
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
                  boxShadow: [
                    BoxShadow(
                        color: Colors.blueAccent.withValues(alpha: 30),
                        blurRadius: 12,
                        spreadRadius: 2),
                    BoxShadow(
                        color: Colors.white.withValues(alpha: 25),
                        blurRadius: 18,
                        spreadRadius: 4),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    "${AppConfig.baseUrl}/media/img/employee/${record.activeEmployee?.idEmployee}.png",
                    width: widthApp * 0.16,
                    height: widthApp * 0.16,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.person_pin,
                        size: 70, color: Colors.grey),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            record.activeEmployee?.fullName ?? 'Name Operator tidak ditemukan',
            style:
                GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            record.activeEmployee?.nrp ?? '-',
            style:
                GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          Text(
            record.activeEmployee?.section.toUpperCase() ?? '-',
            style:
                GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
          Text(
            record.activeEmployee?.division.toUpperCase() ?? '-',
            style:
                GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── INFO TABLE ────────────────────────────────────────────────────────
  Widget _buildInfoTable() {
    final rows = [
      [
        'JOB NUMBER',
        record.detailsRecord.isNotEmpty ? record.detailsRecord[0].jobNumber : ''
      ],
      [
        'DRAW NO',
        record.detailsRecord.isNotEmpty
            ? record.detailsRecord[0].bcode.drawingNumber
            : ''
      ],
      ['MACHINE', record.activeMachine?.nmMc ?? ''],
      [
        'QTY',
        record.detailsRecord.isNotEmpty
            ? record.detailsRecord[0].startQty.toString()
            : ''
      ],
      [
        'SHOOT QTY',
        record.detailsRecord.isNotEmpty
            ? record.detailsRecord[0].shootQty.toString()
            : ''
      ],
      ['START TIME', formatDateTime(record.startTime.toString())],
      ['STATUS', record.runStatus.toUpperCase()],
    ];

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(4),
          1: FlexColumnWidth(6),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: List.generate(rows.length, (i) {
          return TableRow(
            decoration: BoxDecoration(
              color: i.isEven ? Colors.grey.shade200 : Colors.white,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(
                  rows[i][0],
                  style: GoogleFonts.poppins(
                    fontWeight: i == 0 ? FontWeight.bold : FontWeight.normal,
                    fontSize: 15,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(
                  ': ${rows[i][1]}',
                  style: GoogleFonts.poppins(fontSize: 15),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ── FOOTER DIVIDER ────────────────────────────────────────────────────
  Widget _buildFooterDivider() {
    return Container(
      height: 8,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
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
