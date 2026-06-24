import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_provider_data/provider/material_provider.dart';
import 'package:flutter_provider_data/utils/custom_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// Dipindahkan dari record_process.dart (ringkas) - format mixing lot nomor
class MixLotFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.toUpperCase().replaceAll(' ', '');

    if (text.length > 12) {
      text = text.substring(0, 12);
    }

    if (text.length > 6) {
      text = '${text.substring(0, 6)} ${text.substring(6)}';
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

Future<void> showMixLotDialog(BuildContext context) async {
  final tempController = TextEditingController(
    text: context.read<MaterialProvider>().mixLotNumber,
  );

  final isOkMixLotEnabled =
      ValueNotifier<bool>(tempController.text.length == 13);

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: _buildMixLotDialogContent(
          dialogContext,
          tempController,
          isOkMixLotEnabled,
          (fn) => fn(), // localSetState dummy karena kita pakai ValueNotifier
        ),
      );
    },
  );
}

Widget _buildMixLotDialogContent(
  BuildContext dialogContext,
  TextEditingController tempController,
  ValueNotifier<bool> isOkMixLotEnabled,
  void Function(void Function()) localSetState,
) {
  return Container(
    padding: const EdgeInsets.all(3),
    child: Container(
      padding: const EdgeInsets.fromLTRB(5, 5, 5, 15),
      width: MediaQuery.of(dialogContext).size.width * 0.95,
      height: MediaQuery.of(dialogContext).size.width * 0.4,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "MASUKAN MIXING LOT NO",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextField(
              controller: tempController,
              inputFormatters: [MixLotFormatter()],
              decoration: InputDecoration(
                hintText: "MIX LOT NO",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              onChanged: (value) {
                localSetState(() {
                  isOkMixLotEnabled.value = value.length == 13;
                });
              },
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SizedBox(
                  height: 70,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red.shade800, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(
                      "CANCEL",
                      style: GoogleFonts.poppins(
                        color: Colors.red.shade800,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ValueListenableBuilder<bool>(
                valueListenable: isOkMixLotEnabled,
                builder: (context, enabled, _) {
                  return Expanded(
                    child: buildCustomButton(
                      text: "OK",
                      height: 70,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      gradient: LinearGradient(
                        colors: [
                          Colors.blueAccent,
                          Colors.blue.shade900,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      onPressed: enabled
                          ? () {
                              final inputValue = tempController.text;

                              // ✅ Logic tetap sama persis
                              context
                                  .read<MaterialProvider>()
                                  .setManualMixLot(inputValue);

                              if (Navigator.canPop(context)) {
                                Navigator.of(context).pop();
                              }
                            }
                          : null,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ),
  );
}
