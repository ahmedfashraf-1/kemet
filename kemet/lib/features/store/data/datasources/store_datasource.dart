import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

abstract class StoreDataSource {
  Future<List<ProductModel>> getProducts();
}

class StoreDataSourceImpl implements StoreDataSource { 
  final FirebaseFirestore firestore;

  StoreDataSourceImpl(this.firestore);

  @override
  Future<List<ProductModel>> getProducts() async {
    final snapshot = await firestore.collection('products').get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return ProductModel.fromJson(data, doc.id);
    }).toList();
  }
}