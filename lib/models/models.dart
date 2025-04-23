// File: models.dart
// Dart models generated from Prisma schema

import 'package:equatable/equatable.dart';

/// Represents an artist who creates songs
class Artist extends Equatable {
  final int id;
  final String name;
  final String? bio;
  final String? url;
  final String slug;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Song> songs;

  const Artist({
    required this.id,
    required this.name,
    this.bio,
    this.url,
    required this.slug,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.songs = const [],
  });

  @override
  List<Object?> get props => [
    id,
    name,
    bio,
    url,
    slug,
    imageUrl,
    createdAt,
    updatedAt,
  ];

  Artist copyWith({
    int? id,
    String? name,
    String? bio,
    String? url,
    String? slug,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Song>? songs,
  }) {
    return Artist(
      id: id ?? this.id,
      name: name ?? this.name,
      bio: bio ?? this.bio,
      url: url ?? this.url,
      slug: slug ?? this.slug,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      songs: songs ?? this.songs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bio': bio,
      'url': url,
      'slug': slug,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'] as int,
      name: json['name'] as String,
      bio: json['bio'] as String?,
      url: json['url'] as String?,
      slug: json['slug'] as String,
      imageUrl: json['imageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      songs:
          (json['songs'] as List<dynamic>?)
              ?.map((e) => Song.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Represents a song with its metadata and lyrics
class Song extends Equatable {
  final int id;
  final String title;
  final String slug;
  final int? trackNumber;
  final int? views;
  final int? lyricId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Lyric? lyric;
  final List<Artist> artists;

  const Song({
    required this.id,
    required this.title,
    required this.slug,
    this.trackNumber,
    this.views = 0,
    this.lyricId,
    required this.createdAt,
    required this.updatedAt,
    this.lyric,
    this.artists = const [],
  });

  @override
  List<Object?> get props => [
    id,
    title,
    slug,
    trackNumber,
    views,
    lyricId,
    createdAt,
    updatedAt,
  ];

  Song copyWith({
    int? id,
    String? title,
    String? slug,
    int? trackNumber,
    int? views,
    int? lyricId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Lyric? lyric,
    List<Artist>? artists,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      trackNumber: trackNumber ?? this.trackNumber,
      views: views ?? this.views,
      lyricId: lyricId ?? this.lyricId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lyric: lyric ?? this.lyric,
      artists: artists ?? this.artists,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'trackNumber': trackNumber,
      'views': views,
      'lyricId': lyricId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as int,
      title: json['title'] as String,
      slug: json['slug'] as String,
      trackNumber: json['trackNumber'] as int?,
      views: json['views'] as int?,
      lyricId: json['lyricId'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      lyric:
          json['lyric'] != null
              ? Lyric.fromJson(json['lyric'] as Map<String, dynamic>)
              : null,
      artists:
          (json['artists'] as List<dynamic>?)
              ?.map((e) => Artist.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Represents a liked song entry for a specific user
class LikedSong extends Equatable {
  final int id;
  final String userId;
  final int songId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LikedSong({
    required this.id,
    required this.userId,
    required this.songId,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, userId, songId, createdAt, updatedAt];

  LikedSong copyWith({
    int? id,
    String? userId,
    int? songId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LikedSong(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      songId: songId ?? this.songId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'songId': songId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory LikedSong.fromJson(Map<String, dynamic> json) {
    return LikedSong(
      id: json['id'] as int,
      userId: json['userId'] as String,
      songId: json['songId'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// Represents lyrics for a song with content and metadata
class Lyric extends Equatable {
  final int id;
  final String content;
  final String? contentText;
  final String url;
  final String language;
  final String createdBy;
  final bool isSynced;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Lyric({
    required this.id,
    required this.content,
    this.contentText,
    required this.url,
    required this.language,
    required this.createdBy,
    required this.isSynced,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    content,
    contentText,
    url,
    language,
    createdBy,
    isSynced,
    createdAt,
    updatedAt,
  ];

  Lyric copyWith({
    int? id,
    String? content,
    String? contentText,
    String? url,
    String? language,
    String? createdBy,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Lyric(
      id: id ?? this.id,
      content: content ?? this.content,
      contentText: contentText ?? this.contentText,
      url: url ?? this.url,
      language: language ?? this.language,
      createdBy: createdBy ?? this.createdBy,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'contentText': contentText,
      'url': url,
      'language': language,
      'createdBy': createdBy,
      'isSynced': isSynced,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Lyric.fromJson(Map<String, dynamic> json) {
    return Lyric(
      id: json['id'] as int,
      content: json['content'] as String,
      contentText: json['contentText'] as String?,
      url: json['url'] as String,
      language: json['language'] as String,
      createdBy: json['createdBy'] as String,
      isSynced: json['isSynced'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
