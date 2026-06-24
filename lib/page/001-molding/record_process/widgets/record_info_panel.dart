import 'package:flutter/material.dart';
import 'package:flutter_provider_data/provider/jobnumber_provider.dart';
import 'package:flutter_provider_data/provider/material_provider.dart';
import 'package:flutter_provider_data/provider/employee_provider.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_provider_data/utils/logger.dart';

class RecordInfoPanel extends StatelessWidget {
  final double heightBody;
  final double widthApp;

  const RecordInfoPanel({
    super.key,
    required this.heightBody,
    required this.widthApp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widthApp,
      height: heightBody * 0.26,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF3FF),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 2.0,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Consumer<EmployeeProvider>(
                  builder: (context, employeeProvider, child) {
                    final employee = employeeProvider.employee;

                    return Container(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 2.0,
                        vertical: 2.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade600,
                          width: 0.5,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                      ),
                      child: Column(
                        children: [
                          // FOTO EMPLOYEE
                          Expanded(
                            flex: 6,
                            child: Container(
                              margin: const EdgeInsets.only(top: 5.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2.0,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: employee.idEmployee.isEmpty
                                    ? Image.network(
                                        "${AppConfig.baseUrl}/media/img/employee/employee.png",
                                        fit: BoxFit.cover,
                                      )
                                    : Image.network(
                                        "${AppConfig.baseUrl}/media/img/employee/${employee.idEmployee}.png",
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            Image.network(
                                          "${AppConfig.baseUrl}/media/img/employee/employee.png",
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                              ),
                            ),
                          ),

                          // NAMA & NRP
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.all(2.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    employee.fullName,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700,
                                      fontSize: constraints.maxWidth * 0.08,
                                    ),
                                  ),
                                  const SizedBox(height: 1.0),
                                  Text(
                                    employee.nrp,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade700,
                                      fontSize: constraints.maxWidth * 0.06,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // DIVISI & SECTION
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.all(1.0),
                              margin: const EdgeInsets.only(bottom: 5.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    employee.division,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey.shade700,
                                      fontSize: constraints.maxWidth * 0.06,
                                    ),
                                  ),
                                  Text(
                                    employee.section,
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w400,
                                      color: Colors.grey.shade700,
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
            ),
          ),
          Expanded(
            flex: 7,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Consumer2<JobNumberProvider, MaterialProvider>(
                  builder:
                      (context, jobNumberProvider, materialProvider, child) {
                    final jobNumber = jobNumberProvider.jobNumber;
                    final batchNumber = jobNumberProvider.batchNumber;
                    final lotNumber = jobNumberProvider.lotNumber;
                    final totalLotNumber = jobNumberProvider.totalLotNumber;
                    final categoryProduct = jobNumberProvider.productCategory;
                    final typeProduct = jobNumberProvider.productType;

                    final jobDate = jobNumberProvider.jobDate;
                    final jobProcess = jobNumberProvider.jobProcess;

                    // --- Ambil data MaterialProvider ---
                    final germanSilverLn =
                        materialProvider.goldPillData.germanSilverLotNumber;
                    final uedaUshinLn =
                        materialProvider.goldPillData.uedaUshinLotNumber;
                    final materialLn =
                        materialProvider.goldPillData.materialLotNumber;
                    final carbonLot =
                        materialProvider.carbonPillData.carbonLotNumber;

                    final data = [
                      ["JOB NUMBER", jobNumber],
                      ["DATE", formatDateTime(jobDate)],
                      ["PROCESS", jobProcess],
                      ["JOBCODE", batchNumber],
                      ["LOT NUMBER", lotNumber],
                      ["TOTAL LOT", totalLotNumber],
                      ["CATEGORY", categoryProduct],
                      ["TYPE", typeProduct],
                      [
                        "GOLD PILL LOT",
                        "$germanSilverLn  $uedaUshinLn  $materialLn",
                      ],
                      ["CARBON PILL LOT", carbonLot],
                    ];

                    return Container(
                      height: constraints.maxHeight,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 2, vertical: 2),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: Colors.grey.shade400, width: 0.5),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: Table(
                          border: TableBorder(
                            bottom: const BorderSide(
                                color: Colors.grey, width: 1.0),
                            horizontalInside: const BorderSide(
                                color: Colors.grey, width: 0.5),
                          ),
                          columnWidths: const {
                            0: FlexColumnWidth(0.4),
                            1: FlexColumnWidth(0.6),
                          },
                          children: List.generate(data.length, (index) {
                            final rowColor = index % 2 == 0
                                ? Colors.grey.shade100
                                : Colors.white;

                            return TableRow(
                              children: [
                                Container(
                                  color: rowColor,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 6.0),
                                  child: Text(
                                    data[index][0],
                                    style: GoogleFonts.poppins(
                                      fontWeight: data[index][0] == "JOB NUMBER"
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                      fontSize: constraints.maxWidth * 0.025,
                                      color: Colors.blue.shade900,
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                                Container(
                                  color: rowColor,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 6.0),
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Text(
                                      ": ${data[index][1]}",
                                      style: GoogleFonts.poppins(
                                        fontWeight:
                                            data[index][0] == "JOB NUMBER"
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                        fontSize: constraints.maxWidth * 0.025,
                                        color: Colors.grey.shade800,
                                      ),
                                      softWrap: false,
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
            ),
          ),
        ],
      ),
    );
  }
}
