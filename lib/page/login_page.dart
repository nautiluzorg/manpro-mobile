import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_provider_data/navigation/auth_navigator.dart';
import 'package:flutter_provider_data/service/auth_service.dart';
import 'package:flutter_provider_data/service/connectivity_service.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameCtrl = TextEditingController();

  final TextEditingController _passwordCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  final authService = AuthService();

  final ConnectivityService _connectivityService = ConnectivityService.instance;

  StreamSubscription<ManproConnectionStatus>? _connectionSubscription;

  ManproConnectionStatus _connectionStatus = ManproConnectionStatus.checking;

  @override
  void initState() {
    super.initState();

    _initializeConnectivity();
  }

  /// Inisialisasi monitoring koneksi MANPRO.
  Future<void> _initializeConnectivity() async {
    // Dengarkan perubahan status terlebih dahulu.
    _connectionSubscription = _connectivityService.statusStream.listen(
      (status) {
        if (!mounted) return;

        setState(() {
          _connectionStatus = status;
        });
      },
    );

    // Mulai ConnectivityService.
    await _connectivityService.initialize();

    if (!mounted) return;

    // Ambil status terbaru.
    setState(() {
      _connectionStatus = _connectivityService.status;
    });
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();

    _usernameCtrl.dispose();
    _passwordCtrl.dispose();

    super.dispose();
  }

  // ================= LOGIN =================

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // ============================================
    // CEK STATUS MANPRO
    // ============================================

    final isConnected = await _connectivityService.checkConnection();

    if (!mounted) return;

    if (!isConnected) {
      _showConnectionError();
      return;
    }

    // ============================================
    // LOGIN
    // ============================================

    setState(() {
      _isLoading = true;
    });

    final result = await authService.login(
      username: _usernameCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    if (result.success) {
      // Serahkan ke sistem auth (JWT-based navigation).
      await AuthNavigator.goHome(context);
    } else {
      // Layer 2:
      // AuthService tetap menangani DioException,
      // termasuk kondisi koneksi terputus setelah
      // health-check dilakukan.
      if (!mounted) return;

      CustomSnackbar.show(
        context,
        result.errorMessage ?? "Login gagal",
        isSuccess: false,
      );
    }
  }

  // ================= CONNECTION ERROR =================

  void _showConnectionError() {
    switch (_connectionStatus) {
      case ManproConnectionStatus.noNetwork:
        CustomSnackbar.show(
          context,
          "TIDAK ADA KONEKSI NETWORK",
          isSuccess: false,
        );
        break;

      case ManproConnectionStatus.serverDown:
        CustomSnackbar.show(
          context,
          "SERVER MANPRO TIDAK DAPAT DIJANGKAU",
          isSuccess: false,
        );
        break;

      case ManproConnectionStatus.checking:
        CustomSnackbar.show(
          context,
          "SEDANG MENGECEK SERVER MANPRO",
          isSuccess: false,
        );
        break;

      case ManproConnectionStatus.connected:
        // Seharusnya tidak masuk ke sini
        // karena checkConnection() menghasilkan true.
        break;
    }
  }

  // ================= BUILD =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.withValues(alpha: 0.02),
              Colors.white.withValues(alpha: 0.75),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 36),
                  _buildLoginCard(),
                  const SizedBox(height: 28),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= HEADER =================

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 200,
          height: 200,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Image.asset(
            'assets/icon/icon.png',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 22),
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              colors: [
                Colors.blueAccent,
                Colors.cyanAccent,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: Text(
            "MANPRO",
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: [
                Colors.blue.shade800,
                Colors.blueAccent,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: Text(
            "Manufacturing Production Record",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // ================= LOGIN CARD =================

  Widget _buildLoginCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10,
          sigmaY: 10,
        ),
        child: Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildConnectionStatus(),
                const SizedBox(height: 24),
                _buildUsernameField(),
                const SizedBox(height: 18),
                _buildPasswordField(),
                const SizedBox(height: 30),
                _buildLoginButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= CONNECTION STATUS =================

  Widget _buildConnectionStatus() {
    Color color;
    String text;
    IconData icon;

    switch (_connectionStatus) {
      case ManproConnectionStatus.checking:
        color = Colors.orange;
        text = "Checking Server...";
        icon = Icons.sync;
        break;

      case ManproConnectionStatus.connected:
        color = Colors.green;
        text = "MANPRO Connected";
        icon = Icons.cloud_done_outlined;
        break;

      case ManproConnectionStatus.noNetwork:
        color = Colors.red;
        text = "No Network Connection";
        icon = Icons.wifi_off;
        break;

      case ManproConnectionStatus.serverDown:
        color = Colors.red;
        text = "MANPRO Server Down";
        icon = Icons.cloud_off_outlined;
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bulatan indikator.
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.35),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Icon(
            icon,
            size: 18,
            color: color,
          ),

          const SizedBox(width: 7),

          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ================= FIELDS =================

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(fontSize: 14),
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF1F5F9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameCtrl,
      style: GoogleFonts.poppins(),
      decoration: _inputDecoration(
        label: "Username",
        icon: Icons.person_outline,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Username tidak boleh kosong";
        }

        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordCtrl,
      obscureText: _obscurePassword,
      style: GoogleFonts.poppins(),
      decoration: _inputDecoration(
        label: "Password",
        icon: Icons.lock_outline,
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.length < 4) {
          return "Password minimal 4 karakter";
        }

        return null;
      },
    );
  }

  // ================= BUTTON =================

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 80,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blueAccent,
                Colors.blue.shade900,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    "LOGIN",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // ================= FOOTER =================

  Widget _buildFooter() {
    return Text(
      "©2026 MANPRO System",
      style: GoogleFonts.poppins(
        fontSize: 12,
        color: Colors.grey.shade500,
      ),
    );
  }
}

