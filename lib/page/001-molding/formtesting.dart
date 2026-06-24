import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_provider_data/config/app_config.dart';

class FormTesting extends StatefulWidget {
  final String title;
  final String idProses;

  const FormTesting({
    super.key,
    required this.title,
    required this.idProses,
  });

  @override
  State<FormTesting> createState() => _FormTestingState();
}

class _FormTestingState extends State<FormTesting> {
  bool isSubmitting = false;

  final jobNumberController = TextEditingController();

  String jobNumber = "JN001";
  String jobDate = "2025-10-31";
  String jobProcess = "MOULDING";
  String batchNumber = "B001";
  String lotNumber = "L001";
  String totalLotNumber = "100";
  String categoryProduct = "METAL PILL";
  String typeProduct = "TYPE A";
  String germanSilverLn = "GS001";
  String uedaUshinLn = "UU001";
  String materialLn = "M001";
  String carbonLot = "C001";
  String nameEmployee2 = "John Doe";
  String nrp = "EMP001";
  String division = "PRODUCTION";
  String section = "MOLD";
  String photoEmployee = "${AppConfig.baseUrl}/media/img/employee/employee.png";

  String _formatDateTime(String date) => date;

  void resetForm() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Form reset."),
        backgroundColor: Colors.blue.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double widthApp = MediaQuery.of(context).size.width;
    double heightApp = MediaQuery.of(context).size.height;
    double paddingTop = MediaQuery.of(context).padding.top;
    bool isTablet = widthApp > 600;

    final myAppBar = PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.blue.shade800],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: AppBar(
          title: Text(
            'MOLDING TESTING',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
    );

    double heightBody = heightApp - paddingTop - myAppBar.preferredSize.height;

    // double conTextfieldHeight = isTablet ? heightBody * 0.2 : heightBody * 0.55;

    return Scaffold(
      appBar: myAppBar,
      backgroundColor: Colors.blue.shade50,
      body: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.all(isTablet ? 5.0 : 3.0),
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              // HEADER WARNING TEXT
              Container(
                width: widthApp,
                padding:
                    const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade800],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade600.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(2, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: AnimatedHeaderText(),
                ),
              ),

              const SizedBox(height: 10),

              // EMPLOYEE CARD
              Container(
                width: widthApp,
                height: heightBody * 0.26,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade100,
                      Colors.blue.shade200,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade300, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade300.withValues(alpha: 0.4),
                      blurRadius: 6,
                      offset: const Offset(2, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // FOTO
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Column(
                          children: [
                            Expanded(
                              flex: 6,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  photoEmployee,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    nameEmployee2,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade900,
                                    ),
                                  ),
                                  Text(
                                    nrp,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                  Text(
                                    "$division • $section",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.indigo.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // TABEL INFO
                    Expanded(
                      flex: 7,
                      child: Container(
                        margin: const EdgeInsets.all(6),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue.shade200),
                          borderRadius: BorderRadius.circular(10),
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade50, Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Table(
                          border: TableBorder.symmetric(
                            inside: BorderSide(color: Colors.blue.shade100),
                          ),
                          columnWidths: const {
                            0: FlexColumnWidth(0.4),
                            1: FlexColumnWidth(0.6),
                          },
                          children: _buildTableRows(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // BUTTONS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // SUBMIT
                  Expanded(
                    flex: 5,
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade400, Colors.blue.shade800],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.shade400.withValues(alpha: 0.4),
                            blurRadius: 5,
                            offset: const Offset(2, 3),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: isSubmitting ? null : () {},
                        child: Text(
                          isSubmitting ? "SUBMITTING..." : "SUBMIT",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // CANCEL
                  Expanded(
                    flex: 5,
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade100, Colors.white],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border:
                            Border.all(color: Colors.blue.shade400, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.shade200.withValues(alpha: 0.4),
                            blurRadius: 5,
                            offset: const Offset(2, 3),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: resetForm,
                        child: Text(
                          "CANCEL",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  List<TableRow> _buildTableRows() {
    final data = [
      ["JOB NUMBER", jobNumber],
      ["DATE", _formatDateTime(jobDate)],
      ["PROCESS", jobProcess],
      ["JOBCODE", batchNumber],
      ["LOT NUMBER", lotNumber],
      ["TOTAL LOT", totalLotNumber],
      ["CATEGORY", categoryProduct],
      ["TYPE", typeProduct],
      ["GOLD PILL LOT", "$germanSilverLn $uedaUshinLn $materialLn"],
      ["CARBON PILL LOT", carbonLot],
    ];

    return List.generate(data.length, (index) {
      final rowGradient = LinearGradient(
        colors: index.isEven
            ? [Colors.blue.shade50, Colors.white]
            : [Colors.white, Colors.blue.shade50],
      );

      return TableRow(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 5),
            decoration: BoxDecoration(gradient: rowGradient),
            child: Text(
              data[index][0],
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade900,
                fontSize: 14,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 5),
            decoration: BoxDecoration(gradient: rowGradient),
            child: Text(
              ": ${data[index][1]}",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.blue.shade800,
              ),
            ),
          ),
        ],
      );
    });
  }
}

/// ⚠️ Animated header with warning vibe
class AnimatedHeaderText extends StatelessWidget {
  const AnimatedHeaderText({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedTextKit(
      repeatForever: true,
      pause: const Duration(milliseconds: 1000),
      animatedTexts: [
        ColorizeAnimatedText(
          '⚠️ ONCE TESTING FOR ONE SHOOT ⚠️',
          textStyle: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
          colors: [
            Colors.redAccent,
            Colors.orangeAccent,
            Colors.yellow.shade600,
            Colors.white,
            Colors.redAccent,
          ],
          speed: const Duration(milliseconds: 200),
        ),
      ],
    );
  }
}
