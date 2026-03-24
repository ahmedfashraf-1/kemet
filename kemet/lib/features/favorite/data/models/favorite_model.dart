import '../../domain/entities/favorite.dart';

class FavoriteModel extends Favorite {
  FavoriteModel({
    required super.id,
    required super.userId,
    required super.productIds,
    required super.createdAt, 
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id'],
      userId: json['user_id'],
      productIds: json['products'] != null
          ? List<String>.from(json['products'])
          : [],
      createdAt: DateTime.parse(json['created_at']), 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'products': productIds,
      'created_at': createdAt.toIso8601String(), 
    };
  }
}