import 'package:flutter/material.dart';

/// Jenis transisi yang bisa dipakai
enum PageTransitionType {
  fade,
  slideRight,
  slideLeft,
  scale,
  rotation,
  slideFade,
  slideUp, // baru: dari bawah
  scaleRotate, // baru: gabungan scale + rotation
}

class PageTransitionHelper {
  /// Push halaman baru
  static Future navigateWithTransition(
    BuildContext context,
    Widget page, {
    PageTransitionType type = PageTransitionType.fade,
    int duration = 300,
    Curve curve = Curves.easeInOut,
  }) {
    return Navigator.push(
      context,
      _buildPageRoute(page, type, duration, curve),
    );
  }

  /// PushReplacement (replace halaman lama)
  static Future navigateReplaceWithTransition(
    BuildContext context,
    Widget page, {
    PageTransitionType type = PageTransitionType.fade,
    int duration = 300,
    Curve curve = Curves.easeInOut,
  }) {
    return Navigator.pushReplacement(
      context,
      _buildPageRoute(page, type, duration, curve),
    );
  }

  /// Core builder untuk PageRoute
  static PageRouteBuilder _buildPageRoute(
    Widget page,
    PageTransitionType type,
    int duration,
    Curve curve,
  ) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: Duration(milliseconds: duration),
      transitionsBuilder: (_, animation, __, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: curve,
        );

        switch (type) {
          case PageTransitionType.fade:
            return FadeTransition(opacity: curvedAnimation, child: child);

          case PageTransitionType.slideRight:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            );

          case PageTransitionType.slideLeft:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(-1, 0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            );

          case PageTransitionType.scale:
            return ScaleTransition(scale: curvedAnimation, child: child);

          case PageTransitionType.rotation:
            return RotationTransition(turns: curvedAnimation, child: child);

          case PageTransitionType.slideFade:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1, 0),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: FadeTransition(opacity: curvedAnimation, child: child),
            );

          case PageTransitionType.slideUp:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            );

          case PageTransitionType.scaleRotate:
            return RotationTransition(
              turns: curvedAnimation,
              child: ScaleTransition(scale: curvedAnimation, child: child),
            );
        }
      },
    );
  }
}
