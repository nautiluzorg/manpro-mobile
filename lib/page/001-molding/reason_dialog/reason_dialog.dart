import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_provider_data/model/ng_dropdown_model.dart';
import 'package:flutter_provider_data/model/reason_dropdown_model.dart';
import 'package:flutter_provider_data/provider/employee_provider.dart';
import 'package:flutter_provider_data/provider/ng_provider.dart';
import 'package:flutter_provider_data/provider/running_provider.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'helpers/no_leading_zero_formatter.dart';
import 'helpers/reason_dialog_controller.dart';
import 'helpers/reason_dialog_submit_helper.dart';
import 'widgets/action_buttons_row.dart';
import 'widgets/employee_info_section.dart';
import 'widgets/ng_add_button.dart';
import 'widgets/ng_data_table.dart';
import 'widgets/ng_qty_counter.dart';
import 'widgets/reason_dialog_header.dart';
import 'widgets/reason_dropdown.dart';
import 'widgets/record_detail_table.dart';
import 'widgets/shoot_input_section.dart';

class ReasonSelectDialog extends StatefulWidget {
  final String idRecord;
  final Future<void> Function() onSuccess;

  const ReasonSelectDialog({
    super.key,
    required this.idRecord,
    required this.onSuccess,
  });

  @override
  _ReasonSelectDialogState createState() => _ReasonSelectDialogState();
}

class _ReasonSelectDialogState extends State<ReasonSelectDialog> {
  final double _opacity = 1.0;
  late final ReasonDialogController _controller;
  late final RunningProvider _runningProvider;
  late final EmployeeProvider _employeeProvider;

