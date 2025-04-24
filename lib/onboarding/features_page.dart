import 'package:flutter/material.dart';

class FeaturesPage extends StatelessWidget {
  const FeaturesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          const SizedBox(height: 60),
          const Icon(Icons.notifications_active, size: 80, color: Colors.deepPurple),
          const SizedBox(height: 20),
          const Text(
            'Stay Updated & In Control',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(blurRadius: 5, color: Colors.grey.shade300)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                FeatureItem(icon: Icons.notifications, text: "Weekly notifications to track usage"),
                FeatureItem(icon: Icons.favorite, text: "Donate or sell items you don't need"),
                FeatureItem(icon: Icons.lightbulb, text: "Smart suggestions based on your consumption"),
                FeatureItem(icon: Icons.dashboard, text: "Dashboard showing percentages of each zone"),
              ],
            ),
          ),
          const SizedBox(height: 50), // علشان فيه space بعد الكرت
        ],
      ),
    );
  }
}

class FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const FeatureItem({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.deepPurple),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
