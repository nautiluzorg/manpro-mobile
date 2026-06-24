import 'package:flutter/material.dart';
import 'package:flutter_provider_data/page/001-molding/menu_sub_testing.dart';
import 'package:flutter_provider_data/page/001-molding/monitoring_master_page.dart';
import 'package:flutter_provider_data/page/001-molding/runningmoldingpage.dart';
import 'package:flutter_provider_data/page/001-molding/stopmoldingpage.dart';
// import 'package:flutter_provider_data/page/002-oven/oven_running.dart'; // REMOVED\n// import 'package:flutter_provider_data/page/002-oven/record_oven.dart'; // REMOVED
// import 'package:flutter_provider_data/page/003-finishing/record_finishing.dart'; // DELETED
import 'package:flutter_provider_data/page/menu_sub.dart';
import 'package:flutter_provider_data/page/001-molding/recordprocess.dart';
import 'package:flutter_provider_data/page/main_menu_admin.dart';
import 'package:flutter_provider_data/utils/logger.dart';
import 'package:flutter_provider_data/utils/page_transition_helper.dart';
import 'package:google_fonts/google_fonts.dart';

class Menu extends StatefulWidget {
  final String kode;
  final String proses;

  const Menu({Key? key, required this.kode, required this.proses})
      : super(key: key);

