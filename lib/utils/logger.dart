// lib/utils/logger.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_provider_data/navigation/auth_navigator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

//Widget customAppBar
PreferredSizeWidget customAppBar({
  required BuildContext context,
  required String title,
  required String kode,
  required String proses,
  required Widget Function(String kode, String proses) navigateToBuilder,
  bool useFadeTransition = true,
}) {
  return PreferredSize(
    preferredSize: Size.fromHeight(kToolbarHeight),
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.blue.shade900],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: AppBar(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 26.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          onPressed: () async {
            await AuthNavigator.goHome(context);
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    ),
  );
}

PreferredSizeWidget customSubAppBar({
  required BuildContext context,
  required String title,
  required String kode,
  required String proses,
  required Widget Function(String kode, String proses) navigateToBuilder,
  bool useFadeTransition = true,
}) {
  return PreferredSize(
    preferredSize: Size.fromHeight(kToolbarHeight),
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.blue.shade900],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: AppBar(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 26.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          onPressed: () async {
            await AuthNavigator.goToSubMenu(context);
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    ),
  );
}

void logPrint(String message) {
  if (kDebugMode) {
    print(message);
  }
}

String formatDateTime(String dateTimeString) {
  try {
    DateTime dateTime = DateTime.parse(dateTimeString)
        .toLocal(); // Parse UTC time and convert to local time

    // Format the DateTime to local Japan Standard Time (JST)
    return DateFormat('dd-MM-yyyy HH:mm')
        .format(dateTime); // Format to desired string format
  } catch (e) {
    return dateTimeString; // Return the original string if parsing fails
  }
}

String formatDate(String dateTimeString) {
  try {
    DateTime dateTime = DateTime.parse(dateTimeString)
        .toLocal(); // Parse UTC time and convert to local time

    // Format the DateTime to local Japan Standard Time (JST)
    return DateFormat('dd-MM-yyyy')
        .format(dateTime); // Format to desired string format
  } catch (e) {
    return dateTimeString; // Return the original string if parsing fails
  }
}

// Format Date with Month Name
String formatDateBln(String dateTimeString) {
  try {
    final dateTime = DateTime.parse(dateTimeString).toLocal();
    return DateFormat('dd MMMM yyyy').format(dateTime);
  } catch (e) {
    return dateTimeString;
  }
}

String formatDateTimeBln(String dateTimeString) {
  try {
    final dateTime = DateTime.parse(dateTimeString).toLocal();
    return DateFormat('dd MMMM yyyy HH:mm', 'en_US').format(dateTime);
  } catch (e) {
    return dateTimeString;
  }
}

String formatTimeDateBln(String dateTimeString) {
  try {
    final dateTime = DateTime.parse(dateTimeString).toLocal();
    return DateFormat('HH:mm dd MMMM yyyy', 'en_US').format(dateTime);
  } catch (e) {
    return dateTimeString;
  }
}

String formatNowTimeDateBln() {
  final now = DateTime.now();
  return DateFormat('HH:mm dd MMMM yyyy', 'en_US').format(now);
}

String formatDateTimeFromDate(DateTime dateTime) {
  return DateFormat('dd-MM-yyyy HH:mm').format(dateTime.toLocal());
}

String formatDateTimeFromDateBln(DateTime dateTime) {
  return DateFormat('dd MMMM yyyy HH:mm', 'en_US').format(dateTime.toLocal());
}

String getStopDuration(String startPending) {
  final start = DateTime.parse(startPending);
  final duration = DateTime.now().difference(start);

  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final hours = twoDigits(duration.inHours);
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));

  return "$hours:$minutes:$seconds";
}

/// Fade Transition
Future navigateWithFade(BuildContext context, Widget page,
    {int duration = 300}) {
  return Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
      transitionDuration: Duration(milliseconds: duration),
    ),
  );
}

