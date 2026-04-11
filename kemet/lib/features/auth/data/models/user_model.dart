import '../../domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.username,
    required super.email,
    super.address,
    required super.createdAt,
  });

  /// Convert Map → Model
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['user_id'] ?? json['id'],
      username: json['fullName'] ?? json['username'] ?? '',
      email: json['email'] ?? '',
      address: json['address'],
      createdAt: DateTime.parse(
        json['created_at'] ?? json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  /// Convert Model → Map
  Map<String, dynamic> toJson() {
    return {
      'user_id': id,
      'username': username,
      'fullName': username,
      'email': email,
      'address': address,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
