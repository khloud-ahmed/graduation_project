import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_instance_model.dart';
import '../models/donation_model.dart';
import '../services/product_instance_service.dart';
import '../services/donation_service.dart';
import 'donation_page.dart';

class AddDonationFromExistingScreen extends StatefulWidget {
  const AddDonationFromExistingScreen({super.key});

  @override
  State<AddDonationFromExistingScreen> createState() => _AddDonationFromExistingScreenState();
}

class _AddDonationFromExistingScreenState extends State<AddDonationFromExistingScreen> {
  List<ProductInstanceModel> userInstances = [];
  ProductInstanceModel? selectedInstance;

  String? instanceIdArgument;
  String? productNameArgument;

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final DonationService _donationService = DonationService();
  final user = FirebaseAuth.instance.currentUser;

  bool isLoading = true;
  bool isSubmitting = false;
  bool initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!initialized) {
      final args = ModalRoute.of(context)?.settings.arguments as Map?;
      if (args != null && args['instanceId'] != null && args['productName'] != null) {
        instanceIdArgument = args['instanceId'];
        productNameArgument = args['productName'];
      }
      initialized = true;
    }
    if (instanceIdArgument == null) {
      _loadUserInstances();
    } else {
      setState(() => isLoading = false); // لا نحتاج لجلب المنتجات لو دخلنا بالـ arguments
    }
  }

  Future<void> _loadUserInstances() async {
    if (user != null) {
      final instances = await ProductInstanceService().getInstances(user!.uid);
      final filtered = instances.where((instance) {
        final now = DateTime.now();
        return instance.expirationDate.isAfter(now);
      }).toList();

      setState(() {
        userInstances = filtered;
        isLoading = false;
      });
    }
  }

  Future<void> _submitDonation() async {
    if (isSubmitting) return;

    final String? chosenInstanceId =
        instanceIdArgument ?? selectedInstance?.id;
    if (chosenInstanceId == null ||
        _descriptionController.text.isEmpty ||
        _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      setState(() => isSubmitting = true);

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
      final phone = snapshot.data()?['phone'] ?? '';

      final donation = DonationModel(
        id: '',
        instanceId: chosenInstanceId,
        donatorId: user!.uid,
        description: _descriptionController.text.trim(),
        phone: phone,
        address: _addressController.text.trim(),
      );

      await _donationService.addDonation(donation);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Donation submitted successfully')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const DonationPage()),
        (route) => false,
      );
    } catch (e) {
      print('Error submitting donation: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong')),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Add Donation',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E7A8D),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // إذا جاي من زر تايك اكشن اعرض اسم المنتج مباشرة
                  if (instanceIdArgument != null && productNameArgument != null) ...[
                    const Text(
                      'Product to Donate:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        productNameArgument ?? '',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                      ),
                    ),
                  ]
                  // إذا جاي عادي اعرض الـ Dropdown
                  else ...[
                    const Text(
                      'Select Product:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    if (userInstances.isEmpty)
                      const Text(
                        'No available products to donate.',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    if (userInstances.isNotEmpty)
                      DropdownButtonFormField<ProductInstanceModel>(
                        isExpanded: true,
                        value: selectedInstance,
                        hint: const Text('Choose a product instance'),
                        items: userInstances.map((p) {
                          return DropdownMenuItem(
                            value: p,
                            child: Container(
                              color: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                              child: Text(
                                p.productName,
                                style: const TextStyle(fontSize: 16, color: Colors.black),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() => selectedInstance = val);
                        },
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    const SizedBox(height: 18),
                  ],
                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isSubmitting ? null : _submitDonation,
                      icon: const Icon(Icons.volunteer_activism, color: Colors.white),
                      label: const Text(
                        'Submit Donation',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E7A8D),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}