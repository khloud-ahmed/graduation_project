import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/donation_model.dart';

class DonationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// إضافة تبرع جديد مع حفظ created_at وترتيب لاحق
  Future<void> addDonation(DonationModel donation) async {
    final data = donation.toMap();
    data['created_at'] = FieldValue.serverTimestamp();
    final docRef = await _firestore.collection('donation_trans').add(data);
    await docRef.update({'donation_id': docRef.id});
  }

  /// تحديث تبرع موجود
  Future<void> updateDonation(DonationModel donation) async {
    final data = donation.toMap();
    data.remove('created_at');
    await _firestore.collection('donation_trans').doc(donation.id).update(data);
  }

  /// جلب كل التبرعات
  Future<List<DonationModel>> getAllDonations() async {
    final snapshot = await _firestore
        .collection('donation_trans')
        .orderBy('created_at', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => DonationModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// جلب تبرعات مستخدم محدد
  Future<List<DonationModel>> getUserDonations(String userId) async {
    final snapshot = await _firestore
        .collection('donation_trans')
        .where('donator_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => DonationModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  /// حذف تبرع
  Future<void> deleteDonation(String donationId) async {
    await _firestore.collection('donation_trans').doc(donationId).delete();
  }

  /// البحث عن التبرعات حسب اسم المنتج
  Future<List<DonationModel>> searchDonationByName(String name) async {
    final allDonations = await getAllDonations();
    final instanceSnapshot = await _firestore.collection('product_instances').get();
    final instanceMap = {
      for (var doc in instanceSnapshot.docs) doc.id: doc.data(),
    };

    final filtered = allDonations.where((donation) {
      final instanceData = instanceMap[donation.instanceId];
      if (instanceData == null) return false;
      final instanceName = (instanceData['name'] ?? '').toString().toLowerCase();
      return instanceName.contains(name.toLowerCase());
    }).toList();

    return filtered;
  }
}

