import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_provider_data/page/001-molding/animationtext.dart';
import 'package:flutter_provider_data/page/001-molding/recordrunningmanage.dart';
import 'package:flutter_provider_data/page/001-molding/report/record_active_process.dart';
import 'package:flutter_provider_data/page/menu.dart';
import 'package:flutter_provider_data/page/menuform.dart';
import 'package:flutter_provider_data/service/auth_session.dart';
import 'package:flutter_provider_data/service/token_storage.dart';
import 'package:flutter_provider_data/widget/app_drawer.dart';
import 'package:google_fonts/google_fonts.dart';

class MainMenuAdmin extends StatefulWidget {
  const MainMenuAdmin({super.key});

  @override
  State<MainMenuAdmin> createState() => _MainMenuAdminState();
}

class _MainMenuAdminState extends State<MainMenuAdmin> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  // ==== USER PROFILE STATE ====
  String _fullName = '-';
  String _username = '-';
  String _email = '-';
  String? _photoUrl;

  final List<String> carouselAssets = [
    'assets/lottie/scan_qr_code1.json',
    'assets/lottie/scan_qr_code2.json',
    'assets/lottie/scan_qr_code3.json',
    'assets/lottie/scan_qr_code4.json',
    'assets/lottie/scan_qr_code5.json',
  ];

  @override
  void initState() {
    super.initState();

    _loadSession();

    _pageController = PageController(viewportFraction: 0.9);

    // Auto-scroll setiap 3 detik
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_pageController.hasClients) {
        _currentPage++;
        if (_currentPage >= carouselAssets.length) _currentPage = 0;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
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

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    Navigator.pop(context); // tutup drawer
    await AuthSession.logout();

    Navigator.pushReplacementNamed(context, '/'); // atau ke halaman login
  }

  @override
  Widget build(BuildContext context) {
    double widthApp = MediaQuery.of(context).size.width;
    bool isTablet = widthApp > 600;

    final myAppBar = PreferredSize(
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
            'MAIN MENU',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 26.0,
              fontWeight: FontWeight.w600, // bisa bold atau semi-bold
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
      ),
    );

    final List<Map<String, String>> menuItems = [
      {"kode": "001", "proses": "MOLDING PROCESS"},
      {"kode": "002", "proses": "QUALITY PROCESS"},
      {"kode": "003", "proses": "JOBNUMBER PROCESS"},
      {"kode": "004", "proses": "BATCHNUMBER PROCESS"},
      {"kode": "005", "proses": "INSPECTION PROCESS"},
    ];

    return Scaffold(
      appBar: myAppBar,
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
            leading: const Icon(Icons.settings, color: Colors.white),
            title:
                const Text('SETTINGS', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) =>
                      AnimationText(title: "Animation Text", idProses: "001"),
                  transitionsBuilder: (_, animation, __, child) =>
                      FadeTransition(opacity: animation, child: child),
                  transitionDuration: const Duration(milliseconds: 800),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.delete, color: Colors.white),
            title: const Text('DELETE', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => RecordRunningManage(
                      title: "Animation Text", idProses: "001"),
                  transitionsBuilder: (_, animation, __, child) =>
                      FadeTransition(opacity: animation, child: child),
                  transitionDuration: const Duration(milliseconds: 800),
                ),
              );
            },
          ),

          ListTile(
            leading:
                const Icon(Icons.precision_manufacturing, color: Colors.white),
            title: const Text(
              'MOLDING PROCESS',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => RecordActiveProcess(
                      title: "MOLDING PROCESS", idProses: "001"),
                  transitionsBuilder: (_, animation, __, child) =>
                      FadeTransition(opacity: animation, child: child),
                  transitionDuration: const Duration(milliseconds: 800),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.forum_outlined, color: Colors.white),
            title: const Text('FORMS', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) =>
                      MenuForm(title: "FORM RECORD", idProses: "001"),
                  transitionsBuilder: (_, animation, __, child) =>
                      FadeTransition(opacity: animation, child: child),
                  transitionDuration: const Duration(milliseconds: 800),
                ),
              );
            },
          ),

          // Tambahkan menu lain...
        ],
      ),
      body: Column(
        children: [
          // 🌀 Animasi MANPRO di atas grid menu

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(5),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 5 : 3,
                childAspectRatio: 1.5,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            Menu(
                                kode: menuItems[index]['kode'] ?? '',
                                proses: menuItems[index]['proses'] ?? ''),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          var tween = Tween(begin: 0.0, end: 1.0)
                              .chain(CurveTween(curve: Curves.easeIn));
                          var opacityAnimation = animation.drive(tween);
                          return FadeTransition(
                            opacity: opacityAnimation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blueAccent.shade200,
                          Colors.blue.shade800
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        menuItems[index]['proses']!.replaceAll(" ", "\n"),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: isTablet ? 16.0 : 14.0,
                          color: Colors.white,
                          fontWeight:
                              FontWeight.w500, // bisa diubah sesuai kebutuhan
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}





/*

class MainMenuAdmin extends StatefulWidget {
  const MainMenuAdmin({super.key});

  @override
  State<MainMenuAdmin> createState() => _MainMenuAdminState();
}

class _MainMenuAdminState extends State<MainMenuAdmin> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  // ==== USER PROFILE STATE ====
  String _fullName = '-';
  String _username = '-';
  String _email = '-';
  String? _photoUrl;

  final List<String> carouselAssets = [
    'assets/lottie/scan_qr_code1.json',
    'assets/lottie/scan_qr_code2.json',
    'assets/lottie/scan_qr_code3.json',
    'assets/lottie/scan_qr_code4.json',
    'assets/lottie/scan_qr_code5.json',
  ];

  @override
  void initState() {
    super.initState();

    _loadSession();

    _pageController = PageController(viewportFraction: 0.9);

    // Auto-scroll setiap 3 detik
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (_pageController.hasClients) {
        _currentPage++;
        if (_currentPage >= carouselAssets.length) _currentPage = 0;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
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

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    Navigator.pop(context); // tutup drawer
    await AuthSession.logout();

    Navigator.pushReplacementNamed(context, '/'); // atau ke halaman login
  }

  @override
  Widget build(BuildContext context) {
    double widthApp = MediaQuery.of(context).size.width;
    bool isTablet = widthApp > 600;

    final myAppBar = PreferredSize(
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
            'MAIN MENU',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 26.0,
              fontWeight: FontWeight.w600, // bisa bold atau semi-bold
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
      ),
    );

    final List<Map<String, String>> menuItems = [
      {"kode": "001", "proses": "MOULDING"},
      {"kode": "002", "proses": "OVEN"},
      {"kode": "003", "proses": "FINISHING"},
      {"kode": "004", "proses": "PUNCHING"},
      {"kode": "005", "proses": "WASHING"},
      {"kode": "006", "proses": "OY"},
      {"kode": "007", "proses": "PRINTING"},
      {"kode": "008", "proses": "RESISTANCE"},
      {"kode": "009", "proses": "CUTTING"},
      {"kode": "010", "proses": "SPRAY"},
      {"kode": "011", "proses": "CAMERA INSPECTION"},
      {"kode": "012", "proses": "INSPECTION"},
      {"kode": "013", "proses": "GI INSPECTION"},
      {"kode": "014", "proses": "MIP"},
      {"kode": "015", "proses": "SCREENING"},
      {"kode": "016", "proses": "PACKING"},
      {"kode": "017", "proses": "STORE-IN"},
      {"kode": "018", "proses": "CLEANING BEFORE OY"},
      {"kode": "019", "proses": "CLEANING BEFORE INSPECTION"},
      {"kode": "020", "proses": "CLEANING PILL"},
      {"kode": "021", "proses": "PREPUSH"},
      {"kode": "022", "proses": "PUNCHING IHP"},
      {"kode": "023", "proses": "CIIP"},
      {"kode": "024", "proses": "DEFLASHING"},
      {"kode": "025", "proses": "DOT MARKING"},
    ];

    return Scaffold(
      appBar: myAppBar,
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
            leading: const Icon(Icons.settings, color: Colors.white),
            title:
                const Text('SETTINGS', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) =>
                      AnimationText(title: "Animation Text", idProses: "001"),
                  transitionsBuilder: (_, animation, __, child) =>
                      FadeTransition(opacity: animation, child: child),
                  transitionDuration: const Duration(milliseconds: 800),
                ),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.delete, color: Colors.white),
            title: const Text('DELETE', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => RecordRunningManage(
                      title: "Animation Text", idProses: "001"),
                  transitionsBuilder: (_, animation, __, child) =>
                      FadeTransition(opacity: animation, child: child),
                  transitionDuration: const Duration(milliseconds: 800),
                ),
              );
            },
          ),

          ListTile(
            leading:
                const Icon(Icons.precision_manufacturing, color: Colors.white),
            title: const Text(
              'MOLDING PROCESS',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => RecordActiveProcess(
                      title: "MOLDING PROCESS", idProses: "001"),
                  transitionsBuilder: (_, animation, __, child) =>
                      FadeTransition(opacity: animation, child: child),
                  transitionDuration: const Duration(milliseconds: 800),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.forum_outlined, color: Colors.white),
            title: const Text('FORMS', style: TextStyle(color: Colors.white)),
            onTap: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) =>
                      MenuForm(title: "FORM RECORD", idProses: "001"),
                  transitionsBuilder: (_, animation, __, child) =>
                      FadeTransition(opacity: animation, child: child),
                  transitionDuration: const Duration(milliseconds: 800),
                ),
              );
            },
          ),

          // Tambahkan menu lain...
        ],
      ),
      body: Column(
        children: [
          // 🌀 Animasi MANPRO di atas grid menu

          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(5),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 5 : 3,
                childAspectRatio: 1.5,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            Menu(
                                kode: menuItems[index]['kode'] ?? '',
                                proses: menuItems[index]['proses'] ?? ''),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          var tween = Tween(begin: 0.0, end: 1.0)
                              .chain(CurveTween(curve: Curves.easeIn));
                          var opacityAnimation = animation.drive(tween);
                          return FadeTransition(
                            opacity: opacityAnimation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blueAccent.shade200,
                          Colors.blue.shade800
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        menuItems[index]['proses']!.replaceAll(" ", "\n"),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: isTablet ? 16.0 : 14.0,
                          color: Colors.white,
                          fontWeight:
                              FontWeight.w500, // bisa diubah sesuai kebutuhan
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
*/