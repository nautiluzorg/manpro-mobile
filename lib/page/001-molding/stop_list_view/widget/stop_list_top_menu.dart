import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_provider_data/provider/pending_provider.dart';

class StopListTopMenu extends StatelessWidget {
  final double widthApp;
  final PendingProvider prov;
  final Future<void> Function() onScanJobNumber;
  final Future<void> Function() onScanEmployee;
  final VoidCallback onClearFilter;

  const StopListTopMenu({
    super.key,
    required this.widthApp,
    required this.prov,
    required this.onScanJobNumber,
    required this.onScanEmployee,
    required this.onClearFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: Container(
        padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey, width: 1.0),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: Row(
            children: [
              // JOBNUMBER BUTTON
              SizedBox(
                width: widthApp * 0.25,
                child: OutlinedButton(
                  onPressed: prov.isFilterActive
                      ? null
                      : () async {
                          await onScanJobNumber();
                        },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 16),
                    side: BorderSide(
                      color: prov.isFilterActive
                          ? Colors.grey.shade400
                          : Colors.green.shade400,
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.search_sharp,
                        size: 18,
                        color: prov.isFilterActive
                            ? Colors.grey.shade400
                            : Colors.green.shade400,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'JOBNUMBER',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: prov.isFilterActive
                                ? Colors.grey.shade400
                                : Colors.green.shade400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: widthApp * 0.01),

              // OPERATOR BUTTON
              SizedBox(
                width: widthApp * 0.25,
                child: OutlinedButton(
                  onPressed: prov.isFilterActive
                      ? null
                      : () async {
                          await onScanEmployee();
                        },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 16),
                    side: BorderSide(
                      color: prov.isFilterActive
                          ? Colors.grey.shade400
                          : Colors.green.shade400,
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_search,
                        size: 18,
                        color: prov.isFilterActive
                            ? Colors.grey.shade400
                            : Colors.green.shade400,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'OPERATOR',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: prov.isFilterActive
                                ? Colors.grey.shade400
                                : Colors.green.shade400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: widthApp * 0.01),

              // CLEAR BUTTON (Circle gradient)

              if (prov.isFilterActive)
                SizedBox(
                  width: 45,
                  child: InkWell(
                    onTap: onClearFilter,
                    borderRadius: BorderRadius.circular(30),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.redAccent, Colors.red.shade900],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 5,
                            offset: const Offset(1, 2),
                          ),
                        ],
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(10),
                        child: Icon(Icons.clear, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ),

              const Spacer(),

              SizedBox(width: widthApp * 0.02),

              // TOTAL DATA TEXT
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: RichText(
                    textAlign: TextAlign.right,
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        shadows: [
                          Shadow(
                            offset: const Offset(1, 1),
                            blurRadius: 2,
                            color: Colors.grey.withValues(alpha: 0.4),
                          ),
                        ],
                      ),
                      children: [
                        TextSpan(
                          text: 'TOTAL ',
                          style: GoogleFonts.poppins(
                            color: Colors.blueGrey.shade400,
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                        ),
                        WidgetSpan(
                          child: ShaderMask(
                            shaderCallback: (bounds) => LinearGradient(
                              colors: [
                                Colors.red.shade400,
                                Colors.red.shade800,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(
                              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                            ),
                            child: Text(
                              '${prov.filteredPending.length}',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        TextSpan(
                          text: ' MOLD STOP',
                          style: GoogleFonts.poppins(
                            color: Colors.blueGrey.shade400,
                            fontWeight: FontWeight.w500,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
