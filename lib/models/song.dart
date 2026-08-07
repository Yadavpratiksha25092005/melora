import '../core/constants/app_constants.dart';

class Song {
  final String id;
  final String? albumId;
  final String artistId;
  final String title;
  final int durationMs;
  final String fileUrl;
  final String? coverUrl;
  final String? genre;
  final String? lyrics;
  final String? artistName;
  final String? youtubeVideoId;
  final String? youtubeSearchQuery;

  Song({
    required this.id,
    this.albumId,
    required this.artistId,
    required this.title,
    required this.durationMs,
    required this.fileUrl,
    this.coverUrl,
    this.genre,
    this.lyrics,
    this.artistName,
    this.youtubeVideoId,
    this.youtubeSearchQuery,
  });

  /// mm:ss display string, e.g. "3:45"
  String get formattedDuration {
    final totalSeconds = durationMs ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as String,
      albumId: json['album_id'] as String?,
      artistId: json['artist_id'] as String,
      title: json['title'] as String,
      durationMs: json['duration_ms'] as int? ?? 0,
      fileUrl: json['file_url'] as String,
      coverUrl: json['cover_url'] as String?,
      genre: json['genre'] as String?,
      lyrics: json['lyrics'] as String?,
      artistName: json['artist_name'] as String?,
      youtubeVideoId: json['youtube_video_id'] as String?,
      youtubeSearchQuery: json['youtube_search_query'] as String?,
    );
  }

  /// Maps Audius's track JSON onto our existing Song model. Audius often
  /// includes a ready-to-play `stream.url`; when it's missing, we fall
  /// back to constructing the standard stream endpoint from the track id.
  factory Song.fromAudiusJson(Map<String, dynamic> json) {
    final durationSeconds = (json['duration'] as num?)?.toInt() ?? 0;
    final id = json['id']?.toString() ?? '';
    final streamUrl = (json['stream'] as Map<String, dynamic>?)?['url'] as String?;
    final artwork = json['artwork'] as Map<String, dynamic>?;
    final coverUrl = artwork?['480x480'] as String? ??
        artwork?['150x150'] as String? ??
        artwork?['1000x1000'] as String?;

    return Song(
      id: id,
      albumId: null, // Audius uses playlists, not albums
      artistId: json['user_id']?.toString() ?? '',
      title: json['title'] as String? ?? 'Unknown Title',
      durationMs: durationSeconds * 1000,
      fileUrl: streamUrl ??
          '${AppConstants.audiusBaseUrl}/tracks/$id/stream?app_name=${AppConstants.audiusAppName}',
      coverUrl: coverUrl,
      genre: json['genre'] as String?,
    );
  }

  Song copyWith({
    String? id,
    String? albumId,
    String? artistId,
    String? title,
    int? durationMs,
    String? fileUrl,
    String? coverUrl,
    String? genre,
    String? lyrics,
    String? artistName,
    String? youtubeVideoId,
    String? youtubeSearchQuery,
  }) {
    return Song(
      id: id ?? this.id,
      albumId: albumId ?? this.albumId,
      artistId: artistId ?? this.artistId,
      title: title ?? this.title,
      durationMs: durationMs ?? this.durationMs,
      fileUrl: fileUrl ?? this.fileUrl,
      coverUrl: coverUrl ?? this.coverUrl,
      genre: genre ?? this.genre,
      lyrics: lyrics ?? this.lyrics,
      artistName: artistName ?? this.artistName,
      youtubeVideoId: youtubeVideoId ?? this.youtubeVideoId,
      youtubeSearchQuery: youtubeSearchQuery ?? this.youtubeSearchQuery,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'album_id': albumId,
        'artist_id': artistId,
        'title': title,
        'duration_ms': durationMs,
        'file_url': fileUrl,
        'cover_url': coverUrl,
        'genre': genre,
        'lyrics': lyrics,
        'artist_name': artistName,
        'youtube_video_id': youtubeVideoId,
        'youtube_search_query': youtubeSearchQuery,
      };
}