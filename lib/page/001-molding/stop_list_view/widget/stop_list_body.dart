import 'package:flutter/material.dart';
import 'package:flutter_provider_data/provider/pending_provider.dart';
import 'stop_pending_card.dart';

class StopListBody extends StatelessWidget {
  final PendingProvider prov;
  final String idProses;

  const StopListBody({
    super.key,
    required this.prov,
    required this.idProses,
  });

  @override
  Widget build(BuildContext context) {
    if (prov.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (prov.hasError) {
      return Center(child: Text('Error: ${prov.errorMessage}'));
    }

    if (prov.filteredPending.isEmpty) {
      return Center(
        child: Text(
          'MOLDING STOP TIDAK ADA.',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w600,
            color: Colors.blueGrey,
            letterSpacing: 0.5,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: prov.filteredPending.length,
      itemBuilder: (context, index) {
        final pending = prov.filteredPending[index];
        return StopPendingCard(
          pending: pending,
          idProses: idProses,
        );
      },
    );
  }
}
