import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomSnackbarUpdate {
  static void show(
    BuildContext context,
    String message, {
    bool isSuccess = true,
    int durationInSeconds = 2,
    double top = 50.0,
  }) {
    // Ambil overlay sebelum dipakai
    final overlay = Overlay.of(context, rootOverlay: true);

    late final OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (_) {
        return _SnackbarWidget(
          message: message,
          isSuccess: isSuccess,
          top: top,
          durationInSeconds: durationInSeconds,
          overlayEntry: overlayEntry,
        );
      },
    );

    // Masukkan ke overlay
    overlay.insert(overlayEntry);
  }
}

class CustomSnackbar {
  static void show(
    BuildContext context,
    String message, {
    bool isSuccess = true,
    int durationInSeconds = 2,
    double top = 50.0,
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    showWithOverlay(
      overlay,
      message,
      isSuccess: isSuccess,
      durationInSeconds: durationInSeconds,
      top: top,
    );
  }

  // ✅ Method baru yang tidak butuh BuildContext
  static void showWithOverlay(
    OverlayState overlay,
    String message, {
    bool isSuccess = true,
    int durationInSeconds = 2,
    double top = 50.0,
  }) {
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => _SnackbarWidget(
        message: message,
        isSuccess: isSuccess,
        top: top,
        durationInSeconds: durationInSeconds,
        overlayEntry: overlayEntry,
      ),
    );

    overlay.insert(overlayEntry);
  }
}

class _SnackbarWidget extends StatefulWidget {
  final String message;
  final bool isSuccess;
  final double top;
  final int durationInSeconds;
  final OverlayEntry overlayEntry;

  const _SnackbarWidget({
    required this.message,
    required this.isSuccess,
    required this.top,
    required this.durationInSeconds,
    required this.overlayEntry,
  });

  @override
  State<_SnackbarWidget> createState() => _SnackbarWidgetState();
}

class _SnackbarWidgetState extends State<_SnackbarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(_controller);

    _controller.forward();

    Future.delayed(Duration(seconds: widget.durationInSeconds), () {
      if (!mounted) return; // <-- cek dulu
      _controller.reverse().whenComplete(() {
        if (!mounted) return; // <-- cek lagi
        widget.overlayEntry.remove();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.top,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: Material(
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: widget.isSuccess
                        ? Colors.green.withAlpha(180)
                        : const Color.fromARGB(180, 255, 100, 100),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.white.withAlpha(51),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: Text(
                          widget.message,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        widget.isSuccess
                            ? Icons.check_circle_outline
                            : Icons.error_outline,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