  @override
  State<Menu> createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    double widthApp = MediaQuery.of(context).size.width;
    final myAppBar = PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight), // Ukuran AppBar
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.blue.shade800], // Gradasi warna
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: AppBar(
          title: Text(
            'MENU ${widget.proses}',
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
          backgroundColor:
              Colors.transparent, // Menjadikan background AppBar transparan
        ),
      ),
    );
    bool isTablet = widthApp > 600;

    Widget bodyWidget = Center(child: Text("Default")); // Nilai default

    switch (widget.kode) {
      case '001':
        bodyWidget = GridView.builder(
          itemCount: 6,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            late String title;
            late String idproses;
            late IconData iconData;
            late VoidCallback onTap;

            // Semua icon berwarna putih biar matching dengan AppBar
            final Color iconColor = Colors.white;

            switch (index) {
              case 0:
                title = "MOLD RECORD ";
                idproses = widget.kode;
                iconData = Icons.post_add_rounded;
                onTap = () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) =>
                          RecordProcess(title: title, idProses: idproses),
                      transitionsBuilder: (_, animation, __, child) =>
                          FadeTransition(opacity: animation, child: child),
                      transitionDuration: const Duration(milliseconds: 800),
                    ),
                  );
                };
                break;
              case 1:
                title = "MOLD RUNNING";
                idproses = widget.kode;
                iconData = Icons.play_circle_fill_rounded;
                onTap = () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) =>
                          RunningMoldingPage(title: title, idProses: idproses),
                      transitionsBuilder: (_, animation, __, child) =>
                          FadeTransition(opacity: animation, child: child),
                      transitionDuration: const Duration(milliseconds: 800),
                    ),
                  );
                };
                break;
              case 2:
                title = "MOLD STOP";
                idproses = widget.kode;
                iconData = Icons.pause_circle_filled_rounded;
                onTap = () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) =>
                          StopMoldingPage(title: title, idProses: idproses),
                      transitionsBuilder: (_, animation, __, child) =>
                          FadeTransition(opacity: animation, child: child),
                      transitionDuration: const Duration(milliseconds: 800),
                    ),
                  );
                };
                break;
              case 3:
                title = "MOLD MONITORING";
                idproses = widget.kode;
                iconData = Icons.insights;
                onTap = () {
                  PageTransitionHelper.navigateReplaceWithTransition(
                    context,
                    MonitoringMasterPage(title: title, idProses: idproses),
                    type: PageTransitionType.fade,
                    duration: 800,
                    curve: Curves.easeInOut,
                  );
                };
                break;

              case 4:
                title = "MOLD REPORT";
                idproses = widget.kode;
                iconData = Icons.bar_chart_rounded;
                onTap = () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) =>
                          MenuSub(title: title, idProses: idproses),
                      transitionsBuilder: (_, animation, __, child) =>
                          FadeTransition(opacity: animation, child: child),
                      transitionDuration: const Duration(milliseconds: 800),
                    ),
                  );
                };
                break;

              case 5:
                title = "MOLD TESTING";
                idproses = widget.kode;
                iconData = Icons.science_rounded;
                onTap = () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) =>
                          MenuSubTesting(title: title, idProses: idproses),
                      transitionsBuilder: (_, animation, __, child) =>
                          FadeTransition(opacity: animation, child: child),
                      transitionDuration: const Duration(milliseconds: 800),
                    ),
                  );
                };
                break;

              default:
                title = "Unknown";
                iconData = Icons.help_outline;
                break;
            }

            return GestureDetector(
              onTap: onTap,
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
                      color: Colors.black.withAlpha((0.15 * 255).round()),
                      offset: const Offset(3, 3),
                      blurRadius: 6,
                    ),
                    BoxShadow(
                      color:
                          Colors.white.withAlpha((0.05 * 255).round()), // ~13

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
                        color:
                            Colors.white.withAlpha((0.1 * 255).round()), // ~26

                        border: Border.all(
                            color: Colors.white
                                .withAlpha((0.2 * 255).round())), // ~51
                      ),
                      child: Center(
                        child: Icon(
                          iconData,
                          size: isTablet ? 48 : 32,
                          color: iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: isTablet ? 16 : 11,
                        fontWeight: FontWeight.w600, // bisa bold atau semi-bold
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
        break;

      case '002':
        bodyWidget = GridView.builder(
          itemCount: 5,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            late String title;
            late String idproses;
            late IconData iconData;
            late VoidCallback onTap;

            final Color iconColor = Colors.white;
            idproses = widget.kode;

            switch (index) {
              case 0:
                title = "OVEN RECORD";
                idproses = widget.kode;
                iconData = Icons.post_add_rounded;
                onTap = () {
/*
                  PageTransitionHelper.navigateReplaceWithTransition(
                    context,
                    RecordOven(title: title, idProses: idproses),
                    type: PageTransitionType.fade,
                    duration: 800,
                    curve: Curves.easeInOut,
                  );
*/
                };
                break;
              case 1:
                title = "OVEN RUNNING";
                iconData = Icons.play_circle_fill_rounded;
                onTap = () {
/*
                  PageTransitionHelper.navigateReplaceWithTransition(
                    context,
                    OvenRunning(title: title, idProses: idproses),
                    type: PageTransitionType.fade,
                    duration: 800,
                    curve: Curves.easeInOut,
                  );
                  */
                };
                break;
              case 2:
                title = "OVEN STOP";
                iconData = Icons.pause_circle_filled_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 3:
                title = "OVEN MONITORING";
                iconData = Icons.insights;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 4:
                title = "OVEN REPORT";
                iconData = Icons.bar_chart_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              default:
                title = "OTHER MENU";
                iconData = Icons.help_outline;
                onTap = () {
                  logPrint("menu $title");
                };
                break;
            }

            return GestureDetector(
              onTap: onTap,
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
                      color: Color.fromRGBO(0, 0, 0, 0.15), // hitam 15% opacity
                      offset: const Offset(3, 3),
                      blurRadius: 6,
                    ),
                    BoxShadow(
                      color: Color.fromRGBO(
                          255, 255, 255, 0.05), // putih 5% opacity
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
                        color: Color.fromRGBO(
                            255, 255, 255, 0.1), // putih 10% opacity
                        border: Border.all(
                          color: Color.fromRGBO(
                              255, 255, 255, 0.2), // putih 20% opacity
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          iconData,
                          size: isTablet ? 48 : 32,
                          color: iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: isTablet ? 16 : 11,
                        fontWeight: FontWeight.w600, // bisa bold atau semi-bold
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
        break;
      case '003':
        bodyWidget = GridView.builder(
          itemCount: 5,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            late String title;
            late String idproses;
            late IconData iconData;
            late VoidCallback onTap;

            final Color iconColor = Colors.white;
            idproses = widget.kode;

            switch (index) {
              case 0:
                title = "FINISHING\nRECORD";
                iconData = Icons.post_add_rounded;
                onTap = () {
                  logPrint("003-FINISHING: Module Removed");
                };
                break;
              case 1:
                title = "FINISHING\nRUNNING";
                iconData = Icons.play_circle_fill_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 2:
                title = "FINISHING\nSTOP";
                iconData = Icons.pause_circle_filled_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 3:
                title = "FINISHING\nMONITORING";
                iconData = Icons.insights;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 4:
                title = "FINISHING\nREPORT";
                iconData = Icons.bar_chart_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              default:
                title = "OTHER MENU";
                iconData = Icons.help_outline;
                onTap = () {
                  logPrint("menu $title");
                };
                break;
            }

            return GestureDetector(
              onTap: onTap,
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
                      color: Color.fromRGBO(0, 0, 0, 0.15), // hitam 15% opacity
                      offset: const Offset(3, 3),
                      blurRadius: 6,
                    ),
                    BoxShadow(
                      color: Color.fromRGBO(
                          255, 255, 255, 0.05), // putih 5% opacity
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
                        color: Color.fromRGBO(
                            255, 255, 255, 0.1), // putih 10% opacity
                        border: Border.all(
                          color: Color.fromRGBO(
                              255, 255, 255, 0.2), // putih 20% opacity
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          iconData,
                          size: isTablet ? 48 : 32,
                          color: iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: isTablet ? 16 : 11,
                        fontWeight: FontWeight.w600, // bisa bold atau semi-bold
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
        break;

      case '004':
        bodyWidget = GridView.builder(
          itemCount: 5,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            late String title;
            late IconData iconData;
            late VoidCallback onTap;

            final String idproses = widget.kode;
            const Color iconColor = Colors.white;

            switch (index) {
              case 0:
                title = "PUNCHING\nRECORD";
                iconData = Icons.post_add_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 1:
                title = "PUNCHING\nRUNNING";
                iconData = Icons.play_circle_fill_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 2:
                title = "PUNCHING\nSTOP";
                iconData = Icons.pause_circle_filled_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 3:
                title = "PUNCHING\nMONITORING";
                iconData = Icons.insights;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;

              case 4:
                title = "PUNCHING\nREPORT";
                iconData = Icons.bar_chart_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              default:
                title = "OTHER MENU";
                iconData = Icons.help_outline;
                onTap = () {
                  logPrint("menu $title");
                };
                break;
            }

            return GestureDetector(
              onTap: onTap,
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
                      color: Color.fromRGBO(0, 0, 0, 0.15), // hitam 15% opacity
                      offset: const Offset(3, 3),
                      blurRadius: 6,
                    ),
                    BoxShadow(
                      color: Color.fromRGBO(
                          255, 255, 255, 0.05), // putih 5% opacity
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
                        color: Color.fromRGBO(
                            255, 255, 255, 0.1), // putih 10% opacity
                        border: Border.all(
                          color: Color.fromRGBO(
                              255, 255, 255, 0.2), // putih 20% opacity
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          iconData,
                          size: isTablet ? 48 : 32,
                          color: iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: isTablet ? 16 : 11,
                        fontWeight: FontWeight.w600, // bisa bold atau semi-bold
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
        break;

      case '005':
        bodyWidget = GridView.builder(
          itemCount: 5,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            late String title;
            late IconData iconData;
            late VoidCallback onTap;

            final String idproses = widget.kode;
            const Color iconColor = Colors.white;

            switch (index) {
              case 0:
                title = "WASHING\nRECORD";
                iconData = Icons.post_add_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 1:
                title = "WASHING\nRUNNING";
                iconData = Icons.play_circle_fill_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 2:
                title = "WASHING\nSTOP";
                iconData = Icons.pause_circle_filled_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 3:
                title = "WASHING\nMONITORING";
                iconData = Icons.insights;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;

              case 4:
                title = "WASHING\nREPORT";
                iconData = Icons.bar_chart_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              default:
                title = "OTHER MENU";
                iconData = Icons.help_outline;
                onTap = () {
                  logPrint("menu $title");
                };
                break;
            }

            // Widget setiap grid item
            return GestureDetector(
              onTap: onTap,
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
                      color: Color.fromRGBO(0, 0, 0, 0.15), // hitam 15% opacity
                      offset: const Offset(3, 3),
                      blurRadius: 6,
                    ),
                    BoxShadow(
                      color: Color.fromRGBO(
                          255, 255, 255, 0.05), // putih 5% opacity
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
                        color: Color.fromRGBO(
                            255, 255, 255, 0.1), // putih 10% opacity
                        border: Border.all(
                          color: Color.fromRGBO(
                              255, 255, 255, 0.2), // putih 20% opacity
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          iconData,
                          size: isTablet ? 48 : 32,
                          color: iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: isTablet ? 16 : 11,
                        fontWeight: FontWeight.w600, // bisa bold atau semi-bold
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
        break;

      case '006':
        bodyWidget = GridView.builder(
          itemCount: 5,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            late String title;
            late IconData iconData;
            late VoidCallback onTap;

            final String idproses = widget.kode;
            const Color iconColor = Colors.white;

            switch (index) {
              case 0:
                title = "OY RECORD";
                iconData = Icons.post_add_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 1:
                title = "OY RUNNING";
                iconData = Icons.play_circle_fill_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 2:
                title = "OY STOP";
                iconData = Icons.pause_circle_filled_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 3:
                title = "OY MONITORING";
                iconData = Icons.insights;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;

              case 4:
                title = "OY REPORT";
                iconData = Icons.bar_chart_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              default:
                title = "OTHER MENU";
                iconData = Icons.help_outline;
                onTap = () {
                  logPrint("menu $title");
                };
                break;
            }

            // Widget setiap grid item
            return GestureDetector(
              onTap: onTap,
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
                      color: Color.fromRGBO(0, 0, 0, 0.15), // hitam 15% opacity
                      offset: const Offset(3, 3),
                      blurRadius: 6,
                    ),
                    BoxShadow(
                      color: Color.fromRGBO(
                          255, 255, 255, 0.05), // putih 5% opacity
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
                        color: Color.fromRGBO(
                            255, 255, 255, 0.1), // putih 10% opacity
                        border: Border.all(
                          color: Color.fromRGBO(
                              255, 255, 255, 0.2), // putih 20% opacity
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          iconData,
                          size: isTablet ? 48 : 32,
                          color: iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: isTablet ? 16 : 11,
                        fontWeight: FontWeight.w600, // bisa bold atau semi-bold
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
        break;

      case '007':
        bodyWidget = GridView.builder(
          itemCount: 5,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            late String title;
            late IconData iconData;
            late VoidCallback onTap;

            final String idproses = widget.kode;
            const Color iconColor = Colors.white;

            switch (index) {
              case 0:
                title = "PRINTING\nRECORD";
                iconData = Icons.post_add_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 1:
                title = "PRINTING\nRUNNING";
                iconData = Icons.play_circle_fill_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 2:
                title = "PRINTING\nSTOP";
                iconData = Icons.pause_circle_filled_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 3:
                title = "PRINTING\nMONITORING";
                iconData = Icons.insights;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;

              case 4:
                title = "PRINTING\nREPORT";
                iconData = Icons.bar_chart_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              default:
                title = "OTHER MENU";
                iconData = Icons.help_outline;
                onTap = () {
                  logPrint("menu $title");
                };
                break;
            }

            // Widget setiap grid item
            return GestureDetector(
              onTap: onTap,
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
                      color: Color.fromRGBO(0, 0, 0, 0.15), // hitam 15% opacity
                      offset: const Offset(3, 3),
                      blurRadius: 6,
                    ),
                    BoxShadow(
                      color: Color.fromRGBO(
                          255, 255, 255, 0.05), // putih 5% opacity
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
                        color: Color.fromRGBO(
                            255, 255, 255, 0.1), // putih 10% opacity
                        border: Border.all(
                          color: Color.fromRGBO(
                              255, 255, 255, 0.2), // putih 20% opacity
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          iconData,
                          size: isTablet ? 48 : 32,
                          color: iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: isTablet ? 16 : 11,
                        fontWeight: FontWeight.w600, // bisa bold atau semi-bold
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
        break;

      case '008':
        bodyWidget = GridView.builder(
          itemCount: 5,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            late String title;
            late IconData iconData;
            late VoidCallback onTap;

            final String idproses = widget.kode;
            const Color iconColor = Colors.white;

            switch (index) {
              case 0:
                title = "RESISTANCE\nRECORD";
                iconData = Icons.post_add_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 1:
                title = "RESISTANCE\nRUNNING";
                iconData = Icons.play_circle_fill_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 2:
                title = "RESISTANCE\nSTOP";
                iconData = Icons.pause_circle_filled_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 3:
                title = "RESISTANCE\nMONITORING";
                iconData = Icons.insights;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;

              case 4:
                title = "RESISTANCE\nREPORT";
                iconData = Icons.bar_chart_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              default:
                title = "OTHER MENU";
                iconData = Icons.help_outline;
                onTap = () {
                  logPrint("menu $title");
                };
                break;
            }

            // Widget setiap grid item
            return GestureDetector(
              onTap: onTap,
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
                      color: Color.fromRGBO(0, 0, 0, 0.15), // hitam 15% opacity
                      offset: const Offset(3, 3),
                      blurRadius: 6,
                    ),
                    BoxShadow(
                      color: Color.fromRGBO(
                          255, 255, 255, 0.05), // putih 5% opacity
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
                        color: Color.fromRGBO(
                            255, 255, 255, 0.1), // putih 10% opacity
                        border: Border.all(
                          color: Color.fromRGBO(
                              255, 255, 255, 0.2), // putih 20% opacity
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          iconData,
                          size: isTablet ? 48 : 32,
                          color: iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: isTablet ? 16 : 11,
                        fontWeight: FontWeight.w600, // bisa bold atau semi-bold
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
        break;

      case '009':
        bodyWidget = GridView.builder(
          itemCount: 5,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            late String title;
            late IconData iconData;
            late VoidCallback onTap;

            final String idproses = widget.kode;
            const Color iconColor = Colors.white;

            switch (index) {
              case 0:
                title = "CUTTING RECORD";
                iconData = Icons.post_add_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 1:
                title = "CUTTING RUNNING";
                iconData = Icons.play_circle_fill_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 2:
                title = "CUTTING STOP";
                iconData = Icons.pause_circle_filled_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 3:
                title = "CUTTING MONITORING";
                iconData = Icons.insights;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;

              case 4:
                title = "CUTTING REPORT";
                iconData = Icons.bar_chart_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              default:
                title = "OTHER MENU";
                iconData = Icons.help_outline;
                onTap = () {
                  logPrint("menu $title");
                };
                break;
            }

            // Widget setiap grid item
            return GestureDetector(
              onTap: onTap,
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
                      color: Color.fromRGBO(0, 0, 0, 0.15), // hitam 15% opacity
                      offset: const Offset(3, 3),
                      blurRadius: 6,
                    ),
                    BoxShadow(
                      color: Color.fromRGBO(
                          255, 255, 255, 0.05), // putih 5% opacity
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
                        color: Color.fromRGBO(
                            255, 255, 255, 0.1), // putih 10% opacity
                        border: Border.all(
                          color: Color.fromRGBO(
                              255, 255, 255, 0.2), // putih 20% opacity
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          iconData,
                          size: isTablet ? 48 : 32,
                          color: iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: isTablet ? 16 : 11,
                        fontWeight: FontWeight.w600, // bisa bold atau semi-bold
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
        break;

      case '010':
        bodyWidget = GridView.builder(
          itemCount: 5,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            late String title;
            late IconData iconData;
            late VoidCallback onTap;

            final String idproses = widget.kode;
            const Color iconColor = Colors.white;

            switch (index) {
              case 0:
                title = "SPRAY RECORD";
                iconData = Icons.post_add_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 1:
                title = "SPRAY RUNNING";
                iconData = Icons.play_circle_fill_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 2:
                title = "SPRAY STOP";
                iconData = Icons.pause_circle_filled_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 3:
                title = "SPRAY MONITORING";
                iconData = Icons.insights;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;

              case 4:
                title = "SPRAY REPORT";
                iconData = Icons.bar_chart_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              default:
                title = "OTHER MENU";
                iconData = Icons.help_outline;
                onTap = () {
                  logPrint("menu $title");
                };
                break;
            }

            // Widget setiap grid item
            return GestureDetector(
              onTap: onTap,
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
                      color: Color.fromRGBO(0, 0, 0, 0.15), // hitam 15% opacity
                      offset: const Offset(3, 3),
                      blurRadius: 6,
                    ),
                    BoxShadow(
                      color: Color.fromRGBO(
                          255, 255, 255, 0.05), // putih 5% opacity
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
                        color: Color.fromRGBO(
                            255, 255, 255, 0.1), // putih 10% opacity
                        border: Border.all(
                          color: Color.fromRGBO(
                              255, 255, 255, 0.2), // putih 20% opacity
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          iconData,
                          size: isTablet ? 48 : 32,
                          color: iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: isTablet ? 16 : 11,
                        fontWeight: FontWeight.w600, // bisa bold atau semi-bold
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
        break;

      case '011':
        bodyWidget = GridView.builder(
          itemCount: 5,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            late String title;
            late IconData iconData;
            late VoidCallback onTap;

            final String idproses = widget.kode;
            const Color iconColor = Colors.white;

            switch (index) {
              case 0:
                title = "CAMERA INSPECTION\nRECORD";
                iconData = Icons.post_add_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 1:
                title = "CAMERA INSPECTION\nRUNNING";
                iconData = Icons.play_circle_fill_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 2:
                title = "CAMERA  INSPECTION\nSTOP";
                iconData = Icons.pause_circle_filled_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 3:
                title = "CAMERA INSPECTION\nMONITORING";
                iconData = Icons.insights;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;

              case 4:
                title = "CAMERA INSPECTION\nREPORT";
                iconData = Icons.bar_chart_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              default:
                title = "OTHER MENU";
                iconData = Icons.help_outline;
                onTap = () {
                  logPrint("menu $title");
                };
                break;
            }

            // Widget setiap grid item
            return GestureDetector(
              onTap: onTap,
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
                      color: Color.fromRGBO(0, 0, 0, 0.15), // hitam 15% opacity
                      offset: const Offset(3, 3),
                      blurRadius: 6,
                    ),
                    BoxShadow(
                      color: Color.fromRGBO(
                          255, 255, 255, 0.05), // putih 5% opacity
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
                        color: Color.fromRGBO(
                            255, 255, 255, 0.1), // putih 10% opacity
                        border: Border.all(
                          color: Color.fromRGBO(
                              255, 255, 255, 0.2), // putih 20% opacity
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          iconData,
                          size: isTablet ? 48 : 32,
                          color: iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: isTablet ? 16 : 11,
                        fontWeight: FontWeight.w600, // bisa bold atau semi-bold
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
        break;
      case '012':
        bodyWidget = GridView.builder(
          itemCount: 5,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            late String title;
            late IconData iconData;
            late VoidCallback onTap;

            final String idproses = widget.kode;
            const Color iconColor = Colors.white;

            switch (index) {
              case 0:
                title = "INSPECTION\nRECORD";
                iconData = Icons.post_add_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 1:
                title = "INSPECTION\nRUNNING";
                iconData = Icons.play_circle_fill_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 2:
                title = "INSPECTION\nSTOP";
                iconData = Icons.pause_circle_filled_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 3:
                title = "INSPECTION\nMONITORING";
                iconData = Icons.insights;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;

              case 4:
                title = "INSPECTION REPORT";
                iconData = Icons.bar_chart_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              default:
                title = "OTHER MENU";
                iconData = Icons.help_outline;
                onTap = () {
                  logPrint("menu $title");
                };
                break;
            }

            // Widget setiap grid item
            return GestureDetector(
              onTap: onTap,
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
                      color: Color.fromRGBO(0, 0, 0, 0.15), // hitam 15% opacity
                      offset: const Offset(3, 3),
                      blurRadius: 6,
                    ),
                    BoxShadow(
                      color: Color.fromRGBO(
                          255, 255, 255, 0.05), // putih 5% opacity
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
                        color: Color.fromRGBO(
                            255, 255, 255, 0.1), // putih 10% opacity
                        border: Border.all(
                          color: Color.fromRGBO(
                              255, 255, 255, 0.2), // putih 20% opacity
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          iconData,
                          size: isTablet ? 48 : 32,
                          color: iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: isTablet ? 16 : 11,
                        fontWeight: FontWeight.w600, // bisa bold atau semi-bold
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
        break;

      case '013':
        bodyWidget = GridView.builder(
          itemCount: 5,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            late String title;
            late IconData iconData;
            late VoidCallback onTap;

            final String idproses = widget.kode;
            const Color iconColor = Colors.white;

            switch (index) {
              case 0:
                title = "GI INSPECTION\nRECORD";
                iconData = Icons.post_add_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 1:
                title = "GI INSPECTION\nRUNNING";
                iconData = Icons.play_circle_fill_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 2:
                title = "GI INSPECTION\nSTOP";
                iconData = Icons.pause_circle_filled_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 3:
                title = "GI INSPECTION\nMONITORING";
                iconData = Icons.insights;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;

              case 4:
                title = "GI INSPECTION\nREPORT";
                iconData = Icons.bar_chart_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              default:
                title = "OTHER MENU";
                iconData = Icons.help_outline;
                onTap = () {
                  logPrint("menu $title");
                };
                break;
            }

            // Widget setiap grid item
            return GestureDetector(
              onTap: onTap,
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
                      color: Color.fromRGBO(0, 0, 0, 0.15), // hitam 15% opacity
                      offset: const Offset(3, 3),
                      blurRadius: 6,
                    ),
                    BoxShadow(
                      color: Color.fromRGBO(
                          255, 255, 255, 0.05), // putih 5% opacity
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
                        color: Color.fromRGBO(
                            255, 255, 255, 0.1), // putih 10% opacity
                        border: Border.all(
                          color: Color.fromRGBO(
                              255, 255, 255, 0.2), // putih 20% opacity
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          iconData,
                          size: isTablet ? 48 : 32,
                          color: iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: isTablet ? 16 : 11,
                        fontWeight: FontWeight.w600, // bisa bold atau semi-bold
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
        break;

      case '014':
        bodyWidget = GridView.builder(
          itemCount: 5,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            late String title;
            late IconData iconData;
            late VoidCallback onTap;

            final String idproses = widget.kode;
            const Color iconColor = Colors.white;

            switch (index) {
              case 0:
                title = "MIP RECORD";
                iconData = Icons.post_add_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 1:
                title = "MIP RUNNING";
                iconData = Icons.play_circle_fill_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 2:
                title = "MIP STOP";
                iconData = Icons.pause_circle_filled_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 3:
                title = "MIP MONITORING";
                iconData = Icons.insights;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;

              case 4:
                title = "MIP REPORT";
                iconData = Icons.bar_chart_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              default:
                title = "OTHER MENU";
                iconData = Icons.help_outline;
                onTap = () {
                  logPrint("menu $title");
                };
                break;
            }

            // Widget setiap grid item
            return GestureDetector(
              onTap: onTap,
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
                      color: Color.fromRGBO(0, 0, 0, 0.15), // hitam 15% opacity
                      offset: const Offset(3, 3),
                      blurRadius: 6,
                    ),
                    BoxShadow(
                      color: Color.fromRGBO(
                          255, 255, 255, 0.05), // putih 5% opacity
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
                        color: Color.fromRGBO(
                            255, 255, 255, 0.1), // putih 10% opacity
                        border: Border.all(
                          color: Color.fromRGBO(
                              255, 255, 255, 0.2), // putih 20% opacity
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          iconData,
                          size: isTablet ? 48 : 32,
                          color: iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: isTablet ? 16 : 11,
                        fontWeight: FontWeight.w600, // bisa bold atau semi-bold
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
        break;

      case '015':
        bodyWidget = GridView.builder(
          itemCount: 5,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            late String title;
            late IconData iconData;
            late VoidCallback onTap;

            final String idproses = widget.kode;
            const Color iconColor = Colors.white;

            switch (index) {
              case 0:
                title = "SCREENING\nRECORD";
                iconData = Icons.post_add_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 1:
                title = "SCREENING\nRUNNING";
                iconData = Icons.play_circle_fill_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 2:
                title = "SCREENING\nSTOP";
                iconData = Icons.pause_circle_filled_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 3:
                title = "SCREENING\nMONITORING";
                iconData = Icons.insights;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;

              case 4:
                title = "SCREENING\nREPORT";
                iconData = Icons.bar_chart_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              default:
                title = "OTHER MENU";
                iconData = Icons.help_outline;
                onTap = () {
                  logPrint("menu $title");
                };
                break;
            }

            // Widget setiap grid item
            return GestureDetector(
              onTap: onTap,
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
                      color: Color.fromRGBO(0, 0, 0, 0.15), // hitam 15% opacity
                      offset: const Offset(3, 3),
                      blurRadius: 6,
                    ),
                    BoxShadow(
                      color: Color.fromRGBO(
                          255, 255, 255, 0.05), // putih 5% opacity
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
                        color: Color.fromRGBO(
                            255, 255, 255, 0.1), // putih 10% opacity
                        border: Border.all(
                          color: Color.fromRGBO(
                              255, 255, 255, 0.2), // putih 20% opacity
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          iconData,
                          size: isTablet ? 48 : 32,
                          color: iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: isTablet ? 16 : 11,
                        fontWeight: FontWeight.w600, // bisa bold atau semi-bold
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
        break;

      case '016':
        bodyWidget = GridView.builder(
          itemCount: 5,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            late String title;
            late IconData iconData;
            late VoidCallback onTap;

            final String idproses = widget.kode;
            const Color iconColor = Colors.white;

            switch (index) {
              case 0:
                title = "PACKING RECORD";
                iconData = Icons.post_add_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 1:
                title = "PACKING RUNNING";
                iconData = Icons.play_circle_fill_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 2:
                title = "PACKING STOP";
                iconData = Icons.pause_circle_filled_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 3:
                title = "PACKING MONITORING";
                iconData = Icons.insights;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;

              case 4:
                title = "PACKING REPORT";
                iconData = Icons.bar_chart_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              default:
                title = "OTHER MENU";
                iconData = Icons.help_outline;
                onTap = () {
                  logPrint("menu $title");
                };
                break;
            }

            // Widget setiap grid item
            return GestureDetector(
              onTap: onTap,
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
                      color: Color.fromRGBO(0, 0, 0, 0.15), // hitam 15% opacity
                      offset: const Offset(3, 3),
                      blurRadius: 6,
                    ),
                    BoxShadow(
                      color: Color.fromRGBO(
                          255, 255, 255, 0.05), // putih 5% opacity
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
                        color: Color.fromRGBO(
                            255, 255, 255, 0.1), // putih 10% opacity
                        border: Border.all(
                          color: Color.fromRGBO(
                              255, 255, 255, 0.2), // putih 20% opacity
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          iconData,
                          size: isTablet ? 48 : 32,
                          color: iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: isTablet ? 16 : 11,
                        fontWeight: FontWeight.w600, // bisa bold atau semi-bold
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
        break;

      case '017':
        bodyWidget = GridView.builder(
          itemCount: 5,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            late String title;
            late IconData iconData;
            late VoidCallback onTap;

            final String idproses = widget.kode;
            const Color iconColor = Colors.white;

            switch (index) {
              case 0:
                title = "STORE-IN\nRECORD";
                iconData = Icons.post_add_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 1:
                title = "STORE-IN\nRUNNING";
                iconData = Icons.play_circle_fill_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 2:
                title = "STORE-IN\nSTOP";
                iconData = Icons.pause_circle_filled_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 3:
                title = "STORE-IN\nMONITORING";
                iconData = Icons.insights;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;

              case 4:
                title = "STORE-IN\nREPORT";
                iconData = Icons.bar_chart_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              default:
                title = "OTHER MENU";
                iconData = Icons.help_outline;
                onTap = () {
                  logPrint("menu $title");
                };
                break;
            }

            // Widget setiap grid item
            return GestureDetector(
              onTap: onTap,
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
                      color: Color.fromRGBO(0, 0, 0, 0.15), // hitam 15% opacity
                      offset: const Offset(3, 3),
                      blurRadius: 6,
                    ),
                    BoxShadow(
                      color: Color.fromRGBO(
                          255, 255, 255, 0.05), // putih 5% opacity
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
                        color: Color.fromRGBO(
                            255, 255, 255, 0.1), // putih 10% opacity
                        border: Border.all(
                          color: Color.fromRGBO(
                              255, 255, 255, 0.2), // putih 20% opacity
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          iconData,
                          size: isTablet ? 48 : 32,
                          color: iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: isTablet ? 16 : 11,
                        fontWeight: FontWeight.w600, // bisa bold atau semi-bold
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
        break;

      case '018':
        bodyWidget = GridView.builder(
          itemCount: 5,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            late String title;
            late IconData iconData;
            late VoidCallback onTap;

            final String idproses = widget.kode;
            const Color iconColor = Colors.white;

            switch (index) {
              case 0:
                title = "CLEANING BEFORE OY\nRECORD";
                iconData = Icons.post_add_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 1:
                title = "CLEANING BEFORE OY\nRUNNING";
                iconData = Icons.play_circle_fill_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 2:
                title = "CLEANING BEFORE OY\nSTOP";
                iconData = Icons.pause_circle_filled_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 3:
                title = "CLEANING BEFORE OY\nMONITORING";
                iconData = Icons.insights;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;

              case 4:
                title = "CLEANING BEFORE OY\nREPORT";
                iconData = Icons.bar_chart_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              default:
                title = "OTHER MENU";
                iconData = Icons.help_outline;
                onTap = () {
                  logPrint("menu $title");
                };
                break;
            }

            // Widget setiap grid item
            return GestureDetector(
              onTap: onTap,
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
                      color: Color.fromRGBO(0, 0, 0, 0.15), // hitam 15% opacity
                      offset: const Offset(3, 3),
                      blurRadius: 6,
                    ),
                    BoxShadow(
                      color: Color.fromRGBO(
                          255, 255, 255, 0.05), // putih 5% opacity
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
                        color: Color.fromRGBO(
                            255, 255, 255, 0.1), // putih 10% opacity
                        border: Border.all(
                          color: Color.fromRGBO(
                              255, 255, 255, 0.2), // putih 20% opacity
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          iconData,
                          size: isTablet ? 48 : 32,
                          color: iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: isTablet ? 16 : 11,
                        fontWeight: FontWeight.w600, // bisa bold atau semi-bold
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
        break;

      case '019':
        bodyWidget = GridView.builder(
          itemCount: 5,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            late String title;
            late IconData iconData;
            late VoidCallback onTap;

            final String idproses = widget.kode;
            const Color iconColor = Colors.white;

            switch (index) {
              case 0:
                title = "CLEANING BEFORE\nINSPECTION RECORD";
                iconData = Icons.post_add_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 1:
                title = "CLEANING BEFORE\nINSPECTION RUNNING";
                iconData = Icons.play_circle_fill_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 2:
                title = "CLEANING BEFORE\nINSPECTION STOP";
                iconData = Icons.pause_circle_filled_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 3:
                title = "CLEANING BEFORE\nINSPECTION MONITORING";
                iconData = Icons.insights;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;

              case 4:
                title = "CLEANING BEFORE\nINSPECTION REPORT";
                iconData = Icons.bar_chart_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              default:
                title = "OTHER MENU";
                iconData = Icons.help_outline;
                onTap = () {
                  logPrint("menu $title");
                };
                break;
            }

            // Widget setiap grid item
            return GestureDetector(
              onTap: onTap,
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
                      color: Color.fromRGBO(0, 0, 0, 0.15), // hitam 15% opacity
                      offset: const Offset(3, 3),
                      blurRadius: 6,
                    ),
                    BoxShadow(
                      color: Color.fromRGBO(
                          255, 255, 255, 0.05), // putih 5% opacity
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
                        color: Color.fromRGBO(
                            255, 255, 255, 0.1), // putih 10% opacity
                        border: Border.all(
                          color: Color.fromRGBO(
                              255, 255, 255, 0.2), // putih 20% opacity
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          iconData,
                          size: isTablet ? 48 : 32,
                          color: iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: isTablet ? 16 : 11,
                        fontWeight: FontWeight.w600, // bisa bold atau semi-bold
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
        break;
      case '020':
        bodyWidget = GridView.builder(
          itemCount: 5,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            late String title;
            late IconData iconData;
            late VoidCallback onTap;

            final String idproses = widget.kode;
            const Color iconColor = Colors.white;

            switch (index) {
              case 0:
                title = "CLEANING PILL\nRECORD";
                iconData = Icons.post_add_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 1:
                title = "CLEANING PILL\nRUNNING";
                iconData = Icons.play_circle_fill_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 2:
                title = "CLEANING PILL\nSTOP";
                iconData = Icons.pause_circle_filled_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 3:
                title = "CLEANING PILL\nMONITORING";
                iconData = Icons.insights;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;

              case 4:
                title = "CLEANING PILL\nREPORT";
                iconData = Icons.bar_chart_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              default:
                title = "OTHER MENU";
                iconData = Icons.help_outline;
                onTap = () {
                  logPrint("menu $title");
                };
                break;
            }

            // Widget setiap grid item
            return GestureDetector(
              onTap: onTap,
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
                      color: Color.fromRGBO(0, 0, 0, 0.15), // hitam 15% opacity
                      offset: const Offset(3, 3),
                      blurRadius: 6,
                    ),
                    BoxShadow(
                      color: Color.fromRGBO(
                          255, 255, 255, 0.05), // putih 5% opacity
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
                        color: Color.fromRGBO(
                            255, 255, 255, 0.1), // putih 10% opacity
                        border: Border.all(
                          color: Color.fromRGBO(
                              255, 255, 255, 0.2), // putih 20% opacity
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          iconData,
                          size: isTablet ? 48 : 32,
                          color: iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: isTablet ? 16 : 11,
                        fontWeight: FontWeight.w600, // bisa bold atau semi-bold
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
        break;

      case '021':
        bodyWidget = GridView.builder(
          itemCount: 5,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            late String title;
            late IconData iconData;
            late VoidCallback onTap;

            final String idproses = widget.kode;
            const Color iconColor = Colors.white;

            switch (index) {
              case 0:
                title = "PREPUSH\nRECORD";
                iconData = Icons.post_add_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 1:
                title = "PREPUSH\nRUNNING";
                iconData = Icons.play_circle_fill_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 2:
                title = "PREPUSH\nSTOP";
                iconData = Icons.pause_circle_filled_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 3:
                title = "PREPUSH\nMONITORING";
                iconData = Icons.insights;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;

              case 4:
                title = "PREPUSH\nREPORT";
                iconData = Icons.bar_chart_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              default:
                title = "OTHER MENU";
                iconData = Icons.help_outline;
                onTap = () {
                  logPrint("menu $title");
                };
                break;
            }

            // Widget setiap grid item
            return GestureDetector(
              onTap: onTap,
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
                      color: Color.fromRGBO(0, 0, 0, 0.15), // hitam 15% opacity
                      offset: const Offset(3, 3),
                      blurRadius: 6,
                    ),
                    BoxShadow(
                      color: Color.fromRGBO(
                          255, 255, 255, 0.05), // putih 5% opacity
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
                        color: Color.fromRGBO(
                            255, 255, 255, 0.1), // putih 10% opacity
                        border: Border.all(
                          color: Color.fromRGBO(
                              255, 255, 255, 0.2), // putih 20% opacity
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          iconData,
                          size: isTablet ? 48 : 32,
                          color: iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: isTablet ? 16 : 11,
                        fontWeight: FontWeight.w600, // bisa bold atau semi-bold
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
        break;

      case '022':
        bodyWidget = GridView.builder(
          itemCount: 5,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            late String title;
            late IconData iconData;
            late VoidCallback onTap;

            final String idproses = widget.kode;
            const Color iconColor = Colors.white;

            switch (index) {
              case 0:
                title = "PUNCHING IHP\nRECORD";
                iconData = Icons.post_add_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 1:
                title = "PUNCHING IHP\nRUNNING";
                iconData = Icons.play_circle_fill_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 2:
                title = "PUNCHING IHP\nSTOP";
                iconData = Icons.pause_circle_filled_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 3:
                title = "PUNCHING IHP\nMONITORING";
                iconData = Icons.insights;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;

              case 4:
                title = "PUNCHING IHP\nREPORT";
                iconData = Icons.bar_chart_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              default:
                title = "OTHER MENU";
                iconData = Icons.help_outline;
                onTap = () {
                  logPrint("menu $title");
                };
                break;
            }

            // Widget setiap grid item
            return GestureDetector(
              onTap: onTap,
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
                      color: Color.fromRGBO(0, 0, 0, 0.15), // hitam 15% opacity
                      offset: const Offset(3, 3),
                      blurRadius: 6,
                    ),
                    BoxShadow(
                      color: Color.fromRGBO(
                          255, 255, 255, 0.05), // putih 5% opacity
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
                        color: Color.fromRGBO(
                            255, 255, 255, 0.1), // putih 10% opacity
                        border: Border.all(
                          color: Color.fromRGBO(
                              255, 255, 255, 0.2), // putih 20% opacity
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          iconData,
                          size: isTablet ? 48 : 32,
                          color: iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: isTablet ? 16 : 11,
                        fontWeight: FontWeight.w600, // bisa bold atau semi-bold
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
        break;
      case '023':
        bodyWidget = GridView.builder(
          itemCount: 5,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            late String title;
            late IconData iconData;
            late VoidCallback onTap;

            final String idproses = widget.kode;
            const Color iconColor = Colors.white;

            switch (index) {
              case 0:
                title = "CIIP RECORD";
                iconData = Icons.post_add_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 1:
                title = "CIIP RUNNING";
                iconData = Icons.play_circle_fill_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 2:
                title = "CIIP STOP";
                iconData = Icons.pause_circle_filled_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 3:
                title = "CIIP MONITORING";
                iconData = Icons.insights;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;

              case 4:
                title = "CIIP REPORT";
                iconData = Icons.bar_chart_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              default:
                title = "OTHER MENU";
                iconData = Icons.help_outline;
                onTap = () {
                  logPrint("menu $title");
                };
                break;
            }

            // Widget setiap grid item
            return GestureDetector(
              onTap: onTap,
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
                      color: Color.fromRGBO(0, 0, 0, 0.15), // hitam 15% opacity
                      offset: const Offset(3, 3),
                      blurRadius: 6,
                    ),
                    BoxShadow(
                      color: Color.fromRGBO(
                          255, 255, 255, 0.05), // putih 5% opacity
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
                        color: Color.fromRGBO(
                            255, 255, 255, 0.1), // putih 10% opacity
                        border: Border.all(
                          color: Color.fromRGBO(
                              255, 255, 255, 0.2), // putih 20% opacity
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          iconData,
                          size: isTablet ? 48 : 32,
                          color: iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: isTablet ? 16 : 11,
                        fontWeight: FontWeight.w600, // bisa bold atau semi-bold
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
        break;

      case '024':
        bodyWidget = GridView.builder(
          itemCount: 5,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            late String title;
            late IconData iconData;
            late VoidCallback onTap;

            final String idproses = widget.kode;
            const Color iconColor = Colors.white;

            switch (index) {
              case 0:
                title = "DEFLASHING\nRECORD";
                iconData = Icons.post_add_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 1:
                title = "DEFLASHING\nRUNNING";
                iconData = Icons.play_circle_fill_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 2:
                title = "DEFLASHING\nSTOP";
                iconData = Icons.pause_circle_filled_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 3:
                title = "DEFLASHING\nMONITORING";
                iconData = Icons.insights;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;

              case 4:
                title = "DEFLASHING\nREPORT";
                iconData = Icons.bar_chart_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              default:
                title = "OTHER MENU";
                iconData = Icons.help_outline;
                onTap = () {
                  logPrint("menu $title");
                };
                break;
            }

            // Widget setiap grid item
            return GestureDetector(
              onTap: onTap,
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
                      color: Color.fromRGBO(0, 0, 0, 0.15), // hitam 15% opacity
                      offset: const Offset(3, 3),
                      blurRadius: 6,
                    ),
                    BoxShadow(
                      color: Color.fromRGBO(
                          255, 255, 255, 0.05), // putih 5% opacity
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
                        color: Color.fromRGBO(
                            255, 255, 255, 0.1), // putih 10% opacity
                        border: Border.all(
                          color: Color.fromRGBO(
                              255, 255, 255, 0.2), // putih 20% opacity
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          iconData,
                          size: isTablet ? 48 : 32,
                          color: iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: isTablet ? 16 : 11,
                        fontWeight: FontWeight.w600, // bisa bold atau semi-bold
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
        break;
      case '025':
        bodyWidget = GridView.builder(
          itemCount: 5,
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (context, index) {
            late String title;
            late IconData iconData;
            late VoidCallback onTap;

            final String idproses = widget.kode;
            const Color iconColor = Colors.white;

            switch (index) {
              case 0:
                title = "DOT MARKING\nRECORD";
                iconData = Icons.post_add_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 1:
                title = "DOT MARKING\nRUNNING";
                iconData = Icons.play_circle_fill_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 2:
                title = "DOT MARKING\nSTOP";
                iconData = Icons.pause_circle_filled_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              case 3:
                title = "DOT MARKING\nMONITORING";
                iconData = Icons.insights;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;

              case 4:
                title = "DOT MARKING\nREPORT";
                iconData = Icons.bar_chart_rounded;
                onTap = () {
                  logPrint("menu $title dengan id proses $idproses");
                };
                break;
              default:
                title = "OTHER MENU";
                iconData = Icons.help_outline;
                onTap = () {
                  logPrint("menu $title");
                };
                break;
            }

            // Widget setiap grid item
            return GestureDetector(
              onTap: onTap,
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
                      color: Color.fromRGBO(0, 0, 0, 0.15), // hitam 15% opacity
                      offset: const Offset(3, 3),
                      blurRadius: 6,
                    ),
                    BoxShadow(
                      color: Color.fromRGBO(
                          255, 255, 255, 0.05), // putih 5% opacity
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
                        color: Color.fromRGBO(
                            255, 255, 255, 0.1), // putih 10% opacity
                        border: Border.all(
                          color: Color.fromRGBO(
                              255, 255, 255, 0.2), // putih 20% opacity
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          iconData,
                          size: isTablet ? 48 : 32,
                          color: iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: isTablet ? 16 : 11,
                        fontWeight: FontWeight.w600, // bisa bold atau semi-bold
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
        break;

      default:
        bodyWidget = Center(
          child: Text("Default Prosesnya adalah ${widget.proses}"),
        );
    }

    return Scaffold(
      appBar: myAppBar,
      body: bodyWidget,
    );
  }
}
