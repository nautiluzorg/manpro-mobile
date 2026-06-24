import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/master/employee_model.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:flutter_provider_data/model/machine_layout_model.dart';
import 'package:flutter_provider_data/model/master/machine_model.dart';
import 'package:flutter_provider_data/model/record_det_model.dart';
import 'package:flutter_provider_data/model/record_pending_det_model.dart';
import 'package:flutter_provider_data/model/record_pending_min_model.dart';
import 'package:flutter_provider_data/provider/pending_provider.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MachineDetailStopDialog extends StatefulWidget {
  final MachineLayoutModel machine;

  const MachineDetailStopDialog({super.key, required this.machine});

  @override
  State<MachineDetailStopDialog> createState() =>
      _MachineDetailStopDialogState();
}

class _MachineDetailStopDialogState extends State<MachineDetailStopDialog> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context
          .read<PendingProvider>()
          .loadPendingDetail(widget.machine.activeRecordId!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PendingProvider>(
      builder: (context, prov, _) {
        if (prov.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (prov.errorPendingMessage != null) {
          return Center(
            child: Text(
              prov.errorPendingMessage!,
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          body: SafeArea(
            child: Column(
              children: [
                _header(context),
                Expanded(child: _content(prov)),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= HEADER =================
  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF020617),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'MACHINE STOP DETAIL',
              style: GoogleFonts.poppins(
                color: _statusColor(widget.machine.runStatus),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= CONTENT =================

  Widget _content(PendingProvider prov) {
    if (prov.isPendingLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final data = prov.recordPending;
    if (data == null) {
      return const Center(child: Text('No data'));
    }

    final pending =
        data.recordPendings.isNotEmpty ? data.recordPendings.first : null;

    final production =
        data.detailsRecord.isNotEmpty ? data.detailsRecord.first : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _machineHeaderCard(),
          const SizedBox(height: 16),
          if (pending != null) _stopReasonCard(pending),
          const SizedBox(height: 16),
          // _employeeSection(data.employeeFinish),
          _employeeSection(
            data.employeeFinish,
            data.startTime, // DateTime
          ),

          const SizedBox(height: 16),
          if (production != null)
            _productionInfo(data, production, data.machineFinish),
          const SizedBox(height: 16),
          if (pending != null) _downtimeInfo(pending),
        ],
      ),
    );
  }

  // ================= HEADER =====================
  Widget _machineHeaderCard() {
    return _glassCard(
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.precision_manufacturing,
              color: _statusColor(widget.machine.runStatus),
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MACHINE ${widget.machine.name}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Machine Area : Molding Area - ${widget.machine.area}',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                _statusBadge(widget.machine.runStatus),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= SECTIONS =================
  Widget _stopReasonCard(RecordPendingMinModel data) {
    final nameReason = data.reason.nameReason;

    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('STOP REASON'),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              nameReason,
              style: GoogleFonts.poppins(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _downtimeInfo(RecordPendingMinModel pending) {
    final start = pending.startPending;
    final now = DateTime.now();

    final diff = now.difference(start);

    // ⬇️ konversi ke menit dan bulatkan
    final minutes = (diff.inSeconds / 60).round();

    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('DOWNTIME INFORMATION'),
          const SizedBox(height: 12),
          _row(
            'Date & Time Stop',
            formatDateTimeBln(start.toString()),
          ),
          _row(
            'Current Total Downtime',
            '$minutes minute',
          ),
        ],
      ),
    );
  }

  Widget _employeeTile({
    required String name,
    required String role,
    required String division,
    required String section,
    required String imageUrl,
    required Widget extra,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white24,
            image: DecorationImage(
              image: NetworkImage(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
              const SizedBox(height: 6),
              Text(role,
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
              Text(division,
                  style:
                      const TextStyle(color: Colors.white60, fontSize: 11.5)),
              Text(section,
                  style:
                      const TextStyle(color: Colors.white60, fontSize: 11.5)),
            ],
          ),
        ),
        extra,
      ],
    );
  }

  Widget _employeeStatusLabel(EmployeeModel employee) {
    if (employee.isActive) {
      return const Text(
        'ACTIVE',
        style: TextStyle(
          color: Colors.greenAccent,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      );
    }

    return RichText(
      textAlign: TextAlign.right,
      text: const TextSpan(
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        children: [
          TextSpan(
            text: 'JOB WORKING ',
            style: TextStyle(color: Colors.white70),
          ),
          TextSpan(
            text: 'INACTIVE',
            style: TextStyle(color: Colors.redAccent),
          ),
        ],
      ),
    );
  }

  String _getShift(DateTime startJob) {
    final hour = startJob.hour;

    // Shift 1: 07:00 - 18:59
    if (hour >= 7 && hour < 19) {
      return 'SHIFT 1';
    }

    // Shift 2: 19:00 - 06:59
    return 'SHIFT 2';
  }

  Widget _shiftLabel(String shift) {
    final isShift1 = shift == 'SHIFT 1';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color:
            Colors.white.withValues(alpha: 0.04), // ⬅️ sama seperti glassCard
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color:
              Colors.white.withValues(alpha: 0.08), // ⬅️ sama seperti glassCard
          width: 1,
        ),
      ),
      child: Text(
        shift,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          color: isShift1
              ? Colors.blueAccent
              : Colors.blueGrey.shade200, // shift 2 beda tipis
        ),
      ),
    );
  }

  Widget _employeeSection(
    EmployeeModel employee,
    DateTime startJob,
  ) {
    final shift = _getShift(startJob);

    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER: TITLE + SHIFT
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _sectionTitle('OPERATOR ON DUTY'),
              ),
              _shiftLabel(shift),
            ],
          ),

          const SizedBox(height: 12),

          _employeeTile(
            name: employee.fullName,
            role: employee.nrp,
            division: employee.division,
            section: employee.section,
            imageUrl:
                '${AppConfig.baseUrl}/media/img/employee/${employee.idEmployee}.png',
            extra: _employeeStatusLabel(employee),
          ),
        ],
      ),
    );
  }

  Widget _productionInfo(
    RecordPendingDetModel data,
    RecordDetModel detail,
    MachineModel machine,
  ) {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('PRODUCTION INFORMATION'),
          const SizedBox(height: 12),

          // ===== DATE / TIME / QTY TEST =====
          _rowInfoTriple(
            'Date',
            formatDateBln(data.startTime.toString()),
            'Start Time',
            formatDateTimeBln(data.startTime.toString()),
            'Qty',
            detail.startQty.toString(),
          ),

          // ===== JOB / LOT / TOTAL LOT =====

          _rowInfoTriple(
            'Job Number',
            detail.jobnumber,
            'Lot Number',
            detail.lotnumber,
            'Total Lot',
            detail.shootQty.toString(),
          ),

          _rowInfoTriple(
            'Product Category',
            detail.product.productCategory,
            'Product Type',
            detail.product.productType,
            'Qty per Lot',
            detail.startQty.toString(),
          ),

          _rowInfoTriple(
            'BCODE',
            detail.product.bcode,
            'Drawing Number',
            detail.product.drawingNumber,
            'Machine',
            machine.nmMc,
          ),

          // ===== MOLD =====
          _rowInfoTriple(
            'Mold Number',
            detail.moldnumber,
            'Mold Cavity',
            detail.moldcavity.toString(),
            'Total Shoots',
            detail.shootQty.toString(),
          ),

          // ===== MATERIAL / MACHINE =====
          _rowInfoTriple(
            'Gold Pill Lot Number',
            '${detail.goldPillDetail.germanSilverLotNumber} ${detail.goldPillDetail.uedaUshinLotNumber}  ${detail.goldPillDetail.materialLotNumber}',
            'Carbon Pill Lot Number',
            '${detail.carbonPillDetail.carbonLotNumber} ',
            'Machine',
            'MD-0001',
          ),
        ],
      ),
    );
  }

  Widget _rowInfoTriple(
    String label1,
    String value1,
    String label2,
    String value2,
    String label3,
    String value3,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(child: _infoItem(label1, value1)),
          const SizedBox(width: 15),
          Expanded(child: _infoItem(label2, value2)),
          const SizedBox(width: 15),
          Expanded(child: _infoItem(label3, value3)),
        ],
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ================= HELPERS =================
  Widget _glassCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String text) => Text(text,
      style: GoogleFonts.poppins(
          color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w600));

  Widget _row(String l, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l, style: const TextStyle(color: Colors.white70)),
            Text(v,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w500)),
          ],
        ),
      );

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'running':
        return Colors.greenAccent;
      case 'pending':
        return Colors.redAccent;
      case 'testing':
        return Colors.orangeAccent;
      case 'available':
        return Colors.blueAccent;
      default:
        return Colors.grey;
    }
  }

  Widget _statusBadge(String status) {
    final color = _statusColor(status);
    final label = _statusLabel(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'STOP';
      default:
        return status.toUpperCase();
    }
  }
}
