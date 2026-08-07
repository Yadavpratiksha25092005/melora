import 'song.dart';

class Playlist {
  final String id;
  final String userId;
  final String name;
  final String? coverUrl;
  final bool isPublic;
  final List<Song> songs;

  Playlist({
    required this.id,
    required this.userId,
    required this.name,
    this.coverUrl,
    this.isPublic = true,
    this.songs = const [],
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      coverUrl: json['cover_url'] as String?,
      isPublic: json['is_public'] as bool? ?? true,
      songs: (json['songs'] as List<dynamic>? ?? [])
          .map((s) => Song.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}
