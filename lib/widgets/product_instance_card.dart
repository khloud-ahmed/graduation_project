import 'dart:convert';
import 'package:flutter/foundation.dart'; // مهم علشان نعرف إذا كود Web ولا Mobile
import 'package:flutter/material.dart';
import '../models/product_instance_model.dart';

class ProductInstanceCard extends StatelessWidget {
  final ProductInstanceModel instance;
  const ProductInstanceCard({super.key, required this.instance});

  Color getBorderColor() {
    switch (instance.expirationStatus) {
      case 'safe':
        return Colors.green;
      case 'expiring':
        return Colors.orange;
      case 'expired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String getStatusText() {
    switch (instance.expirationStatus) {
      case 'safe':
        return 'Good';
      case 'expiring':
        return 'Soon';
      case 'expired':
        return 'Expired';
      default:
        return 'Unknown';
    }
  }

  Color getStatusBackgroundColor() {
    switch (instance.expirationStatus) {
      case 'safe':
        return Colors.green.shade100;
      case 'expiring':
        return Colors.orange.shade100;
      case 'expired':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade300;
    }
  }

  Color getStatusTextColor() {
    switch (instance.expirationStatus) {
      case 'safe':
        return Colors.green;
      case 'expiring':
        return Colors.orange;
      case 'expired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget buildImage() {
    if (instance.imageData.isEmpty) {
      return Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
      );
    }

    // ✅ لو Web أو الصورة URL نستخدم Image.network
    if (kIsWeb || instance.imageData.startsWith('http')) {
      return Image.network(
        instance.imageData,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 80, color: Colors.grey),
      );
    }

    // ✅ لو Mobile وفيه Base64
    try {
      final bytes = base64Decode(instance.imageData);
      return Image.memory(
        bytes,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.broken_image, size: 80, color: Colors.grey),
      );
    } catch (e) {
      return const Icon(Icons.broken_image, size: 80, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysLeft = instance.expirationDate.difference(DateTime.now()).inDays;
    final displayDaysLeft = daysLeft < 0 ? 0 : daysLeft;
    final expirationDateFormatted =
        '${instance.expirationDate.day}-${instance.expirationDate.month}-${instance.expirationDate.year}';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: getBorderColor(), width: 5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: buildImage(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  instance.productName.isNotEmpty
                      ? instance.productName
                      : 'No name found',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '$displayDaysLeft days remaining',
                  style: const TextStyle(color: Colors.black54),
                ),
                Text(
                  'Expires on $expirationDateFormatted',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: getStatusBackgroundColor(),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              getStatusText(),
              style: TextStyle(
                color: getStatusTextColor(),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
