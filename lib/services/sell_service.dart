import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sell_model.dart';

class SellService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// إضافة عملية بيع جديدة مع حفظ الطابع الزمني
  Future<void> addSell(SellModel sell) async {
    final data = sell.toMap();
    data['created_at'] = FieldValue.serverTimestamp();

    final docRef = await _firestore.collection('sell_trans').add(data);
    await docRef.update({'sell_id': docRef.id});
  }

  /// تحديث عملية بيع موجودة (بدون تغيير created_at)
  Future<void> updateSell(SellModel sell) async {
    final data = sell.toMap();
    data.remove('created_at');

    await _firestore
        .collection('sell_trans')
        .doc(sell.id)
        .update(data);
  }

  /// جلب كل عمليات البيع، مرتبة من الأحدث للأقدم حسب created_at
  Future<List<SellModel>> getAllSells() async {
    final snapshot = await _firestore
        .collection('sell_trans')
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => SellModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// جلب عمليات البيع الخاصة بمستخدم محدد، مرتبة من الأحدث للأقدم
  Future<List<SellModel>> getUserSells(String userId) async {
    final snapshot = await _firestore
        .collection('sell_trans')
        .where('seller_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => SellModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// حذف عملية بيع
  Future<void> deleteSell(String sellId) async {
    await _firestore
        .collection('sell_trans')
        .doc(sellId)
        .delete();
  }
}


