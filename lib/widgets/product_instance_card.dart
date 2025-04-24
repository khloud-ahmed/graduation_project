
import 'package:flutter/material.dart';
import '../models/product_instance_model.dart';

class ProductInstanceCard extends StatelessWidget {
  final ProductInstanceModel instance;
  const ProductInstanceCard({Key? key, required this.instance}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    final daysLeft = instance.expirationDate.difference(DateTime.now()).inDays;
    final expirationDateFormatted = '${instance.expirationDate.day}-${instance.expirationDate.month}-${instance.expirationDate.year}';

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
          Expanded(
  child: Row(
    children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: getStatusTextColor().withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          '$daysLeft d',
          style: TextStyle(
            color: getStatusTextColor(),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const SizedBox(width: 12),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            instance.productName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Expires on $expirationDateFormatted',
            style: const TextStyle(color: Colors.black54),
          ),
        ],
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
              style: TextStyle(color: getStatusTextColor(), fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}