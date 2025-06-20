import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String userId;
  final String name;
  final String category;
  final DateTime expiryDate;
  final int quantity;
  final String imageData;
  final String zone;
  final double? price; // ✅ تم جعله اختياري

  ProductModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.expiryDate,
    required this.quantity,
    required this.imageData,
    required this.zone,
    this.price, // ✅ تم جعله غير مطلوب
  });

  ProductModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? category,
    DateTime? expiryDate,
    int? quantity,
    String? imageData,
    String? zone,
    double? price,
  }) {
    return ProductModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      category: category ?? this.category,
      expiryDate: expiryDate ?? this.expiryDate,
      quantity: quantity ?? this.quantity,
      imageData: imageData ?? this.imageData,
      zone: zone ?? this.zone,
      price: price ?? this.price,
    );
  }

  factory ProductModel.fromMap(Map<String, dynamic> data, String documentId) {
    return ProductModel(
      id: documentId,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      expiryDate: _parseDate(data['expiryDate']),
      quantity: data['quantity'] is int ? data['quantity'] : 1,
      imageData: data['image_data'] ?? '',
      zone: data['zone'] ?? '',
      price: (data['price'] != null)
          ? (data['price'] is int)
              ? (data['price'] as int).toDouble()
              : (data['price'] is double)
                  ? data['price']
                  : double.tryParse(data['price'].toString()) ?? 0.0
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'category': category,
      'expiryDate': Timestamp.fromDate(expiryDate),
      'quantity': quantity,
      'image_data': imageData,
      'zone': zone,
      if (price != null) 'price': price, // ✅ نحفظه فقط لو موجود
    };
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime.now();
      }
    } else {
      return DateTime.now();
    }
  }
}
