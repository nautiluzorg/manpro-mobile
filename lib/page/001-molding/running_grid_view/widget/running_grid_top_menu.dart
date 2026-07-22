import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_provider_data/provider/running_provider.dart';

class RunningGridTopMenu extends StatelessWidget {
  final double widthApp;
  final RunningProvider prov;
  final Future<void> Function() onScanJobNumber;
  final Future<void> Function() onScanEmployee;
  final VoidCallback onClearFilter;
  final VoidCallback onStopSelected;

  const RunningGridTopMenu({
    super.key,
    required this.widthApp,
    required this.prov,
    required this.onScanJobNumber,
    required this.onScanEmployee,
    required this.onClearFilter,
    required this.onStopSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Container(
        padding: const EdgeInsets.only(bottom: 4.0),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey, width: 1.0)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            children: [
              // JOBNUMBERS BUTTON
              SizedBox(
                width: widthApp * 0.24,
                child: OutlinedButton(
                  onPressed: prov.isFilterSearchActive ? null : onScanJobNumber,
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    side: BorderSide(
                      color: prov.isFilterSearchActive
                          ? Colors.grey.shade400
                          : Colors.blue.shade400,
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
                        Icons.search_sharp,
                        size: 18,
                        color: prov.isFilterSearchActive
                            ? Colors.grey.shade400
                            : Colors.blue.shade400,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'JOBNUMBER',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: prov.isFilterSearchActive
                                ? Colors.grey.shade400
                                : Colors.blue.shade400,
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
                  onPressed: prov.isFilterSearchActive ? null : onScanEmployee,
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    side: BorderSide(
                      color: prov.isFilterSearchActive
                          ? Colors.grey.shade400
                          : Colors.blue.shade400,
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
                        color: prov.isFilterSearchActive
                            ? Colors.grey.shade400
                            : Colors.blue.shade400,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'OPERATOR',
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: prov.isFilterSearchActive
                                ? Colors.grey.shade400
                                : Colors.blue.shade400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 2),

              // Clear filter
              SizedBox(
                width: 45,
                child: prov.isFilterSearchActive
                    ? InkWell(
                        onTap: onClearFilter,
                        borderRadius: BorderRadius.circular(30),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.red.shade400,
                                Colors.red.shade900,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
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
                            child: Icon(
                              Icons.clear,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox(),
              ),
              const SizedBox(width: 1),
              // const Spacer(),

              // Stop Selected

              SizedBox(
                width: widthApp * 0.15,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: prov.selectedItems.isEmpty
                          ? [Colors.grey.shade400, Colors.grey.shade500]
                          : [Colors.redAccent, Colors.red.shade900],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: OutlinedButton(
                    onPressed:
                        prov.selectedItems.isEmpty ? null : onStopSelected,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 16),
                      backgroundColor: Colors.transparent,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.stop_circle,
                          size: 18,
                          color: prov.selectedItems.isEmpty
                              ? Colors.grey.shade300
                              : Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'STOP',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: prov.selectedItems.isEmpty
                                  ? Colors.grey.shade300
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 1),

              // Total + label
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
                          text: ' TOTAL ',
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
                                Colors.blue.shade400,
                                Colors.blue.shade800
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ).createShader(
                              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                            ),
                            child: Text(
                              '${prov.filteredRecords.length}',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                        TextSpan(
                          text: ' MOLD RUNNING ',
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
