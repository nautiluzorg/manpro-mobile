// lib/navigation/auth_navigation.dart

// lib/navigation/auth_navigation.dart
import 'package:flutter/material.dart';
import 'package:flutter_provider_data/navigation/page_transitions.dart';
import 'package:flutter_provider_data/page/main_menu_admin.dart';
import 'package:flutter_provider_data/page/login_page.dart';
import 'package:flutter_provider_data/page/main_menu_leader.dart';
import 'package:flutter_provider_data/page/menu.dart';
import 'package:flutter_provider_data/service/token_storage.dart';
import 'package:flutter_provider_data/utils/jwt_helper.dart';

class AuthNavigator {
  static Future<void> goHome(BuildContext context) async {
    final token = await TokenStorage.getAccessToken();
    if (!context.mounted) return;

    if (token == null) {
      _toLogin(context);
      return;
    }

    final payload = JwtHelper.decodePayload(token);

    if (payload == null || JwtHelper.isExpired(payload)) {
      await TokenStorage.clear();
      if (!context.mounted) return;
      _toLogin(context);
      return;
    }

    // Ambil groups langsung dari payload top-level
    final List<String> groups = (payload['groups'] as List<dynamic>? ?? [])
        .map((e) => e.toString().toUpperCase())
        .toList();

    late Widget target;

    if (groups.contains('ADMIN')) {
      target = const MainMenuAdmin();
    } else if (groups.contains('LEADER')) {
      //ini baru di rubah...
      target = const MainMenuLeader(title: "MAIN MENU");
    } else {
      await TokenStorage.clear();
      if (!context.mounted) return;
      _toLogin(context);
      return;
    }

    Navigator.of(context).pushReplacement(
      PageTransitions.zoomFade(target),
    );
  }

  static Future<void> goToSubMenu(BuildContext context) async {
    final token = await TokenStorage.getAccessToken();
    if (!context.mounted) return;

    if (token == null) {
      _toLogin(context);
      return;
    }

    final payload = JwtHelper.decodePayload(token);

    if (payload == null || JwtHelper.isExpired(payload)) {
      await TokenStorage.clear();
      if (!context.mounted) return;
      _toLogin(context);
      return;
    }

    // Ambil groups langsung dari payload top-level
    final List<String> groups = (payload['groups'] as List<dynamic>? ?? [])
        .map((e) => e.toString().toUpperCase())
        .toList();

    late Widget target;

    if (groups.contains('ADMIN')) {
      target = const Menu(kode: "001", proses: "MOLDING PROCESS");
    } else if (groups.contains('LEADER')) {
      //ini baru di rubah...
      target = const MainMenuLeader(title: "MAIN MENU");
    } else {
      await TokenStorage.clear();
      if (!context.mounted) return;
      _toLogin(context);
      return;
    }

    Navigator.of(context).pushReplacement(
      PageTransitions.master(target),
    );
  }

  static void _toLogin(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      PageTransitions.fade(const LoginPage()),
      (_) => false,
    );
  }
}

/*
import 'package:flutter/material.dart';
import 'package:flutter_provider_data/navigation/page_transitions.dart';
import 'package:flutter_provider_data/page/main_menu_admin.dart';
import 'package:flutter_provider_data/page/login_page.dart';
import 'package:flutter_provider_data/page/main_menu_leader.dart';
import 'package:flutter_provider_data/page/menu.dart';
import 'package:flutter_provider_data/service/token_storage.dart';
import 'package:flutter_provider_data/utils/jwt_helper.dart';

class AuthNavigator {
  static Future<void> goHome(BuildContext context) async {
    final token = await TokenStorage.getAccessToken();

    if (token == null) {
      _toLogin(context);
      return;
    }

    final payload = JwtHelper.decodePayload(token);

    if (payload == null || JwtHelper.isExpired(payload)) {
      await TokenStorage.clear();
      _toLogin(context);
      return;
    }

    // Ambil groups langsung dari payload top-level
    final List<String> groups = (payload['groups'] as List<dynamic>? ?? [])
        .map((e) => e.toString().toUpperCase())
        .toList();

    late Widget target;

    if (groups.contains('ADMIN')) {
      target = const MainMenuAdmin();
    } else if (groups.contains('LEADER')) {
      //ini baru di rubah...
      target = const MainMenuLeader(title: "MAIN MENU");
    } else {
      await TokenStorage.clear();
      _toLogin(context);
      return;
    }

    Navigator.of(context).pushReplacement(
      PageTransitions.zoomFade(target),
    );
  }

  static Future<void> goToSubMenu(BuildContext context) async {
    final token = await TokenStorage.getAccessToken();

    if (token == null) {
      _toLogin(context);
      return;
    }

    final payload = JwtHelper.decodePayload(token);

    if (payload == null || JwtHelper.isExpired(payload)) {
      await TokenStorage.clear();
      _toLogin(context);
      return;
    }

    // Ambil groups langsung dari payload top-level
    final List<String> groups = (payload['groups'] as List<dynamic>? ?? [])
        .map((e) => e.toString().toUpperCase())
        .toList();

    late Widget target;

    if (groups.contains('ADMIN')) {
      target = const Menu(kode: "001", proses: "MOLDING PROCESS");
    } else if (groups.contains('LEADER')) {
      //ini baru di rubah...
      target = const MainMenuLeader(title: "MAIN MENU");
    } else {
      await TokenStorage.clear();
      _toLogin(context);
      return;
    }

    Navigator.of(context).pushReplacement(
      PageTransitions.master(target),
    );
  }

  static void _toLogin(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      PageTransitions.fade(const LoginPage()),
      (_) => false,
    );
  }
}
*/
