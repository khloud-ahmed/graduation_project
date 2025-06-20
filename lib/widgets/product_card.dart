import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final daysLeft = product.expiryDate.difference(DateTime.now()).inDays;
    final displayDays = daysLeft < 0 ? 0 : daysLeft;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            product.imageData, // ✅ الصح هنا
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 50,
              height: 50,
              color: Colors.grey[300],
              child: const Icon(Icons.broken_image, color: Colors.grey),
            ),
          ),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Expires in $displayDays day${displayDays == 1 ? '' : 's'}",
          style: const TextStyle(color: Colors.black54),
        ),
        trailing: Icon(
          Icons.warning_amber_rounded,
          color: displayDays <= 0
              ? Colors.red
              : (displayDays <= 30 ? Colors.orange : Colors.green),
        ),
      ),
    );
  }
}

