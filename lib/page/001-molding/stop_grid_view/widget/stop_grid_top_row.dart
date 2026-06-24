import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/record_pending_model.dart';
import 'package:flutter_provider_data/page/001-molding/stop_grid_view/widget/stop_grid_clear_button.dart';
import 'package:flutter_provider_data/page/001-molding/stop_grid_view/widget/stop_grid_continue_button.dart';
import 'package:flutter_provider_data/page/001-molding/stop_grid_view/widget/stop_grid_filter_button.dart';
import 'package:flutter_provider_data/page/001-molding/stop_grid_view/widget/stop_grid_total_text.dart';
import 'package:flutter_provider_data/provider/pending_provider.dart';

class StopGridTopRow extends StatelessWidget {
  final double widthApp;
  final PendingProvider prov;
  final List<RecordPendingModel> selectedItems;
  final Future<void> Function() onScanJobNumber;
  final Future<void> Function() onScanEmployee;
  final VoidCallback onContinue;

  const StopGridTopRow({
    super.key,
    required this.widthApp,
    required this.prov,
    required this.selectedItems,
    required this.onScanJobNumber,
    required this.onScanEmployee,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      child: Row(
        children: [
          StopGridFilterButton(
            width: widthApp * 0.20,
            isDisabled: prov.isFilterActive,
            icon: Icons.search_sharp,
            label: 'JOBNUMBER',
            onTap: onScanJobNumber,
          ),
          SizedBox(width: widthApp * 0.01),
          StopGridFilterButton(
            width: widthApp * 0.20,
            isDisabled: prov.isFilterActive,
            icon: Icons.person_search,
            label: 'OPERATOR',
            onTap: onScanEmployee,
          ),
          SizedBox(width: widthApp * 0.01),
          if (prov.isFilterActive)
            StopGridClearButton(
              onTap: () => prov.clearFilter(),
            ),
          const Spacer(),
          StopGridContinueButton(
            width: widthApp * 0.20,
            isEnabled: selectedItems.isNotEmpty,
            onPressed: onContinue,
          ),
          SizedBox(width: widthApp * 0.02),
          StopGridTotalText(total: prov.filteredPending.length),
        ],
      ),
    );
  }
}
