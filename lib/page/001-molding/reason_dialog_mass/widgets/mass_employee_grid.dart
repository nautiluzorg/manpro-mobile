import 'package:flutter/material.dart';
import 'package:flutter_provider_data/provider/running_provider.dart';
import 'package:flutter_provider_data/model/record_running_model.dart';
import 'package:provider/provider.dart';
import 'mass_employee_card.dart';

class MassEmployeeGrid extends StatelessWidget {
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
