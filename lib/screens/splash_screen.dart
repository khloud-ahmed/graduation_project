// lib/screens/splash_screen.dart

// lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import '../auth/login_page.dart';
import '../screens/home_screen.dart';
import '../services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final StorageService _storage = StorageService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _checkAndNavigate();
  }

  Future<void> _checkAndNavigate() async {
    // 1) هل أكمل المستخدم Onboarding من قبل؟
    final seenOnboarding = await _storage.isOnboardingDone();
    if (!seenOnboarding) {
      await _storage.setOnboardingDone();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    // 2) بعد التأكد من Onboarding، افتح المستخدم على Home أو Login بناءً على الجلسة
    final user = _auth.currentUser;
    if (user != null) {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(userId: user.uid)),
      );
    } else {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}