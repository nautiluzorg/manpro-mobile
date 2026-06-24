import 'package:flutter/material.dart';
import 'package:flutter_provider_data/provider/reason_provider.dart';
import 'package:flutter_provider_data/model/reason_dropdown_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:provider/provider.dart';

class MassReasonDropdown extends StatelessWidget {
  final String idProses;

  const MassReasonDropdown({super.key, required this.idProses});

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<ReasonProvider, bool>((p) => p.isLoading);
    final reasons = context
        .select<ReasonProvider, List<ReasonDropdownModel>>((p) => p.reasons);
    final selected = context
        .select<ReasonProvider, ReasonDropdownModel?>((p) => p.selectedReason);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return DropdownSearch<ReasonDropdownModel>(
      // 🔥 EXACT original filter logic
      items: (f, cs) => reasons
          .where((r) =>
              r.idReason != '02' && r.idReason != '03' && r.idReason != '06')
          .toList(),

      selectedItem: selected,
      itemAsString: (item) => item.nameReason,
      compareFn: (a, b) => a.idReason == b.idReason,
      onChanged: context.read<ReasonProvider>().setSelectedReason,

      // 🔥 EXACT original styling
      decoratorProps: const DropDownDecoratorProps(
        decoration: InputDecoration(
          labelText: "Alasan Stop",
          border: OutlineInputBorder(),
          isDense: false,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        ),
      ),

      popupProps: PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          textCapitalization: TextCapitalization.characters,
          style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.none,
              letterSpacing: 1.0),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: "Searching...",
            hintStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
                letterSpacing: 1.0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
        ),
        itemBuilder: (context, item, isDisabled, isSelected) {
          return SizedBox(
            height: 80,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isSelected
                      ? [Colors.greenAccent, Colors.green.shade900]
                      : [Colors.indigoAccent, Colors.indigo.shade900],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 6,
                      offset: const Offset(0, 3))
                ],
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.nameReason,
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color:
                                  isSelected ? Colors.blueGrey : Colors.white),
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        scrollbarProps:
            const ScrollbarProps(trackVisibility: true, thumbVisibility: true),
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.78),
        menuProps: const MenuProps(
          margin: EdgeInsets.only(top: 12),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8))),
        ),
      ),
    );
  }
}
