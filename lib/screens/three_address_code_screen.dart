import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/result_card.dart';

class ThreeAddressCodeScreen extends StatefulWidget {
  const ThreeAddressCodeScreen({super.key});
  @override
  State<ThreeAddressCodeScreen> createState() => _State();
}

class _State extends State<ThreeAddressCodeScreen> {
  final _ctrl = TextEditingController(text: 'x = b - c * 2');
  bool _loading = false;
  Map<String, dynamic>? _r;
  String? _error;

  Future<void> _run() async {
    setState(() { _loading = true; _error = null; _r = null; });
    try {
      final res = await ApiService.post('three-address-code', {'expression': _ctrl.text});
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
    final tac    = (_r?['tac']        as List?) ?? [];
    final quads  = (_r?['quadruples'] as List?) ?? [];
    final trips  = (_r?['triples']    as List?) ?? [];

    return Scaffold(
      appBar: AppBar(title: const Text('Three Address Code'), backgroundColor: const Color(0xFFC62828), foregroundColor: Colors.white),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        TextField(controller: _ctrl, decoration: const InputDecoration(labelText: 'Expression', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        LoadingButton(loading: _loading, onPressed: _run, label: 'Generate'),
        if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: const TextStyle(color: Colors.red))),
        if (tac.isNotEmpty) MonoCard(title: 'Three Address Code', lines: tac.map((e) => e.toString()).toList()),
        if (quads.isNotEmpty) ResultCard(title: 'Quadruples', child: DataTable2(
          columns: ['Op', 'Arg1', 'Arg2', 'Result'],
          rows: quads.map<List<String>>((q) => [q['op'].toString(), q['arg1'].toString(), q['arg2'].toString(), q['result'].toString()]).toList(),
        )),
        if (trips.isNotEmpty) ResultCard(title: 'Triples', child: DataTable2(
          columns: ['Index', 'Op', 'Arg1', 'Arg2'],
          rows: trips.map<List<String>>((t) => [t['index'].toString(), t['op'].toString(), t['arg1'].toString(), t['arg2'].toString()]).toList(),
        )),
      ])),
    );
  }
}
