import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _entries = [
    {
      'title': 'Lexical Analyzer',
      'body': 'Enter source code. The analyzer will tokenize it and build a symbol table.\nExample: int x = 5 + y;'
    },
    {
      'title': 'LL(1) Parser',
      'body': 'Enter grammar (one rule per line), start symbol, and input string.\nExample grammar:\n  E -> T E\'\n  E\' -> + T E\' | ε\n  T -> F T\'\n  T\' -> * F T\' | ε\n  F -> ( E ) | id\nStart symbol: E\nInput: id + id * id'
    },
    {
      'title': 'SLR / CLR / LALR Parser',
      'body': 'Enter grammar and input string (space-separated tokens).\nExample:\n  E -> E + T | T\n  T -> T * F | F\n  F -> ( E ) | id\nInput: id + id * id'
    },
    {
      'title': 'Regex → NFA / NFA → DFA / Direct DFA / Minimization',
      'body': 'Enter a regular expression.\nSupported operators: | (union), * (Kleene star), concatenation (implicit)\nExample: (a|b)*abb'
    },
    {
      'title': 'Three Address Code / Code Optimization / Code Generation',
      'body': 'Enter an arithmetic expression.\nExample: x = b - c * 2\nOutput: TAC, Quadruples, Triples, Assembly'
    },
    {
      'title': 'SDD / SDT',
      'body': 'Enter an arithmetic expression.\nExample: 3 + 4 * 2\nSDD shows synthesized attribute values.\nSDT generates three-address code with semantic actions.'
    },
    {
      'title': 'Expression Translation',
      'body': 'Enter an expression to see Quadruples, Triples, Pointer to Triples, and Indirect Triples.\nExample: a + b * c'
    },
    {
      'title': 'Grammar Format',
      'body': '• Use -> to separate LHS from RHS\n• Use | to separate multiple productions\n• Use ε for epsilon (empty production)\n• Terminals: lowercase / symbols\n• Non-terminals: UPPERCASE'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help'), backgroundColor: const Color(0xFF1565C0), foregroundColor: Colors.white),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _entries.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (_, i) {
          final e = _entries[i];
          return ExpansionTile(
            leading: const Icon(Icons.help_outline, color: Color(0xFF1565C0)),
            title: Text(e['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(e['body']!, style: const TextStyle(height: 1.6)),
              ),
            ],
          );
        },
      ),
    );
  }
}
