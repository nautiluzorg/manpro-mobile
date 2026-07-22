import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_provider_data/page/menu.dart';
import 'package:flutter_provider_data/provider/testing_provider.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:flutter_provider_data/page/001-molding/record_testing/widgets/warning_banner.dart';
import 'package:flutter_provider_data/page/001-molding/record_testing/widgets/submit_clear_buttons.dart';
import 'package:flutter_provider_data/page/001-molding/record_testing/widgets/section_header.dart';
import 'package:flutter_provider_data/page/001-molding/record_testing/widgets/scan_form_grid.dart';
import 'package:flutter_provider_data/page/001-molding/record_testing/widgets/note_panel.dart';
import 'package:flutter_provider_data/page/001-molding/record_testing/widgets/machine_parameter_table.dart';
import 'package:flutter_provider_data/page/001-molding/record_testing/widgets/employee_job_info_panel.dart';
import 'package:flutter_provider_data/page/001-molding/record_testing/widgets/checklist_table.dart';
import 'package:flutter_provider_data/page/001-molding/record_testing/data/checklist_data.dart';

/// RECORD TESTING page.
///
/// This class only owns page-level concerns now: text controllers, screen
/// orientation lifecycle, and syncing the machine-temperature controllers
/// with TestingProvider on first load. All section UIs live under
/// `record_testing/widgets/` and both dialogs and checklist/business data
/// live under their own folders — see that directory for the pieces this
/// page assembles.
class RecordTesting extends StatefulWidget {
  final String title;
  final String idProses;

  const RecordTesting({
    super.key,
    required this.title,
    required this.idProses,
  });

  @override
  State<RecordTesting> createState() => _RecordTestingState();
}

