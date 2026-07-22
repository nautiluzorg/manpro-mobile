import 'package:flutter/material.dart';
import 'package:flutter_provider_data/page/001-molding/report/monitor_testing.dart';
import 'package:flutter_provider_data/page/001-molding/report/testing_completed.dart';
import 'package:flutter_provider_data/page/menu.dart';
// import 'package:flutter_provider_data/page/001-molding/recordtesting.dart';
import 'package:google_fonts/google_fonts.dart';

class MenuSubTesting extends StatefulWidget {
  final String title;
  final String idProses;

  const MenuSubTesting({Key? key, required this.title, required this.idProses})
      : super(key: key);

  @override
  State<MenuSubTesting> createState() => _MenuSubTestingState();
}

class _MenuSubTestingState extends State<MenuSubTesting> {
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
            'MOLD TESTING',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 26.0,
              fontWeight: FontWeight.w600, // bisa bold atau semi-bold
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      Menu(kode: widget.idProses, proses: "MOULDING"),
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

    // --- Daftar menu yang akan ditampilkan (3 buah) ---
    final List<Map<String, dynamic>> menus = [
      {
        "title": "RECORD TESTING",
        "icon": Icons.note_add_rounded,
        "onTap": () {
/*
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => RecordTesting(
                  title: "MOLDING COMPLETED", idProses: widget.idProses),
              transitionsBuilder: (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
          */
        }
      },
      {
        "title": "CURRENT TESTING",
        "icon": Icons.analytics_rounded,
        "onTap": () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => MonitorTesting(
                  title: "LIST TESTING", idProses: widget.idProses),
              transitionsBuilder: (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
        }
      },
      {
        "title": "TESTING COMPLETED",
        "icon": Icons.check_box_rounded,
        "onTap": () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => TestingCompleted(
                  title: "TESTING COMPLETED", idProses: widget.idProses),
              transitionsBuilder: (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
        }
      },
      {
        "title": "MEASUREMENT CHECK",
        "icon": Icons.ac_unit_rounded,
        "onTap": () {
/*
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => TestingCompleted(
                  title: "TESTING COMPLETED", idProses: widget.idProses),
              transitionsBuilder: (_, animation, __, child) =>
                  FadeTransition(opacity: animation, child: child),
              transitionDuration: const Duration(milliseconds: 800),
            ),
          );
          */
        }
      },
    ];

    return Scaffold(
      appBar: myAppBar,
      body: GridView.builder(
        itemCount: menus.length,
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 0.9,
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
                      color: Colors.white.withOpacity(0.1),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
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
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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
