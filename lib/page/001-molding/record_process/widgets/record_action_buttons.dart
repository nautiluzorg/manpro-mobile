import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_provider_data/provider/jobnumber_provider.dart';

class RecordActionButtons extends StatelessWidget {
  const RecordActionButtons({
    super.key,
    required this.onSubmit,
    required this.onClear,
    required this.onAddNg,
  });

  final Future<void> Function(BuildContext context) onSubmit;
  final void Function(BuildContext context) onClear;
  final void Function(BuildContext context) onAddNg;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        width: double.infinity,
        height: constraints.maxHeight,
        color: Colors.grey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              flex: 6,
              child: LayoutBuilder(builder: (context, buttonConstraints) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2.0, vertical: 2.0),
                      width: buttonConstraints.maxWidth * 0.5,
                      height: buttonConstraints.maxHeight * 0.9,
                      color: Colors.white,
                      child: SizedBox.expand(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blueAccent, Colors.blue.shade900],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Ink(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: OutlinedButton.icon(
                              label: Consumer<JobNumberProvider>(
                                builder: (context, jobProvider, _) => Text(
                                  jobProvider.isSubmitting
                                      ? 'SUBMIT...'
                                      : 'SUBMIT',
                                  style: GoogleFonts.poppins(
                                    color: jobProvider.isSubmitting
                                        ? Colors.grey[400]
                                        : Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                              onPressed: () => onSubmit(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side:
                                    const BorderSide(color: Colors.transparent),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 2.0, vertical: 2.0),
                      width: buttonConstraints.maxWidth * 0.5,
                      height: buttonConstraints.maxHeight * 0.9,
                      color: Colors.white,
                      child: SizedBox.expand(
                        child: OutlinedButton.icon(
                          label: Text(
                            'CLEAR',
                            style: GoogleFonts.poppins(
                              color: Colors.blue.shade800,
                              fontSize: 30,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                          onPressed: () => onClear(context),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: Colors.blue.shade600,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.redAccent,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
            Expanded(
              flex: 4,
              child: LayoutBuilder(builder: (context, ngConstraints) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 2.0, vertical: 2.0),
                  width: ngConstraints.maxWidth,
                  height: ngConstraints.maxHeight * 0.9,
                  color: Colors.white,
                  child: SizedBox.expand(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.redAccent, Colors.red.shade900],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.transparent, width: 1),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: OutlinedButton.icon(
                          label: Text(
                            'ADD NG',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 40.0,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                          onPressed: () => onAddNg(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(
                                color: Colors.transparent, width: 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      );
    });
  }
}
