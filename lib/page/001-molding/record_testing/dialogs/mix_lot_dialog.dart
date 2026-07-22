import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/mix_lot_formatter.dart';

/// "ADD MIXING LOT NO" dialog. Extracted verbatim from
/// record_testing.dart's `showMixLotDialog`.
///
/// Decoupled from the page's TextEditingController: the caller passes the
/// current value in and gets the confirmed value back via [onConfirm]
/// (originally this called `testingProv.setMixLotNo(inputValue)` directly).
Future<void> showMixLotEntryDialog(
  BuildContext context, {
  required String initialValue,
  required ValueChanged<String> onConfirm,
}) {
  final tempController = TextEditingController(text: initialValue);
  bool isOkMixLotEnabled = tempController.text.length == 13;

  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return Transform.translate(
        offset: const Offset(0, -90),
        child: StatefulBuilder(
          builder: (context, localSetState) {
            return Dialog(
              backgroundColor: Colors.blue.shade500,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              child: Container(
                padding: const EdgeInsets.all(3),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(5, 5, 5, 15),
                  width: MediaQuery.of(context).size.width * 0.95,
                  height: MediaQuery.of(context).size.width * 0.4,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "ADD MIXING LOT NO",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: TextField(
                          controller: tempController,
                          inputFormatters: [MixLotFormatter()],
                          style: GoogleFonts.poppins(
                            fontSize: 14.0,
                            color: Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: "MIX LOT NO",
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.grey.shade500,
                              fontStyle: FontStyle.italic,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          onChanged: (value) {
                            localSetState(() {
                              isOkMixLotEnabled = value.length == 13;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 70,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.blue, width: 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                onPressed: () => Navigator.of(dialogContext).pop(),
                                child: Text(
                                  "CANCEL",
                                  style: GoogleFonts.poppins(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              height: 70.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                gradient: isOkMixLotEnabled
                                    ? LinearGradient(
                                        colors: [Colors.blueAccent, Colors.blue.shade800],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      )
                                    : LinearGradient(
                                        colors: [
                                          Colors.blueGrey.shade50,
                                          Colors.blueGrey.shade600
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                              ),
                              child: TextButton(
                                onPressed: isOkMixLotEnabled
                                    ? () {
                                        onConfirm(tempController.text);
                                        Navigator.of(dialogContext).pop();
                                      }
                                    : null,
                                child: Text(
                                  "OK",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );
}
