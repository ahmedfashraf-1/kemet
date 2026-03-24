import '../../domain/entities/product.dart';
import '../../domain/entities/product_category.dart';
import '../../domain/entities/product_photo.dart';

class ProductModel extends Product {
  ProductModel({
    required super.productId,
    required super.name,
    required super.description,
    required super.price,
    required super.category,
    required super.photos,
    required super.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      productId: json['product_id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),

      category: ProductCategory(
        categoryId: json['category']['category_id'],
        categoryName: json['category']['category_name'],
      ),

      photos: (json['photos'] as List? ?? [])
          .map((e) => ProductPhoto(
                photoId: e['photo_id'],
                productId: e['product_id'],
                photoUrl: e['photo_url'],
              ))
          .toList(),

      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'name': name,
      'description': description,
      'price': price,

      'category': {
        'category_id': category.categoryId,
        'category_name': category.categoryName,
      },

      'photos': photos
          .map((e) => {
                'photo_id': e.photoId,
                'product_id': e.productId,
                'photo_url': e.photoUrl,
              })
          .toList(),

      'created_at': createdAt.toIso8601String(),
    };
  }
}