class _RecordTestingState extends State<RecordTesting>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  bool _isFormInitialized = false;

  final mixLotNumberController = TextEditingController();
  final idEmployeeController = TextEditingController();
  final goldPillController = TextEditingController();
  final carbonPillController = TextEditingController();
  final idMachineController = TextEditingController();
  final jobNumberController = TextEditingController();
  final qtyActualController = TextEditingController();
  final mcTempUpperCtrl = TextEditingController();
  final mcTempLowerCtrl = TextEditingController();
  final mcTempLowUpperCtrl = TextEditingController();
  final mcTempLowLowerCtrl = TextEditingController();
  final mcCuringCtrl = TextEditingController();
  final mcPressureCtrl = TextEditingController();
  final mcSettingsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final provid2 = context.watch<TestingProvider>();

    if (provid2.shouldClearMachineForm) {
      _clearFormControllers();
      provid2.acknowledgeClearMachineForm();
    }

    if (_isFormInitialized) return;

    if (provid2.mcTempUpper.isEmpty &&
        provid2.mcTempLower.isEmpty &&
        provid2.mcCuring.isEmpty) {
      return;
    }

    final valueUpper = provid2.mcTempUpper;
    final valueLower = provid2.mcTempLower;

    if (valueUpper.contains('-')) {
      final parts = valueUpper.split('-');
      mcTempUpperCtrl.text = parts[0];
      mcTempLowerCtrl.text = parts[1];
    }

    if (valueLower.contains('-')) {
      final partsLow = valueLower.split('-');
      mcTempLowUpperCtrl.text = partsLow[0];
      mcTempLowLowerCtrl.text = partsLow[1];
    }

    mcCuringCtrl.text = provid2.mcCuring;
    mcPressureCtrl.text = provid2.mcPressure;
    mcSettingsCtrl.text = provid2.mcSettings;

    _isFormInitialized = true;
  }

  void _clearFormControllers() {
    mcTempUpperCtrl.clear();
    mcTempLowerCtrl.clear();
    mcTempLowUpperCtrl.clear();
    mcTempLowLowerCtrl.clear();
    mcCuringCtrl.clear();
    mcPressureCtrl.clear();
    mcSettingsCtrl.clear();
    _isFormInitialized = false;
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _glowController.dispose();
    super.dispose();
  }

  void _saveTemp(TestingProvider prov) {
    prov.mcTempUpper = "${mcTempUpperCtrl.text}-${mcTempLowerCtrl.text}";
  }

  void _saveTempLower(TestingProvider prov) {
    prov.mcTempLower = "${mcTempLowUpperCtrl.text}-${mcTempLowLowerCtrl.text}";
  }

  @override
  Widget build(BuildContext context) {
    final widthApp = MediaQuery.of(context).size.width;
    final heightApp = MediaQuery.of(context).size.height;
    final paddingTop = MediaQuery.of(context).padding.top;

    final myAppBar = customAppBar(
      context: context,
      title: 'MOLDING TEST',
      kode: widget.idProses,
      proses: "MOLDING",
      navigateToBuilder: (kode, proses) => Menu(kode: kode, proses: proses),
    );

    final heightBody = heightApp - paddingTop - myAppBar.preferredSize.height;
    final conTextfieldHeight = heightBody * 0.12;
    final provider = context.read<TestingProvider>();

    return Scaffold(
      appBar: myAppBar,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(2.0),
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                const WarningBanner(),
                const SizedBox(height: 2.0),
                EmployeeJobInfoPanel(height: heightBody * 0.3),
                const SizedBox(height: 5.0),
                Container(
                  width: widthApp,
                  height: conTextfieldHeight,
                  padding: const EdgeInsets.all(1.0),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.shade100,
                    border: Border.all(color: Colors.grey.shade400, width: 2.0),
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  child: Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 5),
                          alignment: Alignment.center,
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            border: Border.all(
                                color: Colors.grey.shade400, width: 0.5),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8)),
                          ),
                          child: ScanFormGrid(
                            idProses: widget.idProses,
                            jobNumberController: jobNumberController,
                            mixLotNumberController: mixLotNumberController,
                            idMachineController: idMachineController,
                            idEmployeeController: idEmployeeController,
                            goldPillController: goldPillController,
                            carbonPillController: carbonPillController,
                            qtyActualController: qtyActualController,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SubmitClearButtons(width: widthApp, height: heightBody * 0.1),
                SectionHeader(title: "MOLD SETUP", width: widthApp),
                Container(
                  width: widthApp,
                  padding: const EdgeInsets.only(top: 2, bottom: 20),
                  child: SingleChildScrollView(
                    child: Consumer<TestingProvider>(
                      builder: (context, prov, _) {
                        return ChecklistTable(
                          items: moldSetupChecklist,
                          isChecked: (i) => prov.isCheckedMold(i),
                          onToggle: (i, v) => prov.updateCheckMold(i, v),
                        );
                      },
                    ),
                  ),
                ),
                SectionHeader(title: "VACUM JIG SETUP", width: widthApp),
                Container(
                  width: widthApp,
                  padding: const EdgeInsets.only(top: 2, bottom: 20),
                  child: SingleChildScrollView(
                    child: Consumer<TestingProvider>(
                      builder: (context, provVac, _) {
                        return ChecklistTable(
                          items: vacumJigChecklist,
                          isChecked: (i) => provVac.isCheckedVacum(i),
                          onToggle: (i, v) => provVac.updateCheckVacum(i, v),
                        );
                      },
                    ),
                  ),
                ),
                SectionHeader(title: "MACHINE PARAMETER", width: widthApp),
                Container(
                  width: widthApp,
                  padding: const EdgeInsets.only(top: 2, bottom: 20),
                  child: SingleChildScrollView(
                    child: MachineParameterTable(
                      mcTempUpperCtrl: mcTempUpperCtrl,
                      mcTempLowerCtrl: mcTempLowerCtrl,
                      mcTempLowUpperCtrl: mcTempLowUpperCtrl,
                      mcTempLowLowerCtrl: mcTempLowLowerCtrl,
                      mcCuringCtrl: mcCuringCtrl,
                      mcPressureCtrl: mcPressureCtrl,
                      mcSettingsCtrl: mcSettingsCtrl,
                      onTempUpperChanged: () => _saveTemp(provider),
                      onTempLowerChanged: () => _saveTempLower(provider),
                    ),
                  ),
                ),
                Container(
                  width: widthApp,
                  padding: const EdgeInsets.only(top: 2, bottom: 60),
                  child: const SingleChildScrollView(child: NotePanel()),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
