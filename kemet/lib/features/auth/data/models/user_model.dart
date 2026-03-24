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
      id: json['user_id'],
      username: json['username'],
      email: json['email'],
      address: json['address'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  /// Convert Model → Map
  Map<String, dynamic> toJson() {
    return {
      'user_id': id,
      'username': username,
      'email': email,
      'address': address,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
