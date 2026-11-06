import 'package:flutter/material.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:flutter_provider_data/provider/running_provider.dart';
import 'package:flutter_provider_data/model/record_running_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MassEmployeeGrid extends StatelessWidget {
  const MassEmployeeGrid({super.key});

  // ===== Design tokens =====
  static const double _cardHeight = 200; // tinggi tiap kartu
  static const double _gap = 12; // jarak antar kartu

  @override
  Widget build(BuildContext context) {
    final runningItems =
        context.select<RunningProvider, List<RecordRunningModel>>(
      (p) => p.selectedItems,
    );

    // List ke bawah, tiap kartu memenuhi lebar layar dengan tinggi tetap
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: runningItems.length,
      separatorBuilder: (_, __) => const SizedBox(height: _gap),
      itemBuilder: (_, i) => SizedBox(
        height: _cardHeight,
        width: double.infinity,
        child: RepaintBoundary(
          child: _EmployeeCard(record: runningItems[i]),
        ),
      ),
    );
  }
}

/// Kartu karyawan (digabung ke file ini supaya cukup 1 file)
class _EmployeeCard extends StatelessWidget {
  final RecordRunningModel record;

  const _EmployeeCard({required this.record});

  // ===== Design tokens =====
  static const double _photoSize = 180;
  static const double _photoRadius = 2;

  @override
  Widget build(BuildContext context) {
    final employeeId = record.activeEmployee?.idEmployee ?? '';
    final imageUrl = "${AppConfig.baseUrl}/media/img/employee/$employeeId.png";

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.blue.shade900],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // PHOTO
          ClipRRect(
            borderRadius: BorderRadius.circular(_photoRadius),
            child: Image.network(
              imageUrl,
              width: _photoSize,
              height: _photoSize,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: _photoSize,
                height: _photoSize,
                color: Colors.white24,
                alignment: Alignment.center,
                child: const Icon(Icons.person, size: 48, color: Colors.white),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // INFO SECTION
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.activeEmployee?.fullName ?? '-',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    height: 1.3,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                _InfoLine(
                  label: "Job Number",
                  value: record.detailsRecord.first.jobNumber,
                ),
                const SizedBox(height: 4),
                _InfoLine(
                  label: "Machine",
                  value: record.activeMachine?.nmMc ?? "No Machine",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Baris info "label : value" (digabung ke file ini)
class _InfoLine extends StatelessWidget {
  final String label;
  final String value;

  const _InfoLine({required this.label, required this.value});

  static const double _labelWidth = 106;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: _labelWidth,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 14,
              height: 1.3,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.poppins(
              fontSize: 15,
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:flutter_provider_data/provider/running_provider.dart';
import 'package:flutter_provider_data/model/record_running_model.dart';
import 'package:provider/provider.dart';
import 'mass_employee_card.dart';

class MassEmployeeGrid extends StatelessWidget {
  const MassEmployeeGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final runningItems =
        context.select<RunningProvider, List<RecordRunningModel>>(
      (p) => p.selectedItems,
    );

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      // Tinggi kartu fix (tidak tergantung lebar layar),
      // jumlah kolom menyesuaikan: HP 1 kolom, tablet 2 kolom
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisExtent: 92,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: runningItems.length,
      itemBuilder: (_, i) => RepaintBoundary(
        child: MassEmployeeCard(record: runningItems[i]),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_provider_data/provider/running_provider.dart';
import 'package:flutter_provider_data/model/record_running_model.dart';
import 'package:provider/provider.dart';
import 'mass_employee_card.dart';

class MassEmployeeGrid extends StatelessWidget {
  const MassEmployeeGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final runningItems =
        context.select<RunningProvider, List<RecordRunningModel>>(
      (p) => p.selectedItems,
    );

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: runningItems.length,
      itemBuilder: (_, i) => MassEmployeeCard(record: runningItems[i]),
    );
  }
}

*/
