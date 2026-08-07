class Album {
  final String id;
  final String artistId;
  final String title;
  final String? coverUrl;
  final String? releasedAt;

  Album({
    required this.id,
    required this.artistId,
    required this.title,
    this.coverUrl,
    this.releasedAt,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      id: json['id'] as String,
      artistId: json['artist_id'] as String,
      title: json['title'] as String,
      coverUrl: json['cover_url'] as String?,
      releasedAt: json['released_at'] as String?,
    );
  }
}
