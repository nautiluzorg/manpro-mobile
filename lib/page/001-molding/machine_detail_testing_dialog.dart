import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/machine_layout_model.dart';
import 'package:flutter_provider_data/model/record_testing_detail_model.dart';
import 'package:flutter_provider_data/model/record_testing_header_model.dart';
import 'package:flutter_provider_data/provider/testing_provider.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_provider_data/config/app_config.dart';

enum NoteType { info, warning, danger }

class MachineDetailTestingDialog extends StatefulWidget {
  final MachineLayoutModel machine;

  const MachineDetailTestingDialog({super.key, required this.machine});

  @override
  State<MachineDetailTestingDialog> createState() =>
      _MachineDetailTestingDialogState();
}

class _MachineDetailTestingDialogState
    extends State<MachineDetailTestingDialog> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<TestingProvider>()
          .fetchTestingDetail(widget.machine.activeRecordId!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TestingProvider>(
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
                _header(context),
                Expanded(child: _content(prov)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: const Color(0xFF020617),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'MACHINE TESTING DETAIL',
              style: GoogleFonts.poppins(
                color: Colors.orangeAccent,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _content(TestingProvider prov) {
    if (prov.isTestingLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (prov.detail == null) {
      return const Center(child: Text('No data'));
    }

    final header = prov.detail!.header;
    final detail = prov.detail!.details.first;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _machineHeaderCard(),
          const SizedBox(height: 16),
          _testPhase(),
          const SizedBox(height: 16),
          _testerInfo(header),
          const SizedBox(height: 16),
          _productionInfo(header, detail), // ✅ AMAN
          const SizedBox(height: 16),
          _testParametersCheck(),
          const SizedBox(height: 16),
          _statusGrid(detail),
          const SizedBox(height: 16),
          _noteParagraph(
            title: 'INFO',
            message: header.notes ?? '-',
          ),
        ],
      ),
    );
  }

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
                  'Machine Area : ${widget.machine.area}- Molding Section',
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

  Widget _testPhase() {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title('TESTING PHASE'),
          const SizedBox(height: 12),
          _badge('MOLD TESTING ON MACHINE ${widget.machine.name}'),
        ],
      ),
    );
  }

  Widget _productionInfo(
    RecordTestingHeaderModel header,
    RecordTestingDetailModel detail,
  ) {
    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('MOLDING TEST INFORMATION'),
          const SizedBox(height: 12),

          // ===== DATE / TIME / QTY TEST =====
          _rowInfoTriple(
            'Date',
            formatDateBln(header.startTime.toString()),
            'Start Time',
            formatDateTimeBln(header.startTime.toString()),
            'Qty Test',
            detail.testQty.toString(),
          ),

          // ===== JOB / LOT / TOTAL LOT =====
          _rowInfoTriple(
            'Job Number',
            detail.jobnumber.toString(),
            'Lot Number',
            detail.lotnumber.toString(),
            'Total Lot',
            header.totalJobnumber.toString(),
          ),

          // ===== PRODUCT =====
          _rowInfoTriple(
            'Product Category',
            detail.productCategory,
            'Product Type',
            detail.productType,
            'Qty per Lot',
            detail.qty.toString(),
          ),

          // ===== BCODE / DRAWING / CUSTOMER =====
          _rowInfoTriple(
            'BCODE',
            detail.bcode,
            'Drawing Number',
            detail.drawingNumber,
            'Customer',
            detail.companyName, // ❗ belum ada di API
          ),

          // ===== MOLD =====
          _rowInfoTriple(
            'Mold Number',
            detail.moldnumber.toString(),
            'Mold Cavity',
            detail.moldcavity.toString(),
            'Total Shoots',
            detail.totalShootQty.toString(),
          ),

          // ===== MATERIAL / MACHINE =====
          _rowInfoTriple(
            'Gold Pill Lot Number',
            detail.goldPill ?? '-',
            'Carbon Pill Lot Number',
            detail.carbonPill ?? '-',
            'Machine',
            header.machine.nmMc,
          ),
        ],
      ),
    );
  }

  Widget _testerInfo(RecordTestingHeaderModel? h) {
    if (h == null) return const SizedBox();

    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('TESTER INFORMATION'),
          const SizedBox(height: 12),
          _person(
            idEmployee: h.employee.idEmployee,
            name: h.employee.fullName,
            nrp: h.employee.nrp,
            division: h.employee.division,
            section: h.employee.section,
          ),
        ],
      ),
    );
  }

  Widget _noteParagraph({
    required String title,
    required String message,
    NoteType type = NoteType.info,
  }) {
    final color = _noteColor(type);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== HEADER =====
          Row(
            children: [
              Icon(
                Icons.sticky_note_2_outlined,
                color: color,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ===== PARAGRAPH =====
          Text(
            message,
            style: const TextStyle(
              color: Colors.white70,
              height: 1.5,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Color _noteColor(NoteType type) {
    switch (type) {
      case NoteType.info:
        return Colors.cyanAccent;
      case NoteType.warning:
        return Colors.orangeAccent;
      case NoteType.danger:
        return Colors.redAccent;
    }
  }

  Widget _statusGrid(RecordTestingDetailModel? d) {
    if (d == null) return const SizedBox();

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.4,
      children: [
        _infoTileMultiRow(
          'MACHINE TEMPERATURE',
          Icons.thermostat,
          [
            {'label': 'Upper', 'value': d.mcTempUpper.toString()},
            {'label': 'Lower', 'value': d.mcTempLower.toString()},
          ],
        ),
        _infoTile('MACHINE PRESSURE', d.mcPressure.toString(), Icons.speed),
        _infoTile('MACHINE CURING TIME', '${d.mcCuring} s', Icons.timer),
        _infoTile('MACHINE SETTINGS', d.mcSettings.toString(), Icons.settings),
      ],
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

  // ================= HELPERS =================
  Widget _glassCard({required Widget child}) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: child,
      );

  Widget _title(String t) => Text(t,
      style: GoogleFonts.poppins(
          color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14));

  Widget _rowCheck(String label, String value) {
    final isPass = value.toUpperCase() == 'CHECKED';
    final color = isPass ? Colors.greenAccent : Colors.blueAccent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // ================= LABEL =================
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70),
            ),
          ),

          // ================= FIXED STATUS COLUMN =================
          SizedBox(
            width: 110, // 🔥 kunci alignment
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  isPass
                      ? Icons.check_box_outlined
                      : Icons.check_box_outline_blank,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _subTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      );

  Widget _testParametersCheck() {
    final prov = context.read<TestingProvider>();
    final detail = prov.detail?.details.first;

    // Cek apakah product category METAL PILL
    final isMetalPill = detail?.productCategory == 'METAL PILL';

    // Daftar semua checkbox
    final moldSetupChecks = [
      'Pin Bush',
      'Guide Bush',
      'Spring Safety',
      'Spring Height',
      'Positioning',
      'Mold Condition',
      'Plating Mold & Jig',
      'Bolt Condition',
      'Packing Rubber',
      'Mold Opening Angle',
    ];

    final vacumJigChecks = [
      'Stopper',
      'Guide Bush On Top',
      'Suiction PIN',
      'Guide PIN On Bottom Vacum',
      'Top Vacum No Bending',
    ];

    return _glassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('PARAMETERS CHECKED ON MACHINE ${widget.machine.name}'),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ================= LEFT COLUMN =================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _subTitle('MOLD SETUP CHECK'),
                    ...moldSetupChecks.map(
                      (label) => _rowCheck(
                        label,
                        'CHECKED', // ✅ selalu checked
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 40),

              // ================= RIGHT COLUMN =================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _subTitle('VACUM & JIG CHECK'),
                    ...vacumJigChecks.map(
                      (label) => _rowCheck(
                        label,
                        isMetalPill
                            ? 'CHECKED'
                            : 'NONE', // ❌ hanya METAL PILL semua checked
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(String text) => SizedBox(
        width: double.infinity,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.orangeAccent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            textAlign: TextAlign.left,
            style: const TextStyle(
              color: Colors.orangeAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

  Widget _person({
    required String idEmployee,
    required String name,
    required String nrp,
    required String division,
    required String section,
  }) {
    // final dummyPhoto = 'https://i.pravatar.cc/150?u=$nrp';
    final dummyPhoto =
        '${AppConfig.baseUrl}/media/img/employee/$idEmployee.png';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ================= PHOTO =================
        CircleAvatar(
          radius: 42, // ⬅️ BESAR & JELAS
          backgroundColor: Colors.white24,
          backgroundImage: NetworkImage(dummyPhoto),
        ),

        const SizedBox(width: 14),

        // ================= TEXT INFO =================
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                nrp,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              Text(
                division,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
              Text(
                section,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: Colors.orangeAccent.shade200,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }

  Widget _infoTile(String label, String value, IconData icon) {
    return _glassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // 🔴 PENTING
        children: [
          Icon(icon, color: Colors.cyanAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTileMultiRow(
    String title,
    IconData icon,
    List<Map<String, String>> rows,
  ) {
    return _glassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.cyanAccent),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                ...rows.map(
                  (row) => Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            row['label']!,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: Text(
                            row['value']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
}
