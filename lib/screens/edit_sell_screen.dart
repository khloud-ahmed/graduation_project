import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sell_model.dart';
import '../models/product_instance_model.dart';
import 'package:intl/intl.dart';

class EditSellScreen extends StatefulWidget {
  final SellModel sell;

  const EditSellScreen({super.key, required this.sell});

  @override
  State<EditSellScreen> createState() => _EditSellScreenState();
}

class _EditSellScreenState extends State<EditSellScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _priceController = TextEditingController();

  ProductInstanceModel? _productInstance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _descController.text = widget.sell.description;
    _addressController.text = widget.sell.address;
    _phoneController.text = widget.sell.phone;
    _priceController.text = widget.sell.price.toString();
    _fetchProductInstance();
  }

  Future<void> _fetchProductInstance() async {
    final doc = await FirebaseFirestore.instance
        .collection('product_instance')
        .doc(widget.sell.instanceId)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      if (!mounted) return;
      setState(() {
        _productInstance = ProductInstanceModel.fromMap(data, doc.id);
        _isLoading = false;
      });
    } else {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnackBar('Product instance not found.', Colors.red);
    }
  }

  Future<void> _updateSell() async {
    if (!_formKey.currentState!.validate()) return;

    await FirebaseFirestore.instance
        .collection('sell_trans')
        .doc(widget.sell.id)
        .update({
      'description': _descController.text.trim(),
      'address': _addressController.text.trim(),
      'phone': _phoneController.text.trim(),
      'price': double.tryParse(_priceController.text.trim()) ?? widget.sell.price,
    });

    _showSnackBar('Sell updated successfully!', Colors.green);

    Navigator.pop(context, true);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Sell', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E7A8D),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _productInstance == null
              ? const Center(child: Text('Product data not available.'))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        _productInstance!.imageData.isNotEmpty
                            ? Image.network(
                                _productInstance!.imageData,
                                height: 180,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                height: 180,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image, size: 100),
                              ),
                        const SizedBox(height: 16),
                        Text('Product: ${_productInstance!.productName}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                            'Expiration Date: ${DateFormat('yyyy-MM-dd').format(_productInstance!.expirationDate)}'),
                        const SizedBox(height: 8),
                        Text('Category: ${_productInstance!.category}'),
                        const Divider(height: 32),
                        TextFormField(
                          controller: _descController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            labelText: 'Address',
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (v) => v == null || v.isEmpty
                              ? 'Please enter an address'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (v) => v == null || v.isEmpty
                              ? 'Please enter a phone number'
                              : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Price',
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (v) {
                            final value = double.tryParse(v ?? '');
                            if (value == null || value <= 0) {
                              return 'Please enter a valid price';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _updateSell,
                            icon: const Icon(Icons.save, color: Colors.white),
                            label: const Text(
                              'Save Changes',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E7A8D),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}

