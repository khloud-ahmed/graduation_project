import 'package:flutter/material.dart';

class SmartZonesPage extends StatelessWidget {
  const SmartZonesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'dotColor': Colors.red,
        'squareColor': Colors.green,
        'label': 'fridge',
      },
      {
        'dotColor': Colors.yellow,
        'squareColor': Colors.blue,
        'label': 'sauce',
      },
      {
        'dotColor': Colors.green,
        'squareColor': Colors.red.shade200,
        'label': 'cosmetics',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.dashboard, size: 80, color: Colors.deepPurple),
          const SizedBox(height: 20),
          const Text(
            'Smart Zones for Your Products',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'Your items are grouped into Green (Safe), Yellow (Expiring Soon), and Red (Expired) zones based on expiry dates.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 30),
          // الكروت
          ...items.map((item) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // الدايرة الصغيرة
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: item['dotColor'] as Color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // المربع الملون
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: item['squareColor'] as Color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // الشرايط الرمادية (كأنها معلومات)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 80,
                            height: 8,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            width: 100,
                            height: 8,
                            color: Colors.grey.shade300,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // اسم المنتج
                    Text(
                      item['label'] as String,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
