import 'package:flutter/material.dart';

class ProductStatusWidget extends StatelessWidget {
  final int safeCount;
  final int expiringCount;
  final int expiredCount;

  const ProductStatusWidget({
    super.key,
    required this.safeCount,
    required this.expiringCount,
    required this.expiredCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFFB7A8FF), Color(0xFF8675FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatusCircle(count: safeCount, label: "Valid", color: Colors.green),
          _buildStatusCircle(count: expiringCount, label: "Expiring", color: Colors.amber),
          _buildStatusCircle(count: expiredCount, label: "Expired", color: Colors.red),
        ],
      ),
    );
  }

  Widget _buildStatusCircle({required int count, required String label, required Color color}) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
          alignment: Alignment.center,
          child: Text(
            '$count',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500))
      ],
    );
  }
}