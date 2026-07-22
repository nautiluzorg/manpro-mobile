import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:flutter_provider_data/provider/testing_provider.dart';
import 'package:flutter_provider_data/utils/logger.dart';

// NOTE: `formatDateTimeFromDateBln` is used exactly as it was in the
// original file. It isn't defined in this widget — keep whatever import
// your project already uses for it available in this file if the analyzer
// complains (it wasn't shown in the source file provided for this refactor).

/// The 30%-height summary row shown above the scan form: employee photo
/// card (30% width) + job info key/value table (70% width).
///
/// Extracted verbatim from record_testing.dart's build() method — same
/// Consumer<TestingProvider> reads, same layout math, same field list.
class EmployeeJobInfoPanel extends StatelessWidget {
  final double height;

  const EmployeeJobInfoPanel({super.key, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEEF2FF), Color(0xFFD6E0FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.grey.shade400, width: 2.0),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withValues(alpha: 0.2),
            offset: const Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: _EmployeePhotoCard()),
          Expanded(flex: 7, child: _JobInfoTable()),
        ],
      ),
    );
  }
}

class _EmployeePhotoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TestingProvider>(
      builder: (context, provider, _) {
        final employee = provider.employee;
        final photoUrl = employee.isValid
            ? "${AppConfig.baseUrl}/media/img/employee/${employee.idEmployee}.png"
            : "${AppConfig.baseUrl}/media/img/employee/employee.png";

        return LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              margin:
                  const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.blueGrey.shade200,
                  width: 0.5,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Expanded(
                    flex: 6,
                    child: Container(
                      margin: const EdgeInsets.only(top: 5.0),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blueGrey.shade100,
                          width: 2.0,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.network(photoUrl, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            employee.fullName.isNotEmpty
                                ? employee.fullName
                                : "EMPLOYEE NAME",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              color: Colors.blueGrey.shade900,
                              fontSize: constraints.maxWidth * 0.08,
                            ),
                          ),
                          const SizedBox(height: 1.0),
                          Text(
                            employee.nrp.isNotEmpty ? employee.nrp : "NRP",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              color: Colors.blueGrey.shade700,
                              fontSize: constraints.maxWidth * 0.06,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(2.0),
                      margin: const EdgeInsets.only(bottom: 5.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            employee.division.isNotEmpty
                                ? employee.division
                                : "DIVISION",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              color: Colors.blueGrey.shade700,
                              fontSize: constraints.maxWidth * 0.06,
                            ),
                          ),
                          Text(
                            employee.section.isNotEmpty
                                ? employee.section
                                : "SECTION",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w400,
                              color: Colors.blueGrey.shade600,
                              fontSize: constraints.maxWidth * 0.05,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _JobInfoTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<TestingProvider>(
      builder: (context, provider, _) {
        final jobNumber =
            provider.jobNumber.isNotEmpty ? provider.jobNumber : "";
        final jobDate = provider.jobDate;
        final jobProcess =
            provider.nmProses.isNotEmpty ? provider.nmProses : "";
        final batchNumber =
            provider.batchNumber.isNotEmpty ? provider.batchNumber : "";
        final drawno =
            provider.drawNumber.isNotEmpty ? provider.drawNumber : "";
        final lotNumber =
            provider.lotNumber.isNotEmpty ? provider.lotNumber : "";
        final totalLotNumber =
            provider.totalLotNumber.isNotEmpty ? provider.totalLotNumber : "";
        final qty = provider.qty.isNotEmpty ? provider.qty : "";
        final categoryProduct =
            provider.productCategory.isNotEmpty ? provider.productCategory : "";
        final typeProduct =
            provider.productType.isNotEmpty ? provider.productType : "";
        final germanSilverLn = provider.goldPill?.germanSilverLotNumber ?? "";
        final uedaUshinLn = provider.goldPill?.uedaUshinLotNumber ?? "";
        final materialLn = provider.goldPill?.materialLotNumber ?? "";
        final carbonLot = provider.carbonPill?.carbonLotNumber ?? "";
        final moldCavity = provider.selectedMoldCavity?.toString() ?? '';
        final totalShoot =
            provider.totalShootQty > 0 ? provider.totalShootQty.toString() : '';

        final data = [
          [
            "DATE & TIME",
            jobDate != null ? formatDateTimeFromDateBln(jobDate) : ""
          ],
          ["JOB NUMBER", jobNumber],
          ["PROCESS", jobProcess],
          ["JOBCODE", batchNumber],
          ["LOT NUMBER", lotNumber],
          ["MOLD CAVITY", moldCavity],
          ["TOTAL SHOOT", totalShoot],
          ["DRAW NUMBER", drawno],
          ["TOTAL LOT", totalLotNumber],
          ["QTY", qty],
          ["CATEGORY", categoryProduct],
          ["TYPE", typeProduct],
          ["GOLD PILL LOT NO", "$germanSilverLn  $uedaUshinLn  $materialLn"],
          ["CARBON PILL LOT NO", carbonLot],
        ];

        return LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              height: constraints.maxHeight * 1,
              margin:
                  const EdgeInsets.symmetric(horizontal: 6.0, vertical: 10.0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.blueGrey.shade100, width: 0.5),
                borderRadius: const BorderRadius.all(Radius.circular(12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueGrey.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Table(
                  border: TableBorder(
                    bottom:
                        BorderSide(color: Colors.blueGrey.shade200, width: 1.0),
                    horizontalInside:
                        BorderSide(color: Colors.blueGrey.shade100, width: 0.5),
                  ),
                  columnWidths: const {
                    0: FlexColumnWidth(0.4),
                    1: FlexColumnWidth(0.6),
                  },
                  children: List.generate(data.length, (index) {
                    final rowColor =
                        index % 2 == 0 ? Colors.blueGrey.shade50 : Colors.white;
                    final isJobNumberRow = data[index][0] == "JOB NUMBER";

                    return TableRow(
                      children: [
                        Container(
                          color: rowColor,
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 6.0),
                          child: Text(
                            data[index][0],
                            style: GoogleFonts.poppins(
                              fontWeight: isJobNumberRow
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              fontSize: constraints.maxWidth * 0.025,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ),
                        Container(
                          color: rowColor,
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 6.0),
                          child: Text(
                            ": ${data[index][1]}",
                            style: GoogleFonts.poppins(
                              fontWeight: isJobNumberRow
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              fontSize: constraints.maxWidth * 0.025,
                              color: Colors.blueGrey.shade800,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
