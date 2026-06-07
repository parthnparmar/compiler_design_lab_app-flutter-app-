import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'result_card.dart';

class SvgDiagramCard extends StatelessWidget {
  final String title;
  final String? svgData;

  const SvgDiagramCard({super.key, required this.title, this.svgData});

  @override
  Widget build(BuildContext context) {
    if (svgData == null || svgData!.isEmpty) return const SizedBox.shrink();

    // Strip XML declaration if present — flutter_svg needs clean SVG
    final cleanSvg = svgData!.contains('<svg')
        ? svgData!.substring(svgData!.indexOf('<svg'))
        : svgData!;

    return ResultCard(
      title: title,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: MediaQuery.of(context).size.width - 56,
            maxWidth: 1800,
          ),
          child: SvgPicture.string(
            cleanSvg,
            fit: BoxFit.contain,
            placeholderBuilder: (_) => const Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    );
  }
}
