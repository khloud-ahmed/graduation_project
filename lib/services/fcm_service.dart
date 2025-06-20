import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/local_notification_service.dart';
import '../app_globals.dart';
import '../screens/usage_response_bottom_sheet.dart'; // تأكد من المسار الصحيح

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;




  void initFCM() async {
    // 🛡 طلب صلاحية الإشعارات
    NotificationSettings settings = await _messaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        // عند تجديد التوكن
        _messaging.onTokenRefresh.listen((newToken) {
          FirebaseFirestore.instance.collection('users').doc(userId).update({
            'fcm_token': newToken,
          });
        });

        // تسجيل التوكن لأول مرة
        String? token = await _messaging.getToken();
        if (token != null) {
          FirebaseFirestore.instance.collection('users').doc(userId).update({
            'fcm_token': token,
          });
        }
      }
    }

    // 🔔 استقبال الرسائل أثناء فتح التطبيق
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.data.isNotEmpty) {
        // لو فيه بيانات --> عرض إشعار محلي
        LocalNotificationService.showNotification(
          title: message.data['title'] ?? 'ExpiSave',
          body: message.data['body'] ?? '',
          payload: jsonEncode(message.data),
        );
      } else if (message.notification != null) {
        // fallback لو فيه notification جاهز من FCM
        LocalNotificationService.showNotification(
          title: message.notification!.title ?? 'ExpiSave',
          body: message.notification!.body ?? '',
          payload: jsonEncode(message.data),
        );
      }
    });

    // ✅ عند فتح الإشعار من الخلفية
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print ("for ground massege $message");

      if (navigatorKey.currentContext != null) {
        _handleMessage(navigatorKey.currentContext!, message);
      }
    });

    // ✅ عند فتح التطبيق من إشعار وهو مغلق
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null && navigatorKey.currentContext != null) {
        _handleMessage(navigatorKey.currentContext!, message);
      }
    });
  }

  void _handleMessage(BuildContext context, RemoteMessage message) {
    final data = message.data;
    final status = data['status']; // تأكد أنه يُرسل من الـ Function
    final instanceId = data['instance_id'];
    final productName = data['product_name'];

    // ✅ افتح BottomSheet فقط إذا لم يكن Expired
    if (status != 'expired' && instanceId != null && productName != null) {
      showProductActionSheet(
        context,
        instanceId,
        productName,
      );
    } else {
      debugPrint("No BottomSheet: status is expired");
    }
  }
}