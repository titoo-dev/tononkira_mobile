import 'package:equatable/equatable.dart';

/// Represents a section of lyrics, such as a couplet, refrain, etc.
class LyricsSection extends Equatable {
  final String type;
  final int? verseNumber;
  final List<String> content;

  const LyricsSection({
    required this.type,
    this.verseNumber,
    required this.content,
  });

  @override
  List<Object?> get props => [type, verseNumber, content];

  LyricsSection copyWith({
    String? type,
    int? verseNumber,
    List<String>? content,
  }) {
    return LyricsSection(
      type: type ?? this.type,
      verseNumber: verseNumber ?? this.verseNumber,
      content: content ?? this.content,
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'verseNumber': verseNumber, 'content': content};
  }

  factory LyricsSection.fromJson(Map<String, dynamic> json) {
    return LyricsSection(
      type: json['type'] as String,
      verseNumber: json['verseNumber'] as int?,
      content:
          (json['content'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }
}

/// Represents an analysis of lyrics broken down into sections
class LyricsAnalysis extends Equatable {
  final List<LyricsSection> content;

  const LyricsAnalysis({required this.content});

  @override
  List<Object?> get props => [content];

  LyricsAnalysis copyWith({List<LyricsSection>? content}) {
    return LyricsAnalysis(content: content ?? this.content);
  }

  Map<String, dynamic> toJson() {
    return {'content': content.map((section) => section.toJson()).toList()};
  }

  factory LyricsAnalysis.fromJson(Map<String, dynamic> json) {
    return LyricsAnalysis(
      content:
          (json['content'] as List<dynamic>)
              .map((e) => LyricsSection.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }
}
