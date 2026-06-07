import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/result_card.dart';

class LexicalAnalyzerScreen extends StatefulWidget {
  const LexicalAnalyzerScreen({super.key});
  @override
  State<LexicalAnalyzerScreen> createState() => _State();
}

class _State extends State<LexicalAnalyzerScreen> {
  final _ctrl = TextEditingController(text: 'int x = 5 + y;\nif (x > 0) return x;');
  bool _loading = false;
  Map<String, dynamic>? _result;
  String? _error;

  Future<void> _run() async {
    setState(() { _loading = true; _error = null; _result = null; });
    try {
      final res = await ApiService.post('lexical-analyzer', {'source_code': _ctrl.text});
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
    final tokens = (_result?['tokens'] as List?) ?? [];
    final symbols = (_result?['symbol_table'] as List?) ?? [];
    return Scaffold(
      appBar: AppBar(title: const Text('Lexical Analyzer'), backgroundColor: const Color(0xFF1565C0), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(controller: _ctrl, maxLines: 5, decoration: const InputDecoration(labelText: 'Source Code', border: OutlineInputBorder(), alignLabelWithHint: true)),
          const SizedBox(height: 12),
          LoadingButton(loading: _loading, onPressed: _run, label: 'Analyze'),
          if (_error != null) _errWidget(_error!),
          if (tokens.isNotEmpty) ResultCard(
            title: 'Token Stream',
            child: DataTable2(
              columns: ['Line', 'Type', 'Value'],
              rows: tokens.map<List<String>>((t) => [t['line'].toString(), t['type'].toString(), t['value'].toString()]).toList(),
            ),
          ),
          if (symbols.isNotEmpty) ResultCard(
            title: 'Symbol Table',
            child: DataTable2(
              columns: ['ID', 'Name', 'Type'],
              rows: symbols.map<List<String>>((s) => [s['id'].toString(), s['name'].toString(), s['type'].toString()]).toList(),
            ),
          ),
        ]),
      ),
    );
  }
}

Widget _errWidget(String msg) => Padding(
  padding: const EdgeInsets.only(top: 8),
  child: Text(msg, style: const TextStyle(color: Colors.red)),
);
