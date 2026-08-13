import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

/// Banner oranye dengan teks berjalan berisi pengingat untuk operator
/// baru (scan QR, input qty shoot, input NG, dsb).
class WorkdayOverAnnouncementBanner extends StatelessWidget {
  const WorkdayOverAnnouncementBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: 80,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.orangeAccent,
                Colors.orange.shade600,
                Colors.orange.shade900,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(40),
                blurRadius: 5,
                offset: const Offset(2, 3),
              ),
            ],
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: AnimatedTextKit(
                repeatForever: true,
                pause: const Duration(seconds: 3),
                displayFullTextOnTap: true,
                stopPauseOnTap: true,
                animatedTexts: [
                  TyperAnimatedText(
                    '📢 Scan QRCode ID Card Employee untuk operator baru',
                    speed: const Duration(milliseconds: 100),
                    textStyle: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellowAccent,
                    ),
                  ),
                  FadeAnimatedText(
                    '📢 Jangan lupa input qty Shoot last operator',
                    duration: const Duration(seconds: 10),
                    textStyle: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.tealAccent,
                    ),
                  ),
                  ColorizeAnimatedText(
                    '💡 Jangan lupa input data NG last Operator jika ada!',
                    speed: const Duration(milliseconds: 50),
                    textStyle: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    colors: const [
                      Colors.cyanAccent,
                      Colors.lightGreenAccent,
                      Colors.yellowAccent,
                      Colors.white,
                    ],
                  ),
                  TyperAnimatedText(
                    '🫶 Tetap jaga kualitas Molding!',
                    speed: const Duration(milliseconds: 100),
                    textStyle: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.tealAccent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
