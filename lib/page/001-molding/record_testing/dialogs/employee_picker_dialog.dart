import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:flutter_provider_data/model/master/employee_model.dart';
import 'package:flutter_provider_data/provider/employee_provider.dart';
import 'package:flutter_provider_data/provider/testing_provider.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';

/// "PILIH OPERATOR" picker dialog. Extracted verbatim from
/// record_testing.dart's `showEmployeeDropdownDialog` — same job-number
/// gate, same employee load/select flow.
Future<void> showEmployeePickerDialog(BuildContext context) async {
  final employeeProv = context.read<EmployeeProvider>();
  final testingProv = context.read<TestingProvider>();

  if (!testingProv.isJobNumberScanned) {
    CustomSnackbar.show(
      context,
      "Mohon Scan Job Number terlebih dahulu.",
      isSuccess: false,
    );
    return;
  }

  if (employeeProv.employeeList.isEmpty && !employeeProv.isLoading) {
    await employeeProv.loadEmployees();
  }

  if (employeeProv.employeeList.isEmpty) {
    CustomSnackbar.show(context, "Data Employee belum tersedia.", isSuccess: false);
    return;
  }

  EmployeeModel? selectedItem;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (dialogContext, localSetState) {
          return Dialog(
            backgroundColor: Colors.blue.shade500,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
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
                      "PILIH OPERATOR",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownSearch<EmployeeModel>(
                      items: (f, cs) => employeeProv.employeeList,
                      itemAsString: (item) => item.fullName,
                      compareFn: (a, b) => a.idEmployee == b.idEmployee,
                      onChanged: (item) => localSetState(() => selectedItem = item),
                      decoratorProps: const DropDownDecoratorProps(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Operator",
                          hintText: "Nama Operator",
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 12),
                        ),
                      ),
                      popupProps: PopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          inputFormatters: [
                            TextInputFormatter.withFunction(
                              (oldValue, newValue) => TextEditingValue(
                                text: newValue.text.toUpperCase(),
                                selection: newValue.selection,
                              ),
                            ),
                          ],
                          decoration: InputDecoration(
                            labelText: "Cari Operator",
                            hintText: "Ketik Nama Operator...",
                            prefixIcon: const Icon(Icons.search),
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5),
                              borderSide: const BorderSide(color: Colors.blue, width: 2),
                            ),
                          ),
                        ),
                        itemBuilder: (context, item, isDisabled, isSelected) {
                          final photoUrl =
                              '${AppConfig.baseUrl}/media/img/employee/${item.idEmployee}.png';

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              gradient: isSelected
                                  ? LinearGradient(
                                      colors: [Colors.blue.shade200, Colors.lightBlue.shade100],
                                    )
                                  : LinearGradient(
                                      colors: [Colors.grey.shade50, Colors.grey.shade100],
                                    ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 6,
                                  offset: const Offset(2, 3),
                                ),
                                BoxShadow(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  blurRadius: 4,
                                  offset: const Offset(-2, -2),
                                ),
                              ],
                              border: Border.all(
                                color: isSelected ? Colors.lightBlue.shade400 : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(5),
                              onTap: () => localSetState(() => selectedItem = item),
                              child: ListTile(
                                contentPadding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
                                leading: Container(
                                  width: 55,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [Colors.blue.shade100, Colors.blue.shade300],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.25),
                                        blurRadius: 6,
                                        offset: const Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: Image.network(
                                      photoUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.person),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  item.fullName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: isSelected ? Colors.blue.shade900 : Colors.black87,
                                  ),
                                ),
                                subtitle: Text(
                                  "NRP: ${item.nrp}",
                                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                                ),
                                trailing: isSelected
                                    ? Icon(Icons.check_circle, color: Colors.amber.shade400, size: 28)
                                    : null,
                              ),
                            ),
                          );
                        },
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.8,
                          maxWidth: MediaQuery.of(context).size.width * 0.95,
                          minWidth: MediaQuery.of(context).size.width * 0.95,
                        ),
                        scrollbarProps: const ScrollbarProps(
                          trackVisibility: true,
                          thumbVisibility: true,
                        ),
                        menuProps: const MenuProps(
                          margin: EdgeInsets.only(top: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 70,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.blue, width: 1),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              ),
                              onPressed: () => Navigator.pop(dialogContext),
                              child: Text(
                                "CANCEL",
                                style: GoogleFonts.poppins(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              gradient: selectedItem == null
                                  ? LinearGradient(
                                      colors: [Colors.blueGrey.shade50, Colors.blueGrey.shade600],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    )
                                  : LinearGradient(
                                      colors: [Colors.blueAccent, Colors.blue.shade800],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                            ),
                            child: TextButton(
                              onPressed: selectedItem == null
                                  ? null
                                  : () {
                                      testingProv.setEmployee(selectedItem!);
                                      Navigator.pop(dialogContext);
                                    },
                              child: Text(
                                "OK",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
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
      );
    },
  );
}
