import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Bar gradient biru berisi ringkasan record (dipakai di halaman utama
/// maupun form new operator).
///
/// NOTE: `data` sengaja bertipe `dynamic` mengikuti struktur asli
/// (item pertama dari `prov.pendingDetail`). Ganti ke tipe model
/// PendingDetail yang sebenarnya kalau mau strict typing, bro.
class WorkdayOverHeaderBar extends StatelessWidget {
  final dynamic data;

  const WorkdayOverHeaderBar({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    Widget headerText(String text) => Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            decoration: TextDecoration.none,
          ),
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.blue.shade900],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          headerText(data.idRecord),
          headerText(data.customer),
          headerText(data.productCategory),
          headerText(data.productType),
        ],
      ),
    );
  }
}
