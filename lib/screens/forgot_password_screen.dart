import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/app_logo.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _State();
}

class _State extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  String? _error, _success;

  Future<void> _sendOtp() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) { setState(() => _error = 'Please enter your email.'); return; }
    if (!RegExp(r'^[\w.-]+@[\w.-]+\.\w+$').hasMatch(email)) {
      setState(() => _error = 'Enter a valid email address.'); return;
    }
    setState(() { _loading = true; _error = null; _success = null; });
    try {
      final res = await ApiService.post('forgot-password', {'email': email});
      if (!mounted) return;
      if (res['success'] == true) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => ResetPasswordScreen(email: email)));
      } else {
        setState(() => _error = res['message']?.toString() ?? 'Failed to send OTP.');
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
        title: const Text('Forgot Password'),
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
                const SizedBox(height: 14),
                const Text('Forgot Password',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                const Text('Enter your email to receive an OTP',
                    style: TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 24),

                if (_error   != null) _alertBox(_error!,   isError: true),
                if (_success != null) _alertBox(_success!, isError: false),

                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                    hintText: 'your@email.com',
                  ),
                ),
                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _sendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0), foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _loading
                        ? const SizedBox(height: 20, width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Send OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('← Back to Login', style: TextStyle(fontSize: 13)),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
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
