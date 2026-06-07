import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/result_card.dart';
import '../widgets/svg_diagram.dart';

class NfaToDfaScreen extends StatefulWidget {
  const NfaToDfaScreen({super.key});
  @override
  State<NfaToDfaScreen> createState() => _State();
}

class _State extends State<NfaToDfaScreen> {
  final _ctrl = TextEditingController(text: '(a|b)*abb');
  bool _loading = false;
  Map<String, dynamic>? _r;
  String? _error;

  Future<void> _run() async {
    setState(() { _loading = true; _error = null; _r = null; });
    try {
      final res = await ApiService.post('nfa-to-dfa', {'regex': _ctrl.text});
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
    final table    = (_r?['table']            as List?) ?? [];
    final closures = (_r?['epsilon_closures'] as List?) ?? [];
    return Scaffold(
      appBar: AppBar(
        title: const Text('NFA → DFA (Subset Construction)'),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(
            controller: _ctrl,
            decoration: const InputDecoration(
              labelText: 'Regular Expression',
              hintText: 'e.g. (a|b)*abb',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          LoadingButton(loading: _loading, onPressed: _run, label: 'Convert to DFA'),
          if (_error != null) Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_error!, style: const TextStyle(color: Colors.red)),
          ),
          if (_r != null) ...[
            if (closures.isNotEmpty) ResultCard(
              title: 'ε-Closure Table',
              child: DataTable2(
                columns: (closures.first as Map).keys.map((k) => k.toString()).toList(),
                rows: closures.map<List<String>>(
                  (r) => (r as Map).values.map((v) => v.toString()).toList(),
                ).toList(),
              ),
            ),
            if (table.isNotEmpty) ResultCard(
              title: 'DFA Transition Table',
              child: DataTable2(
                columns: (table.first as Map).keys.map((k) => k.toString()).toList(),
                rows: table.map<List<String>>(
                  (r) => (r as Map).values.map((v) => v.toString()).toList(),
                ).toList(),
              ),
            ),
            SvgDiagramCard(title: 'DFA Diagram', svgData: _r!['diagram'] as String?),
          ],
        ]),
      ),
    );
  }
}
