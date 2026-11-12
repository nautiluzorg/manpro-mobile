import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_provider_data/config/app_config.dart';
import 'package:flutter_provider_data/model/master/employee_model.dart';
import 'package:flutter_provider_data/provider/employee_provider.dart';
import 'package:flutter_provider_data/utils/custom_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

/// Dipindahkan dari recordprocess.dart (fungsi showEmployeeDialog).
/// Parameter & logic dibuat identik agar tidak mengubah fungsionalitas.
Future<void> showEmployeeDialog(
  BuildContext context,
  EmployeeProvider employeeProvider,
) async {
  EmployeeModel? selectedEmployeeItem;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: Colors.blue.shade500,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: Colors.white,
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
                      'PILIH OPERATOR',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey.shade800,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownSearch<EmployeeModel>(
                      items: (f, cs) => employeeProvider.employeeList,
                      itemAsString: (item) => item.fullName,
                      compareFn: (a, b) => a.idEmployee == b.idEmployee,
                      onChanged: (item) {
                        setState(() {
                          selectedEmployeeItem = item;
                        });
                      },
                      decoratorProps: const DropDownDecoratorProps(
                        decoration: InputDecoration(
                          labelText: 'Pilih Operator',
                          hintText: 'Nama Operator',
                          border: OutlineInputBorder(),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 20, horizontal: 12),
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
                            labelText: 'Cari Operator',
                            hintText: 'Ketik Nama Operator...',
                            prefixIcon: const Icon(Icons.search),
                            border: InputBorder.none,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 18),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                  color: Colors.blue, width: 2),
                            ),
                          ),
                        ),
                        itemBuilder: (context, EmployeeModel item, isDisabled,
                            isSelected) {
                          final photoUrl =
                              '${AppConfig.baseUrl}/media/img/employee/${item.idEmployee}.png';
                          final List<Color> gradientColors = isSelected
                              ? [
                                  const Color(0xFF1976D2),
                                  const Color(0xFF0D47A1)
                                ]
                              : [Colors.white, Colors.blue.shade50];
                          final Color titleColor =
                              isSelected ? Colors.white : Colors.blue.shade800;
                          final Color subtitleColor = isSelected
                              ? Colors.blue.shade200
                              : Colors.grey.shade600;

                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: isSelected
                                  ? BorderSide(
                                      color: Colors.lightBlue.shade300,
                                      width: 2.5,
                                    )
                                  : BorderSide(
                                      color: Colors.grey.shade300, width: 1),
                            ),
                            elevation: isSelected ? 8 : 2,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  selectedEmployeeItem = item;
                                });
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    colors: gradientColors,
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 10),
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                    ),
                                    child: CircleAvatar(
                                      backgroundColor: isSelected
                                          ? Colors.white
                                          : Colors.blue.shade100,
                                      child: ClipOval(
                                        child: Image.network(
                                          photoUrl,
                                          fit: BoxFit.cover,
                                          width: 50,
                                          height: 50,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Icon(
                                            Icons.person,
                                            size: 30,
                                            color: isSelected
                                                ? Colors.blue.shade800
                                                : Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    item.fullName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      color: titleColor,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'NRP: ${item.nrp}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: subtitleColor,
                                      fontStyle: FontStyle.normal,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? Icon(Icons.check_circle,
                                          color: Colors.amber.shade300,
                                          size: 28)
                                      : null,
                                ),
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
                            trackVisibility: true, thumbVisibility: true),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // CANCEL
                        Expanded(
                          child: SizedBox(
                            height: 70,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color: Colors.red.shade800, width: 2),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () => Navigator.pop(dialogContext),
                              child: Text(
                                'CANCEL',
                                style: GoogleFonts.poppins(
                                  color: Colors.red.shade800,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: buildCustomButton(
                            text: 'OK',
                            height: 70,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            gradient: LinearGradient(
                              colors: [
                                Colors.blueAccent,
                                Colors.blue.shade900,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            onPressed: selectedEmployeeItem == null
                                ? null
                                : () {
                                    employeeProvider
                                        .selectEmployee(selectedEmployeeItem!);
                                    Navigator.pop(dialogContext);
                                  },
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
