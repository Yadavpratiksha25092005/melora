class User {
  final String id;
  final String email;
  final String username;
  final String? avatarUrl;
  final String? phone;

  User({
    required this.id,
    required this.email,
    required this.username,
    this.avatarUrl,
    this.phone,
  });

  factory User.fromJson(Map<String, dynamic> json) {
  return User(
    id: json['id'] as String,
    email: (json['email'] as String?) ?? '',
    username: (json['username'] as String?) ??
        (json['name'] as String?) ??
        (json['phone_number'] as String?) ??
        (json['phone'] as String?) ??
        'User',
    avatarUrl: json['avatar_url'] as String?,
    phone: (json['phone'] as String?) ?? (json['phone_number'] as String?),
  );
}

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'username': username,
        'avatar_url': avatarUrl,
        'phone': phone,
      };

  User copyWith({
    String? id,
    String? email,
    String? username,
    String? avatarUrl,
    String? phone,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
    );
  }
}