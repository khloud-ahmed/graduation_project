import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import '../app_globals.dart';
import '../screens/usage_response_bottom_sheet.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static void initialize() {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        debugPrint('Notification Clicked with payload: $payload');

        if (payload != null && payload.isNotEmpty) {
          try {
            final data = jsonDecode(payload);
            debugPrint('Decoded Data: $data');

            final status = data['status'];
            // ignore: unused_local_variable
            final responseType = data['response'];

            // ✅ القاعدة الذهبية: افتح لو الحالة مش expired
            if (status != 'expired' &&
                data['instance_id'] != null &&
                data['product_name'] != null) {
              if (navigatorKey.currentContext != null) {
                showProductActionSheet(
                  navigatorKey.currentContext!,
                  data['instance_id'],
                  data['product_name'],
                );
              } else {
                debugPrint("Context is null: cannot show bottom sheet");
              }
            } else {
              debugPrint("BottomSheet is disabled for expired status");
            }
          } catch (e) {
            debugPrint('Error decoding payload: $e');
          }
        }
      },
    );
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'expi_channel',
      'ExpiSave Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    debugPrint('Showing notification with payload: $payload');

    await _notificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}