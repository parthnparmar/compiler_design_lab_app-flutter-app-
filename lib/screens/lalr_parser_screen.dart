import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/result_card.dart';

class LALRParserScreen extends StatefulWidget {
  const LALRParserScreen({super.key});
  @override
  State<LALRParserScreen> createState() => _State();
}

class _State extends State<LALRParserScreen> {
  final _gCtrl = TextEditingController(text: "E -> E + T | T\nT -> T * F | F\nF -> ( E ) | id");
  final _iCtrl = TextEditingController(text: 'id + id * id');
  bool _loading = false;
  Map<String, dynamic>? _r;
  String? _error;

  Future<void> _run() async {
    setState(() { _loading = true; _error = null; _r = null; });
    try {
      final res = await ApiService.post('lalr-parser', {'grammar': _gCtrl.text, 'input_string': _iCtrl.text});
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
    final aug      = (_r?['augmented_grammar']   as List?) ?? [];
    final states   = (_r?['states']              as List?) ?? [];
    final rows     = (_r?['table_rows']          as List?) ?? [];
    final aT       = (_r?['action_terminals']        as List?)?.cast<String>() ?? [];
    final gNT      = (_r?['goto_non_terminals']      as List?)?.cast<String>() ?? [];
    final trace    = (_r?['parse_trace']         as List?) ?? [];
    final conflicts= (_r?['conflicts']           as List?) ?? [];
    final merged   = (_r?['merged_info']         as List?) ?? [];
    final accepted = _r?['accepted'] as bool?;
    final clrN  = _r?['clr_state_count'];
    final lalrN = _r?['lalr_state_count'];

    return Scaffold(
      appBar: AppBar(title: const Text('LALR Parser'), backgroundColor: const Color(0xFF00695C), foregroundColor: Colors.white),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextField(controller: _gCtrl, maxLines: 5, decoration: const InputDecoration(labelText: 'Grammar', border: OutlineInputBorder(), alignLabelWithHint: true)),
        const SizedBox(height: 8),
        TextField(controller: _iCtrl, decoration: const InputDecoration(labelText: 'Input String', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        LoadingButton(loading: _loading, onPressed: _run, label: 'Parse'),
        if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: const TextStyle(color: Colors.red))),
        if (accepted != null) StatusBadge(accepted: accepted),
        if (clrN != null) Padding(padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text('CLR States: $clrN  →  LALR States: $lalrN', style: const TextStyle(fontWeight: FontWeight.bold))),
        if (conflicts.isNotEmpty) ResultCard(title: 'Conflicts', child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: conflicts.map<Widget>((c) => Text('⚠ $c', style: const TextStyle(color: Colors.orange))).toList())),
        if (aug.isNotEmpty) ResultCard(title: 'Augmented Grammar', child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: aug.map<Widget>((r) => Text('${r['Rule']}: ${r['Production']}', style: const TextStyle(fontFamily: 'monospace', fontSize: 13))).toList())),
        if (merged.isNotEmpty) ResultCard(title: 'Merged States (CLR→LALR)', child: DataTable2(
          columns: (merged.first as Map).keys.map((k) => k.toString()).toList(),
          rows: merged.map<List<String>>((r) => (r as Map).values.map((v) => v.toString()).toList()).toList(),
        )),
        if (states.isNotEmpty) ResultCard(title: 'LALR Item Sets', child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: states.map<Widget>((s) => Padding(padding: const EdgeInsets.only(bottom: 8),
              child: Text('${s['label']}:\n${(s['item_list'] as List).join('\n')}', style: const TextStyle(fontFamily: 'monospace', fontSize: 12)))).toList())),
        if (rows.isNotEmpty) ResultCard(title: 'LALR Parsing Table', child: DataTable2(
          columns: ['State', ...aT, ...gNT],
          rows: rows.map<List<String>>((r) => ['${(r as Map)['State']}', ...aT.map((t) => r[t]?.toString() ?? ''), ...gNT.map((n) => r[n]?.toString() ?? '')]).toList(),
        )),
        if (trace.isNotEmpty) ResultCard(title: 'Parse Trace', child: DataTable2(
          columns: (trace.first as Map).keys.map((k) => k.toString()).toList(),
          rows: trace.map<List<String>>((s) => (s as Map).values.map((v) => v.toString()).toList()).toList(),
        )),
      ])),
    );
  }
}
