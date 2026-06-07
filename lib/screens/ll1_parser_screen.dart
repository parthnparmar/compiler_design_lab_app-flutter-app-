import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/result_card.dart';

class LL1ParserScreen extends StatefulWidget {
  const LL1ParserScreen({super.key});
  @override
  State<LL1ParserScreen> createState() => _State();
}

class _State extends State<LL1ParserScreen> {
  final _grammarCtrl = TextEditingController(text: "E -> T E'\nE' -> + T E' | ε\nT -> F T'\nT' -> * F T' | ε\nF -> ( E ) | id");
  final _startCtrl   = TextEditingController(text: 'E');
  final _inputCtrl   = TextEditingController(text: 'id + id * id');
  bool _loading = false;
  Map<String, dynamic>? _result;
  String? _error;

  Future<void> _run() async {
    setState(() { _loading = true; _error = null; _result = null; });
    try {
      final res = await ApiService.post('ll1-parser', {
        'grammar': _grammarCtrl.text,
        'start_symbol': _startCtrl.text,
        'input_string': _inputCtrl.text,
      });
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
    final first  = (_result?['first_sets']   as Map?) ?? {};
    final follow = (_result?['follow_sets']  as Map?) ?? {};
    final table  = (_result?['parsing_table'] as Map?) ?? {};
    final steps  = (_result?['steps']        as List?) ?? [];

    // Build parsing table rows
    final termSet = table.values.expand((v) => (v as Map).keys).toSet().cast<String>().toList();
    termSet.sort();
    final terminals = steps.isNotEmpty ? termSet : <String>[];
    final tableRows = table.entries.map((e) {
      final row = <String>[e.key];
      for (final t in terminals) {
        final prod = (e.value as Map)[t];
        row.add(prod != null ? '${e.key}→$prod' : '');
      }
      return row;
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('LL(1) Parser'), backgroundColor: const Color(0xFF2E7D32), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(controller: _grammarCtrl, maxLines: 6, decoration: const InputDecoration(labelText: 'Grammar', border: OutlineInputBorder(), alignLabelWithHint: true)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: TextField(controller: _startCtrl, decoration: const InputDecoration(labelText: 'Start Symbol', border: OutlineInputBorder()))),
            const SizedBox(width: 8),
            Expanded(child: TextField(controller: _inputCtrl, decoration: const InputDecoration(labelText: 'Input String', border: OutlineInputBorder()))),
          ]),
          const SizedBox(height: 12),
          LoadingButton(loading: _loading, onPressed: _run, label: 'Parse'),
          if (_error != null) _errWidget(_error!),
          if (first.isNotEmpty) ResultCard(
            title: 'FIRST Sets',
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: first.entries.map((e) => Text('FIRST(${e.key}) = { ${(e.value as List).join(', ')} }',
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13))).toList()),
          ),
          if (follow.isNotEmpty) ResultCard(
            title: 'FOLLOW Sets',
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: follow.entries.map((e) => Text('FOLLOW(${e.key}) = { ${(e.value as List).join(', ')} }',
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13))).toList()),
          ),
          if (tableRows.isNotEmpty) ResultCard(
            title: 'LL(1) Parsing Table',
            child: DataTable2(
              columns: ['NT', ...terminals],
              rows: tableRows,
            ),
          ),
          if (steps.isNotEmpty) ResultCard(
            title: 'Parse Trace',
            child: DataTable2(
              columns: (steps.first as Map).keys.map((k) => k.toString()).toList(),
              rows: steps.map<List<String>>((s) => (s as Map).values.map((v) => v.toString()).toList()).toList(),
            ),
          ),
        ]),
      ),
    );
  }
}

Widget _errWidget(String msg) => Padding(padding: const EdgeInsets.only(top: 8), child: Text(msg, style: const TextStyle(color: Colors.red)));
