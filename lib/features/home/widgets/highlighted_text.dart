import 'package:flutter/material.dart';

class HighlightedText extends StatelessWidget {
  final String text;
  final String highlight;
  final TextStyle style;
  final TextStyle highlightStyle;

  const HighlightedText({
    super.key,
    required this.text,
    required this.highlight,
    required this.style,
    required this.highlightStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (highlight.isEmpty ||
        !text.toLowerCase().contains(highlight.toLowerCase())) {
      return Text(text, style: style);
    }

    final matches = RegExp(highlight, caseSensitive: false).allMatches(text);
    final TextSpan span = TextSpan(
      children: _buildTextSpans(text, matches),
      style: style,
    );

    return RichText(text: span, maxLines: 1, overflow: TextOverflow.ellipsis);
  }

  List<TextSpan> _buildTextSpans(String text, Iterable<RegExpMatch> matches) {
    final List<TextSpan> spans = [];
    int lastMatchEnd = 0;

    for (final match in matches) {
      // Add text before match
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }

      // Add highlighted text
      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: highlightStyle,
        ),
      );

      lastMatchEnd = match.end;
    }

    // Add remaining text after last match
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    return spans;
  }
}
