import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/result_card.dart';

class SLRParserScreen extends StatefulWidget {
  const SLRParserScreen({super.key});
  @override
  State<SLRParserScreen> createState() => _State();
}

class _State extends State<SLRParserScreen> {
  final _grammarCtrl = TextEditingController(text: "E -> E + T | T\nT -> T * F | F\nF -> ( E ) | id");
  final _inputCtrl   = TextEditingController(text: 'id + id * id');
  bool _loading = false;
  Map<String, dynamic>? _result;
  String? _error;

  Future<void> _run() async {
    setState(() { _loading = true; _error = null; _result = null; });
    try {
      final res = await ApiService.post('slr-parser', {'grammar': _grammarCtrl.text, 'input_string': _inputCtrl.text});
      if (!mounted) return;
      setState(() { _result = res; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final augGrammar = (_result?['augmented_grammar'] as List?) ?? [];
    final states     = (_result?['states']         as List?) ?? [];
    final follow     = (_result?['follow_sets']    as Map?)  ?? {};
    final tableRows  = (_result?['table_rows']     as List?) ?? [];
    final actionT    = (_result?['action_terminals']     as List?)?.cast<String>() ?? [];
    final gotoNT     = (_result?['goto_non_terminals']   as List?)?.cast<String>() ?? [];
    final trace      = (_result?['parse_trace']    as List?) ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('SLR Parser'), backgroundColor: const Color(0xFF6A1B9A), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(controller: _grammarCtrl, maxLines: 5, decoration: const InputDecoration(labelText: 'Grammar', border: OutlineInputBorder(), alignLabelWithHint: true)),
          const SizedBox(height: 8),
          TextField(controller: _inputCtrl, decoration: const InputDecoration(labelText: 'Input String (space-separated)', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          LoadingButton(loading: _loading, onPressed: _run, label: 'Parse'),
          if (_error != null) _errWidget(_error!),
          if (augGrammar.isNotEmpty) ResultCard(
            title: 'Augmented Grammar',
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: augGrammar.map<Widget>((r) => Text('${r['rule']}: ${r['head']} → ${(r['body'] as List).join(' ')}',
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13))).toList()),
          ),
          if (follow.isNotEmpty) ResultCard(
            title: 'FOLLOW Sets',
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: follow.entries.map((e) => Text('FOLLOW(${e.key}) = { ${(e.value as List).join(', ')} }',
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13))).toList()),
          ),
          if (states.isNotEmpty) ResultCard(
            title: 'LR(0) Canonical Collection',
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: states.map<Widget>((s) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('I${s['index']}:\n${(s['items'] as List).join('\n')}',
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
              )).toList()),
          ),
          if (tableRows.isNotEmpty) ResultCard(
            title: 'SLR Parsing Table (ACTION + GOTO)',
            child: DataTable2(
              columns: ['State', ...actionT, ...gotoNT],
              rows: tableRows.map<List<String>>((r) {
                final row = r as Map;
                return ['${row['state']}', ...actionT.map((t) => row[t]?.toString() ?? ''), ...gotoNT.map((n) => row[n]?.toString() ?? '')];
              }).toList(),
            ),
          ),
          if (trace.isNotEmpty) ResultCard(
            title: 'Parse Trace',
            child: DataTable2(
              columns: (trace.first as Map).keys.map((k) => k.toString()).toList(),
              rows: trace.map<List<String>>((s) => (s as Map).values.map((v) => v.toString()).toList()).toList(),
            ),
          ),
        ]),
      ),
    );
  }
}

Widget _errWidget(String msg) => Padding(padding: const EdgeInsets.only(top: 8), child: Text(msg, style: const TextStyle(color: Colors.red)));
