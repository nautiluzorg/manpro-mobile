import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_provider_data/provider/running_provider.dart';
import 'running_list_card.dart';

class RunningListBody extends StatelessWidget {
  final String idProses;
  final Future<void> Function(String idRecord) onStopDialog;

  const RunningListBody({
    super.key,
    required this.idProses,
    required this.onStopDialog,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer<RunningProvider>(
        builder: (context, prov, child) {
          if (prov.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (prov.hasError) {
            return Center(child: Text('Error: ${prov.errorMessage}'));
          }

          final filteredList = prov.filteredRecords;

          if (filteredList.isEmpty) {
            return Center(
              child: Text(
                'SAAT INI TIDAK ADA RUNNING MOLDING.',
                style: GoogleFonts.poppins(
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey,
                  letterSpacing: 0.5,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: filteredList.length,
            itemBuilder: (context, index) {
              return RunningListCard(
                record: filteredList[index],
                idProses: idProses,
                onStopDialog: onStopDialog,
              );
            },
          );
        },
      ),
    );
  }
}
