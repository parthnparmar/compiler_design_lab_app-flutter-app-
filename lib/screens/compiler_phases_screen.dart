import 'package:flutter/material.dart';

// ── same logic as compiler_phases.html JS ──────────────────────────────────

const _kwMap = {
  'c':          ['int','float','char','void','return','if','else','while','for','main'],
  'cpp':        ['int','float','char','void','return','if','else','while','for','class','public','private'],
  'java':       ['public','class','static','void','int','float','return','if','else','while','for','String'],
  'python':     ['def','return','if','else','while','for','class','import','from'],
  'csharp':     ['class','static','void','int','float','return','if','else','while','for','public','private'],
  'javascript': ['function','let','const','var','return','if','else','while','for','class'],
};

const _examples = {
  'c': 'int main() {\n    int x = 10;\n    int y = 20;\n    int sum = x + y;\n    return 0;\n}',
  'cpp': 'int main() {\n    int x = 10;\n    int y = 20;\n    int sum = x + y;\n    return 0;\n}',
  'java': 'public class Main {\n    public static void main(String[] args) {\n        int x = 10;\n        int y = 20;\n        int sum = x + y;\n    }\n}',
  'python': 'def main():\n    x = 10\n    y = 20\n    sum_val = x + y\n    return sum_val',
  'csharp': 'class Program {\n    static void Main() {\n        int x = 10;\n        int y = 20;\n        int sum = x + y;\n    }\n}',
  'javascript': 'function main() {\n    let x = 10;\n    let y = 20;\n    let sum = x + y;\n    return sum;\n}',
};

// ── Token model ─────────────────────────────────────────────────────────────
class Token {
  final String type, value;
  const Token(this.type, this.value);
}

// ── Phase 1: Lexical Analysis ────────────────────────────────────────────────
List<Token> _lexicalAnalysis(String code, String lang) {
  final kw = _kwMap[lang] ?? _kwMap['c']!;
  final pattern = RegExp(
    r'[a-zA-Z_]\w*|\d+(?:\.\d+)?|[+\-*\/=<>!]=?|[(){}\[\];,.]|"[^"]*"',
  );
  final tokens = <Token>[];
  for (final m in pattern.allMatches(code)) {
    final v = m.group(0)!;
    String t;
    if (kw.contains(v))                             t = 'KEYWORD';
    else if (RegExp(r'^\d+(\.\d+)?$').hasMatch(v)) t = 'NUMBER';
    else if (RegExp(r'^[a-zA-Z_]\w*$').hasMatch(v))t = 'IDENTIFIER';
    else if (['+','-','*','/','=','<','>','!','==','!=','<=','>='].contains(v)) t = 'OPERATOR';
    else                                             t = 'SYMBOL';
    tokens.add(Token(t, v));
  }
  return tokens;
}

// ── Phase 2: Syntax Analysis (simple AST) ───────────────────────────────────
class AstNode {
  final String node;
  final String? dtype, value;
  final List<AstNode> children;
  AstNode(this.node, {this.dtype, this.value, List<AstNode>? children})
      : children = children ?? [];
}

List<AstNode> _syntaxAnalysis(List<Token> tokens) {
  final nodes = <AstNode>[];
  int i = 0;
  while (i < tokens.length) {
    final tok = tokens[i];
    if (tok.type == 'KEYWORD' &&
        ['int','float','char','let','const','var','def'].contains(tok.value)) {
      final node = AstNode('Declaration', dtype: tok.value);
      i++;
      if (i < tokens.length && tokens[i].type == 'IDENTIFIER') {
        node.children.add(AstNode('Identifier', value: tokens[i].value));
        i++;
        if (i < tokens.length && tokens[i].value == '=') {
          i++;
          if (i < tokens.length) {
            node.children.add(AstNode('Value', value: tokens[i].value));
            i++;
          }
        }
      }
      nodes.add(node);
    } else if (tok.type == 'IDENTIFIER') {
      final node = AstNode('Expression',
          children: [AstNode('Identifier', value: tok.value)]);
      i++;
      if (i < tokens.length && tokens[i].type == 'OPERATOR') {
        node.children.add(AstNode('Operator', value: tokens[i].value));
        i++;
        if (i < tokens.length) {
          node.children.add(AstNode(tokens[i].type, value: tokens[i].value));
          i++;
        }
      }
      nodes.add(node);
    } else {
      i++;
    }
  }
  return nodes;
}

