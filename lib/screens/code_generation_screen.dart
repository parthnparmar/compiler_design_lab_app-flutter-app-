import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/result_card.dart';

class CodeGenerationScreen extends StatefulWidget {
  const CodeGenerationScreen({super.key});
  @override
  State<CodeGenerationScreen> createState() => _State();
}

class _State extends State<CodeGenerationScreen> {
  final _ctrl = TextEditingController(text: 'x = b - c * 2');
  bool _loading = false;
  Map<String, dynamic>? _r;
  String? _error;

  Future<void> _run() async {
    setState(() { _loading = true; _error = null; _r = null; });
    try {
      final res = await ApiService.post('code-generation', {'expression': _ctrl.text});
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
    final tac = (_r?['tac']      as List?) ?? [];
    final asm = (_r?['assembly'] as List?) ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text('Code Generation'), backgroundColor: const Color(0xFF283593), foregroundColor: Colors.white),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextField(controller: _ctrl, decoration: const InputDecoration(labelText: 'Expression', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        LoadingButton(loading: _loading, onPressed: _run, label: 'Generate'),
        if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: const TextStyle(color: Colors.red))),
        if (tac.isNotEmpty) MonoCard(title: 'Three Address Code', lines: tac.map((e) => e.toString()).toList()),
        if (asm.isNotEmpty) MonoCard(title: 'Assembly Code', lines: asm.map((e) => e.toString()).toList(), color: const Color(0xFF1565C0)),
      ])),
    );
  }
}
