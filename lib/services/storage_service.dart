// lib/services/storage_service.dart

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  // نمط الـ Singleton حتى نستخدم كائن واحد في التطبيق كله
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  static const String _KEY_ONBOARDING_DONE = 'onboarding_completed';

  /// جلب حالة إكمال الـ Onboarding (إذا لم توجد قيمة تعني false)
  Future<bool> isOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_KEY_ONBOARDING_DONE) ?? false;
  }

  /// تعيين علامة الانتهاء من الـ Onboarding إلى true
  Future<void> setOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_KEY_ONBOARDING_DONE, true);
  }
}