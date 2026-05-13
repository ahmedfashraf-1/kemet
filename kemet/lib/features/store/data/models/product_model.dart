import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_category.dart';
import '../../domain/entities/product_photo.dart';

class ProductModel extends Product {
  ProductModel({
    required super.productId,
    required super.name,
    super.nameAr,
    required super.description,
    super.descriptionAr,
    required super.price,
    required super.category,
    required super.photos,
    required super.isAvailable,
    required super.stock,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json, String id) {
    final categoryData = json['category'];
    final category = ProductCategory(
      categoryId: (categoryData is Map) ? (categoryData['category_id'] ?? '') : '',
      categoryName: (categoryData is Map) ? (categoryData['category_name'] ?? 'General') : 'General',
      categoryNameAr: (categoryData is Map) ? categoryData['category_name_ar']?.toString() : null,
    );
    final photosList = json['photos'] as List? ?? [];
    final photos = photosList.map((e) {
      if (e is Map) {
        return ProductPhoto(
          photoId: e['photo_id'] ?? '',
          photoUrl: e['photo_url'] ?? '',
        );
      }
      return const ProductPhoto(photoId: '', photoUrl: '');
    }).toList();

    return ProductModel(
      productId: id,
      name: json['name']?.toString() ?? 'No Name',
      nameAr: json['name_ar']?.toString(),
      description: json['description']?.toString() ?? '',
      descriptionAr: json['description_ar']?.toString(),

      price: json['price'] is String 
    ? double.parse(json['price']) 
    : (json['price'] ?? 0).toDouble(),
      isAvailable: json['is_available'] ?? true,
      stock: json['stock'] is int
    ? json['stock']
    : int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
      category: category,
      photos: photos,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'name_ar': nameAr,
      'description': description,
      'description_ar': descriptionAr,
      'price': price,
      'is_available': isAvailable,
      'stock': stock,
      'category': {
        'category_id': category.categoryId,
        'category_name': category.categoryName,
        'category_name_ar': category.categoryNameAr,
      },
      'photos': photos
          .map((e) => {'photo_id': e.photoId, 'photo_url': e.photoUrl})
          .toList(),
    };
  }
}