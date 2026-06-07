import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/app_logo.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _State();
}

class _State extends State<RegisterScreen> {
  final _fnCtrl   = TextEditingController();
  final _lnCtrl   = TextEditingController();
  final _uCtrl    = TextEditingController();
  final _eCtrl    = TextEditingController();
  final _pCtrl    = TextEditingController();
  final _cpCtrl   = TextEditingController();
  bool _loading   = false;
  bool _obscure   = true;
  bool _cobscure  = true;
  String? _error;
  String? _success;

  Future<void> _register() async {
    final fn = _fnCtrl.text.trim();
    final ln = _lnCtrl.text.trim();
    final u  = _uCtrl.text.trim();
    final e  = _eCtrl.text.trim();
    final p  = _pCtrl.text;
    final cp = _cpCtrl.text;

    if ([fn, ln, u, e, p, cp].any((s) => s.isEmpty)) {
      setState(() => _error = 'All fields are required.');
      return;
    }
    if (p != cp) { setState(() => _error = 'Passwords do not match.'); return; }
    if (p.length < 6) { setState(() => _error = 'Password must be at least 6 characters.'); return; }
    if (!RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(e)) {
      setState(() => _error = 'Enter a valid email address.'); return;
    }

    setState(() { _loading = true; _error = null; _success = null; });
    try {
      final res = await ApiService.post('register', {
        'firstname': fn, 'lastname': ln, 'username': u, 'email': e, 'password': p,
      });
      if (!mounted) return;
      if (res['success'] == true) {
        setState(() => _success = 'Account created! You can now login.');
      } else {
        setState(() => _error = res['message']?.toString() ?? 'Registration failed.');
      }
    } catch (ex) {
      if (!mounted) return;
      setState(() => _error = ex.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text('Create Account'),
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
                const AppLogo(size: 80, showShadow: false),
                const SizedBox(height: 12),
                const Text('Create Account', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                const Text('Join Compiler Design Lab today', style: TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 22),

                if (_error   != null) _alertBox(_error!,   isError: true),
                if (_success != null) ...[
                  _alertBox(_success!, isError: false),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => const LoginScreen())),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0), foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: const Text('Go to Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ] else ...[
                  // First + Last name row
                  Row(children: [
                    Expanded(child: _field(_fnCtrl, 'First Name', Icons.badge_outlined)),
                    const SizedBox(width: 12),
                    Expanded(child: _field(_lnCtrl, 'Last Name',  Icons.badge_outlined)),
                  ]),
                  const SizedBox(height: 12),
                  _field(_uCtrl, 'Username', Icons.person_outline),
                  const SizedBox(height: 12),
                  _field(_eCtrl, 'Email Address', Icons.email_outlined, keyboard: TextInputType.emailAddress),
                  const SizedBox(height: 12),
                  _pwField(_pCtrl,  'Password',         _obscure,  () => setState(() => _obscure  = !_obscure)),
                  const SizedBox(height: 12),
                  _pwField(_cpCtrl, 'Confirm Password', _cobscure, () => setState(() => _cobscure = !_cobscure)),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _register,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1565C0), foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      child: _loading
                          ? const SizedBox(height: 20, width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Create Account', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text('Already have an account? ', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => const LoginScreen())),
                      child: const Text('Sign in',
                          style: TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ]),
                ],
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon,
      {TextInputType keyboard = TextInputType.text}) =>
    TextField(
      controller: c,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label, prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );

  Widget _pwField(TextEditingController c, String label, bool obscure, VoidCallback toggle) =>
    TextField(
      controller: c,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label, prefixIcon: const Icon(Icons.lock_outline),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        suffixIcon: IconButton(icon: Icon(obscure ? Icons.visibility_off : Icons.visibility), onPressed: toggle),
      ),
    );
}

Widget _alertBox(String msg, {required bool isError}) => Container(
  margin: const EdgeInsets.only(bottom: 12),
  padding: const EdgeInsets.all(10),
  decoration: BoxDecoration(
    color: isError ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
    border: Border.all(color: isError ? const Color(0xFFFCA5A5) : const Color(0xFF86EFAC)),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Row(children: [
    Icon(isError ? Icons.warning_amber_rounded : Icons.check_circle_outline,
        color: isError ? const Color(0xFFB91C1C) : const Color(0xFF166534), size: 18),
    const SizedBox(width: 8),
    Expanded(child: Text(msg,
        style: TextStyle(color: isError ? const Color(0xFFB91C1C) : const Color(0xFF166534), fontSize: 13))),
  ]),
);
