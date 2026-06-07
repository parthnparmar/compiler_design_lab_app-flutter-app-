import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/result_card.dart';

class SDDScreen extends StatefulWidget {
  const SDDScreen({super.key});
  @override
  State<SDDScreen> createState() => _State();
}

class _State extends State<SDDScreen> {
  final _ctrl = TextEditingController(text: '3 + 4 * 2');
  bool _loading = false;
  Map<String, dynamic>? _r;
  String? _error;

  Future<void> _run() async {
    setState(() { _loading = true; _error = null; _r = null; });
    try {
      final res = await ApiService.post('sdd', {'expression': _ctrl.text});
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
    final steps = (_r?['steps']      as List?) ?? [];
    final attrs = (_r?['attr_table'] as List?) ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text('SDD — Syntax Directed Definition'), backgroundColor: const Color(0xFF558B2F), foregroundColor: Colors.white),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextField(controller: _ctrl, decoration: const InputDecoration(labelText: 'Expression', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        LoadingButton(loading: _loading, onPressed: _run, label: 'Evaluate'),
        if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: const TextStyle(color: Colors.red))),
        if (_r?['error'] != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text('Error: ${_r!['error']}', style: const TextStyle(color: Colors.red))),
        if (_r?['final_val'] != null) Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.green)),
          child: Text('Result = ${_r!['final_val']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
        ),
        if (steps.isNotEmpty) ResultCard(title: 'Evaluation Steps', child: DataTable2(
          columns: (steps.first as Map).keys.map((k) => k.toString()).toList(),
          rows: steps.map<List<String>>((s) => (s as Map).values.map((v) => v.toString()).toList()).toList(),
        )),
        if (attrs.isNotEmpty) ResultCard(title: 'Attribute Table', child: DataTable2(
          columns: (attrs.first as Map).keys.map((k) => k.toString()).toList(),
          rows: attrs.map<List<String>>((a) => (a as Map).values.map((v) => v.toString()).toList()).toList(),
        )),
      ])),
    );
  }
}
