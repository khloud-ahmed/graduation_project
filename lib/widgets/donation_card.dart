import 'package:flutter/material.dart';
import '../models/product_instance_model.dart';

class DonationCard extends StatelessWidget {
  final ProductInstanceModel instance;
  final String donatorName;

  const DonationCard({
    super.key,
    required this.instance,
    required this.donatorName,
  });

  @override
  Widget build(BuildContext context) {
    final zone = instance.expirationStatus;
    final zoneLabel = zone == 'safe'
        ? 'Safe'
        : zone == 'expiring'
            ? 'Soon'
            : 'Expired';
    final zoneColor = zone == 'safe'
        ? Colors.green
        : zone == 'expiring'
            ? Colors.orange
            : Colors.red;

    final expirationText =
        'Expiration date: ${instance.expirationDate.day}-${instance.expirationDate.month}-${instance.expirationDate.year}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF9FB),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ صورة المنتج من URL
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: instance.imageData.isNotEmpty
                ? Image.network(
                    instance.imageData,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 150,
                      color: Colors.grey[200],
                      alignment: Alignment.center,
                      child: const Icon(Icons.broken_image, size: 60, color: Colors.grey),
                    ),
                  )
                : Container(
                    height: 150,
                    color: Colors.grey[200],
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                  ),
          ),

          // ✅ باقي التفاصيل
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الحالة
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: zoneColor.withOpacity(0.15),
                    border: Border.all(color: zoneColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    zoneLabel,
                    style: TextStyle(
                      color: zoneColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // اسم المنتج
                Text(
                  instance.productName,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),

                // وصف مبسط
                Text(
                  'A high-quality, sealed product.\n$expirationText',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 6),

                // اسم المتبرع
                Text(
                  'Donated by: $donatorName',
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

