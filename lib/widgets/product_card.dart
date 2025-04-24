import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: ListTile(
        leading: Image.network(product.imageUrl, width: 50, height: 50),
        title: Text(product.name),
        subtitle: Text("Expires in ${product.expiryDate.difference(DateTime.now()).inDays} days"),
        trailing: const Icon(Icons.warning, color: Colors.orange),
      ),
    );
  }
}
