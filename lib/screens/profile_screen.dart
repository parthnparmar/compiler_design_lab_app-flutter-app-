import 'package:flutter/material.dart';
import '../services/auth_session.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final initial = AuthSession.firstname.isNotEmpty
        ? AuthSession.firstname[0].toUpperCase()
        : '?';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // Avatar
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFF1565C0),
                  child: Text(initial,
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const SizedBox(height: 14),
                Text('${AuthSession.firstname} ${AuthSession.lastname}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                Text('@${AuthSession.username}',
                    style: const TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 24),

                _infoRow('First Name', AuthSession.firstname),
                _infoRow('Last Name',  AuthSession.lastname),
                _infoRow('Username',   AuthSession.username),
                _infoRow('Email',      AuthSession.email),

                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    onPressed: () {
                      AuthSession.logout();
                      Navigator.pushAndRemoveUntil(context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) => Container(
    padding: const EdgeInsets.symmetric(vertical: 10),
    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0)))),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600, fontSize: 14)),
      Text(value.isEmpty ? '-' : value, style: const TextStyle(color: Color(0xFF1A1A2E), fontSize: 14)),
    ]),
  );
}
