class User {
  final String token;
  final String userId;
  final String name;

  User({required this.token, required this.userId, required this.name});

  // Standard fromJson for local storage (flat structure)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      token: json['token'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
    );
  }

  // Factory for parsing API response (nested structure)
  factory User.fromApiResponse(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final user = data['user'] ?? {};

    return User(
      token: data['token'] ?? '',
      userId: (user['id'] ?? '').toString(),
      name: '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'token': token, 'userId': userId, 'name': name};
  }
}
