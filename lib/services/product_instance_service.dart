import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_instance_model.dart';

class ProductInstanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔁 دالة لحساب حالة الصلاحية
  String _calculateExpirationStatus(DateTime expirationDate) {
    final now = DateTime.now();
    final diff = expirationDate.difference(now).inDays;

    if (diff > 180) return 'safe';
    if (diff > 30) return 'expiring';
    if (diff <= 0) return 'expired';
    return 'expiring';
  }

  /// ✅ إضافة نسخة من المنتج (instance)
  Future<void> addInstance(ProductInstanceModel instance) async {
    final productDoc = await _firestore.collection('products').doc(instance.productId).get();

    if (!productDoc.exists) {
      throw Exception('Product not found');
    }

    final productData = productDoc.data();
    final productName = productData?['name'] ?? 'Unknown';
    final category = productData?['category'] ?? 'Unknown';

    final docRef = _firestore.collection('product_instance').doc();
    final expirationStatus = _calculateExpirationStatus(instance.expirationDate);

    final newInstance = ProductInstanceModel(
      id: docRef.id,
      instanceId: docRef.id, // ✅ بدل UUID
      userId: instance.userId,
      productId: instance.productId,
      productName: productName,
      addedDate: instance.addedDate,
      expirationDate: instance.expirationDate,
      quantity: instance.quantity,
      imageData: instance.imageData,
      expirationStatus: expirationStatus,
      category: category,
    );

    await docRef.set(newInstance.toMap());
  }

  /// 🔄 جلب كل المنتجات (لأغراض عامة أو إدارية)
  Future<List<ProductInstanceModel>> getAllInstances() async {
    final snapshot = await _firestore.collection('product_instance').get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final model = ProductInstanceModel.fromMap(data, doc.id);
      final newStatus = _calculateExpirationStatus(model.expirationDate);
      return model.copyWith(expirationStatus: newStatus);
    }).toList();
  }

  /// 🔄 جلب المنتجات الخاصة بمستخدم معين
  Future<List<ProductInstanceModel>> getInstances(String userId) async {
    final snapshot = await _firestore
        .collection('product_instance')
        .where('user_id', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      final model = ProductInstanceModel.fromMap(data, doc.id);
      final newStatus = _calculateExpirationStatus(model.expirationDate);
      return model.copyWith(expirationStatus: newStatus);
    }).toList();
  }
}
