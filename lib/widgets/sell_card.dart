import 'package:flutter/material.dart';
import '../models/product_instance_model.dart';

class SellCard extends StatelessWidget {
  final ProductInstanceModel instance;
  final String sellerName;
  final double price;

  const SellCard({
    super.key,
    required this.instance,
    required this.sellerName,
    required this.price,
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
        'Expiration: ${instance.expirationDate.day}-${instance.expirationDate.month}-${instance.expirationDate.year}';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF9FB),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // صورة المنتج
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
            ),
            child: instance.imageData.isNotEmpty
                ? Image.network(
                    instance.imageData,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
          ),
          // تفاصيل
          Expanded(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    instance.productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Seller: $sellerName',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    expirationText,
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // الحالة
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: zoneColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          zoneLabel,
                          style: TextStyle(
                            color: zoneColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      // السعر
                      Text(
                        'EGP ${price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
