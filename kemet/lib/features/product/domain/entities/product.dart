import 'product_category.dart';
import 'product_photo.dart';

class Product {
  final String productId;
  final String name;
  final String description;
  final double price;
  final ProductCategory category;     
  final List<ProductPhoto> photos;    
  final DateTime createdAt;

  const Product({
    required this.productId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.photos,
    required this.createdAt,
  });
}