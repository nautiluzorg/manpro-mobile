import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final String fullName;
  final String username;
  final String email;
  final ImageProvider avatar;
  final VoidCallback onLogout;
  final List<Widget> menuItems;

  const AppDrawer({
    super.key,
    required this.fullName,
    required this.username,
    required this.email,
    required this.avatar,
    required this.onLogout,
    required this.menuItems,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        // 🔹 BACKGROUND DRAWER GRADIENT
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue.shade900.withValues(alpha: 0.95),
              Colors.white.withValues(alpha: 0.5),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              _buildHeader(),
              const SizedBox(height: 8),

              // 🔹 MENU ITEMS (NORMAL FLOW)
              ...menuItems,

              const Divider(color: Colors.white24),

              // 🔹 LOGOUT (NORMAL, TIDAK STICKY)
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.white),
                title: const Text(
                  'LOGOUT',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: onLogout,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================= HEADER =================

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blueAccent,
            Colors.blue.shade900,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 34,
            backgroundImage: avatar,
            backgroundColor: Colors.white,
          ),
          const SizedBox(height: 10),
          Text(
            fullName.isNotEmpty ? fullName : username,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
