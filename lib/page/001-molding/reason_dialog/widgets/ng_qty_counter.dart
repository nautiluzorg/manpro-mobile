import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget counter qty NG dengan tombol - dan +.
class NgQtyCounter extends StatelessWidget {
  final TextEditingController ngQtyController;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const NgQtyCounter({
    super.key,
    required this.ngQtyController,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.redAccent, Colors.red.shade900],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.shade200.withValues(alpha: 0.5),
                  offset: const Offset(1, 1),
                  blurRadius: 4,
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onDecrement,
              child: const Padding(
                padding: EdgeInsets.all(6.0),
                child: Icon(Icons.remove, color: Colors.white, size: 24),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueGrey),
                borderRadius: BorderRadius.circular(5),
              ),
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: ngQtyController,
                builder: (context, value, _) {
                  return Text(
                    value.text.isEmpty ? '0' : value.text,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.greenAccent, Colors.green.shade900],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.shade200.withValues(alpha: 0.5),
                  offset: const Offset(1, 1),
                  blurRadius: 4,
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: onIncrement,
              child: const Padding(
                padding: EdgeInsets.all(6.0),
                child: Icon(Icons.add, color: Colors.white, size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
