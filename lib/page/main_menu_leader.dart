import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_provider_data/navigation/page_transitions.dart';
import 'package:flutter_provider_data/page/001-molding/record_process/record_process.dart';
import 'package:flutter_provider_data/page/001-molding/record_testing/record_testing.dart';
import 'package:flutter_provider_data/page/001-molding/report/monitor_testing.dart';
import 'package:flutter_provider_data/page/001-molding/runningmoldingpage.dart';
import 'package:flutter_provider_data/page/001-molding/stopmoldingpage.dart';
import 'package:flutter_provider_data/page/login_page.dart';
import 'package:flutter_provider_data/service/auth_session.dart';
import 'package:flutter_provider_data/service/token_storage.dart';
import 'package:flutter_provider_data/widget/app_drawer.dart';
import 'package:google_fonts/google_fonts.dart';

class MainMenuLeader extends StatefulWidget {
  final String title;

  const MainMenuLeader({super.key, required this.title});

  @override
  State<MainMenuLeader> createState() => _MainMenuLeaderState();
}

class _MainMenuLeaderState extends State<MainMenuLeader>
    with TickerProviderStateMixin {
  int selectedIndex = 0;
  AnimationController? _glowController;

  String _fullName = '-';
  String _username = '-';
  String _email = '-';
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadSession();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
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
    Navigator.of(context).pop();
    await AuthSession.logout();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  void _goToPage(Widget page) {
    Navigator.of(context).push(
      PageTransitions.slideFade(page),
    );
  }

  @override
  void dispose() {
    _glowController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
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
            title: const Text('APP SETTINGS',
                style: TextStyle(color: Colors.white)),
            onTap: () {},
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
            leading: const Icon(Icons.info_outline, color: Colors.white),
            title: const Text('ABOUT', style: TextStyle(color: Colors.white)),
            onTap: () {
              // Tambahkan aksi menu
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade100, Colors.grey.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 24,
                ),
                child: Column(
                  children: [
                    _buildMoldingSection(),
                    const SizedBox(height: 5),
                    _buildQualityCheckSection(),
                    const SizedBox(height: 5),
                    // _buildAfterProcessSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: AppBar(
          title: Text(
            widget.title,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w600,
            ),
          ),
          leading: Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
    );
  }

  // ====================== MOLDING ======================

  Widget _buildMoldingSection() {
    final moldingProcesses = [
      'MOLDING',
    ];
    final List<Color> colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blueAccent.withAlpha(40),
                  Colors.cyan.withAlpha(60),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withAlpha(60),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ===== TITLE =====

                ShaderMask(
                  shaderCallback: (bounds) {
                    return const LinearGradient(
                      colors: [
                        Color(0xFF263238), // Blue Grey 900 (steel)
                        Color(0xFF1565C0), // Blue industrial
                        Color(0xFF00838F), // Teal deep
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: Text(
                    'MOLDING PROCESS',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: Colors.white, // wajib
                    ),
                  ),
                ),

                const SizedBox(height: 4),
                Text(
                  'Molding Production & Running Control',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.blueGrey.shade600,
                  ),
                ),

                const SizedBox(height: 16),

                /// ===== BUTTONS (TIDAK DIUBAH) =====
                Row(
                  children: [
                    Expanded(
                      child: _buildGradientButton(
                        'RECORD MOLDING',
                        Colors.blueAccent,
                        Colors.blue.shade900,
                        onPressed: () {
                          _goToPage(
                            RecordProcess(
                              title: "RECORD MOLDING",
                              idProses: "001",
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildGradientButton(
                        'LIST MOLDING RUNNING',
                        Colors.blueAccent,
                        Colors.blue.shade900,
                        onPressed: () {
                          _goToPage(
                            RunningMoldingPage(
                              title: "LIST MOLDING RUNNING",
                              idProses: "001",
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildGradientButton(
                        'LIST MOLDING STOP',
                        Colors.blueAccent,
                        Colors.blue.shade900,
                        onPressed: () {
                          _goToPage(
                            StopMoldingPage(
                              title: "LIST MOLDING STOP",
                              idProses: "001",
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                /// ===== PROCESS TAG =====
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(160),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withAlpha(120),
                    ),
                  ),
                  child: RichText(
                    text: TextSpan(
                      children: List.generate(moldingProcesses.length * 2 - 1,
                          (index) {
                        if (index.isEven) {
                          final processIndex = index ~/ 2;
                          final color = colors[processIndex % colors.length];
                          return TextSpan(
                            text: moldingProcesses[processIndex],
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          );
                        } else {
                          return TextSpan(
                            text: '  •  ',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          );
                        }
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQualityCheckSection() {
    final qualityButtons = [
      'MOLDING TEST',
      'LIST TESTING RUNNING',
      'LIST TESTING DONE',
    ];

    final qualityProcesses = [
      'MOLDING TESTING',
      'MOLDING INSPECTION MIDDLE',
    ];

    final List<Color> colors = [
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepOrange.withAlpha(20),
                  Colors.orangeAccent.withAlpha(50),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Colors.white.withAlpha(70),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(28),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ===== TITLE =====
                ShaderMask(
                  shaderCallback: (bounds) {
                    return const LinearGradient(
                      colors: [
                        Color(0xFFBF360C), // Deep Orange 900
                        Color(0xFFD84315), // Deep Orange 800
                        Color(0xFFF4511E), // Deep Orange 600
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: Text(
                    'MOLDING TEST',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                      color: Colors.white, // WAJIB putih
                    ),
                  ),
                ),

                const SizedBox(height: 4),
                Text(
                  'Testing Molding and checking MIM for Approval Production',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.green.shade800.withAlpha(180),
                  ),
                ),

                const SizedBox(height: 16),

                /// ===== BUTTONS (TIDAK DIUBAH) =====
                Row(
                  children: qualityButtons.map((title) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: _buildGradientButton(
                          title,
                          Colors.blueAccent,
                          Colors.blue.shade900,
                          onPressed: () {
                            if (title == 'MOLDING TEST') {
                              _goToPage(
                                RecordTesting(
                                  title: 'RECORD TESTING',
                                  idProses: '001',
                                ),
                              );
                            } else if (title == 'LIST TESTING RUNNING') {
                              _goToPage(
                                MonitorTesting(
                                  title: 'LIST TESTING',
                                  idProses: '001',
                                ),
                              );
                            } else if (title == 'LIST TESTING FINISH') {
                              /*
                              _goToPage(
                                RecordTesting(
                                  title: 'LIST TESTING FINISH',
                                  idProses: '001',
                                ),
                              );
                              */
                            }
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 14),

                /// ===== PROCESS TAG =====
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(160),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.white.withAlpha(120),
                    ),
                  ),
                  child: RichText(
                    text: TextSpan(
                      children: List.generate(qualityProcesses.length * 2 - 1,
                          (index) {
                        if (index.isEven) {
                          final processIndex = index ~/ 2;
                          final color = colors[processIndex % colors.length];
                          return TextSpan(
                            text: qualityProcesses[processIndex],
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          );
                        } else {
                          return TextSpan(
                            text: '  •  ',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          );
                        }
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientButton(
    String title,
    Color start,
    Color end, {
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 75,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 6,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [start, end],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ProcessButton {
  final String title;
  final VoidCallback onPressed;

  ProcessButton({
    required this.title,
    required this.onPressed,
  });
}
