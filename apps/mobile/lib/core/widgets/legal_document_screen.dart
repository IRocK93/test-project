import 'package:flutter/material.dart';
import 'package:baby_mon/core/constants/constants.dart';


class LegalDocumentScreen extends StatelessWidget {
  final String title;
  final String content;

  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _parseContent(context),
        ),
      ),
    );
  }

  List<Widget> _parseContent(BuildContext context) {
    final lines = content.split('\n');
    final widgets = <Widget>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Headers
      if (line.startsWith('## ')) {
        widgets.add(const SizedBox(height: 24));
        widgets.add(Text(
          line.substring(3).trim(),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 1.3),
        ));
        widgets.add(const SizedBox(height: 12));
      } else if (line.startsWith('### ')) {
        widgets.add(const SizedBox(height: 16));
        widgets.add(Text(
          line.substring(4).trim(),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.3),
        ));
        widgets.add(const SizedBox(height: 8));
      } else if (line.startsWith('---')) {
        widgets.add(const Divider(height: 24));
      } else if (line.startsWith('**') && line.contains(':**')) {
        // Bold label line
        widgets.add(const SizedBox(height: 8));
        widgets.add(RichText(
          text: _parseBoldText(line),
        ));
      } else if (line.startsWith('- ') || line.startsWith('  - ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(left: 8, top: 2, bottom: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontSize: 14)),
              Expanded(child: Text(line.replaceFirst(RegExp(r'^[\s]*[-•]\s*'), ''), style: const TextStyle(fontSize: 14, height: 1.5))),
            ],
          ),
        ));
      } else if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 6));
      } else {
        // Check if the line is ALL CAPS (a disclaimer)
        final isAllCaps = line == line.toUpperCase() && line.length > 20 && line.contains(RegExp(r'[A-Z]'));
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 4),
          child: Text(
            line,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              fontWeight: isAllCaps ? FontWeight.w700 : FontWeight.w400,
              color: isAllCaps ? context.colorScheme.error : null,
            ),
          ),
        ));
      }
    }
    return widgets;
  }

  TextSpan _parseBoldText(String line) {
    final parts = <TextSpan>[];
    final boldPattern = RegExp(r'\*\*(.+?)\*\*');
    final matches = boldPattern.allMatches(line);

    int lastEnd = 0;
    for (final match in matches) {
      if (match.start > lastEnd) {
        parts.add(TextSpan(text: line.substring(lastEnd, match.start)));
      }
      parts.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ));
      lastEnd = match.end;
    }
    if (lastEnd < line.length) {
      parts.add(TextSpan(text: line.substring(lastEnd)));
    }
    return TextSpan(style: const TextStyle(fontSize: 14, height: 1.5), children: parts);
  }
}
