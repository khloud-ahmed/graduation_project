import 'package:flutter/material.dart';
import '../models/product_instance_model.dart';
import '../models/sell_model.dart';

class SellDetailsScreen extends StatelessWidget {
  final ProductInstanceModel instance;
  final SellModel sell;
  final String sellerName;

  const SellDetailsScreen({
    super.key,
    required this.instance,
    required this.sell,
    required this.sellerName,
  });

  @override
  Widget build(BuildContext context) {
    final status = instance.expirationStatus.capitalize();
    final isSafe = instance.expirationStatus == 'safe';

    final statusColor = isSafe ? Colors.green : Colors.orange;
    final statusBgColor = isSafe ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E7A8D),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Product Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: instance.imageData.isNotEmpty
                    ? Image.network(
                        instance.imageData,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: double.infinity,
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 80),
                      ),
              ),
              const SizedBox(height: 16),

              // Product Name
              Text(
                instance.productName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                sell.description,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Price
              Text(
                'EGP ${sell.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Color(0xFF4F46E5),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 12),

              // Product Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const Divider(height: 32),

              // Seller Info
              InfoRow(
                icon: Icons.person,
                label: 'Sold by:',
                value: sellerName,
              ),
              InfoRow(
                icon: Icons.location_on,
                label: 'Address:',
                value: sell.address,
              ),
              InfoRow(
                icon: Icons.map,
                label: 'Location:',
                value: 'Alexandria', // ثابت أو dynamic حسب المطلوب
              ),
              InfoRow(
                icon: Icons.phone,
                label: 'Phone:',
                value: sell.phone,
              ),
              const SizedBox(height: 12),
              InfoRow(
                icon: Icons.info,
                label: 'Condition:',
                value: status,
                valueColor: statusColor,
              ),
              InfoRow(
                icon: Icons.inventory,
                label: 'Remaining:',
                value: 'Full', // يمكنك تعديله لعرض الكمية المتبقية فعلياً
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF1E7A8D), size: 20),
          const SizedBox(width: 8),
          Text(
            '$label ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: valueColor ?? Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

extension StringExt on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
