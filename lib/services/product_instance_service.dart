import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_instance_model.dart';
import 'package:uuid/uuid.dart';  // ✅ لازم الاستيراد ده

class ProductInstanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addInstance(ProductInstanceModel instance) async {
    // حساب الزون تلقائيًا
    final now = DateTime.now();
    final diff = instance.expirationDate.difference(now).inDays;
    String status;
    if (diff > 180) {
      status = 'safe';
    } else if (diff > 90) {
      status = 'expiring';
    } else if (diff <= 0) {
      status = 'expired';
    } else {
      status = 'expiring';
    }
// 🟢 جلب اسم المنتج من Collection products
    final productDoc =
        await _firestore.collection('products').doc(instance.productId).get();
    final productName = productDoc.data()?['name'] ?? 'Unknown';
final String newInstanceId = const Uuid().v4();
    final newInstance = ProductInstanceModel(
      instanceId: newInstanceId,
      id: instance.id,
      userId: instance.userId,
      productId: instance.productId,
      productName: productName,
      addedDate: instance.addedDate,
      expirationDate: instance.expirationDate,
      quantity: instance.quantity,
      expirationStatus: status,
    );

    await _firestore.collection('product_instance').add(newInstance.toMap());
  }

  Future<List<ProductInstanceModel>> getInstances(String userId) async {
    final snapshot = await _firestore
        .collection('product_instance')
        .where('user_id', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => ProductInstanceModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}
