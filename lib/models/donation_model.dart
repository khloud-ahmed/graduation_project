import 'package:cloud_firestore/cloud_firestore.dart';

class DonationModel {
  final String id;
  final String instanceId;   // 👈 بنحتفظ بـ ID فقط
  final String donatorId;
  final String description;
  final String phone;
  final String address;

  DonationModel({
    required this.id,
    required this.instanceId,
    required this.donatorId,
    required this.description,
    required this.phone,
    required this.address,
  });

  // ✅ Factory لتحويل الداتا من Firestore
  factory DonationModel.fromMap(Map<String, dynamic> data, String docId) {
    final instanceField = data['instance_id'];
    String resolvedInstanceId;

    if (instanceField is DocumentReference) {
      resolvedInstanceId = instanceField.id;
    } else if (instanceField is String) {
      resolvedInstanceId = instanceField;
    } else {
      resolvedInstanceId = '';
    }

    return DonationModel(
      id: docId,
      instanceId: resolvedInstanceId,
      donatorId: data['donator_id'] ?? '',
      description: data['description'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
    );
  }

  // ✅ Map عشان نضيفها لـ Firestore
  Map<String, dynamic> toMap() {
    return {
      'instance_id': FirebaseFirestore.instance
          .collection('product_instance')
          .doc(instanceId), // 👈 هنا نخزن كـ DocumentReference
      'donator_id': donatorId,
      'description': description,
      'phone': phone,
      'address': address,
    };
  }

  // ✅ نسخة معدلة من الكائن (للأمان والتعديل)
  DonationModel copyWith({
    String? id,
    String? instanceId,
    String? donatorId,
    String? description,
    String? phone,
    String? address,
  }) {
    return DonationModel(
      id: id ?? this.id,
      instanceId: instanceId ?? this.instanceId,
      donatorId: donatorId ?? this.donatorId,
      description: description ?? this.description,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }
}

