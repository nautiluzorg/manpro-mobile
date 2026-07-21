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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          side: BorderSide(color: color, width: 1),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
