import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/result_card.dart';
import '../widgets/svg_diagram.dart';

class RegexToNFAScreen extends StatefulWidget {
  const RegexToNFAScreen({super.key});
  @override
  State<RegexToNFAScreen> createState() => _State();
}

class _State extends State<RegexToNFAScreen> {
  final _ctrl = TextEditingController(text: '(a|b)*abb');
  bool _loading = false;
  Map<String, dynamic>? _r;
  String? _error;

  Future<void> _run() async {
    setState(() { _loading = true; _error = null; _r = null; });
    try {
      final res = await ApiService.post('regex-to-nfa', {'regex': _ctrl.text});
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
    final table = (_r?['table'] as List?) ?? [];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Regex → NFA (Thompson\'s Construction)'),
        backgroundColor: const Color(0xFF00838F),
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
              helperText: 'Use | for OR, * for Kleene star, () for grouping',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          LoadingButton(loading: _loading, onPressed: _run, label: 'Generate NFA'),
          if (_error != null) Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_error!, style: const TextStyle(color: Colors.red)),
          ),
          if (_r != null) ...[
            ResultCard(
              title: 'NFA Info',
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Postfix Expression: ${_r!['postfix']}',
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 14)),
                const SizedBox(height: 4),
                Text('Start State: ${_r!['start']}    Final State: ${_r!['end']}',
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 14)),
              ]),
            ),
            if (table.isNotEmpty) ResultCard(
              title: 'NFA Transition Table',
              child: DataTable2(
                columns: (table.first as Map).keys.map((k) => k.toString()).toList(),
                rows: table.map<List<String>>(
                  (r) => (r as Map).values.map((v) => v.toString()).toList(),
                ).toList(),
              ),
            ),
            SvgDiagramCard(title: 'NFA Diagram', svgData: _r!['diagram'] as String?),
          ],
        ]),
      ),
    );
  }
}
