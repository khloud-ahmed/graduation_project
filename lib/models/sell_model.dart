import 'package:cloud_firestore/cloud_firestore.dart';

class SellModel {
  final String id;
  final String instanceId;
  final String sellerId;
  final String description;
  final String phone;
  final String address;
  final double price;
  final DateTime sellDate;

  SellModel({
    required this.id,
    required this.instanceId,
    required this.sellerId,
    required this.description,
    required this.phone,
    required this.address,
    required this.price,
    required this.sellDate,
  });

  factory SellModel.fromMap(Map<String, dynamic> data, String docId) {
    String resolvedInstanceId = '';
    final instanceField = data['instance_id'];
    if (instanceField is DocumentReference) {
      resolvedInstanceId = instanceField.id;
    } else if (instanceField is String) {
      resolvedInstanceId = instanceField;
    }

    return SellModel(
      id: docId,
      instanceId: resolvedInstanceId,
      sellerId: data['seller_id'] ?? '',
      description: data['description'] ?? '',
      phone: data['phone'] ?? '',
      address: data['address'] ?? '',
      price: (data['price'] is int)
          ? (data['price'] as int).toDouble()
          : (data['price'] is double)
              ? data['price']
              : double.tryParse(data['price'].toString()) ?? 0.0,
      sellDate: _parseTimestamp(data['sell_date']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'instance_id': FirebaseFirestore.instance
          .collection('product_instance')
          .doc(instanceId),
      'seller_id': sellerId,
      'description': description,
      'phone': phone,
      'address': address,
      'price': price,
      'sell_date': Timestamp.fromDate(sellDate),
    };
  }

  SellModel copyWith({
    String? id,
    String? instanceId,
    String? sellerId,
    String? description,
    String? phone,
    String? address,
    double? price,
    DateTime? sellDate,
  }) {
    return SellModel(
      id: id ?? this.id,
      instanceId: instanceId ?? this.instanceId,
      sellerId: sellerId ?? this.sellerId,
      description: description ?? this.description,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      price: price ?? this.price,
      sellDate: sellDate ?? this.sellDate,
    );
  }

  static DateTime _parseTimestamp(dynamic ts) {
    if (ts is Timestamp) return ts.toDate();
    if (ts is DateTime) return ts;
    return DateTime.now();
  }
}

