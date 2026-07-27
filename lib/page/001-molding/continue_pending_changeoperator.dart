import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/ng_operator_model.dart';
import 'package:flutter_provider_data/model/record_pending_detail_model.dart';
import 'package:flutter_provider_data/provider/employee_provider.dart';
import 'package:flutter_provider_data/provider/pending_provider.dart';
import 'package:flutter_provider_data/utils/custom_button.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:flutter_provider_data/utils/mobile_scanner_page.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class ContinuePendingChangeOperator extends StatefulWidget {
  final String idPending;
  final void Function(bool)? onSuccess;

  const ContinuePendingChangeOperator({
    super.key,
    required this.idPending,
    this.onSuccess,
  });

  @override
  State<ContinuePendingChangeOperator> createState() =>
      _ContinuePendingChangeOperatorState();
}

class _ContinuePendingChangeOperatorState
    extends State<ContinuePendingChangeOperator> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final prov = context.read<PendingProvider>();

      prov.resetPendingDetail();
      prov.clearNextMachine();
      prov.resetEmployeeScanState();

      await prov.loadPendingDetailWithNg(int.parse(widget.idPending));
    });
  }

  Widget recordHeaderRow({
    required String idRecord,
    required String customer,
    required String productCategory,
    required String productType,
  }) {
    final textStyle = GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blueAccent,
            Colors.blue.shade900,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(idRecord, style: textStyle),
          Text(customer, style: textStyle),
          Text(productCategory, style: textStyle),
          Text(productType, style: textStyle),
        ],
      ),
    );
  }

  Widget employeePhotoCard({
    required String employeeId,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double size = MediaQuery.of(context).size.width * 0.18;

        return Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 🔹 Outer soft aura (ambient glow)
              Container(
                width: size + 32,
                height: size + 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.greenAccent.withValues(alpha: 0.18),
                      blurRadius: 60,
                      spreadRadius: 8,
                    ),
                  ],
                ),
              ),

              // 🔹 Inner focused aura
              Container(
                width: size + 14,
                height: size + 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.greenAccent.withValues(alpha: 0.25),
                      blurRadius: 28,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),

              // 🔹 Photo
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.blueGrey.withValues(alpha: 0.5),
                    width: 2,
                  ),
                  image: DecorationImage(
                    image: NetworkImage(
                      "${AppConfig.baseUrl}/media/img/employee/$employeeId.png",
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget employeeInfoSection({
    required String name,
    required String nrp,
    required String division,
    required String section,
  }) {
    return Column(
      children: [
        Text(
          name,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          nrp,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          division,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          section,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget employeeActionButtons({
    required BuildContext context,
    required PendingProvider provider,
  }) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: customOutlinedButton(
            text: 'CANCEL',
            borderColor: Colors.red,
            textColor: Colors.red,
            fontSize: 20,
            height: 75,
            onPressed: () {
              provider.resetNextOperatorState();
              context.read<EmployeeProvider>().clearEmployee();

              Navigator.of(context).pop();
            },
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: buildCustomButton(
            text: 'CONFIRM',
            height: 75,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            gradient: LinearGradient(
              colors: [Colors.greenAccent, Colors.green.shade900],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            onPressed: () async {
              final ctx = context; // ⬅ simpan context aman sebelum async gap
              final overlay = Overlay.of(ctx, rootOverlay: true);

              final employeeProv = ctx.read<EmployeeProvider>();
              final pendingProv = ctx.read<PendingProvider>();

              final code = await Navigator.push<String>(
                ctx,
                MaterialPageRoute(builder: (_) => const MobileScannerPage()),
              );
              if (!ctx.mounted) return;
              if (code == null || code.isEmpty || code == "-1") return;
              // ✅ VALIDASI OPERATOR TIDAK BOLEH SAMA
              final currentOperatorId = pendingProv.ngDetail.idEmployee;
              if (code == currentOperatorId) {
                CustomSnackbar.showWithOverlay(
                  overlay,
                  "ID EMPLOYEE TIDAK BOLEH SAMA, HARUS OPERATOR BARU",
                  isSuccess: false,
                );
                return;
              }

              // 🔥 Scan employee lewat EmployeeProvider
              final success = await employeeProv.scanEmployee(code);

              if (!ctx.mounted) return;

              if (!success) {
                CustomSnackbar.showWithOverlay(
                  overlay,
                  employeeProv.errorMessage ?? "Employee scan failed",
                  isSuccess: false,
                );
                return;
              }

              // 🔥 Employee valid → simpan ke PendingProvider
              pendingProv.attachEmployee(employeeProv.employee);
            },
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: buildCustomButton(
            text: 'SUBMIT',
            height: 75,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            gradient: (provider.hasConfirmedEmployee && !provider.isSubmitting)
                ? LinearGradient(
                    colors: [
                      Colors.blueAccent,
                      Colors.blue.shade600,
                      Colors.blue.shade900,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : LinearGradient(
                    colors: [
                      Colors.grey.shade400,
                      Colors.grey.shade600,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
            onPressed: (provider.hasConfirmedEmployee && !provider.isSubmitting)
                ? () async {
                    final data = provider.ngDetail;

                    // ✅ Aman karena sebelum await
                    if (data.isEmpty) {
                      CustomSnackbar.show(
                        context,
                        "Data pending kosong",
                        isSuccess: false,
                      );
                      return;
                    }

                    // ✅ Simpan semua reference sebelum await
                    final navigator =
                        Navigator.of(context, rootNavigator: true);

                    final success = await provider.updateRecordOpChange(
                      idPending: data.idPending,
                    );

                    if (!mounted) return;
                    // 🔥 TAMBAHAN: refresh list-nya di sini, gak gantung ke pop chain
                    if (success) {
                      await provider.fetchPending('001');
                    }

                    if (!mounted) return;

                    if (widget.onSuccess != null) {
                      widget.onSuccess!(success);
                    }

                    navigator.pop(success);
                  }
                : null,
          ),
        ),
      ],
    );
  }

  Widget pendingDetailSection({
    required RecordPendingDetailModel data, // ✅ ganti type
  }) {
    return Expanded(
      flex: 7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 7,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: _pendingInfoTable(data), // ✅ langsung pass
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                _pendingNgSection(data), // ✅ langsung pass
              ],
            ),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget _pendingInfoTable(RecordPendingDetailModel data) {
    // ✅ ganti type
    final rows = [
      ('JOBNUMBER', data.jobnumber.toString(), true), // ✅
      ('MACHINE', data.machineName, false), // ✅
      ('BCODE', data.bcode, false), // ✅
      ('QTY', data.qty.toString(), false), // ✅
      ('START JOB', formatDateTime(data.startTime), false), // ✅
      ('PENDING TIME', formatDateTime(data.startPending), false), // ✅
      ('REASON', data.reason.toString(), false), // ✅
      ('TOTAL SHOOT', data.shootQty.toString(), false), // ✅
      ('DONE SHOOT', data.shootTotal.toString(), false), // ✅
    ];

    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FixedColumnWidth(20),
        2: FlexColumnWidth(2),
      },
      children: List.generate(rows.length, (index) {
        final item = rows[index];
        final bool isReason = item.$1 == 'REASON';
        return _tableRow(
          label: item.$1,
          value: item.$2,
          isBold: isReason,
          valueColor: isReason ? Colors.red : null,
          index: index,
        );
      }),
    );
  }

  TableRow _tableRow({
    required String label,
    required String value,
    required int index,
    bool isBold = false,
    Color? valueColor,
  }) {
    return TableRow(
      decoration: BoxDecoration(
        color: index.isEven
            ? Colors.indigo.shade200.withValues(alpha: 0.15) // baris genap
            : Colors.white, // baris ganjil
        border: const Border(
          bottom: BorderSide(color: Colors.grey),
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(6),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(6),
          child: Text(':', textAlign: TextAlign.center),
        ),
        Padding(
          padding: const EdgeInsets.all(6),
          child: Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _pendingNgSection(RecordPendingDetailModel data) {
    // ✅ ganti type
    final ngList = data.ngList; // ✅

    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              children: [
                const TextSpan(text: 'NG LIST OLEH OPERATOR '),
                TextSpan(
                  text: data.employeeName, // ✅
                  style: const TextStyle(color: Colors.blue),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          if (ngList.length == 1 &&
              ngList[0].idNg == '000000' &&
              ngList[0].ngName.toUpperCase() == 'NO NG')
            Text(
              'SO FAR IS GOOD NO NG FOUND.',
              style: TextStyle(color: Colors.green.shade800),
            )
          else
            _ngTable(ngList),
        ],
      ),
    );
  }

  Widget _ngTable(List<NgOperatorModel> ngList) {
    // ✅ ganti type
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Table(
              border: TableBorder.all(color: Colors.grey.shade400),
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(4),
                2: FlexColumnWidth(1),
              },
              children: [
                _ngHeaderRow(),
                ...ngList.asMap().entries.map((entry) {
                  final index = entry.key;
                  final ng = entry.value;
                  final bool isEven = index.isEven;

                  return TableRow(
                    decoration: BoxDecoration(
                      color: isEven
                          ? Colors.indigo.shade200.withValues(alpha: 0.15)
                          : Colors.white,
                    ),
                    children: [
                      _ngCell((index + 1).toString(), alignCenter: true),
                      _ngCell(ng.ngName),
                      _ngCell(ng.qty.toString(), alignCenter: true),
                    ],
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  TableRow _ngHeaderRow() {
    return TableRow(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.blue.shade900],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      children: [
        _ngHeaderCell('NO'),
        _ngHeaderCell('NG NAME'),
        _ngHeaderCell('QTY'),
      ],
    );
  }

  Widget _ngHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _ngCell(String text, {bool alignCenter = false}) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Text(
        text,
        textAlign: alignCenter ? TextAlign.center : TextAlign.left,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myAppBar = customDialogAppBar(
      title: 'CONTINUE RUNNING',
    );

    return Scaffold(
        appBar: myAppBar,
        body: Consumer<PendingProvider>(
          builder: (context, provider, _) {
            if (provider.isNgLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.ngError != null) {
              return Center(child: Text('Error: ${provider.ngError}'));
            }

            if (provider.ngDetail.isEmpty) {
              return const Center(
                  child: Text('TIDAK ADA MOLDING YANG STOP SAAT INI'));
            }

            final data = provider.ngDetail;

            return SingleChildScrollView(
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(children: [
                    recordHeaderRow(
                      idRecord: data.idRecord, // ✅
                      customer: data.customer, // ✅
                      productCategory: data.productCategory, // ✅
                      productType: data.productType, // ✅
                    ),
                    SizedBox(height: 10.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                employeePhotoCard(
                                  employeeId: data.idEmployee, // ✅
                                ),
                                const SizedBox(height: 12),
                                employeeInfoSection(
                                  name: data.employeeName, // ✅
                                  nrp: data.nrp, // ✅
                                  division: data.division, // ✅
                                  section: data.section, // ✅
                                ),
                                const SizedBox(height: 20),
                                employeeActionButtons(
                                  context: context,
                                  provider: provider,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        pendingDetailSection(
                          data: data, // ✅ langsung pass data
                        ),
                      ],
                    ),
                    SizedBox(height: 10.0),
                    jobNumberBanner(
                      jobNumber: data.jobnumber.toString(), // ✅
                    ),
                    SizedBox(height: 10.0),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: nextOperatorCard(
                            photoUrl:
                                "${AppConfig.baseUrl}/media/img/employee/${provider.photoNextOperator}",
                            name: provider.nameNextOperator,
                            nrp: provider.nrpNextOperator,
                            division: provider.divNextOperator,
                            section: provider.secNextOperator,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 7,
                          child: nextMachineInfoTable(
                            sisaShoot: data.sisaShoot, // ✅
                            machineName: data.machineName, // ✅
                            nextOperatorName: provider.nameNextOperator,
                          ),
                        ),
                      ],
                    ),
                  ]),
                ),
              ),
            );
          },
        ));
  }

  Widget jobNumberBanner({
    required String jobNumber,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.cyanAccent,
            Colors.cyan.shade900,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Center(
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: "CONTINUE RUNNING MOLDING FOR JOBNUMBER ",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white, // 🔥 biar kontras
                ),
              ),
              TextSpan(
                text: jobNumber,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.yellowAccent, // 🔥 highlight
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget nextOperatorCard({
    required String photoUrl,
    required String name,
    required String nrp,
    required String division,
    required String section,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 🔹 Photo (STRUCTURE & SIZE SAMA)
        LayoutBuilder(
          builder: (context, constraints) {
            final double size = MediaQuery.of(context).size.width * 0.18;

            return Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer soft aura
                  Container(
                    width: size + 32,
                    height: size + 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.2),
                          blurRadius: 60,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                  ),

                  // Inner focused aura
                  Container(
                    width: size + 14,
                    height: size + 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.greenAccent.withValues(alpha: 0.15),
                          blurRadius: 28,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),

                  // Photo
                  Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.25),
                        width: 2,
                      ),
                      image: DecorationImage(
                        image: NetworkImage(photoUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // 🔹 Name
        Text(
          name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),

        const SizedBox(height: 6),

        // 🔹 NRP
        Text(
          nrp,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            letterSpacing: 0.6,
          ),
        ),

        const SizedBox(height: 6),

        // 🔹 Division
        Text(
          division,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),

        const SizedBox(height: 4),

        // 🔹 Section
        Text(
          section,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  Widget nextMachineInfoTable({
    required int sisaShoot,
    required String machineName,
    required String nextOperatorName,
  }) {
    final rows = [
      ('SISA SHOOT', sisaShoot.toString(), true, null),
      ('MACHINE', machineName, true, null),
      ('NEXT OPERATOR', nextOperatorName, true, Colors.green),
    ];

    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(1.2), // ⬅ lebih kecil
          1: FixedColumnWidth(20),
          2: FlexColumnWidth(2.8), // ⬅ geser sisa ke kanan
        },
        children: List.generate(rows.length, (index) {
          final item = rows[index];
          final bool isEven = index.isEven;

          return _tableRow2(
            label: item.$1,
            value: item.$2,
            isBold: item.$3,
            valueColor: item.$4,
            backgroundColor: isEven
                ? Colors.indigo.shade200.withValues(alpha: 0.15)
                : Colors.white,
          );
        }),
      ),
    );
  }

  TableRow _tableRow2({
    required String label,
    required String value,
    bool isBold = false,
    Color? valueColor,
    Color? backgroundColor,
  }) {
    return TableRow(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: const Border(
          bottom: BorderSide(color: Colors.grey),
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(6),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.all(6),
          child: Text(
            ':',
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(6),
          child: Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}
