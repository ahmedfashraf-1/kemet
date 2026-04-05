import 'dart:convert';

import '../../domain/entities/favorite.dart';

class FavoriteModel extends Favorite {
  FavoriteModel({
    required super.id,
    required super.location,
    required super.name 
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      id: json['id'],
      location: json['location'],
      name: json['name']
    );
  }

// msh m7tgenhaaa kefyaa slok katee3 p2a
  // Map<String, dynamic> toJson() {
  //   return {
  //     'id': id,
  //     'location': location
  //   };
  // }
}