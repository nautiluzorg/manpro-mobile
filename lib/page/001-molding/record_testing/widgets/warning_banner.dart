import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

/// The top rotating-warning banner ("Check kembali setting mesin...").
/// Extracted verbatim from record_testing.dart's `_container` +
/// `AnimatedTextKit` block — same 3 messages, same gradient shader per line.
class WarningBanner extends StatelessWidget {
  const WarningBanner({super.key});

  static const _messages = [
    'Check kembali setting mesin sebelum proses Molding!',
    'Hati-hati, suhu dan tekanan harus sesuai standar!',
    'Jangan abaikan tanda abnormal pada mesin dan material!',
  ];

  static final List<List<Color>> _messageGradients = [
    [Colors.redAccent, Colors.orange.shade900, Colors.yellowAccent],
    [Colors.yellow.shade400, Colors.orange.shade300, Colors.red.shade300],
    [Colors.yellow.shade400, Colors.orangeAccent, Colors.red.shade500],
  ];

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );

    return Container(
      height: 80,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.indigoAccent,
            Colors.indigo.shade900.withValues(alpha: 0.95),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Center(
        child: AnimatedTextKit(
          repeatForever: true,
          animatedTexts: [
            for (var i = 0; i < _messages.length; i++)
              TyperAnimatedText(
                _messages[i],
                textStyle: textStyle.copyWith(
                  foreground: Paint()
                    ..shader = LinearGradient(
                      colors: _messageGradients[i],
                    ).createShader(const Rect.fromLTWH(0.0, 0.0, 300.0, 70.0)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
