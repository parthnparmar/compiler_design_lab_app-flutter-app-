import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/result_card.dart';

class ExprTranslationScreen extends StatefulWidget {
  const ExprTranslationScreen({super.key});
  @override
  State<ExprTranslationScreen> createState() => _State();
}

class _State extends State<ExprTranslationScreen> {
  final _ctrl = TextEditingController(text: 'a + b * c');
  bool _loading = false;
  Map<String, dynamic>? _r;
  String? _error;

  Future<void> _run() async {
    setState(() { _loading = true; _error = null; _r = null; });
    try {
      final res = await ApiService.post('expr-translation', {'expression': _ctrl.text});
      if (!mounted) return;
      setState(() => _r = res);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _tbl(String title, List? rows) {
    if (rows == null || rows.isEmpty) return const SizedBox.shrink();
    return ResultCard(title: title, child: DataTable2(
      columns: (rows.first as Map).keys.map((k) => k.toString()).toList(),
      rows: rows.map<List<String>>((r) => (r as Map).values.map((v) => v.toString()).toList()).toList(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expression Translation'), backgroundColor: const Color(0xFF37474F), foregroundColor: Colors.white),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextField(controller: _ctrl, decoration: const InputDecoration(labelText: 'Expression', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        LoadingButton(loading: _loading, onPressed: _run, label: 'Translate'),
        if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: const TextStyle(color: Colors.red))),
        _tbl('Quadruples',            _r?['quad_rows']            as List?),
        _tbl('Triples',               _r?['triple_rows']          as List?),
        _tbl('Pointer to Triples',    _r?['pointer_rows']         as List?),
        _tbl('Indirect Triples',      _r?['indirect_triple_rows'] as List?),
      ])),
    );
  }
}
