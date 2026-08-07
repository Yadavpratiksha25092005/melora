class Artist {
  final String id;
  final String name;
  final String? bio;
  final String? imageUrl;

  Artist({required this.id, required this.name, this.bio, this.imageUrl});

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(
      id: json['id'] as String,
      name: json['name'] as String,
      bio: json['bio'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }
}
