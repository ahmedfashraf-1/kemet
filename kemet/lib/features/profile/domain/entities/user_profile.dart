class User {
  final String id;
  final String username;
  final String email;
  final String? address;
  final String createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.address,
    required this.createdAt,
  });
}