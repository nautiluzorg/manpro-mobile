import 'package:flutter/material.dart';
import 'package:flutter_provider_data/page/operator/inspectionform.dart';
import 'package:flutter_provider_data/page/main_menu_leader.dart';
import 'package:flutter_provider_data/page/operator/measurementform.dart';
import 'package:flutter_provider_data/page/operator/onebatch.dart';
import 'package:flutter_provider_data/page/operator/onejoborder.dart';
import 'package:flutter_provider_data/page/main_menu_admin.dart';
import 'package:google_fonts/google_fonts.dart';

class MenuForm extends StatefulWidget {
  final String title;
  final String idProses;

  const MenuForm({Key? key, required this.title, required this.idProses})
      : super(key: key);

  @override
  State<MenuForm> createState() => _MenuFormState();
}

class _MenuFormState extends State<MenuForm> {
  @override
  Widget build(BuildContext context) {
    double widthApp = MediaQuery.of(context).size.width;
    bool isTablet = widthApp > 600;

    final myAppBar = PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.blue.shade800],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: AppBar(
          title: Text(
            'FORM RECORD',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 26.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      MainMenuAdmin(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const curve = Curves.easeIn;
                    var tween = Tween<double>(begin: 0.0, end: 1.0)
                        .chain(CurveTween(curve: curve));
                    var opacityAnimation = animation.drive(tween);

                    return FadeTransition(
                      opacity: opacityAnimation,
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              );
            },
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
      ),
    );

    // --- Daftar 4 menu ---
    final List<Map<String, dynamic>> menus = [
      {
        "title": "MAIN MENU",
        "icon": Icons.list_alt,
        "onTap": () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => MainMenuLeader(title: "MAIN MENU"),
              transitionsBuilder: (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
        },
      },
      {
        "title": "JOBORDER FLOW",
        "icon": Icons.list_alt,
        "onTap": () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) =>
                  OneJoborder(title: "RECORD PROCESS", idProses: "001"),
              transitionsBuilder: (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
        },
      },
      {
        "title": "BATCH FLOW",
        "icon": Icons.note_add,
        "onTap": () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) =>
                  OneBatch(title: "RECORD PROCESS", idProses: "001"),
              transitionsBuilder: (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
        },
      },
      {
        "title": "INSPECTION",
        "icon": Icons.pending_actions,
        "onTap": () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) =>
                  InspectionForm(title: "RECORD PROCESS", idProses: "001"),
              transitionsBuilder: (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
        },
      },
      {
        "title": "MEASUREMENT",
        "icon": Icons.assignment_turned_in,
        "onTap": () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) =>
                  MeasurementForm(title: "RECORD PROCESS", idProses: "001"),
              transitionsBuilder: (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
        },
      },
    ];

    return Scaffold(
      appBar: myAppBar,
      body: GridView.builder(
        itemCount: menus.length,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, // 2 kolom supaya 4 menu terlihat rapi
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          final menu = menus[index];
          return GestureDetector(
            onTap: menu["onTap"],
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.blue.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    offset: const Offset(3, 3),
                    blurRadius: 6,
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.05),
                    offset: const Offset(-3, -3),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: isTablet ? 90 : 60,
                    height: isTablet ? 90 : 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.1),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2)),
                    ),
                    child: Center(
                      child: Icon(
                        menu["icon"],
                        size: isTablet ? 48 : 32,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    menu["title"],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// Contoh placeholder page
class FormPage extends StatelessWidget {
  final String title;
  final String idProses;

  const FormPage({Key? key, required this.title, required this.idProses})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text("Halaman $title untuk proses $idProses"),
      ),
    );
  }
}
