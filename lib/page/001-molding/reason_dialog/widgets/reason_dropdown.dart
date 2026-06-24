import 'package:flutter/material.dart';
import 'package:flutter_provider_data/model/reason_dropdown_model.dart';
import 'package:flutter_provider_data/provider/running_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_search/dropdown_search.dart';

class ReasonDropdown extends StatelessWidget {
  final RunningProvider provider;
  final void Function(ReasonDropdownModel?) onChanged;

  const ReasonDropdown({
    super.key,
    required this.provider,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Ambil padding sistem (untuk navigasi bar Android)
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
      child: DropdownSearch<ReasonDropdownModel>(
        items: (f, cs) => provider.reasonItems,
        itemAsString: (ReasonDropdownModel? item) => item?.nameReason ?? '',
        compareFn: (ReasonDropdownModel? a, ReasonDropdownModel? b) =>
            a?.idReason == b?.idReason,
        onChanged: onChanged,
        dropdownBuilder: (context, selectedItem) {
          return Text(
            selectedItem?.nameReason ?? '',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.blueGrey,
            ),
          );
        },
        decoratorProps: DropDownDecoratorProps(
          decoration: InputDecoration(
            labelText: "CHOOSE REASON",
            hintText: "CHOOSE REASON",
            border: const OutlineInputBorder(),
            labelStyle: GoogleFonts.poppins(
              color: Colors.blueGrey,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            hintStyle: GoogleFonts.poppins(
              color: Colors.blueGrey.shade400,
              fontSize: 16,
            ),
          ),
        ),
        popupProps: PopupProps.menu(
          showSearchBox: true,

          // 🔥 SOLUSI PALING AMPUH UNTUK V6.0.2:
          // Kita pakai containerBuilder untuk membungkus list dengan padding manual
          containerBuilder: (context, popupWidget) {
            return Container(
              // Berikan jarak di bawah agar tidak tertutup menubar tablet
              padding: EdgeInsets.only(bottom: bottomPadding + 20),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.all(Radius.circular(4)),
              ),
              child: popupWidget,
            );
          },

          searchFieldProps: TextFieldProps(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: 'Searching...',
              labelText: 'Search',
              hintStyle: GoogleFonts.poppins(fontSize: 16),
              border: const OutlineInputBorder(),
            ),
          ),

          itemBuilder: (context, item, isDisabled, isSelected) {
            return Card(
              margin:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              elevation: 4, // Naikkan elevation sedikit biar lebih tegas
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigoAccent, Colors.indigo.shade900],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ListTile(
                  // 🔥 KUNCI MEMBUAT TINGGI: Atur padding vertikal di sini
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0, // Tambahkan nilai ini untuk tinggi ListTile
                    horizontal: 20.0,
                  ),
                  title: Text(
                    item.nameReason,
                    style: GoogleFonts.poppins(
                      fontSize:
                          22, // Ukuran font diperbesar sedikit untuk tablet
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 2.0,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios,
                      color: Colors.white70, size: 20),
                  onTap: () => Navigator.of(context).pop(item),
                ),
              ),
            );
          },

          constraints: BoxConstraints(
            // Batasi tinggi menu agar tidak "bablas" sampai ke dasar layar
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),

          menuProps: const MenuProps(
            elevation: 8,
            borderRadius: BorderRadius.all(Radius.circular(4)),
            // Hilangkan margin kustom di sini agar containerBuilder yang bekerja
          ),
        ),
      ),
    );
  }
}
