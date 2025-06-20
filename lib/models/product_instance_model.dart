import 'package:cloud_firestore/cloud_firestore.dart';

class ProductInstanceModel {
  final String id;
  final String userId;
  final String instanceId;
  final String productId;
  final String productName;
  final DateTime addedDate;
  final DateTime expirationDate;
  final int quantity;
  final String imageData;
  final String expirationStatus;
  final String category;

  ProductInstanceModel({
    required this.id,
    required this.userId,
    required this.instanceId,
    required this.productId,
    required this.productName,
    required this.addedDate,
    required this.expirationDate,
    required this.quantity,
    required this.imageData,
    required this.expirationStatus,
    required this.category,
  });

  // ✅ Override للـ == والـ hashCode لحل مشكلة DropdownButton
  @override
  bool operator ==(Object other) {
    return identical(this, other) || 
      (other is ProductInstanceModel && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;

  // ✅ من Map إلى Model
  factory ProductInstanceModel.fromMap(Map<String, dynamic> data, String docId) {
    return ProductInstanceModel(
      id: docId,
      userId: data['user_id'] ?? '',
      instanceId: data['instance_id'] ?? '',
      productId: data['product_id'] ?? '',
      productName: data['product_name'] ?? '',
      addedDate: _parseTimestamp(data['added_date']),
      expirationDate: _parseTimestamp(data['expiration_date']),
      quantity: _parseInt(data['quantity']),
      imageData: data['image_data'] ?? '',
      expirationStatus: data['expiration_status'] ?? '',
      category: data['category'] ?? '',
    );
  }

  // ✅ من Model إلى Map
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'instance_id': instanceId,
      'product_id': productId,
      'product_name': productName,
      'added_date': Timestamp.fromDate(addedDate),
      'expiration_date': Timestamp.fromDate(expirationDate),
      'quantity': quantity,
      'image_data': imageData,
      'expiration_status': expirationStatus,
      'category': category,
    };
  }

  // ✅ نسخة معدلة من الكائن
  ProductInstanceModel copyWith({
    String? id,
    String? userId,
    String? instanceId,
    String? productId,
    String? productName,
    DateTime? addedDate,
    DateTime? expirationDate,
    int? quantity,
    String? imageData,
    String? expirationStatus,
    String? category,
  }) {
    return ProductInstanceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      instanceId: instanceId ?? this.instanceId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      addedDate: addedDate ?? this.addedDate,
      expirationDate: expirationDate ?? this.expirationDate,
      quantity: quantity ?? this.quantity,
      imageData: imageData ?? this.imageData,
      expirationStatus: expirationStatus ?? this.expirationStatus,
      category: category ?? this.category,
    );
  }

  // ✅ تحويل Timestamp أو DateTime بشكل آمن
  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is DateTime) {
      return timestamp;
    } else {
      return DateTime.now();
    }
  }

  // ✅ تحويل أي قيمة عددية إلى int
  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 1;
    return 1;
  }
}
