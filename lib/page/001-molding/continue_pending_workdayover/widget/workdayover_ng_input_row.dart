import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_provider_data/model/ng_dropdown_model.dart';
import 'package:flutter_provider_data/provider/ng_provider.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';

/// Baris input NG: dropdown pilih NG, stepper qty (- / angka / +),
/// dan tombol ADD. Semua state (selectedNgId, qtyNg) tetap dipegang
/// parent, widget ini menerima value + callback saja.
class WorkdayOverNgInputRow extends StatelessWidget {
  final NGProvider ngProvider;
  final String? selectedNgId;
  final int qtyNg;
  final ValueChanged<NgDropdownModel> onNgSelected;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onAdd;

  const WorkdayOverNgInputRow({
    super.key,
    required this.ngProvider,
    required this.selectedNgId,
    required this.qtyNg,
    required this.onNgSelected,
    required this.onIncrement,
    required this.onDecrement,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Dropdown NG Name
        Expanded(
          flex: 4,
          child: DropdownSearch<NgDropdownModel>(
            items: (f, cs) => ngProvider.listNG,
            itemAsString: (NgDropdownModel? item) => item?.ngName ?? '',
            compareFn: (a, b) => a.idNg == b.idNg,
            selectedItem: ngProvider.listNG
                    .where((e) => e.idNg == selectedNgId)
                    .isNotEmpty
                ? ngProvider.listNG.firstWhere((e) => e.idNg == selectedNgId)
                : null,
            onChanged: (NgDropdownModel? selected) {
              if (selected == null) return;
              onNgSelected(selected);
            },
            decoratorProps: DropDownDecoratorProps(
              decoration: InputDecoration(
                hintText: "PILIH NG",
                hintStyle: GoogleFonts.poppins(
                  color: Colors.grey.shade500,
                  fontSize: 13,
                ),
                border: const OutlineInputBorder(),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 14,
                ),
              ),
            ),
            popupProps: PopupProps.menu(
              showSearchBox: true,
              fit: FlexFit.loose,
              containerBuilder: (context, popupWidget) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 20,
                  ),
                  child: popupWidget,
                );
              },
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  hintText: "Search NG",
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  hintStyle: GoogleFonts.poppins(fontSize: 13),
                ),
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              itemBuilder: (context, item, isDisabled, isSelected) {
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  constraints: const BoxConstraints(minHeight: 75),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.indigoAccent,
                        Colors.indigo.shade900,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    dense: false,
                    title: Text(
                      item.ngName,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context, item);
                    },
                  ),
                );
              },
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.70,
                minWidth: MediaQuery.of(context).size.width * 0.80,
              ),
              scrollbarProps: const ScrollbarProps(
                thumbVisibility: true,
                trackVisibility: true,
              ),
              menuProps: const MenuProps(
                margin: EdgeInsets.only(top: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 6),

        // Button Decrease (-)
        SizedBox(
          width: 40,
          height: 40,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              backgroundColor: Colors.red.shade500,
              shape: const CircleBorder(),
            ),
            onPressed: onDecrement,
            child: const Icon(Icons.remove, size: 18, color: Colors.white),
          ),
        ),

        const SizedBox(width: 4),

        // Text QTY NG
        Container(
          width: 55,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            qtyNg.toString(),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),

        const SizedBox(width: 4),

        // Button Increase (+)
        SizedBox(
          width: 40,
          height: 40,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.zero,
              backgroundColor: Colors.green,
              shape: const CircleBorder(),
            ),
            onPressed: onIncrement,
            child: const Icon(Icons.add, size: 18, color: Colors.white),
          ),
        ),

        const SizedBox(width: 6),

        // Button ADD
        SizedBox(
          height: 45,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            onPressed: () {
              if (selectedNgId == null) {
                CustomSnackbar.show(
                  context,
                  'Pilih NG terlebih dahulu',
                  isSuccess: false,
                );
                return;
              }

              if (qtyNg <= 0) {
                CustomSnackbar.show(
                  context,
                  'QTY NG harus lebih dari 0',
                  isSuccess: false,
                );
                return;
              }

              onAdd();
            },
            child: Ink(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blueAccent,
                    Colors.blue.shade900,
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'ADD',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}
