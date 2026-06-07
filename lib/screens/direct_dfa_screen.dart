import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/result_card.dart';
import '../widgets/svg_diagram.dart';

class DirectDfaScreen extends StatefulWidget {
  const DirectDfaScreen({super.key});
  @override
  State<DirectDfaScreen> createState() => _State();
}

class _State extends State<DirectDfaScreen> {
  final _ctrl = TextEditingController(text: '(a|b)*abb');
  bool _loading = false;
  Map<String, dynamic>? _r;
  String? _error;

  Future<void> _run() async {
    setState(() { _loading = true; _error = null; _r = null; });
    try {
      final res = await ApiService.post('direct-dfa', {'regex': _ctrl.text});
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
    final followpos = (_r?['followpos_table'] as List?) ?? [];
    final dfaTable  = (_r?['dfa_table']       as List?) ?? [];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Direct DFA (Syntax Tree Method)'),
        backgroundColor: const Color(0xFF4A148C),
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
          LoadingButton(loading: _loading, onPressed: _run, label: 'Construct DFA'),
          if (_error != null) Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_error!, style: const TextStyle(color: Colors.red)),
          ),
          if (_r != null) ...[
            // Syntax Tree diagram
            SvgDiagramCard(title: 'Syntax Tree', svgData: _r!['tree_diagram'] as String?),
            if (followpos.isNotEmpty) ResultCard(
              title: 'followpos Table',
              child: DataTable2(
                columns: ['Position', 'Symbol', 'followpos'],
                rows: followpos.map<List<String>>((r) => [
                  r['Position'].toString(),
                  r['Symbol'].toString(),
                  r['followpos'].toString(),
                ]).toList(),
              ),
            ),
            if (dfaTable.isNotEmpty) ResultCard(
              title: 'DFA Transition Table',
              child: DataTable2(
                columns: (dfaTable.first as Map).keys.map((k) => k.toString()).toList(),
                rows: dfaTable.map<List<String>>(
                  (r) => (r as Map).values.map((v) => v.toString()).toList(),
                ).toList(),
              ),
            ),
            // DFA diagram
            SvgDiagramCard(title: 'DFA Diagram', svgData: _r!['dfa_diagram'] as String?),
          ],
        ]),
      ),
    );
  }
}
