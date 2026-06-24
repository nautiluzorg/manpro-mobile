import 'dart:async';
import 'package:flutter/material.dart';
// import 'package:flutter_provider_data/page/main_menu_home.dart'; // REMOVED unused
// import 'package:flutter_provider_data/page/menu.dart';
import 'package:flutter_provider_data/service/auth_session.dart';
import 'package:flutter_provider_data/service/token_storage.dart';
import 'package:flutter_provider_data/widget/app_drawer.dart';
import 'package:google_fonts/google_fonts.dart';

class MainMenuSimple extends StatefulWidget {
  const MainMenuSimple({super.key, required this.title});
  final String title;

  @override
  State<MainMenuSimple> createState() => _MainMenuSimpleState();
}

class _MainMenuSimpleState extends State<MainMenuSimple> {
  String _fullName = '-';
  String _username = '-';
  String _email = '-';
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final ok = await AuthSession.load();
    if (!ok) return;

    final profile = await TokenStorage.getUserProfile();

    setState(() {
      _username = AuthSession.username ?? '-';
      _fullName =
          AuthSession.fullName.isNotEmpty ? AuthSession.fullName : _username;

      _email = profile?['email'] ?? '-';
      _photoUrl = profile?['photo'];
    });
  }

  Future<void> _logout() async {
    Navigator.pop(context);
    await AuthSession.logout();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    double widthApp = MediaQuery.of(context).size.width;
    bool isTablet = widthApp > 600;

    final List<Map<String, String>> menuItems = [
      {"code": "001", "proses": "MOLDING PROCESS"},
      {"code": "002", "proses": "QUALITY CHECK"},
      {"code": "003", "proses": "AFTER PROCESS"},
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.blue.shade900],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: AppBar(
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              widget.title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 26.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
          ),
        ),
      ),
      drawer: AppDrawer(
        fullName: _fullName,
        username: _username,
        email: _email,
        avatar: _photoUrl != null
            ? NetworkImage(_photoUrl!)
            : const AssetImage('assets/avatar_default.png'),
        onLogout: _logout,
        menuItems: [
          ListTile(
            leading: const Icon(Icons.home, color: Colors.white),
            title: const Text('HOME', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Tambahkan aksi menu
            },
          ),
          ListTile(
            leading: const Icon(Icons.ondemand_video, color: Colors.white),
            title: const Text('VIDEO TRAINING',
                style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.description, color: Colors.white),
            title: const Text(
              'DOCUMENTATION',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.white),
            title: const Text('APP SETTINGS',
                style: TextStyle(color: Colors.white)),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.info_outline, color: Colors.white),
            title: const Text('ABOUT', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Tambahkan aksi menu
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: isTablet ? 3 : 1, // tablet 3 kolom, phone 1 kolom
          childAspectRatio: 2, // ukuran button sama
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
/*
              if (menuItems[index]['kode'] == '001') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MainMenuHome()),
                );
              } else if (menuItems[index]['code'] == '002') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MainMenuHome()),
                );
              } else if (menuItems[index]['code'] == '003') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MainMenuHome()),
                );
              }
              */
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent.shade200, Colors.blue.shade800],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  menuItems[index]['proses']!.replaceAll(" ", "\n"),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: isTablet ? 18 : 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
