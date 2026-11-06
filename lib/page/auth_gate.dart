import 'package:flutter/material.dart';
import 'package:flutter_provider_data/page/login_page.dart';
import 'package:flutter_provider_data/page/main_menu_admin.dart';
import 'package:flutter_provider_data/page/main_menu_leader.dart';
import 'package:flutter_provider_data/service/auth_session.dart';

/// Memulihkan session tersimpan sebelum menampilkan halaman login.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Widget? _page;

  @override
  void initState() {
    super.initState();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final authenticated = await AuthSession.load();
    if (!mounted) return;

    if (!authenticated) {
      setState(() => _page = const LoginPage());
      return;
    }

    final groups = AuthSession.groups;
    if (groups.contains('ADMIN')) {
      setState(() => _page = const MainMenuAdmin());
    } else if (groups.contains('LEADER')) {
      setState(() => _page = const MainMenuLeader(title: 'MAIN MENU'));
    } else {
      await AuthSession.logout();
      if (!mounted) return;
      setState(() => _page = const LoginPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return _page ??
        const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
  }
}
