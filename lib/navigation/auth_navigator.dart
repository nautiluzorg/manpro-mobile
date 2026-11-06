// lib/navigation/auth_navigation.dart
import 'package:flutter/material.dart';
import 'package:flutter_provider_data/navigation/page_transitions.dart';
import 'package:flutter_provider_data/page/main_menu_admin.dart';
import 'package:flutter_provider_data/page/login_page.dart';
import 'package:flutter_provider_data/page/main_menu_leader.dart';
import 'package:flutter_provider_data/page/menu.dart';
import 'package:flutter_provider_data/service/auth_session.dart';
import 'package:flutter_provider_data/provider/running_provider.dart';
import 'package:provider/provider.dart';

class AuthNavigator {
  // ================================================================
  // GO HOME (Main Menu Admin / Leader)
  // ================================================================
  static Future<void> goHome(BuildContext context) async {
    final payload = await _resolveValidPayload();

    if (!context.mounted) return;

    if (payload == null) {
      _toLogin(context);
      return;
    }

    final groups = _extractGroups(payload);

    late Widget target;

    if (groups.contains('ADMIN')) {
      target = const MainMenuAdmin();
    } else if (groups.contains('LEADER')) {
      target = const MainMenuLeader(title: "MAIN MENU");
    } else {
      context.read<RunningProvider>().resetForLogout();
      await AuthSession.logout();
      if (!context.mounted) return;
      _toLogin(context);
      return;
    }

    Navigator.of(context).pushReplacement(
      PageTransitions.zoomFade(target),
    );
  }

  // ================================================================
  // GO TO SUB MENU
  // ================================================================
  static Future<void> goToSubMenu(BuildContext context) async {
    final payload = await _resolveValidPayload();

    if (!context.mounted) return;

    if (payload == null) {
      _toLogin(context);
      return;
    }

    final groups = _extractGroups(payload);

    late Widget target;

    if (groups.contains('ADMIN')) {
      target = const Menu(kode: "001", proses: "MOLDING PROCESS");
    } else if (groups.contains('LEADER')) {
      target = const MainMenuLeader(title: "MAIN MENU");
    } else {
      await AuthSession.logout();
      if (!context.mounted) return;
      _toLogin(context);
      return;
    }

    Navigator.of(context).pushReplacement(
      PageTransitions.master(target),
    );
  }

  // ================================================================
  // HELPER: Ambil payload token yang valid.
  // Kalau access token expired, coba refresh dulu SEBELUM
  // nyerah dan nendang user ke login page.
  //
  // Ini penting buat kasus: app di-kill/tablet restart lebih
  // dari ACCESS_TOKEN_LIFETIME (4 jam), tapi refresh token
  // (valid 25 hari) masih hidup. Tanpa ini, user akan selalu
  // diminta login ulang tiap buka app setelah 4 jam,
  // walaupun sesinya sebenarnya masih valid.
  // ================================================================
  static Future<Map<String, dynamic>?> _resolveValidPayload() async {
    final loaded = await AuthSession.load();
    return loaded ? AuthSession.payload : null;
  }

  // ================================================================
  // HELPER: Ekstrak groups dari payload JWT.
  // ================================================================
  static List<String> _extractGroups(Map<String, dynamic> payload) {
    return (payload['groups'] as List<dynamic>? ?? [])
        .map((e) => e.toString().toUpperCase())
        .toList();
  }

  static void _toLogin(BuildContext context) {
    context.read<RunningProvider>().resetForLogout();
    Navigator.of(context).pushAndRemoveUntil(
      PageTransitions.fade(const LoginPage()),
      (_) => false,
    );
  }
}
