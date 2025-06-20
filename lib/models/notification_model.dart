import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime sentAt;
final String? response; // ✅ جديد
  final String? instanceId;
   final String? productName; // ✅ جديد
  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.sentAt,
     this.response,  // ✅ جديد
    this.instanceId,
     this.productName, // 
  });

  factory NotificationModel.fromMap(Map<String, dynamic> data, String docId) {
    return NotificationModel(
      id: docId,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      type: data['type'] ?? '',
      isRead: data['is_read'] ?? false,
      sentAt: (data['sent_at'] as Timestamp).toDate(),
      response: data['response'], // ✅ جديد
      instanceId: data['instance_id'], // ✅ جديد
       productName: data['product_name'],
    );
  }
}
