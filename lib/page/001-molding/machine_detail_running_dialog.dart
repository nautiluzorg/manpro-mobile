import 'package:flutter/material.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:flutter_provider_data/model/machine_layout_model.dart';
import 'package:flutter_provider_data/model/record_det_model.dart';
import 'package:flutter_provider_data/model/record_running_det_model.dart';
import 'package:flutter_provider_data/provider/running_provider.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MachineDetailRunningDialog extends StatefulWidget {
  final MachineLayoutModel machine;

  const MachineDetailRunningDialog({super.key, required this.machine});

  @override
  State<MachineDetailRunningDialog> createState() =>
      _MachineDetailRunningDialogState();
}

class _MachineDetailRunningDialogState
    extends State<MachineDetailRunningDialog> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<RunningProvider>()
          .fetchRunningDetail(widget.machine.activeRecordId!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RunningProvider>(
      builder: (context, prov, _) {
        if (prov.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (prov.error != null) {
          return Center(
            child: Text(
              prov.error!,
              style: const TextStyle(color: Colors.redAccent),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFF0F172A),
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(child: _buildContent(prov)),
              ],
            ),
          ),
        );
      },
    );
  }

  // ================= HEADER =================
  Widget _buildHeader(BuildContext context) {
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
              'MACHINE RUNNING DETAIL',
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
  Widget _buildContent(RunningProvider prov) {
    if (prov.isTestingLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (prov.detail == null) {
      return const Center(child: Text('No data'));
    }
    final record = prov.detail!;
    final detail = prov.detail!.detailsRecord.first;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _machineHeaderCard(),
          const SizedBox(height: 16),
          _employeeSection(record),
          const SizedBox(height: 16),
          _runningPhase(),
          const SizedBox(height: 16),
          _productionInfo(record, detail),
          const SizedBox(height: 16),
          _activityLog(record),
        ],
      ),
    );
  }

  // ================= CARD : HEADER =================
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

  String getShiftFromDateTime(DateTime dateTime) {
    final hour = dateTime.hour;

    // Shift 2: 19:00 - 23:59 atau 00:00 - 06:59
    if (hour >= 19 || hour < 7) {
      return 'SHIFT 2';
    }

    // Shift 1: 07:00 - 18:59
    return 'SHIFT 1';
  }

  Widget _employeeSection(
    RecordRunningDetModel record,
  ) {
    final startMolding = record.startTime;
    final employee = record.employeeFinish;
    final shift = getShiftFromDateTime(startMolding);

    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('OPERATOR ON DUTY'),
          const SizedBox(height: 12),
          _employeeTile(
            name: employee.fullName,
            role: employee.nrp,
            division: employee.division,
            section: employee.section,
            imageUrl:
                '${AppConfig.baseUrl}/media/img/employee/${employee.idEmployee}.png',
            extra: _employeeExtraInfo(shift),
          ),
        ],
      ),
    );
  }

  Widget _runningPhase() {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title('RUNNING PHASE'),
          const SizedBox(height: 12),
          _badge('MOLD RUNNING ON MACHINE ${widget.machine.name}'),
        ],
      ),
    );
  }

  Widget _productionInfo(
    RecordRunningDetModel record,
    RecordDetModel detail,
  ) {
    final product = detail.product;
    final machine = record.machineFinish;
    final gold = detail.goldPillDetail;
    final carbon = detail.carbonPillDetail;

    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('MOLDING RUNNING INFORMATION'),
          const SizedBox(height: 12),

          // ===== DATE / TIME / QTY TEST =====
          _rowInfoTriple(
            'Date',
            formatDateBln(record.startTime.toString()),
            'Start Time',
            formatDateTimeBln(record.startTime.toString()),
            'Qty Target',
            detail.startQty.toString(),
          ),

          // ===== JOB / LOT / TOTAL LOT =====
          _rowInfoTriple(
            'Job Number',
            detail.jobnumber,
            'Lot Number',
            detail.lotnumber,
            'Total Lot',
            record.totalJobnumber,
          ),

          // ===== PRODUCT =====
          _rowInfoTriple(
            'Product Category',
            product.productCategory,
            'Product Type',
            product.productType,
            'Qty per Lot',
            detail.startQty.toString(),
          ),

          // ===== BCODE / DRAWING / CUSTOMER =====
          _rowInfoTriple(
            'BCODE',
            product.bcode,
            'Drawing Number',
            product.drawingNumber,
            'Customer',
            product.companyName, // ❗ belum ada di API
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
            '${gold.germanSilverLotNumber} ${gold.uedaUshinLotNumber} ${gold.materialLotNumber}',
            'Carbon Pill Lot Number',
            carbon.carbonLotNumber,
            'Machine',
            machine.nmMc,
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

  // ================= EMPLOYEE =================

  // ================= ACTIVITY =================
  Widget _activityLog(
    RecordRunningDetModel record,
  ) {
    final emp = record.employeeFinish;
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('ACTIVITY INFORMATION'),
          const SizedBox(height: 12),
          _logItem(
            formatTimeDateBln(record.startTime.toString()),
            'Molding Running Started',
          ),
          _logItem(
            formatNowTimeDateBln(),
            'Currently Molding still Running and operated by ${emp.fullName}',
          ),
        ],
      ),
    );
  }

  // ================= UI HELPERS =================
  Widget _glassCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: child,
    );
  }

  Widget _title(String t) => Text(t,
      style: GoogleFonts.poppins(
          color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14));

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: Colors.greenAccent,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }

  Widget _statusBadge(String status) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PHOTO
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: Image.network(
              imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 12),

          // TEXT
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
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12)),
                Text(division,
                    style:
                        const TextStyle(color: Colors.white60, fontSize: 11.5)),
                Text(section,
                    style:
                        const TextStyle(color: Colors.white60, fontSize: 11.5)),
              ],
            ),
          ),

          // EXTRA (SHIFT + STATUS)
          extra,
        ],
      ),
    );
  }

  Widget _jobWorkingActiveLabel() {
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
            text: 'ACTIVE',
            style: TextStyle(color: Colors.greenAccent),
          ),
        ],
      ),
    );
  }

  Widget _shiftLabel(String shift) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Text(
        shift.toUpperCase(),
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _employeeExtraInfo(String shift) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _shiftLabel(shift),
        _jobWorkingActiveLabel(),
      ],
    );
  }

  Widget _logItem(String time, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(time,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(width: 12),
          Expanded(
              child: Text(text, style: const TextStyle(color: Colors.white70))),
        ],
      ),
    );
  }

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

  Widget _badge(String text) => SizedBox(
        width: double.infinity,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.greenAccent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            textAlign: TextAlign.left,
            style: const TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
}
