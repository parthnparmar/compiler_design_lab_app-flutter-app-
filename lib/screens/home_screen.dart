import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'lexical_analyzer_screen.dart';
import 'll1_parser_screen.dart';
import 'slr_parser_screen.dart';
import 'clr_parser_screen.dart';
import 'lalr_parser_screen.dart';
import 'three_address_code_screen.dart';
import 'code_optimization_screen.dart';
import 'code_generation_screen.dart';
import 'regex_to_nfa_screen.dart';
import 'nfa_to_dfa_screen.dart';
import 'direct_dfa_screen.dart';
import 'dfa_minimization_screen.dart';
import 'sdd_screen.dart';
import 'sdt_screen.dart';
import 'expr_translation_screen.dart';
import 'about_screen.dart';
import 'help_screen.dart';
import 'compiler_phases_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const _tools = [
    {'title': 'Lexical Analyzer',   'icon': Icons.text_fields,    'color': Color(0xFF1565C0)},
    {'title': 'LL(1) Parser',       'icon': Icons.account_tree,   'color': Color(0xFF2E7D32)},
    {'title': 'SLR Parser',         'icon': Icons.schema,         'color': Color(0xFF6A1B9A)},
    {'title': 'CLR Parser',         'icon': Icons.device_hub,     'color': Color(0xFFE65100)},
    {'title': 'LALR Parser',        'icon': Icons.alt_route,      'color': Color(0xFF00695C)},
    {'title': 'Regex → NFA',        'icon': Icons.timeline,       'color': Color(0xFF00838F)},
    {'title': 'NFA → DFA',          'icon': Icons.merge_type,     'color': Color(0xFF1565C0)},
    {'title': 'Direct DFA',         'icon': Icons.auto_graph,     'color': Color(0xFF4A148C)},
    {'title': 'DFA Minimization',   'icon': Icons.compress,       'color': Color(0xFF880E4F)},
    {'title': 'Three Address Code', 'icon': Icons.code,           'color': Color(0xFFC62828)},
    {'title': 'Code Optimization',  'icon': Icons.speed,          'color': Color(0xFF4527A0)},
    {'title': 'Code Generation',    'icon': Icons.memory,         'color': Color(0xFF283593)},
    {'title': 'SDD',                'icon': Icons.calculate,      'color': Color(0xFF558B2F)},
    {'title': 'SDT',                'icon': Icons.transform,      'color': Color(0xFF4E342E)},
    {'title': 'Expr Translation',   'icon': Icons.swap_horiz,     'color': Color(0xFF37474F)},
    {'title': 'Compiler Phases',    'icon': Icons.layers,         'color': Color(0xFF0E639C)},
  ];

  Widget _screenFor(String title) {
    switch (title) {
      case 'Lexical Analyzer':   return const LexicalAnalyzerScreen();
      case 'LL(1) Parser':       return const LL1ParserScreen();
      case 'SLR Parser':         return const SLRParserScreen();
      case 'CLR Parser':         return const CLRParserScreen();
      case 'LALR Parser':        return const LALRParserScreen();
      case 'Regex → NFA':        return const RegexToNFAScreen();
      case 'NFA → DFA':          return const NfaToDfaScreen();
      case 'Direct DFA':         return const DirectDfaScreen();
      case 'DFA Minimization':   return const DfaMinimizationScreen();
      case 'Three Address Code': return const ThreeAddressCodeScreen();
      case 'Code Optimization':  return const CodeOptimizationScreen();
      case 'Code Generation':    return const CodeGenerationScreen();
      case 'SDD':                return const SDDScreen();
      case 'SDT':                return const SDTScreen();
      case 'Expr Translation':   return const ExprTranslationScreen();
      case 'Compiler Phases':     return const CompilerPhasesScreen();
      default:                   return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compiler Design Lab'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.help_outline), tooltip: 'Help',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpScreen()))),
          IconButton(icon: const Icon(Icons.info_outline), tooltip: 'About',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()))),
          IconButton(icon: const Icon(Icons.login), tooltip: 'Login',
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()))),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.1,
          ),
          itemCount: _tools.length,
          itemBuilder: (context, i) {
            final tool = _tools[i];
            final color = tool['color'] as Color;
            return InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => _screenFor(tool['title'] as String))),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: color.withAlpha(90)),
                ),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(tool['icon'] as IconData, size: 38, color: color),
                  const SizedBox(height: 10),
                  Text(tool['title'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
                ]),
              ),
            );
          },
        ),
      ),
    );
  }
}
