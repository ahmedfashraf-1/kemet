import 'package:kemet/features/profile/domain/entities/user_profile.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    required super.username,
    required super.email,
    super.address,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String docId) {
    return UserModel(
      id: docId,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      address: json['address'],
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'address': address,
      'created_at': createdAt,
    };
  }
}
