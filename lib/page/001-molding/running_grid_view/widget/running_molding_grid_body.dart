import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_provider_data/model/record_running_model.dart';
import 'package:flutter_provider_data/provider/running_provider.dart';
import 'package:flutter_provider_data/page/001-molding/running_grid_view/widget/running_molding_card.dart';
import 'package:provider/provider.dart';

class RunningMoldingGridBody extends StatelessWidget {
  final List<RecordRunningModel> list;

  const RunningMoldingGridBody({
    super.key,
    required this.list,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: list.isEmpty
          ? Center(
              child: Text(
                'TIDAK ADA RUNNING MOLDING.',
                style: GoogleFonts.poppins(
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey,
                  letterSpacing: 0.5,
                ),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                childAspectRatio: 0.70,
              ),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];
                final prov = context.read<RunningProvider>();
                final isSelected = prov.selectedItems.contains(item);

                return RunningMoldingCard(
                  item: item,
                  isSelected: isSelected,
                  onTapCard: () => prov.toggleSelectedItem(item),
                );
              },
            ),
    );
  }
}
