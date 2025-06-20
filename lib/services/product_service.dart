import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔁 حساب حالة المنتج (zone) حسب تاريخ الصلاحية
  String _calculateZone(DateTime expiryDate) {
    final now = DateTime.now();
    final difference = expiryDate.difference(now).inDays;

    if (difference > 180) return 'safe';
    if (difference > 30) return 'expiring';
    if (difference <= 0) return 'expired';
    return 'expiring';
  }

  /// ✅ إضافة منتج جديد
  Future<void> addProduct(ProductModel product) async {
    try {
      final zone = _calculateZone(product.expiryDate);
      final newProduct = product.copyWith(zone: zone);

      await _firestore.collection('products').add(newProduct.toMap());
    } catch (e) {
      print('❌ [addProduct] Error: $e');
    }
  }

  /// ✅ تحديث الزون لمنتج معين
  Future<void> updateZone(String productId, String newZone) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'zone': newZone,
      });
    } catch (e) {
      print('❌ [updateZone] Error: $e');
    }
  }

  /// ✅ جلب كل منتجات يوزر معين
  Future<List<ProductModel>> getUserProducts(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('❌ [getUserProducts] Error: $e');
      return [];
    }
  }

  /// ✅ تحديث تلقائي لحالة المنتجات (zone)
  Future<void> autoUpdateZones() async {
    try {
      final snapshot = await _firestore.collection('products').get();

      for (var doc in snapshot.docs) {
        final product = ProductModel.fromMap(doc.data(), doc.id);
        final updatedZone = _calculateZone(product.expiryDate);

        if (updatedZone != product.zone) {
          await updateZone(product.id, updatedZone);
        }
      }

      print('✅ Zones updated automatically.');
    } catch (e) {
      print('❌ [autoUpdateZones] Error: $e');
    }
  }
}
