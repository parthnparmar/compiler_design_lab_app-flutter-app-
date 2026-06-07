import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'forgot_password_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});
  @override
  State<ResetPasswordScreen> createState() => _State();
}

class _State extends State<ResetPasswordScreen> {
  final _otpCtrl  = TextEditingController();
  final _pCtrl    = TextEditingController();
  final _cpCtrl   = TextEditingController();
  bool _loading   = false;
  bool _obscure   = true;
  bool _cobscure  = true;
  String? _error;

  Future<void> _reset() async {
    final otp = _otpCtrl.text.trim();
    final p   = _pCtrl.text;
    final cp  = _cpCtrl.text;
    if (otp.isEmpty || p.isEmpty || cp.isEmpty) {
      setState(() => _error = 'All fields are required.'); return;
    }
    if (otp.length != 6) { setState(() => _error = 'OTP must be 6 digits.'); return; }
    if (p != cp) { setState(() => _error = 'Passwords do not match.'); return; }
    if (p.length < 6) { setState(() => _error = 'Password must be at least 6 characters.'); return; }

    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiService.post('reset-password', {
        'email': widget.email, 'otp': otp, 'password': p,
      });
      if (!mounted) return;
      if (res['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset successful! Please login.'),
              backgroundColor: Colors.green),
        );
        Navigator.pushAndRemoveUntil(context,
            MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
      } else {
        setState(() => _error = res['message']?.toString() ?? 'Reset failed.');
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
        title: const Text('Reset Password'),
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
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(color: const Color(0xFF1565C0), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.key, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 14),
                const Text('Reset Password',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                const SizedBox(height: 4),
                Text('OTP sent to ${widget.email}',
                    style: const TextStyle(fontSize: 13, color: Colors.grey), textAlign: TextAlign.center),
                const SizedBox(height: 22),

                if (_error != null) Container(
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
                    Expanded(child: Text(_error!, style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 13))),
                  ]),
                ),

                // OTP field
                TextField(
                  controller: _otpCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 8),
                  decoration: const InputDecoration(
                    labelText: 'Enter OTP',
                    border: OutlineInputBorder(),
                    counterText: '',
                    hintText: '• • • • • •',
                  ),
                ),
                const SizedBox(height: 12),

                // New password
                TextField(
                  controller: _pCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Confirm password
                TextField(
                  controller: _cpCtrl,
                  obscureText: _cobscure,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(_cobscure ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _cobscure = !_cobscure),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _reset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0), foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _loading
                        ? const SizedBox(height: 20, width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Reset Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 10),

                TextButton(
                  onPressed: () => Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                  child: const Text('Resend OTP', style: TextStyle(fontSize: 13)),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