/// Slide from Right
Future navigateWithSlideRight(BuildContext context, Widget page,
    {int duration = 300}) {
  return Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(animation),
        child: child,
      ),
      transitionDuration: Duration(milliseconds: duration),
    ),
  );
}

/// Slide from Left
Future navigateWithSlideLeft(BuildContext context, Widget page,
    {int duration = 300}) {
  return Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
            .animate(animation),
        child: child,
      ),
      transitionDuration: Duration(milliseconds: duration),
    ),
  );
}

/// Scale / Zoom Transition
Future navigateWithScale(BuildContext context, Widget page,
    {int duration = 300}) {
  return Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) =>
          ScaleTransition(scale: animation, child: child),
      transitionDuration: Duration(milliseconds: duration),
    ),
  );
}

/// Rotation Transition
Future navigateWithRotation(BuildContext context, Widget page,
    {int duration = 300}) {
  return Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) =>
          RotationTransition(turns: animation, child: child),
      transitionDuration: Duration(milliseconds: duration),
    ),
  );
}

/// Slide + Fade Transition
Future navigateWithSlideFade(BuildContext context, Widget page,
    {int duration = 300}) {
  return Navigator.push(
    context,
    PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) => SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(animation),
        child: FadeTransition(opacity: animation, child: child),
      ),
      transitionDuration: Duration(milliseconds: duration),
    ),
  );
}

//FUNCTION HELPER APPBAR FOR FULL DIALOG.

PreferredSizeWidget customDialogAppBar({
  required String title,
  bool showBackButton = false,
  VoidCallback? onBack,
}) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(kToolbarHeight),
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blueAccent,
            Colors.blue.shade900,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: onBack,
              )
            : null,
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  );
}

PreferredSizeWidget customAppBar2({
  required BuildContext context,
  required String title,
  required String proses,
  required Widget Function(String kode, String proses) navigateToBuilder,
  bool useFadeTransition = true,
}) {
  return PreferredSize(
    preferredSize: Size.fromHeight(kToolbarHeight),
    child: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blueAccent, Colors.blue.shade900],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: AppBar(
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 26.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          onPressed: () {
            Widget targetPage = navigateToBuilder(title, proses);
            if (useFadeTransition) {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      targetPage,
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
            } else {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => targetPage));
            }
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
    ),
  );
}

//CUSTOM TEXTFIELD
Widget buildTextField({
  required TextEditingController controller,
  required String label,
  required String hint,
  IconData? icon, // nullable
  bool readOnly = false,
  VoidCallback? onIconTap,
  List<TextInputFormatter>? inputFormatters,
  Widget? suffixIcon,
}) {
  final bool hasPrefixIcon = icon != null;

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 2.0),
    child: TextField(
      controller: controller,
      readOnly: readOnly,
      inputFormatters: inputFormatters,
      keyboardType:
          inputFormatters != null ? TextInputType.number : TextInputType.text,
      style: GoogleFonts.poppins(
        fontSize: 13.0,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        // Gunakan widget label dengan padding bawah
        label: Padding(
          padding: const EdgeInsets.only(bottom: 6), // jarak bawah label
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14.0,
              color: Colors.black,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: hasPrefixIcon ? 0 : 12,
          vertical: 12,
        ),
        prefixIcon: hasPrefixIcon
            ? Container(
                width: 36,
                height: 36,
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade300,
                      Colors.blue.shade900,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: Colors.grey.shade500,
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: IconButton(
                  onPressed: onIconTap,
                  icon: Icon(
                    icon,
                    size: 20,
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              )
            : null,
        suffixIcon: suffixIcon != null
            ? Container(
                width: 36,
                height: 36,
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blueGrey.shade50,
                      Colors.blueGrey.shade400,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: Colors.blueGrey.shade300,
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: suffixIcon,
              )
            : null,
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          color: Colors.grey.shade500,
          fontStyle: FontStyle.italic,
          fontSize: 14.0,
        ),
      ),
    ),
  );
}
