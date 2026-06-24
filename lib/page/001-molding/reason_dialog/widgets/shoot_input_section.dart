import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_provider_data/provider/running_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../helpers/no_leading_zero_formatter.dart';

/// Section input Shoot Finished dan Shoot Remain untuk Reason '06'.
class ShootInputSection extends StatelessWidget {
  final TextEditingController currentShootQtyController;
  final TextEditingController shootRemainController;

  const ShootInputSection({
    super.key,
    required this.currentShootQtyController,
    required this.shootRemainController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 15.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 1,
                child: TextField(
                  controller: currentShootQtyController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(5),
                    NoLeadingZeroFormatter(),
                  ],
                  onChanged: (value) {
                    final provider = context.read<RunningProvider>();
                    if (provider.recordDetails.isEmpty ||
                        provider.recordDetails[0].detailsRecord.isEmpty) {
                      return;
                    }

                    final shootFinished = int.tryParse(value) ?? 0;
                    final initialShootQty =
                        provider.recordDetails[0].detailsRecord[0].shootQty;

                    provider.updateShootRemain(shootFinished, initialShootQty);
                  },
                  style: const TextStyle(
                      color: Colors.blueGrey, fontWeight: FontWeight.w500),
                  decoration: const InputDecoration(
                    labelText: 'SHOOT FINISHED',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: Consumer<RunningProvider>(
                  builder: (context, provider, child) {
                    shootRemainController.text =
                        provider.shootRemain.toString();
                    return TextField(
                      controller: shootRemainController,
                      readOnly: true,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        labelText: 'SHOOT REMAIN',
                        labelStyle: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.blueGrey,
                        ),
                        border: const OutlineInputBorder(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
