import 'package:flutter/material.dart';
import 'package:flutter_provider_data/provider/pending_provider.dart';
import 'package:flutter_provider_data/provider/ng_provider.dart';
import 'package:flutter_provider_data/model/ng_dropdown_model.dart';
import 'workdayover_header_bar.dart';
import 'workdayover_announcement_banner.dart';
import 'workdayover_new_operator_info_row.dart';
// import 'workdayover_ng_section.dart';

/// Panel lengkap "CONTINUE WORKDAY OVER WITH NEW OPERATOR":
/// banner pengumuman + header record + info operator baru + section NG.
class WorkdayOverNewOperatorPanel extends StatelessWidget {
  final PendingProvider prov;
  final NGProvider ngProvider;

  final TextEditingController qtyShootController;

  final String scannedEmployeeId;
  final String scannedEmployeeName;
  final String scannedEmployeeSection;
  final String scannedEmployeeDivision;

  final String? selectedNgId;
  final int qtyNg;
  final List<Map<String, dynamic>> addedNgItems;

  final VoidCallback onScanNewOperator;
  final VoidCallback onBack;
  final VoidCallback onSubmitNewOperator;
  final ValueChanged<NgDropdownModel> onNgSelected;
  final VoidCallback onIncrementNg;
  final VoidCallback onDecrementNg;
  final VoidCallback onAddNg;
  final void Function(int index) onDeleteNg;

  const WorkdayOverNewOperatorPanel({
    super.key,
    required this.prov,
    required this.ngProvider,
    required this.qtyShootController,
    required this.scannedEmployeeId,
    required this.scannedEmployeeName,
    required this.scannedEmployeeSection,
    required this.scannedEmployeeDivision,
    required this.selectedNgId,
    required this.qtyNg,
    required this.addedNgItems,
    required this.onScanNewOperator,
    required this.onBack,
    required this.onSubmitNewOperator,
    required this.onNgSelected,
    required this.onIncrementNg,
    required this.onDecrementNg,
    required this.onAddNg,
    required this.onDeleteNg,
  });

  @override
  Widget build(BuildContext context) {
    final data = prov.pendingDetail.first;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WorkdayOverAnnouncementBanner(),
            const SizedBox(height: 5),
            WorkdayOverHeaderBar(data: data),
            const SizedBox(height: 5),
            WorkdayOverNewOperatorInfoRow(
              data: data,
              scannedEmployeeId: scannedEmployeeId,
              scannedEmployeeName: scannedEmployeeName,
              scannedEmployeeSection: scannedEmployeeSection,
              scannedEmployeeDivision: scannedEmployeeDivision,
              qtyShootFilled: qtyShootController.text.isNotEmpty,
              onScanNewOperator: onScanNewOperator,
              onBack: onBack,
              onSubmit: onSubmitNewOperator,
            ),
            const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