  @override
  void initState() {
    super.initState();

    _controller = ReasonDialogController();
    _runningProvider = context.read<RunningProvider>();
    _employeeProvider = context.read<EmployeeProvider>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _employeeProvider.clearEmployee();
      _runningProvider.resetConfirm();
      _loadDataAsync();
    });

    _controller.currentShootQtyController.addListener(() {
      if (_runningProvider.recordDetails.isEmpty ||
          _runningProvider.recordDetails[0].detailsRecord.isEmpty) {
        return;
      }

      final shootFinished =
          int.tryParse(_controller.currentShootQtyController.text) ?? 0;
      final initialShootQty =
          _runningProvider.recordDetails[0].detailsRecord[0].shootQty;
      _runningProvider.updateShootRemain(shootFinished, initialShootQty);
    });
  }

  Future<void> _loadDataAsync() async {
    _runningProvider.loadRecordDetail(widget.idRecord);
    _runningProvider.loadReasonItems();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleReasonChanged(ReasonDropdownModel? selected) {
    _runningProvider.setSelectedReason(selected);

    if (selected?.idReason != '03') {
      _controller.resetNgState();
    }
  }

  Future<void> _handleCancel() async {
    _runningProvider.resetConfirm(); // ✅ pakai yang sudah disimpan
    _employeeProvider.clearEmployee();
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _handleSubmit() async {
    final overlay = Overlay.of(context, rootOverlay: true);
    final navigator = Navigator.of(context);

    final helper = ReasonDialogSubmitHelper(
      overlay: overlay,
      runningProvider: _runningProvider,
      employeeProvider: _employeeProvider,
      controller: _controller,
      idRecord: widget.idRecord,
      onSuccess: widget.onSuccess,
    );

    final success = await helper.submit();
    if (!mounted) return;

    if (success) {
      navigator.pop(true); // ✅ pastikan ini ada
    }
  }

  void _handleNgChanged(NgDropdownModel? selected) {
    if (selected != null) {
      setState(() {
        _controller.setSelectedNgItem(selected);
        _controller.validateInputs();
      });
    }
  }

  void _handleAddNg() {
    final data = _runningProvider.recordDetails;
    if (data.isEmpty) return;

    final idNg = _controller.selectedNgItemObject?.idNg ?? '';
    final ngName = _controller.selectedNgItemObject?.ngName ?? '';
    final qty = int.tryParse(_controller.ngQtyController.text) ?? 0;
    final jobnumber = data[0].detailsRecord.isNotEmpty
        ? data[0].detailsRecord[0].jobNumber
        : '';
    final idEmploFinish = data[0].activeEmployee.idEmployee;
    final nmEmploFinish = data[0].activeEmployee.fullName;
    final idRecord = data[0].idRecord.isNotEmpty ? data[0].idRecord : '';

    if (idNg.isEmpty || ngName.isEmpty || qty <= 0 || jobnumber.isEmpty) {
      CustomSnackbar.show(
        context,
        "Please select NG, enter valid quantity, and jobnumber",
        isSuccess: false,
      );
      return;
    }

    setState(() {
      _controller.addOrUpdateNgItem(
        idNg: idNg,
        ngName: ngName,
        qty: qty,
        jobnumber: jobnumber,
        idEmployee: idEmploFinish,
        nmEmployee: nmEmploFinish,
        idRecord: idRecord,
      );
    });
  }

  void _handleDeleteNg(int index) {
    setState(() {
      _controller.removeNgItemAt(index);
    });
  }

  void _handleDecrementNgQty() {
    setState(() {
      _controller.decrementNgQty();
    });
  }

  void _handleIncrementNgQty() {
    setState(() {
      _controller.incrementNgQty();
    });
  }

  @override
  Widget build(BuildContext context) {
    final myAppBar = customDialogAppBar(
      title: 'PILIH REASON UNTUK STOP',
    );

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: _opacity,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: myAppBar,
        body: Consumer<RunningProvider>(
          builder: (context, provider, child) {
            if (provider.isLoadingDetails || provider.isLoadingReason) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.detailErrorMessage != null ||
                provider.reasonErrorMessage != null) {
              return Center(
                child: Text(
                  provider.detailErrorMessage ??
                      provider.reasonErrorMessage ??
                      "Unknown Error",
                ),
              );
            }

            if (provider.recordDetails.isEmpty) {
              return const Center(child: Text("No Data Available"));
            }

            final data = provider.recordDetails;

            return SingleChildScrollView(
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Column(
                    children: [
                      ReasonDialogHeader(
                        idRecord: widget.idRecord,
                        data: data,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          EmployeeInfoSection(data: data),
                          const SizedBox(width: 10),
                          RecordDetailTable(data: data),
                        ],
                      ),
                      ReasonDropdown(
                        provider: provider,
                        onChanged: _handleReasonChanged,
                      ),
                      const SizedBox(height: 10),
                      ActionButtonsRow(
                        onCancel: _handleCancel,
                        onSubmit: _handleSubmit,
                      ),
                      const SizedBox(height: 10),
                      if (provider.selectedReason?.idReason == '03') ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: TextField(
                                      controller:
                                          _controller.currentShootQtyController,
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(5),
                                        NoLeadingZeroFormatter(),
                                      ],
                                      style: const TextStyle(
                                        color: Colors.blueGrey,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      decoration: const InputDecoration(
                                        labelText: 'SHOOTS',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  _buildNgDropdownSection(provider),
                                  const SizedBox(width: 4),
                                  NgQtyCounter(
                                    ngQtyController:
                                        _controller.ngQtyController,
                                    onDecrement: _handleDecrementNgQty,
                                    onIncrement: _handleIncrementNgQty,
                                  ),
                                  const SizedBox(width: 4),
                                  NgAddButton(
                                    isEnabled: _controller.isAddButtonEnabled,
                                    onPressed: _handleAddNg,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              NgDataTable(
                                ngDataList: _controller.ngDataList,
                                onDelete: _handleDeleteNg,
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (provider.selectedReason?.idReason == '06') ...[
                        ShootInputSection(
                          currentShootQtyController:
                              _controller.currentShootQtyController,
                          shootRemainController:
                              _controller.shootRemainController,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildNgDropdownSection(RunningProvider runProv) {
    if (runProv.isLoadingDetails || runProv.isLoadingReason) {
      return const Expanded(
        flex: 3,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (runProv.detailErrorMessage != null ||
        runProv.reasonErrorMessage != null) {
      return Expanded(
        flex: 3,
        child: Center(
          child: Text(
            runProv.detailErrorMessage ??
                runProv.reasonErrorMessage ??
                "Unknown Error",
          ),
        ),
      );
    }

    if (runProv.recordDetails.isEmpty ||
        runProv.recordDetails[0].detailsRecord.isEmpty) {
      return const Expanded(
        flex: 3,
        child: Center(child: Text("No Record Details Available")),
      );
    }

    final ngProv = context.read<NGProvider>();
    final productType =
        runProv.recordDetails[0].detailsRecord[0].bcode.productType;
    final idProses = runProv.recordDetails[0].proses.idProses;

    if (!ngProv.hasLoadedForThisRecord) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ngProv.hasLoadedForThisRecord = true;
        ngProv.loadNGList(
          productType: productType,
          idProses: idProses,
        );
      });
    }

    return Expanded(
      flex: 3,
      child: Consumer<NGProvider>(
        builder: (context, ngProv, child) {
          if (ngProv.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (ngProv.errorMessage != null) {
            return Text("Error: ${ngProv.errorMessage}");
          }

          if (ngProv.listNG.isEmpty) {
            return const Text("No NG data available");
          }

          return DropdownSearch<NgDropdownModel>(
            selectedItem: _controller.selectedNgItemObject,
            items: (f, cs) => ngProv.listNG,
            itemAsString: (NgDropdownModel? item) => item?.ngName ?? 'Unknown',
            compareFn: (a, b) => (a.idNg) == (b.idNg),
            onChanged: _handleNgChanged,
            dropdownBuilder: (context, selectedItem) {
              return Text(
                selectedItem?.ngName ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.blueGrey,
                ),
              );
            },
            decoratorProps: DropDownDecoratorProps(
              decoration: InputDecoration(
                labelText: "CHOOSE NG",
                labelStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey,
                ),
                border: const OutlineInputBorder(),
              ),
            ),
            popupProps: PopupProps.menu(
              showSearchBox: true,
              containerBuilder: (context, popupWidget) {
                final bottomPadding = MediaQuery.of(context).padding.bottom;
                return Container(
                  padding: EdgeInsets.only(bottom: bottomPadding + 20),
                  child: popupWidget,
                );
              },
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: 'Searching...',
                  labelText: 'Search',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.blueGrey.shade400,
                  ),
                  labelStyle: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.blueGrey.shade400,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.blueGrey.shade400,
                ),
              ),
              itemBuilder: (context, item, isDisabled, isSelected) {
                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 4.0,
                    horizontal: 10.0,
                  ),
                  elevation: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.indigoAccent,
                          Colors.indigo.shade700,
                          Colors.indigo.shade900,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text(
                          item.ngName,
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        onTap: () => Navigator.of(context).pop(item),
                      ),
                    ),
                  ),
                );
              },
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
                minHeight: MediaQuery.of(context).size.height * 0.8,
                maxWidth: MediaQuery.of(context).size.width * 0.8,
                minWidth: MediaQuery.of(context).size.width * 0.8,
              ),
              menuProps: const MenuProps(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
