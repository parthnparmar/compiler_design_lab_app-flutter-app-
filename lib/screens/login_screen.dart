import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/auth_session.dart';
import '../widgets/app_logo.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';
import 'profile_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _State();
}

class _State extends State<LoginScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _loading = false, _obscure = true;
  String? _error;

  Future<void> _login() async {
    if (_userCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) {
      setState(() => _error = 'Please enter username and password.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiService.post('login', {
        'username': _userCtrl.text.trim(),
        'password': _passCtrl.text,
      });
      if (!mounted) return;
      if (res['success'] == true) {
        AuthSession.login(res['user'] as Map<String, dynamic>);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const ProfileScreen()));
      } else {
        setState(() => _error = res['message']?.toString() ?? 'Login failed.');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Login'),
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
                // Logo
                const AppLogo(size: 90, showShadow: false),
                const SizedBox(height: 14),
                const Text('Compiler Design Lab',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                const Text('Sign in to your account',
                    style: TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 24),

                // Error
                if (_error != null) _errorBox(_error!),

                // Username
                TextField(
                  controller: _userCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // Password
                TextField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                    child: const Text('Forgot password?', style: TextStyle(fontSize: 13)),
                  ),
                ),

                // Login button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _loading
                        ? const SizedBox(height: 20, width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 16),

                // Register link
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text("Don't have an account? ", style: TextStyle(color: Colors.grey, fontSize: 13)),
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const RegisterScreen())),
                    child: const Text('Register here',
                        style: TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.w600, fontSize: 13)),
                  ),
                ]),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _errorBox(String msg) => Container(
  margin: const EdgeInsets.only(bottom: 12),
  padding: const EdgeInsets.all(10),
  decoration: BoxDecoration(
    color: const Color(0xFFFEF2F2),
    border: Border.all(color: const Color(0xFFFCA5A5)),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Row(children: [
    const Icon(Icons.warning_amber_rounded, color: Color(0xFFB91C1C), size: 18),
    const SizedBox(width: 8),
    Expanded(child: Text(msg, style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 13))),
  ]),
);
