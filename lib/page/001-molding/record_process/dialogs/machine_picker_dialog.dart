import 'package:flutter/material.dart';

import 'package:flutter_provider_data/model/machine_model_dropdown.dart';
import 'package:flutter_provider_data/provider/machine_provider.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_provider_data/utils/custom_button.dart';
import 'package:flutter/services.dart';

// Dipindahkan dari recordprocess.dart (fungsi showMachinePickerDialog)

Future<void> showMachinePickerDialog(BuildContext context) async {
  final provider = Provider.of<MachineProvider>(context, listen: false);

  // Load machine list
  final error = await provider.loadMachines();
  if (error != null) {
    if (!context.mounted) return;
    if (context.mounted) {
      CustomSnackbar.show(context, error, isSuccess: false);
    }
    return;
  }

  if (provider.machineList.isEmpty) {
    CustomSnackbar.show(context, 'Data Machine kosong!', isSuccess: false);
    return;
  }

  MachineModelDropdown? selectedItem;

  if (!context.mounted) return;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (dialogContext, localSetState) {
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
                      'PILIH MACHINE',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.blueGrey.shade700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownSearch<MachineModelDropdown>(
                      items: (f, cs) => provider.machineList,
                      itemAsString: (item) => item.nmMc,
                      compareFn: (a, b) => a.idMc == b.idMc,
                      onChanged: (item) async {
                        if (item == null) return;

                        final error =
                            await provider.validateMachineDropdown(item.idMc);

                        if (error != null) {
                          if (!context.mounted) return;

                          CustomSnackbar.show(
                            context,
                            error,
                            isSuccess: false,
                          );

                          return;
                        }

                        localSetState(() {
                          selectedItem = item;
                        });
                      },
                      decoratorProps: const DropDownDecoratorProps(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Machine',
                          hintText: 'Nama Machine',
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
                            labelText: 'Cari Machine',
                            hintText: 'Ketik Nama Machine...',
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
                        itemBuilder: (
                          context,
                          MachineModelDropdown item,
                          isDisabled,
                          isSelected,
                        ) {
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: LinearGradient(
                                colors: isSelected
                                    ? [
                                        Colors.blue.shade200,
                                        Colors.lightBlue.shade100
                                      ]
                                    : [
                                        Colors.grey.shade50,
                                        Colors.grey.shade100
                                      ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
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
                                color: isSelected
                                    ? Colors.lightBlue.shade400
                                    : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () async {
                                final error = await provider
                                    .validateMachineDropdown(item.idMc);

                                if (error != null) {
                                  if (!context.mounted) return;

                                  CustomSnackbar.show(
                                    context,
                                    error,
                                    isSuccess: false,
                                  );

                                  return;
                                }

                                localSetState(() {
                                  selectedItem = item;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 12),
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue.shade100,
                                          Colors.blue.shade300,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.25),
                                          blurRadius: 6,
                                          offset: const Offset(2, 2),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: FaIcon(
                                        FontAwesomeIcons.gear,
                                        color: Colors.blueGrey.shade600,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    item.nmMc,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isSelected
                                          ? Colors.blue.shade900
                                          : Colors.black87,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'AREA: ${item.areaMc}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? Icon(Icons.check_circle,
                                          color: Colors.amber.shade400,
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5))),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 70,
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                    color: Colors.red.shade800, width: 2),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                Navigator.pop(dialogContext);
                              },
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
                            onPressed: selectedItem == null
                                ? null
                                : () {
                                    provider.selectMachine(selectedItem!);
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
