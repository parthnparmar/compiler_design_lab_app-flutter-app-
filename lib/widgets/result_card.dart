import 'package:flutter/material.dart';

class ResultCard extends StatelessWidget {
  final String title;
  final Widget child;
  const ResultCard({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1565C0))),
          const Divider(),
          child,
        ]),
      ),
    );
  }
}

class DataTable2 extends StatelessWidget {
  final List<String> columns;
  final List<List<String>> rows;
  const DataTable2({super.key, required this.columns, required this.rows});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(Colors.blue.shade50),
        dataRowMinHeight: 36,
        dataRowMaxHeight: 48,
        columnSpacing: 20,
        columns: columns.map((c) => DataColumn(
          label: Text(c, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        )).toList(),
        rows: rows.map((r) => DataRow(
          cells: r.map((c) => DataCell(
            Text(c, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
          )).toList(),
        )).toList(),
      ),
    );
  }
}

class LoadingButton extends StatelessWidget {
  final bool loading;
  final VoidCallback onPressed;
  final String label;
  const LoadingButton({super.key, required this.loading, required this.onPressed, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1565C0),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: loading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class MonoCard extends StatelessWidget {
  final String title;
  final List<String> lines;
  final Color? color;
  const MonoCard({super.key, required this.title, required this.lines, this.color});

  @override
  Widget build(BuildContext context) {
    return ResultCard(
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines.map((l) => Text(l, style: TextStyle(fontFamily: 'monospace', fontSize: 13, color: color ?? Colors.black87))).toList(),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final bool accepted;
  const StatusBadge({super.key, required this.accepted});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: accepted ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accepted ? Colors.green : Colors.red),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(accepted ? Icons.check_circle : Icons.cancel, color: accepted ? Colors.green : Colors.red),
        const SizedBox(width: 8),
        Text(accepted ? 'String Accepted ✓' : 'String Rejected ✗',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: accepted ? Colors.green.shade700 : Colors.red.shade700)),
      ]),
    );
  }
}
