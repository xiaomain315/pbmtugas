class User {
  final int id;
  final String name;
  final String username;
  final String token;

  User({
    required this.id,
    required this.name,
    required this.username,
    required this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return User(
      id: data['user']['id'],
      name: data['user']['name'],
      username: data['user']['username'],
      token: data['token'],
    );
  }
}