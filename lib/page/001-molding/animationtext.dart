import 'package:flutter/material.dart';
import 'package:flutter_provider_data/page/main_menu_admin.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:math'; // <<< penting agar sin dan pi tersedia
import 'dart:ui'; // ⬅️ ini penting untuk ImageFilter.blur()

class AnimationText extends StatefulWidget {
  final String title;
  final String idProses;

  const AnimationText({
    super.key,
    required this.title,
    required this.idProses,
  });

  @override
  State<AnimationText> createState() => _AnimationTextState();
}

class _AnimationTextState extends State<AnimationText>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );

    final myAppBar = PreferredSize(
      preferredSize: Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.blue.shade800],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: AppBar(
          title: Text(
            'All Animated Text Effects',
            style: const TextStyle(
                color: Colors.white, fontSize: 20.0, fontFamily: "Montserrat"),
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
          backgroundColor: Colors.transparent,
        ),
      ),
    );

    return Scaffold(
      appBar: myAppBar,
      backgroundColor: Colors.indigo.shade50,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle("TypewriterAnimatedText"),
          _container(
            child: AnimatedTextKit(
              animatedTexts: [
                TypewriterAnimatedText(
                  'System Initializing...',
                  textStyle: textStyle,
                  speed: const Duration(milliseconds: 120),
                ),
              ],
              repeatForever: true,
            ),
          ),
          _buildSectionTitle("FadeAnimatedText"),
          _container(
            child: AnimatedTextKit(
              animatedTexts: [
                FadeAnimatedText('Loading...', textStyle: textStyle),
                FadeAnimatedText('Please Wait...', textStyle: textStyle),
                FadeAnimatedText('Almost Ready!', textStyle: textStyle),
              ],
              repeatForever: true,
            ),
          ),
          _buildSectionTitle("TyperAnimatedText"),
          _container(
            child: AnimatedTextKit(
              animatedTexts: [
                TyperAnimatedText('Checking Sensors...', textStyle: textStyle),
                TyperAnimatedText('Calibrating...', textStyle: textStyle),
                TyperAnimatedText('Done!', textStyle: textStyle),
              ],
              repeatForever: true,
            ),
          ),
          _buildSectionTitle("ColorizeAnimatedText"),
          _container(
            color: Colors.black,
            child: AnimatedTextKit(
              animatedTexts: [
                ColorizeAnimatedText(
                  '⚠️ WARNING: TEST IN PROGRESS ⚠️',
                  textStyle: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  colors: [
                    Colors.red,
                    Colors.orange,
                    Colors.yellow,
                    Colors.white,
                  ],
                ),
              ],
              repeatForever: true,
            ),
          ),
          _buildSectionTitle("RotateAnimatedText"),
          _container(
            child: AnimatedTextKit(
              animatedTexts: [
                RotateAnimatedText(
                  'INSPECTING...',
                  textStyle: textStyle,
                ),
                RotateAnimatedText(
                  'CALIBRATING...',
                  textStyle: textStyle,
                ),
                RotateAnimatedText(
                  'READY!',
                  textStyle: textStyle,
                ),
              ],
              repeatForever: true,
            ),
          ),
          _buildSectionTitle("WavyAnimatedText"),
          _container(
            child: AnimatedTextKit(
              animatedTexts: [
                WavyAnimatedText('Testing Product Quality...',
                    textStyle: textStyle),
              ],
              repeatForever: true,
            ),
          ),
          _buildSectionTitle("FlickerAnimatedText"),
          _container(
            color: Colors.black,
            child: AnimatedTextKit(
              animatedTexts: [
                FlickerAnimatedText(
                  '⚡ SYSTEM ACTIVE ⚡',
                  textStyle: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.greenAccent,
                  ),
                ),
              ],
              repeatForever: true,
            ),
          ),
          _buildSectionTitle("TextLiquidFill (Efek Air)"),
          _container(
            color: Colors.black,
            height: 120,
            child: Center(
              child: TextLiquidFill(
                text: 'MANPRO',
                waveColor: Colors.blueAccent,
                boxBackgroundColor: Colors.black,
                textStyle: GoogleFonts.poppins(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                ),
                boxHeight: 100,
              ),
            ),
          ),

          // 🆕 Tambahan Section: Ticker / Announcement Style
          _buildSectionTitle("Ticker / Announcement Animated Text"),
          _container(
            color: Colors.indigo.shade900,
            height: 80,
            child: AnimatedTextKit(
              animatedTexts: [
                TyperAnimatedText(
                  '🚀 New production record system is now live!',
                  textStyle: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellowAccent,
                  ),
                  speed: const Duration(milliseconds: 80),
                ),
                FadeAnimatedText(
                  '📢 Please complete calibration before 5 PM!',
                  textStyle: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.orangeAccent,
                  ),
                ),
                ColorizeAnimatedText(
                  '💡 Remember: Safety and quality come first!',
                  textStyle: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  colors: [
                    Colors.cyanAccent,
                    Colors.lightGreenAccent,
                    Colors.yellowAccent,
                    Colors.white,
                  ],
                ),
              ],
              repeatForever: true,
              pause: const Duration(milliseconds: 800),
              displayFullTextOnTap: true,
              stopPauseOnTap: true,
            ),
          ),

          _buildSectionTitle("Glowing Text (True Neon Effect Safe)"),
          _container(
            color: Colors.black,
            height: 200,
            child: Center(
              child: AnimatedBuilder(
                animation: _glowController,
                builder: (context, child) {
                  final glow = (1 + sin(_glowController.value * 2 * pi)) * 0.5;

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // ✨ Lapisan cahaya lembut (blur glow aman)
                      Opacity(
                        opacity: 0.5 + 0.3 * glow,
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(
                              sigmaX: 20 + 5 * glow, sigmaY: 20 + 5 * glow),
                          child: Text(
                            'MANPRO SYSTEM',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              color: Colors.cyanAccent.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),

                      // 💡 Lapisan tengah (aura dalam lebih kuat)
                      Opacity(
                        opacity: 0.7 + 0.3 * glow,
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(
                              sigmaX: 10 + 2 * glow, sigmaY: 10 + 2 * glow),
                          child: Text(
                            'MANPRO SYSTEM',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 64,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              color: Colors.blueAccent.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ),

                      // 🌟 Lapisan utama (teks solid terang)
                      Text(
                        'MANPRO SYSTEM',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: Colors.blueAccent,
                          shadows: [
                            Shadow(
                              color: Colors.cyanAccent.withValues(alpha: 0.7),
                              blurRadius: 20 + 5 * glow,
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.indigo.shade900,
        ),
      ),
    );
  }

  Widget _container({required Widget child, Color? color, double? height}) {
    return Container(
      height: height ?? 80,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color ?? Colors.indigo.shade400,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 5,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: Center(child: child),
    );
  }
}
