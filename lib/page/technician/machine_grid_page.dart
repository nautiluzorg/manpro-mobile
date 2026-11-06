import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// =====================================================================
// MACHINE GRID PAGE
//
// - Menampilkan 84 mesin dalam bentuk grid, SEMUA muat dalam 1 layar
//   (jumlah kolom dihitung otomatis dari ukuran layar, tanpa scroll).
// - Warna tile mengikuti status mesin (Running / Stop / Idle / Maintenance).
// - Chip di atas = ringkasan jumlah + filter (mesin lain diredupkan).
// - Klik tile -> dialog detail mesin.
//
// Data saat ini DUMMY (_generateMachines). Untuk data asli, ganti isi
// _machines dengan hasil mapping dari provider/API ke MachineInfo.
// =====================================================================

// ---------------------------------------------------------------------
// MODEL
// ---------------------------------------------------------------------

enum MachineStatus {
  running(
    label: 'RUNNING',
    short: 'RUN',
    color: Color(0xFF2E7D32),
    gradient: [Color(0xFF43A047), Color(0xFF1B7F3B)],
  ),
  stop(
    label: 'STOP',
    short: 'STOP',
    color: Color(0xFFC62828),
    gradient: [Color(0xFFE53935), Color(0xFFB71C1C)],
  ),
  idle(
    label: 'IDLE',
    short: 'IDLE',
    color: Color(0xFFEF6C00),
    gradient: [Color(0xFFFFA000), Color(0xFFE65100)],
  ),
  maintenance(
    label: 'MAINTENANCE',
    short: 'MAINT',
    color: Color(0xFF546E7A),
    gradient: [Color(0xFF78909C), Color(0xFF455A64)],
  );

  final String label;
  final String short;
  final Color color;
  final List<Color> gradient;

  const MachineStatus({
    required this.label,
    required this.short,
    required this.color,
    required this.gradient,
  });
}

class MachineInfo {
  final String code;
  final String type;
  final MachineStatus status;
  final String? jobNumber;
  final String? moldNo;
  final String? operatorName;
  final DateTime? startTime;
  final int? cycleSeconds;
  final int qtyActual;
  final int qtyTarget;
  final String? note;

  const MachineInfo({
    required this.code,
    required this.type,
    required this.status,
    this.jobNumber,
    this.moldNo,
    this.operatorName,
    this.startTime,
    this.cycleSeconds,
    this.qtyActual = 0,
    this.qtyTarget = 0,
    this.note,
  });

  double get progress =>
      qtyTarget == 0 ? 0 : (qtyActual / qtyTarget).clamp(0.0, 1.0).toDouble();
}

// ---------------------------------------------------------------------
// DATA DUMMY (ganti dengan data asli dari provider/API)
// ---------------------------------------------------------------------

List<MachineInfo> _generateMachines(int count) {
  final rnd = Random(84);

  const operators = [
    'AHMAD FAUZI',
    'BUDI SANTOSO',
    'CAHYO NUGROHO',
    'DEDI KURNIAWAN',
    'EKO PRASETYO',
    'FAJAR RAMADHAN',
    'GILANG PERMANA',
    'HENDRA WIJAYA',
    'IRFAN HAKIM',
    'JOKO SUSILO',
  ];
  const stopReasons = [
    'GANTI MOLD',
    'TUNGGU MATERIAL',
    'MESIN TROUBLE',
    'ISTIRAHAT',
    'TUNGGU QC',
  ];
  const idleNotes = ['STANDBY - MENUNGGU JOB', 'STANDBY - MOLD BELUM SIAP'];
  const maintNotes = [
    'PREVENTIVE MAINTENANCE',
    'GANTI HEATER',
    'SERVICE HYDRAULIC',
  ];
  const tonnages = [80, 100, 120, 150, 200];

  final now = DateTime.now();

  return List.generate(count, (i) {
    final n = i + 1;
    final roll = rnd.nextInt(100);
    final status = roll < 60
        ? MachineStatus.running
        : roll < 75
            ? MachineStatus.stop
            : roll < 90
                ? MachineStatus.idle
                : MachineStatus.maintenance;

    final hasJob =
        status == MachineStatus.running || status == MachineStatus.stop;
    final target = (10 + rnd.nextInt(41)) * 100;

    String? note;
    switch (status) {
      case MachineStatus.running:
        note = null;
      case MachineStatus.stop:
        note = stopReasons[rnd.nextInt(stopReasons.length)];
      case MachineStatus.idle:
        note = idleNotes[rnd.nextInt(idleNotes.length)];
      case MachineStatus.maintenance:
        note = maintNotes[rnd.nextInt(maintNotes.length)];
    }

    return MachineInfo(
      code: 'MC-${n.toString().padLeft(2, '0')}',
      type: 'INJECTION ${tonnages[rnd.nextInt(tonnages.length)]}T',
      status: status,
      jobNumber: hasJob ? 'J26-${1000 + rnd.nextInt(9000)}' : null,
      moldNo: hasJob ? 'M-${100 + rnd.nextInt(900)}' : null,
      operatorName: hasJob ? operators[rnd.nextInt(operators.length)] : null,
      startTime: hasJob
          ? now.subtract(Duration(minutes: 30 + rnd.nextInt(600)))
          : null,
      cycleSeconds: hasJob ? 18 + rnd.nextInt(28) : null,
      qtyActual: hasJob ? rnd.nextInt(target + 1) : 0,
      qtyTarget: hasJob ? target : 0,
      note: note,
    );
  });
}

