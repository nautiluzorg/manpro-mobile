import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_provider_data/navigation/page_transitions.dart';
import 'package:flutter_provider_data/page/001-molding/record_process/record_process.dart';
import 'package:flutter_provider_data/page/001-molding/record_testing/record_testing.dart';
import 'package:flutter_provider_data/page/001-molding/runningmoldingpage.dart';
import 'package:flutter_provider_data/page/001-molding/stopmoldingpage.dart';
import 'package:flutter_provider_data/page/login_page.dart';
import 'package:flutter_provider_data/page/technician/record_chocotei/record_chocotei.dart';
import 'package:flutter_provider_data/service/auth_session.dart';
import 'package:flutter_provider_data/service/token_storage.dart';
import 'package:flutter_provider_data/provider/running_provider.dart';
import 'package:flutter_provider_data/widget/app_drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// =====================================================================
// MENU UTAMA LEADER
//
// Struktur halaman:
//   Scaffold
//   ├─ appBar : _buildAppBar()
//   ├─ drawer : AppDrawer (profil + menu + logout)
//   └─ body   : _GlassSection "MOLDING PROCESS"
//               _GlassSection "MOLDING TEST"
//
// Menambah tombol baru cukup menambah satu ProcessButton di list
// pada _buildMoldingSection() / _buildQualityCheckSection().
// =====================================================================

/// Satu tombol menu: judul + aksi yang dijalankan saat ditekan
class ProcessButton {
  final String title;
  final VoidCallback onPressed;

  ProcessButton({
    required this.title,
    required this.onPressed,
  });
}

class MainMenuLeader extends StatefulWidget {
  final String title;

  const MainMenuLeader({super.key, required this.title});

  @override
  State<MainMenuLeader> createState() => _MainMenuLeaderState();
}

class _MainMenuLeaderState extends State<MainMenuLeader> {
  String _fullName = '-';
  String _username = '-';
  String _email = '-';
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  // ---------------------------------------------------------------
  // SESSION & NAVIGASI
  // ---------------------------------------------------------------

  /// Ambil data user untuk ditampilkan di drawer
  Future<void> _loadSession() async {
    final ok = await AuthSession.load();
    if (!ok) return;

    final profile = await TokenStorage.getUserProfile();
    if (!mounted) return;

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
    context.read<RunningProvider>().resetForLogout();
    await AuthSession.logout();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  }

  /// Satu-satunya jalur pindah halaman (dengan animasi slideFade)
  void _goToPage(Widget page) {
    Navigator.of(context).push(
      PageTransitions.slideFade(page),
    );
  }

  // ---------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------

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

  // ---------------------------------------------------------------
  // SECTION: MOLDING PROCESS
  // ---------------------------------------------------------------

