import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/result_card.dart';
import '../widgets/svg_diagram.dart';

class DfaMinimizationScreen extends StatefulWidget {
  const DfaMinimizationScreen({super.key});
  @override
  State<DfaMinimizationScreen> createState() => _State();
}

class _State extends State<DfaMinimizationScreen> {
  final _ctrl = TextEditingController(text: '(a|b)*abb');
  bool _loading = false;
  Map<String, dynamic>? _r;
  String? _error;

  Future<void> _run() async {
    setState(() { _loading = true; _error = null; _r = null; });
    try {
      final res = await ApiService.post('dfa-minimization', {'regex': _ctrl.text});
      if (!mounted) return;
      // Check for server-side error field
      if (res.containsKey('error')) {
        setState(() => _error = res['error'].toString());
      } else {
        setState(() => _r = res);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final partitions = (_r?['partition_steps'] as List?) ?? [];
    final minTable   = (_r?['min_table']       as List?) ?? [];
    final start      = _r?['start']?.toString();
    final finals     = (_r?['final_states']    as List?)?.cast<String>() ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('DFA Minimization (Partition Refinement)'),
        backgroundColor: const Color(0xFF880E4F),
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
          LoadingButton(loading: _loading, onPressed: _run, label: 'Minimize DFA'),

          if (_error != null) Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(_error!, style: const TextStyle(color: Colors.red)),
          ),

          if (_r != null) ...[
            if (start != null) ResultCard(
              title: 'Summary',
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Start State: $start',
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 13)),
                Text('Final States: ${finals.join(', ')}',
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 13)),
              ]),
            ),

            if (partitions.isNotEmpty) ResultCard(
              title: 'Partition Refinement Steps',
              child: DataTable2(
                columns: ['Step', 'Partitions'],
                rows: partitions.map<List<String>>((r) => [
                  (r as Map)['Step'].toString(),
                  r['Partitions'].toString(),
                ]).toList(),
              ),
            ),

            if (minTable.isNotEmpty) ResultCard(
              title: 'Minimized DFA Transition Table',
              child: DataTable2(
                columns: (minTable.first as Map).keys.map((k) => k.toString()).toList(),
                rows: minTable.map<List<String>>(
                  (r) => (r as Map).values.map((v) => v.toString()).toList(),
                ).toList(),
              ),
            ),

            SvgDiagramCard(
              title: 'Minimized DFA Diagram',
              svgData: _r!['diagram'] as String?,
            ),
          ],
        ]),
      ),
    );
  }
}
