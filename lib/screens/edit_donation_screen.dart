import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/donation_model.dart';
import '../models/product_instance_model.dart';
import 'package:intl/intl.dart';

class EditDonationScreen extends StatefulWidget {
  final DonationModel donation;

  const EditDonationScreen({super.key, required this.donation});

  @override
  State<EditDonationScreen> createState() => _EditDonationScreenState();
}

class _EditDonationScreenState extends State<EditDonationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  ProductInstanceModel? _productInstance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _descController.text = widget.donation.description;
    _addressController.text = widget.donation.address;
    _phoneController.text = widget.donation.phone;
    _fetchProductInstance();
  }

 Future<void> _fetchProductInstance() async {
  final doc = await FirebaseFirestore.instance
      .collection('product_instance')
      .doc(widget.donation.instanceId)
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product instance not found.')),
    );
  }
}
  Future<void> _updateDonation() async {
    if (!_formKey.currentState!.validate()) return;

    await FirebaseFirestore.instance
        .collection('donation_trans')
        .doc(widget.donation.id)
        .update({
      'description': _descController.text.trim(),
      'address': _addressController.text.trim(),
      'phone': _phoneController.text.trim(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Donation updated successfully!')),
    );

    Navigator.pop(context, true); // Return true to refresh the previous page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Donation', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
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
                        // Product Image
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

                        // Product Name (Static)
                        Text('Product: ${_productInstance!.productName}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),

                        // Expiration Date (Static)
                        Text(
                            'Expiration Date: ${DateFormat('yyyy-MM-dd').format(_productInstance!.expirationDate)}'),
                        const SizedBox(height: 8),

                        // Category (Static)
                        Text('Category: ${_productInstance!.category}'),
                        const Divider(height: 32),

                        // Editable Fields
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
                        const SizedBox(height: 24),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _updateDonation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E7A8D),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'Save Changes',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
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