// ── Phase 3: Semantic Analysis ───────────────────────────────────────────────
Map<String, dynamic> _semanticAnalysis(List<AstNode> ast) {
  final table = <Map<String, String>>[];
  final errors = <String>[];
  final seen = <String>{};
  for (final node in ast) {
    if (node.node == 'Declaration') {
      final ids = node.children.where((c) => c.node == 'Identifier').toList();
      if (ids.isNotEmpty) {
        final name = ids[0].value!;
        if (seen.contains(name)) {
          errors.add("Variable '$name' already declared");
        } else {
          seen.add(name);
          table.add({'Name': name, 'Type': node.dtype ?? '?', 'Scope': 'local'});
        }
      }
    }
  }
  return {'table': table, 'errors': errors};
}

// ── Phase 4: Intermediate Code (TAC) ────────────────────────────────────────
List<String> _intermediateCode(List<AstNode> ast) {
  final tac = <String>[];
  int tc = 0;
  for (final node in ast) {
    if (node.node == 'Declaration') {
      final ids  = node.children.where((c) => c.node == 'Identifier').toList();
      final vals = node.children.where((c) => c.node == 'Value').toList();
      if (ids.isNotEmpty && vals.isNotEmpty) {
        tac.add('${ids[0].value} = ${vals[0].value}');
      }
    } else if (node.node == 'Expression') {
      final parts = node.children.map((c) => c.value ?? '').toList();
      if (parts.length == 3) {
        tac.add('t${++tc} = ${parts[0]} ${parts[1]} ${parts[2]}');
      }
    }
  }
  return tac;
}

// ── Phase 5: Code Optimization ───────────────────────────────────────────────
List<Map<String, String>> _optimize(List<String> tac) {
  final result = <Map<String, String>>[];
  final consts = <String, int>{};
  final assignRe = RegExp(r'^(\w+) = (\d+)$');
  final exprRe   = RegExp(r'^(\w+) = (\w+) ([+\-*/]) (\w+)$');
  for (final line in tac) {
    final m1 = assignRe.firstMatch(line);
    if (m1 != null) {
      consts[m1.group(1)!] = int.parse(m1.group(2)!);
      result.add({'Original': line, 'Optimized': line, 'Technique': 'No change'});
      continue;
    }
    final m2 = exprRe.firstMatch(line);
    if (m2 != null) {
      final res = m2.group(1)!, a = m2.group(2)!, op = m2.group(3)!, b = m2.group(4)!;
      if (consts.containsKey(a) && consts.containsKey(b)) {
        final ca = consts[a]!, cb = consts[b]!;
        final v = op == '+' ? ca + cb : op == '-' ? ca - cb :
                  op == '*' ? ca * cb : cb != 0 ? ca ~/ cb : 0;
        result.add({'Original': line, 'Optimized': '$res = $v', 'Technique': 'Constant Folding'});
        consts[res] = v;
      } else {
        result.add({'Original': line, 'Optimized': line, 'Technique': 'No change'});
      }
    } else {
      result.add({'Original': line, 'Optimized': line, 'Technique': 'No change'});
    }
  }
  return result;
}

// ── Phase 6: Code Generation (Assembly) ─────────────────────────────────────
List<String> _codeGen(List<Map<String, String>> optimized) {
  final asm = <String>[];
  final re = RegExp(r'^(\w+) = (\w+|\d+)(?: ([+\-*/]) (\w+|\d+))?$');
  for (final opt in optimized) {
    final m = re.firstMatch(opt['Optimized']!);
    if (m == null) continue;
    final dest = m.group(1)!, src1 = m.group(2)!, op = m.group(3), src2 = m.group(4);
    if (op == null) {
      asm.add('MOV $dest, $src1');
    } else {
      asm.add('MOV EAX, $src1');
      if (op == '+')      asm.add('ADD EAX, $src2');
      else if (op == '-') asm.add('SUB EAX, $src2');
      else if (op == '*') asm.add('MUL EAX, $src2');
      else if (op == '/') asm.add('DIV EAX, $src2');
      asm.add('MOV $dest, EAX');
    }
  }
  return asm;
}

