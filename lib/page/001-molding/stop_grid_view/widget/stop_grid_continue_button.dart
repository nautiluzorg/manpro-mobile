import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StopGridContinueButton extends StatelessWidget {
  final double width;
  final bool isEnabled;
  final VoidCallback onPressed;

  const StopGridContinueButton({
    super.key,
    required this.width,
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          gradient: isEnabled
              ? LinearGradient(
                  colors: [Colors.greenAccent, Colors.green.shade900],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                )
              : LinearGradient(
                  colors: [Colors.grey.shade400, Colors.grey.shade500],
                ),
          borderRadius: BorderRadius.circular(26),
        ),
        child: OutlinedButton(
          onPressed: isEnabled ? onPressed : null,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
            backgroundColor: Colors.transparent,
            side: BorderSide.none,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.play_arrow_rounded,
                size: 20,
                color: isEnabled ? Colors.white : Colors.grey.shade300,
              ),
              const SizedBox(width: 4),
              Text(
                'CONTINUE',
                style: GoogleFonts.poppins(
                  color: isEnabled ? Colors.white : Colors.grey.shade300,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
