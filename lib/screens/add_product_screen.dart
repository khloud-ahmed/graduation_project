import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'home_screen.dart';

class AddProductScreen extends StatefulWidget {
  final String userId;
  final String userName;
  const AddProductScreen({super.key, required this.userId, required this.userName});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  String? _selectedCategory;
  DateTime? _selectedDate;
  XFile? _pickedImage;
  bool _isSaving = false;

  final List<String> _categories = [
    'Medicine',
    'Haircare',
    'Skincare',
    'Food'
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _pickedImage = image;
      });
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveProduct() async {
    if (_isSaving) return;
    if (_nameController.text.isEmpty ||
        _selectedCategory == null ||
        _selectedDate == null ||
        _quantityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final productName = _nameController.text.trim();
    final category = _selectedCategory!;
    final expirationDate = _selectedDate!;
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 1;
    final now = DateTime.now();
    final difference = expirationDate.difference(now).inDays;

    String status;
    if (difference > 180) {
      status = 'safe';
    } else if (difference > 90) {
      status = 'expiring';
    } else if (difference <= 0) {
      status = 'expired';
    } else {
      status = 'expiring';
    }

    final productRef = FirebaseFirestore.instance.collection('products');
    final instanceRef = FirebaseFirestore.instance.collection('product_instance');

    try {
      final existing = await productRef.where('name', isEqualTo: productName).limit(1).get();
      String productId;

      if (existing.docs.isNotEmpty) {
        productId = existing.docs.first.id;
      } else {
        final newDoc = await productRef.add({
          'name': productName,
          'category': category,
          'created_at': now,
          'image': '',
          'placeholder': true
        });
        productId = newDoc.id;
      }

      final instanceId = const Uuid().v4();
      await instanceRef.doc(instanceId).set({

        'instance_id': instanceId,
        'product_id': productId,
        'user_id': widget.userId,
        'product_name': productName,
        'expiration_date': expirationDate,
        'added_date': now,
        'updated_at': now,
        'quantity': quantity,
        'expiration_status': status,
        'consumption_rate': '',
        'status': '',
        'placeholder': true
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product saved successfully!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(userId: widget.userId, userName: widget.userName),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: Colors.black),
        title: const Text('Add Product', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _pickedImage == null
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                            SizedBox(height: 8),
                            Text("Tap to upload photo", style: TextStyle(color: Colors.grey))
                          ],
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          File(_pickedImage!.path),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                prefixIcon: Icon(Icons.inventory_2_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              value: _selectedCategory,
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val),
            ),
            const SizedBox(height: 16),
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Expiration Date',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.calendar_today),
                hintText: _selectedDate != null
                    ? DateFormat('yyyy-MM-dd').format(_selectedDate!)
                    : 'Select a date',
              ),
              onTap: _pickDate,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                prefixIcon: Icon(Icons.format_list_numbered),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: Colors.black,
              ),
              onPressed: _saveProduct,
              child: const Text('Save Product'),
            ),
          ],
        ),
      ),
    );
  }
}