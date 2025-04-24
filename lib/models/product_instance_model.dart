class ProductInstanceModel {
  final String id;
  final String userId;
  final String instanceId;
  final String productId;
  final String productName;
  final DateTime addedDate;
  final DateTime expirationDate;
  final int quantity;
  final String expirationStatus; // safe, expiring, expired

  ProductInstanceModel({
    required this.id,
    required this.userId,
    required this.instanceId,
    required this.productId,
     required this.productName,
    required this.addedDate,
    required this.expirationDate,
    required this.quantity,
    required this.expirationStatus,

  });

  factory ProductInstanceModel.fromMap(Map<String, dynamic> data, String docId) {
    return ProductInstanceModel(
      instanceId: data['instance_id'] ?? '',
      id: docId,
      userId: data['user_id'],
      productId: data['product_id'],
      productName: data['product_name'] ?? '',
      addedDate: DateTime.parse(data['added_date']),
      expirationDate: DateTime.parse(data['expiration_date']),
      quantity: data['quantity'],
      expirationStatus: data['expiration_status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'instance_id': instanceId,
      'product_id': productId,
      'product_name': productName,
      'added_date': addedDate.toIso8601String(),
      'expiration_date': expirationDate.toIso8601String(),
      'quantity': quantity,
      'expiration_status': expirationStatus,
    };
  }
}