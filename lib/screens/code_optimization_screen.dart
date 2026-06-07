import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/result_card.dart';

class CodeOptimizationScreen extends StatefulWidget {
  const CodeOptimizationScreen({super.key});
  @override
  State<CodeOptimizationScreen> createState() => _State();
}

class _State extends State<CodeOptimizationScreen> {
  final _ctrl = TextEditingController(text: 'x = b - c * 2');
  bool _loading = false;
  Map<String, dynamic>? _r;
  String? _error;

  Future<void> _run() async {
    setState(() { _loading = true; _error = null; _r = null; });
    try {
      final res = await ApiService.post('code-optimization', {'expression': _ctrl.text});
      if (!mounted) return;
      setState(() => _r = res);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = (_r?['steps'] as List?) ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text('Code Optimization'), backgroundColor: const Color(0xFF4527A0), foregroundColor: Colors.white),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextField(controller: _ctrl, decoration: const InputDecoration(labelText: 'Expression', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        LoadingButton(loading: _loading, onPressed: _run, label: 'Optimize'),
        if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: const TextStyle(color: Colors.red))),
        ...steps.map((s) => MonoCard(
          title: s['name'].toString(),
          lines: (s['code'] as List).map((c) => c.toString()).toList(),
        )),
      ])),
    );
  }
}
