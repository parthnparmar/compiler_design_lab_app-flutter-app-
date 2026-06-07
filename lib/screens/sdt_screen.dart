import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/result_card.dart';

class SDTScreen extends StatefulWidget {
  const SDTScreen({super.key});
  @override
  State<SDTScreen> createState() => _State();
}

class _State extends State<SDTScreen> {
  final _ctrl = TextEditingController(text: '3 + 4 * 2');
  bool _loading = false;
  Map<String, dynamic>? _r;
  String? _error;

  Future<void> _run() async {
    setState(() { _loading = true; _error = null; _r = null; });
    try {
      final res = await ApiService.post('sdt', {'expression': _ctrl.text});
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
    final code  = (_r?['code']  as List?) ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text('SDT — Syntax Directed Translation'), backgroundColor: const Color(0xFF4E342E), foregroundColor: Colors.white),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextField(controller: _ctrl, decoration: const InputDecoration(labelText: 'Expression', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        LoadingButton(loading: _loading, onPressed: _run, label: 'Translate'),
        if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: const TextStyle(color: Colors.red))),
        if (_r?['postfix'] != null) ResultCard(title: 'Postfix Expression', child: Text(_r!['postfix'].toString(), style: const TextStyle(fontFamily: 'monospace', fontSize: 15))),
        if (code.isNotEmpty) MonoCard(title: 'Generated Three-Address Code', lines: code.asMap().entries.map((e) => '${e.key + 1}:  ${e.value}').toList()),
        if (steps.isNotEmpty) ResultCard(title: 'Translation Steps', child: DataTable2(
          columns: (steps.first as Map).keys.map((k) => k.toString()).toList(),
          rows: steps.map<List<String>>((s) => (s as Map).values.map((v) => v.toString()).toList()).toList(),
        )),
      ])),
    );
  }
}
