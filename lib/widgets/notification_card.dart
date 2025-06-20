import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import '../screens/usage_response_bottom_sheet.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;

  const NotificationCard({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        notification.type == "expiry_warning" ? Icons.warning_amber_rounded : Icons.notifications_outlined,
        color: Colors.black,
      ),
      title: Text(notification.title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(notification.body),
      trailing: Text(
        _formatTimeAgo(notification.sentAt),
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      onTap: () async {
  FirebaseFirestore.instance
      .collection('notification')
      .doc(notification.id)
      .update({'is_read': true});

  final response = notification.response;
  final instanceId = notification.instanceId;
  final productName = notification.productName;

  if (response == 'no' && instanceId != null && productName != null) {
    // جلب حالة المنتج
    final productDoc = await FirebaseFirestore.instance
        .collection('product_instance')
        .doc(instanceId)
        .get();
    final expirationStatus = productDoc.data()?['expiration_status'];

    // فتح Bottom Sheet فقط لو المنتج مش منتهي
    if (expirationStatus != 'expired') {
      showProductActionSheet(context, instanceId, productName);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$productName has expired. Please dispose of it safely.')),
      );
    }
  } else if (response == 'yes' && instanceId != null) {
    FirebaseFirestore.instance
        .collection('product_instance')
        .doc(instanceId)
        .update({'last_usage_response': 'yes'});
  }
},
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
