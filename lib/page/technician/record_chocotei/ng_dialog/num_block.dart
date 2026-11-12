import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NumBlock extends StatelessWidget {
  final Function(String) onNumPressed;
  final VoidCallback onBackspace;
  final VoidCallback onClose;

  const NumBlock({
    super.key,
    required this.onNumPressed,
    required this.onBackspace,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    // Mendapatkan ukuran layar
    double screenWidth = MediaQuery.of(context).size.width;

    return LayoutBuilder(builder: (context, constraints) {
      return GridView.builder(
        shrinkWrap: true,
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: screenWidth / 4,
          childAspectRatio: 1.0,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: 12,
        itemBuilder: (context, index) {
          String buttonText;
          VoidCallback onPress;

          if (index == 9) {
            buttonText = '0';
            onPress = () => onNumPressed(buttonText);
          } else if (index == 10) {
            buttonText = 'CLEAR';
            onPress = onBackspace;
          } else if (index == 11) {
            buttonText = 'OK';
            onPress = onClose;
          } else {
            buttonText = (index + 1).toString();
            onPress = () => onNumPressed(buttonText);
          }

          return GestureDetector(
            onTap: onPress,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.indigoAccent,
                    Colors.indigo.shade900
                  ], // Gradasi biru
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                buttonText,
                style: GoogleFonts.poppins(
                  fontSize: 35,
                  color: Colors.white,
                  fontWeight: FontWeight
                      .w600, // optional, biar teksnya sedikit lebih tegas
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
