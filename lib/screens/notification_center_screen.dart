import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
//import '../widgets/notification_card.dart';
import '../screens/usage_response_bottom_sheet.dart'; // ✅ استدعاء الـ Bottom Sheet
import 'package:firebase_auth/firebase_auth.dart';
class NotificationCenterScreen extends StatelessWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ الخلفية بيضاء
      appBar: AppBar(
        title: const Text('Notifications', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('notification')
      .where('user_id', isEqualTo: FirebaseAuth.instance.currentUser?.uid) // إضافة شرط user_id
      .orderBy('sent_at', descending: true)
      .snapshots(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }
          final notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final data = notifications[index].data() as Map<String, dynamic>;
              final notification = NotificationModel.fromMap(data, notifications[index].id);

              return ListTile(
                leading: Icon(
                  notification.type == "expiry_warning" 
                    ? Icons.warning_amber_rounded 
                    : Icons.notifications_outlined,
                  color: Colors.black,
                ),
                title: Text(notification.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(notification.body),
                trailing: Text(
                  _formatTimeAgo(notification.sentAt),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: () async {
  // تحديث حالة الإشعار إلى مقروء
  FirebaseFirestore.instance
      .collection('notification')
      .doc(notification.id)
      .update({'is_read': true});

  final response = notification.response;
  final instanceId = notification.instanceId;

  if (response == 'no' && instanceId != null) {
    // جلب حالة المنتج
    final productDoc = await FirebaseFirestore.instance
        .collection('product_instance')
        .doc(instanceId)
        .get();

    final productName = productDoc.data()?['product_name'] ?? 'this product';
    final expirationStatus = productDoc.data()?['expiration_status'];

    // فتح Bottom Sheet فقط لو المنتج مش منتهي
    if (expirationStatus != 'expired') {
      showProductActionSheet(context, instanceId, productName);
    }
  }
},
              );
            },
          );
        },
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }
}