// ---------------------------------------------------------------------
// HELPER FORMAT
// ---------------------------------------------------------------------

String _fmtInt(int n) => n
    .toString()
    .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.');

String _fmtDateTime(DateTime d) {
  String t(int n) => n.toString().padLeft(2, '0');
  return '${t(d.day)}/${t(d.month)}/${d.year}  ${t(d.hour)}:${t(d.minute)}';
}

// =====================================================================
// PAGE
// =====================================================================

class MachineGridPage extends StatefulWidget {
  final String title;

  const MachineGridPage({super.key, this.title = 'MACHINE MONITOR'});

  @override
  State<MachineGridPage> createState() => _MachineGridPageState();
}

class _MachineGridPageState extends State<MachineGridPage>
    with SingleTickerProviderStateMixin {
  static const int _machineCount = 84;

  // Kandidat jumlah kolom (pembagi 84 supaya grid terisi rapi)
  static const List<int> _colCandidates = [4, 6, 7, 12, 14, 21];

  // Rasio lebar:tinggi tile yang diinginkan
  static const double _targetRatio = 1.3;

  late final List<MachineInfo> _machines;
  late final AnimationController _pulse;
  MachineStatus? _filter; // null = tampilkan semua

  @override
  void initState() {
    super.initState();
    _machines = _generateMachines(_machineCount);
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _showMachineDialog(MachineInfo machine) {
    showDialog<void>(
      context: context,
      builder: (_) => _MachineDetailDialog(machine: machine),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.blue.shade900],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade100, Colors.grey.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                _buildStatsStrip(),
                const SizedBox(height: 10),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, c) =>
                        _buildGrid(c.maxWidth, c.maxHeight),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // RINGKASAN + FILTER
  // ---------------------------------------------------------------

  Widget _buildStatsStrip() {
    final counts = {
      for (final s in MachineStatus.values)
        s: _machines.where((m) => m.status == s).length,
    };

    return Row(
      children: [
        Expanded(
          child: _StatChip(
            label: 'ALL',
            count: _machines.length,
            color: Colors.blue.shade800,
            selected: _filter == null,
            onTap: () => setState(() => _filter = null),
          ),
        ),
        for (final s in MachineStatus.values) ...[
          const SizedBox(width: 6),
          Expanded(
            child: _StatChip(
              label: s.label,
              count: counts[s]!,
              color: s.color,
              selected: _filter == s,
              onTap: () => setState(() => _filter = _filter == s ? null : s),
            ),
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------
  // GRID (selalu muat 1 layar)
  // ---------------------------------------------------------------

  Widget _buildGrid(double maxW, double maxH) {
    final gap = maxW >= 700 ? 8.0 : 5.0;
    final total = _machines.length;

    // Pilih jumlah kolom yang bentuk tile-nya paling mendekati target
    var bestCols = _colCandidates.first;
    var bestDiff = double.infinity;
    for (final cols in _colCandidates) {
      final rows = (total / cols).ceil();
      final tileW = (maxW - gap * (cols - 1)) / cols;
      final tileH = (maxH - gap * (rows - 1)) / rows;
      final diff = (tileW / tileH - _targetRatio).abs();
      if (diff < bestDiff) {
        bestDiff = diff;
        bestCols = cols;
      }
    }

    final rows = (total / bestCols).ceil();
    final tileH =
        ((maxH - gap * (rows - 1)) / rows).floorToDouble().clamp(20.0, 400.0);

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: total,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: bestCols,
        mainAxisExtent: tileH,
        crossAxisSpacing: gap,
        mainAxisSpacing: gap,
      ),
      itemBuilder: (context, i) {
        final m = _machines[i];
        return _MachineTile(
          machine: m,
          pulse: _pulse,
          dim: _filter != null && m.status != _filter,
          onTap: () => _showMachineDialog(m),
        );
      },
    );
  }
}

// =====================================================================
// CHIP RINGKASAN / FILTER
// =====================================================================

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? color : Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: selected ? 3 : 1,
      shadowColor: color.withValues(alpha: 0.4),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? color : color.withValues(alpha: 0.35),
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$count',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  height: 1.1,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : color,
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: selected ? Colors.white : Colors.blueGrey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// TILE MESIN
// =====================================================================

class _MachineTile extends StatelessWidget {
  final MachineInfo machine;
  final Animation<double> pulse;
  final bool dim;
  final VoidCallback onTap;

  const _MachineTile({
    required this.machine,
    required this.pulse,
    required this.dim,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = machine.status;

    return AnimatedOpacity(
      opacity: dim ? 0.22 : 1,
      duration: const Duration(milliseconds: 200),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: s.gradient,
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: s.color.withValues(alpha: 0.35),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: onTap,
            child: LayoutBuilder(
              builder: (context, c) {
                final w = c.maxWidth;
                final h = c.maxHeight;

                final compact = h < 50; // tile kecil: hanya kode mesin
                final showJob = h >= 74 && w >= 84; // tile besar: + job number
                final codeSize = (w * 0.17).clamp(11.0, 17.0).toDouble();
                final subSize = (w * 0.105).clamp(8.0, 11.0).toDouble();
                final pad = w < 60 ? 4.0 : 8.0;

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned(
                      top: pad,
                      right: pad,
                      child: _StatusDot(status: s, pulse: pulse),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        pad,
                        pad,
                        compact ? pad : pad + 12,
                        pad,
                      ),
                      child: compact
                          ? Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  machine.code,
                                  style: GoogleFonts.poppins(
                                    fontSize: codeSize,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  machine.code,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: codeSize,
                                    height: 1.15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  s.short,
                                  maxLines: 1,
                                  style: GoogleFonts.poppins(
                                    fontSize: subSize,
                                    height: 1.2,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.6,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                                if (showJob)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Text(
                                      machine.jobNumber ?? '-',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.poppins(
                                        fontSize: subSize - 1,
                                        height: 1.2,
                                        fontWeight: FontWeight.w500,
                                        color:
                                            Colors.white.withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Titik status: berdenyut kalau mesin RUNNING
class _StatusDot extends StatelessWidget {
  final MachineStatus status;
  final Animation<double> pulse;

  const _StatusDot({required this.status, required this.pulse});

  @override
  Widget build(BuildContext context) {
    if (status != MachineStatus.running) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.85),
        ),
      );
    }

    return AnimatedBuilder(
      animation: pulse,
      builder: (context, _) {
        final v = pulse.value;
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.25 + 0.5 * v),
                blurRadius: 3 + 6 * v,
                spreadRadius: 1.5 * v,
              ),
            ],
          ),
        );
      },
    );
  }
}

// =====================================================================
// DIALOG DETAIL MESIN
// =====================================================================

class _MachineDetailDialog extends StatelessWidget {
  final MachineInfo machine;

  const _MachineDetailDialog({required this.machine});

  @override
  Widget build(BuildContext context) {
    final m = machine;
    final s = m.status;

    final noteLabel = switch (s) {
      MachineStatus.running => 'KETERANGAN',
      MachineStatus.stop => 'ALASAN STOP',
      MachineStatus.idle => 'KETERANGAN',
      MachineStatus.maintenance => 'KETERANGAN',
    };

    return Dialog(
      backgroundColor: Colors.white,
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ---------- HEADER ----------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: s.gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.precision_manufacturing_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.code,
                            style: GoogleFonts.poppins(
                              fontSize: 26,
                              height: 1.15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            m.type,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.85),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        s.label,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          color: s.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ---------- BODY ----------
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Column(
                  children: [
                    _DetailRow(label: 'JOB NUMBER', value: m.jobNumber ?? '-'),
                    _DetailRow(label: 'MOLD NO', value: m.moldNo ?? '-'),
                    _DetailRow(label: 'OPERATOR', value: m.operatorName ?? '-'),
                    _DetailRow(
                      label: 'START TIME',
                      value: m.startTime != null
                          ? _fmtDateTime(m.startTime!)
                          : '-',
                    ),
                    _DetailRow(
                      label: 'CYCLE TIME',
                      value: m.cycleSeconds != null
                          ? '${m.cycleSeconds} detik'
                          : '-',
                    ),
                    if (m.note != null)
                      _DetailRow(label: noteLabel, value: m.note!),
                  ],
                ),
              ),

              // ---------- PROGRESS ----------
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'PRODUKSI',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.6,
                            color: Colors.blueGrey.shade600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          m.qtyTarget == 0
                              ? '-'
                              : '${_fmtInt(m.qtyActual)} / ${_fmtInt(m.qtyTarget)} PCS',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: m.progress,
                        minHeight: 12,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(s.color),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${(m.progress * 100).toStringAsFixed(0)}%',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: s.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ---------- TOMBOL ----------
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.blue.shade800, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'TUTUP',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Baris info bergaya tabel: label | titik dua | nilai
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 108,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.blueGrey.shade500,
              ),
            ),
          ),
          SizedBox(
            width: 14,
            child: Text(
              ':',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.blueGrey.shade500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
