import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StopGridTotalText extends StatelessWidget {
  final int total;

  const StopGridTotalText({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.right,
      text: TextSpan(
        children: [
          TextSpan(
            text: 'TOTAL ',
            style: GoogleFonts.poppins(
              color: Colors.blueGrey.shade400,
              fontWeight: FontWeight.w500,
              fontSize: 18,
            ),
          ),
          WidgetSpan(
            child: ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [Colors.red.shade400, Colors.red.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
              child: Text(
                '$total',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          TextSpan(
            text: ' MOLD STOP',
            style: GoogleFonts.poppins(
              color: Colors.blueGrey.shade400,
              fontWeight: FontWeight.w500,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}
