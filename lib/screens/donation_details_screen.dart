import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/donation_model.dart';
import '../models/product_instance_model.dart';

class DonationDetailsScreen extends StatelessWidget {
  final DonationModel donation;
  final ProductInstanceModel instance;
  final String donatorName;

  const DonationDetailsScreen({
    super.key,
    required this.donation,
    required this.instance,
    required this.donatorName,
  });

  @override
  Widget build(BuildContext context) {
    final donatedSince = DateFormat('MMM yyyy').format(instance.addedDate);

    Color statusColor;
    switch (instance.expirationStatus) {
      case 'safe':
        statusColor = Colors.green;
        break;
      case 'expiring':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.red;
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E7A8D),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Donation Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            if (instance.imageData.isNotEmpty)
              Image.network(
                instance.imageData,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
              )
            else
              Container(
                width: double.infinity,
                height: 220,
                color: Colors.grey[200],
                child: const Icon(Icons.image, size: 80, color: Colors.grey),
              ),

            const SizedBox(height: 16),

            // Details Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        instance.productName,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        donatorName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      Text('Donating since $donatedSince',
                          style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 12),
                      const Divider(),

                      const Text(
                        'Product Details',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          const Icon(Icons.category, color: Color(0xFF1E7A8D)),
                          const SizedBox(width: 8),
                          Text('Category: ${instance.category}'),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Color(0xFF1E7A8D)),
                          const SizedBox(width: 8),
                          Text('Listed: ${DateFormat.yMMMd().format(instance.addedDate)}'),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.description, color: Color(0xFF1E7A8D)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                donation.description,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          instance.expirationStatus.toUpperCase(),
                          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                        ),
                      ),

                      const SizedBox(height: 16),
                      const Divider(),

                      const Text(
                        'Contact Information',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          const Icon(Icons.location_on, color: Color(0xFF1E7A8D)),
                          const SizedBox(width: 8),
                          Expanded(child: Text(donation.address)),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          const Icon(Icons.phone, color: Color(0xFF1E7A8D)),
                          const SizedBox(width: 8),
                          Text(donation.phone),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