  Widget _buildMoldingSection() {
    final buttons = [
      ProcessButton(
        title: 'RECORD MOLDING',
        onPressed: () => _goToPage(
          RecordProcess(title: "RECORD MOLDING", idProses: "001"),
        ),
      ),
      ProcessButton(
        title: 'LIST MOLDING RUNNING',
        onPressed: () => _goToPage(
          RunningMoldingPage(title: "LIST MOLDING RUNNING", idProses: "001"),
        ),
      ),
      ProcessButton(
        title: 'LIST MOLDING STOP',
        onPressed: () => _goToPage(
          StopMoldingPage(title: "LIST MOLDING STOP", idProses: "001"),
        ),
      ),
    ];

    return _GlassSection(
      title: 'MOLDING PROCESS',
      subtitle: 'Molding Production & Running Control',
      subtitleColor: Colors.blueGrey.shade600,
      titleGradient: const [
        Color(0xFF263238), // Blue Grey 900 (steel)
        Color(0xFF1565C0), // Blue industrial
        Color(0xFF00838F), // Teal deep
      ],
      titleLetterSpacing: 1.2,
      backgroundColors: [
        Colors.blueAccent.withAlpha(40),
        Colors.cyan.withAlpha(60),
      ],
      gradientBegin: Alignment.topLeft,
      gradientEnd: Alignment.bottomRight,
      borderAlpha: 60,
      shadowAlpha: 25,
      processTags: const ['MOLDING'],
      // Tombol dipisah jarak 10
      buttons: Row(
        children: [
          for (var i = 0; i < buttons.length; i++) ...[
            if (i > 0) const SizedBox(width: 10),
            Expanded(child: _buildGradientButton(buttons[i])),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // SECTION: MOLDING TEST
  // ---------------------------------------------------------------

  Widget _buildQualityCheckSection() {
    final buttons = [
      ProcessButton(
        title: 'MOLDING TEST',
        onPressed: () => _goToPage(
          RecordTesting(title: 'RECORD TESTING', idProses: '001'),
        ),
      ),
      ProcessButton(
        title: 'RECORD CHOCOTEI',
        onPressed: () => _goToPage(
          // MonitorTesting(title: 'LIST TESTING', idProses: '001'),
          RecordChocotei(title: "RECORD CHOCOTEI", idProses: "001"),
          // TechnicianFormPage(),
        ),
      ),
      ProcessButton(
        title: 'LIST TESTING DONE',
        // Belum ada halaman tujuan (sama seperti sebelumnya: tidak ada aksi).
        // Kalau nanti sudah ada, isi di sini, contoh:
        // onPressed: () => _goToPage(RecordTesting(...)),
        onPressed: () {},
      ),
    ];

    return _GlassSection(
      title: 'MOLDING TEST',
      subtitle: 'Testing Molding and checking MIM for Approval Production',
      subtitleColor: Colors.green.shade800.withAlpha(180),
      titleGradient: const [
        Color(0xFFBF360C), // Deep Orange 900
        Color(0xFFD84315), // Deep Orange 800
        Color(0xFFF4511E), // Deep Orange 600
      ],
      titleLetterSpacing: 1.1,
      backgroundColors: [
        Colors.deepOrange.withAlpha(20),
        Colors.orangeAccent.withAlpha(50),
      ],
      gradientBegin: Alignment.topCenter,
      gradientEnd: Alignment.bottomCenter,
      borderAlpha: 70,
      shadowAlpha: 28,
      processTags: const ['MOLDING TESTING', 'MOLDING INSPECTION MIDDLE'],
      // Tiap tombol diberi padding horizontal 6
      buttons: Row(
        children: [
          for (final b in buttons)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _buildGradientButton(b),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // TOMBOL GRADIENT (dipakai kedua section)
  // ---------------------------------------------------------------

  Widget _buildGradientButton(ProcessButton button) {
    return SizedBox(
      height: 75,
      child: ElevatedButton(
        onPressed: button.onPressed,
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
              colors: [Colors.blueAccent, Colors.blue.shade900],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Text(
              button.title,
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

// =====================================================================
// KARTU KACA (glass card) - dipakai oleh kedua section
// Isi: judul gradient, subjudul, baris tombol, dan tag proses.
// =====================================================================
class _GlassSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color subtitleColor;
  final List<Color> titleGradient;
  final double titleLetterSpacing;
  final List<Color> backgroundColors;
  final Alignment gradientBegin;
  final Alignment gradientEnd;
  final int borderAlpha;
  final int shadowAlpha;
  final Widget buttons;
  final List<String> processTags;

  const _GlassSection({
    required this.title,
    required this.subtitle,
    required this.subtitleColor,
    required this.titleGradient,
    required this.titleLetterSpacing,
    required this.backgroundColors,
    required this.gradientBegin,
    required this.gradientEnd,
    required this.borderAlpha,
    required this.shadowAlpha,
    required this.buttons,
    required this.processTags,
  });

  @override
  Widget build(BuildContext context) {
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
                colors: backgroundColors,
                begin: gradientBegin,
                end: gradientEnd,
              ),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withAlpha(borderAlpha)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(shadowAlpha),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ===== TITLE (teks dengan efek gradient) =====
                ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      colors: titleGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: titleLetterSpacing,
                      color: Colors.white, // wajib putih untuk ShaderMask
                    ),
                  ),
                ),

                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: subtitleColor,
                  ),
                ),

                const SizedBox(height: 16),

                // ===== BUTTONS =====
                buttons,

                const SizedBox(height: 14),

                // ===== PROCESS TAG =====
                _ProcessTags(tags: processTags),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// TAG PROSES: teks berwarna dipisah titik tengah ( A  •  B  •  C )
// =====================================================================
class _ProcessTags extends StatelessWidget {
  final List<String> tags;

  const _ProcessTags({required this.tags});

  static const List<Color> _colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.purple,
    Colors.teal,
  ];

  @override
  Widget build(BuildContext context) {
    final spans = <InlineSpan>[];
    for (var i = 0; i < tags.length; i++) {
      if (i > 0) {
        spans.add(
          TextSpan(
            text: '  •  ',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        );
      }
      spans.add(
        TextSpan(
          text: tags[i],
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _colors[i % _colors.length],
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(160),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAlpha(120)),
      ),
      child: RichText(text: TextSpan(children: spans)),
    );
  }
}
