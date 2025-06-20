import 'package:flutter/material.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // خلفية بيضاء
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // ✅ اللوجو
              Image.asset(
                'assets/images/logo.jpg', // تأكد من وضع الصورة هنا في مجلد assets وتحديث pubspec.yaml
                height: 180,
              ),
              const SizedBox(height: 30),
              const Text(
                'Welcome to\nExpiSave',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E7A8D), // لون العنوان بنفس اللون المطلوب
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Track your food, medicine, and products easily and stay ahead of expiry dates',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const Spacer(),
             
            ],
          ),
        ),
      ),
    );
  }
}

