class ProductModel {
  final String id;
  final String userId;
  final String name;
  final String category;
  final DateTime expiryDate;
  final int quantity;
  final String imageUrl;
  final String zone;

  ProductModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.expiryDate,
    required this.quantity,
    required this.imageUrl,
    required this.zone,

  });
ProductModel copyWith({
  String? id,
  String? userId,
  String? name,
  String? category,
  DateTime? expiryDate,
  int? quantity,
  String? imageUrl,
  String? zone,
}) {
  return ProductModel(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    name: name ?? this.name,
    category: category ?? this.category,
    expiryDate: expiryDate ?? this.expiryDate,
    quantity: quantity ?? this.quantity,
    imageUrl: imageUrl ?? this.imageUrl,
    zone: zone ?? this.zone,
  );
}

  factory ProductModel.fromMap(Map<String, dynamic> data, String documentId) {
    return ProductModel(
      id: documentId,
      userId: data['userId'],
      name: data['name'],
      category: data['category'],
      expiryDate: DateTime.parse(data['expiryDate']),
      quantity: data['quantity'],
      imageUrl: data['imageUrl'],
      zone: data['zone'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'category': category,
      'expiryDate': expiryDate.toIso8601String(),
      'quantity': quantity,
      'imageUrl': imageUrl,
      'zone': zone,
    };
  }
}