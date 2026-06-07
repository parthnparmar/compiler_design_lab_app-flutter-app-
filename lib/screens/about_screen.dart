import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About'), backgroundColor: const Color(0xFF1565C0), foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Center(child: Icon(Icons.code, size: 72, color: Color(0xFF1565C0))),
          const SizedBox(height: 16),
          const Center(child: Text('Compiler Design Lab', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
          const Center(child: Text('v1.0.0', style: TextStyle(color: Colors.grey))),
          const SizedBox(height: 24),
          _section('About', 'A comprehensive tool for studying and visualizing compiler design concepts. All computations are performed by the Python backend.'),
          _section('Features', '• Lexical Analysis\n• LL(1) Parser with FIRST/FOLLOW\n• SLR / CLR / LALR Parsers\n• Regex to NFA / NFA to DFA\n• Direct DFA Construction\n• DFA Minimization\n• Three Address Code\n• Code Optimization\n• Code Generation (Assembly)\n• SDD / SDT Evaluation\n• Expression Translation'),
          _section('Tech Stack', 'Frontend: Flutter (Dart)\nBackend: Python Flask\nCommunication: REST API (JSON)'),
        ]),
      ),
    );
  }

  Widget _section(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1565C0))),
        const Divider(),
        Text(body, style: const TextStyle(height: 1.6)),
      ]),
    );
  }
}