/*
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_provider_data/navigation/auth_navigator.dart';
import 'package:flutter_provider_data/service/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_provider_data/utils/connectivity_helper.dart';
import 'package:flutter_provider_data/utils/custom_snackbar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  final authService = AuthService();

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    // Layer 1: cek koneksi device dulu sebelum nembak API,
    // biar user gak nunggu timeout percuma kalau emang jelas offline.
    final hasInternet = await ConnectivityHelper.hasInternetConnection();
    if (!hasInternet) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        "TIDAK ADA KONEKSI INTERNET",
        isSuccess: false,
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await authService.login(
      username: _usernameCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.success) {
      // ⬇️ SERAHKAN KE SISTEM AUTH (JWT-based navigation)
      await AuthNavigator.goHome(context);
    } else {
      // Layer 2: pesan dari AuthService, termasuk
      // "Tidak ada koneksi internet" kalau DioException connectionError
      // (kasus WiFi nyambung tapi internetnya mati/putus).
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        result.errorMessage ?? "Login gagal",
        isSuccess: false,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.withValues(alpha: 0.02), // biru sangat tipis
              Colors.white.withValues(alpha: 0.75), // putih dominan
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 36),
                  _buildLoginCard(),
                  const SizedBox(height: 28),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 200,
          height: 200,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Image.asset(
            'assets/icon/icon.png',
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 22),
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              colors: [
                Colors.blueAccent,
                Colors.cyanAccent,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: Text(
            "MANPRO",
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: Colors.white, // wajib putih agar gradient terlihat
            ),
          ),
        ),
        const SizedBox(height: 8),
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: [
                Colors.blue.shade800,
                Colors.blueAccent,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds);
          },
          child: Text(
            "Manufacturing Production Record",
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white, // wajib
            ),
          ),
        ),
      ],
    );
  }

  // ================= LOGIN CARD =================
  Widget _buildLoginCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 30,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildUsernameField(),
                const SizedBox(height: 18),
                _buildPasswordField(),
                const SizedBox(height: 30),
                _buildLoginButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= FIELDS =================
  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.poppins(fontSize: 14),
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF1F5F9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
    );
  }

  Widget _buildUsernameField() {
    return TextFormField(
      controller: _usernameCtrl,
      style: GoogleFonts.poppins(),
      decoration: _inputDecoration(
        label: "Username",
        icon: Icons.person_outline,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Username tidak boleh kosong";
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordCtrl,
      obscureText: _obscurePassword,
      style: GoogleFonts.poppins(),
      decoration: _inputDecoration(
        label: "Password",
        icon: Icons.lock_outline,
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.length < 4) {
          return "Password minimal 4 karakter";
        }
        return null;
      },
    );
  }

  // ================= BUTTON =================
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 80,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blueAccent,
                Colors.blue.shade900,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    "LOGIN",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // ================= FOOTER =================
  Widget _buildFooter() {
    return Text(
      "©2026 MANPRO System",
      style: GoogleFonts.poppins(
        fontSize: 12,
        color: Colors.grey.shade500,
      ),
    );
  }
}
*/
