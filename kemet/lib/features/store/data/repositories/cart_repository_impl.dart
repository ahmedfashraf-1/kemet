import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_category.dart';
import '../../domain/entities/product_photo.dart';
import '../../domain/repositories/cart_repository.dart';

/// Firestore structure:
/// carts/{userId}/items/{productId}  →  { ...productFields, quantity: int }
class CartRepositoryImpl implements CartRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  CartRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  // ── Helpers ────────────────────────────────────────────────────────────────

  String? get _userId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>> get _itemsRef {
    final uid = _userId;
    if (uid == null) throw Exception('User not logged in');
    return _firestore.collection('carts').doc(uid).collection('items');
  }

  CartItem _docToCartItem(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    final quantity = (data['quantity'] ?? 1) as int;

    final catData = data['category'] as Map<String, dynamic>? ?? {};
    final category = ProductCategory(
      categoryId: catData['category_id'] ?? '',
      categoryName: catData['category_name'] ?? '',
      categoryNameAr: catData['category_name_ar'] ?? null,
    );

    final photosList = data['photos'] as List<dynamic>? ?? [];
    final photos = photosList.map((e) {
      final m = e as Map<String, dynamic>;
      return ProductPhoto(photoId: m['photo_id'] ?? '', photoUrl: m['photo_url'] ?? '');
    }).toList();

    final product = Product(
      productId: doc.id,
      name: data['name'] ?? '',
      nameAr: data['name_ar'] ?? null,
      description: data['description'] ?? '',
      descriptionAr: data['description_ar'] ?? null,
      price: (data['price'] ?? 0).toDouble(),
      category: category,
      photos: photos,
      isAvailable: data['is_available'] ?? true,
      stock: (data['stock'] ?? 0) as int,
    );

    return CartItem(product: product, quantity: quantity);
  }

  Map<String, dynamic> _cartItemToDoc(Product product, int quantity) {
    return {
      'name': product.name,
      'name_ar': product.nameAr,
      'description': product.description,
      'description_ar': product.descriptionAr,
      'price': product.price,
      'is_available': product.isAvailable,
      'stock': product.stock,
      'category': {
        'category_id': product.category.categoryId,
        'category_name': product.category.categoryName,
        'category_name_ar': product.category.categoryNameAr,
      },
      'photos': product.photos
          .map((p) => {'photo_id': p.photoId, 'photo_url': p.photoUrl})
          .toList(),
      'quantity': quantity,
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  // ── CartRepository ─────────────────────────────────────────────────────────

  @override
  Future<Cart> getCart() async {
    if (_userId == null) return const Cart();
    final snapshot = await _itemsRef.orderBy('updated_at').get();
    final items = snapshot.docs.map(_docToCartItem).toList();
    return Cart(items: items);
  }

  @override
  Future<Cart> addToCart(Product product, int quantity) async {
    final docRef = _itemsRef.doc(product.productId);
    final existing = await docRef.get();

    if (existing.exists) {
      final currentQty = (existing.data()!['quantity'] ?? 0) as int;
      final newQty = (currentQty + quantity).clamp(1, product.stock);
      await docRef.update({
        'quantity': newQty,
        'updated_at': FieldValue.serverTimestamp(),
      });
    } else {
      await docRef.set(_cartItemToDoc(product, quantity.clamp(1, product.stock)));
    }

    return getCart();
  }

  @override
  Future<Cart> updateQuantity(String productId, int quantity) async {
    final docRef = _itemsRef.doc(productId);
    if (quantity <= 0) {
      await docRef.delete();
    } else {
      await docRef.update({
        'quantity': quantity,
        'updated_at': FieldValue.serverTimestamp(),
      });
    }
    return getCart();
  }

  @override
  Future<Cart> removeFromCart(String productId) async {
    await _itemsRef.doc(productId).delete();
    return getCart();
  }

  @override
  Future<void> clearCart() async {
    if (_userId == null) return;
    final batch = _firestore.batch();
    final snapshot = await _itemsRef.get();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}