// ── Screen ───────────────────────────────────────────────────────────────────
class CompilerPhasesScreen extends StatefulWidget {
  const CompilerPhasesScreen({super.key});
  @override
  State<CompilerPhasesScreen> createState() => _State();
}

class _State extends State<CompilerPhasesScreen> {
  String _lang = 'c';
  late TextEditingController _codeCtrl;
  bool _ran = false;

  // results
  List<Token> _tokens = [];
  List<AstNode> _ast = [];
  Map<String, dynamic> _semantics = {};
  List<String> _tac = [];
  List<Map<String, String>> _optimized = [];
  List<String> _assembly = [];

  @override
  void initState() {
    super.initState();
    _codeCtrl = TextEditingController(text: _examples[_lang]);
  }

  void _run() {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) return;
    final tokens   = _lexicalAnalysis(code, _lang);
    final ast      = _syntaxAnalysis(tokens);
    final sem      = _semanticAnalysis(ast);
    final tac      = _intermediateCode(ast);
    final opt      = _optimize(tac);
    final asm      = _codeGen(opt);
    setState(() {
      _tokens = tokens; _ast = ast; _semantics = sem;
      _tac = tac; _optimized = opt; _assembly = asm; _ran = true;
    });
  }

  Color get _appColor => const Color(0xFF0E639C);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text('Compiler Phases Visualizer'),
        backgroundColor: const Color(0xFF2D2D30),
        foregroundColor: Colors.white,
      ),
      body: Column(children: [
        // ── Controls bar ──
        Container(
          color: const Color(0xFF2D2D30),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(children: [
            const Text('Language:', style: TextStyle(color: Colors.white70)),
            const SizedBox(width: 8),
            DropdownButton<String>(
              value: _lang,
              dropdownColor: const Color(0xFF3C3C3C),
              style: const TextStyle(color: Colors.white),
              items: _kwMap.keys.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
              onChanged: (v) {
                setState(() { _lang = v!; _codeCtrl.text = _examples[_lang]!; _ran = false; });
              },
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _run,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Run Compiler'),
              style: ElevatedButton.styleFrom(backgroundColor: _appColor, foregroundColor: Colors.white),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => setState(() => _ran = false),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.white70),
              child: const Text('Clear'),
            ),
          ]),
        ),
        // ── Body ──
        Expanded(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Left: code editor
            Expanded(
              flex: 1,
              child: Column(children: [
                Container(color: const Color(0xFF2D2D30), width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    child: const Text('Source Code Editor', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                Expanded(
                  child: TextField(
                    controller: _codeCtrl,
                    maxLines: null,
                    expands: true,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 13, color: Color(0xFFD4D4D4)),
                    decoration: const InputDecoration(
                      filled: true, fillColor: Color(0xFF1E1E1E),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                    ),
                  ),
                ),
              ]),
            ),
            // Right: results
            if (_ran) Expanded(
              flex: 2,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(10),
                child: Column(children: [
                  _phaseCard('Phase 1: Lexical Analysis (Scanner)', _buildTokens()),
                  _phaseCard('Phase 2: Syntax Analysis (AST)', _buildAST()),
                  _phaseCard('Phase 3: Semantic Analysis', _buildSemantics()),
                  _phaseCard('Phase 4: Intermediate Code Generation (TAC)', _buildTAC()),
                  _phaseCard('Phase 5: Code Optimization', _buildOptimized()),
                  _phaseCard('Phase 6: Code Generation (Assembly)', _buildAssembly()),
                ]),
              ),
            ) else Expanded(
              flex: 2,
              child: Center(
                child: Text('Press ▶ Run Compiler to see all 6 phases',
                    style: TextStyle(color: Colors.white38, fontSize: 16)),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _phaseCard(String title, Widget content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: const Color(0xFF252526), borderRadius: BorderRadius.circular(5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: Color(0xFF2D2D30),
            border: Border(bottom: BorderSide(color: Color(0xFF0E639C), width: 2)),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(5), topRight: Radius.circular(5)),
          ),
          child: Text(title, style: const TextStyle(color: Color(0xFF4EC9B0), fontWeight: FontWeight.bold)),
        ),
        Padding(padding: const EdgeInsets.all(10), child: content),
      ]),
    );
  }

  Widget _buildTokens() {
    return Wrap(spacing: 6, runSpacing: 6, children: _tokens.map((t) {
      final color = switch (t.type) {
        'KEYWORD'    => const Color(0xFF569CD6),
        'IDENTIFIER' => const Color(0xFF4EC9B0),
        'NUMBER'     => const Color(0xFFB5CEA8),
        'OPERATOR'   => const Color(0xFFD4D4D4),
        _            => const Color(0xFFCE9178),
      };
      final tc = t.type == 'NUMBER' ? Colors.black : Colors.white;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        child: Text('${t.value} (${t.type})', style: TextStyle(color: tc, fontSize: 12, fontFamily: 'monospace')),
      );
    }).toList());
  }

  Widget _buildAST() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: _ast.map((n) => _astNode(n, 0)).toList());
  }

  Widget _astNode(AstNode n, int depth) {
    final label = '${n.node}${n.dtype != null ? ' (${n.dtype})' : ''}${n.value != null ? ': ${n.value}' : ''}';
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: EdgeInsets.only(left: depth * 20.0),
        child: Text('${depth > 0 ? '├─ ' : ''}$label',
            style: const TextStyle(color: Color(0xFFDCDCAA), fontFamily: 'monospace', fontSize: 13)),
      ),
      ...n.children.map((c) => _astNode(c, depth + 1)),
    ]);
  }

  Widget _buildSemantics() {
    final table = (_semantics['table'] as List<Map<String, String>>?) ?? [];
    final errors = (_semantics['errors'] as List<String>?) ?? [];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Symbol Table:', style: TextStyle(color: Color(0xFF4EC9B0), fontWeight: FontWeight.bold)),
      const SizedBox(height: 6),
      if (table.isNotEmpty) _darkTable(['Name', 'Type', 'Scope'],
          table.map((r) => [r['Name']!, r['Type']!, r['Scope']!]).toList()),
      if (errors.isNotEmpty) ...errors.map((e) =>
          Text('✗ $e', style: const TextStyle(color: Color(0xFFF48771), fontFamily: 'monospace', fontSize: 13))),
      if (errors.isEmpty) const Text('✓ No semantic errors',
          style: TextStyle(color: Color(0xFF4EC9B0), fontFamily: 'monospace', fontSize: 13)),
    ]);
  }

  Widget _buildTAC() {
    if (_tac.isEmpty) return const Text('No TAC generated', style: TextStyle(color: Colors.white54));
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: _tac.asMap().entries.map((e) =>
            Text('${e.key + 1}.  ${e.value}',
                style: const TextStyle(color: Color(0xFFD4D4D4), fontFamily: 'monospace', fontSize: 13))).toList());
  }

  Widget _buildOptimized() {
    return _darkTable(['Original', 'Optimized', 'Technique'],
        _optimized.map((o) => [o['Original']!, o['Optimized']!, o['Technique']!]).toList());
  }

  Widget _buildAssembly() {
    if (_assembly.isEmpty) return const Text('No assembly generated', style: TextStyle(color: Colors.white54));
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: _assembly.asMap().entries.map((e) =>
            Text('${e.key + 1}.  ${e.value}',
                style: const TextStyle(color: Color(0xFF9CDCFE), fontFamily: 'monospace', fontSize: 13))).toList());
  }

  Widget _darkTable(List<String> cols, List<List<String>> rows) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        defaultColumnWidth: const IntrinsicColumnWidth(),
        border: TableBorder.all(color: const Color(0xFF3C3C3C)),
        children: [
          TableRow(
            decoration: const BoxDecoration(color: Color(0xFF2D2D30)),
            children: cols.map((c) => Padding(
              padding: const EdgeInsets.all(8),
              child: Text(c, style: const TextStyle(color: Color(0xFF4EC9B0), fontWeight: FontWeight.bold, fontFamily: 'monospace', fontSize: 12)),
            )).toList(),
          ),
          ...rows.map((r) => TableRow(
            children: r.map((cell) => Padding(
              padding: const EdgeInsets.all(8),
              child: Text(cell, style: const TextStyle(color: Color(0xFFD4D4D4), fontFamily: 'monospace', fontSize: 12)),
            )).toList(),
          )),
        ],
      ),
    );
  }
}
