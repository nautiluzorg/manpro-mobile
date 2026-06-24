import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class StopGridFilterButton extends StatelessWidget {
  final double width;
  final bool isDisabled;
  final IconData icon;
  final String label;
  final Future<void> Function() onTap;

  const StopGridFilterButton({
    super.key,
    required this.width,
    required this.isDisabled,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDisabled ? Colors.grey.shade400 : Colors.green.shade400;

    return SizedBox(
      width: width,
      child: OutlinedButton(
        onPressed: isDisabled ? null : onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          side: BorderSide(color: color, width: 1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
