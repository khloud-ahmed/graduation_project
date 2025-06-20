import 'package:flutter/material.dart';

void showProductActionSheet(BuildContext context, String instanceId, String productName) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "What would you like to do with $productName?",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _actionTile(
              context,
              Icons.volunteer_activism,
              "Donate it",
              "Help someone by donating this product.",
              Colors.green,
              () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/add_donation_from_existing_screen',
                  arguments: {
                    'instanceId': instanceId,
                    'productName': productName,
                  },
                );
              },
            ),
            _actionTile(
              context,
              Icons.sell,
              "Sell it",
              "Get some value back by selling it.",
              Colors.orange,
              () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  '/add_sell_from_existing_screen',
                  arguments: {
                    'instanceId': instanceId,
                    'productName': productName,
                  },
                );
              },
            ),
            _actionTile(
              context,
              Icons.archive,
              "Keep it",
              "I'll keep it for now.",
              Colors.grey,
              () {
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      );
    },
  );
}

Widget _actionTile(
  BuildContext context,
  IconData icon,
  String title,
  String subtitle,
  Color color,
  VoidCallback onTap,
) {
  return ListTile(
    leading: Icon(icon, color: color, size: 32),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
    subtitle: Text(subtitle),
    onTap: onTap,
  );
}

