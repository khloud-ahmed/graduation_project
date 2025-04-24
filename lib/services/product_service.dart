import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addProduct(ProductModel product) async {
    // تحديد الزون تلقائيًا عند إضافة المنتج
    final now = DateTime.now();
    final difference = product.expiryDate.difference(now).inDays;
    String zone;

    if (difference > 180) {
      zone = 'safe';
    } else if (difference > 90) {
      zone = 'expiring';
    } else if (difference <= 0) {
      zone = 'expired';
    } else {
      zone = 'expiring';
    }

    final newProduct = product.copyWith(zone: zone);
    await _firestore.collection('products').add(newProduct.toMap());
  }

  Future<void> updateZone(String productId, String newZone) async {
    await _firestore.collection('products').doc(productId).update({
      'zone': newZone,
    });
  }

  Future<List<ProductModel>> getUserProducts(String userId) async {
    final snapshot = await _firestore
        .collection('products')
        .where('userId', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> autoUpdateZones() async {
    final now = DateTime.now();
    final snapshot = await _firestore.collection('products').get();

    for (var doc in snapshot.docs) {
      final product = ProductModel.fromMap(doc.data(), doc.id);
      final difference = product.expiryDate.difference(now).inDays;
      String newZone;

      if (difference > 180) {
        newZone = 'safe';
      } else if (difference > 90) {
        newZone = 'expiring';
      } else if (difference <= 0) {
        newZone = 'expired';
      } else {
        newZone = 'expiring';
      }

      if (newZone != product.zone) {
        await updateZone(product.id, newZone);
      }
    }
  }
}
