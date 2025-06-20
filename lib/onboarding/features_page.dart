import 'package:flutter/material.dart';

class FeaturesPage extends StatelessWidget {
  const FeaturesPage({super.key});

  final Color mainColor = const Color.fromRGBO(30, 122, 141, 1);

  final List<Map<String, dynamic>> features = const [
    {
      'icon': Icons.notifications_active,
      'text': "Weekly notifications to track usage",
    },
    {
      'icon': Icons.sell,
      'text': "Donate or sell items you don't need",
    },
    {
      'icon': Icons.lightbulb_outline,
      'text': "Smart suggestions based on your consumption",
    },
    {
      'icon': Icons.dashboard_customize,
      'text': "Dashboard showing percentages of each zone",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            const SizedBox(height: 40),
            CircleAvatar(
              radius: 50,
              backgroundColor: mainColor.withOpacity(0.1),
              child: Icon(Icons.notifications_active, size: 50, color: mainColor),
            ),
            const SizedBox(height: 20),
            const Text(
              'Stay Updated & In Control',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Track your usage and make smarter decisions with our powerful features.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.grey.shade300,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: features.map((feature) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Icon(feature['icon'], color: mainColor, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            feature['text'],
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
