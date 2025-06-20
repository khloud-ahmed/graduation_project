import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_instance_model.dart';
import '../services/upload_service.dart';

class EditProductScreen extends StatefulWidget {
  final ProductInstanceModel instance;
  const EditProductScreen({super.key, required this.instance});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  String? _selectedCategory;
  DateTime? _selectedDate;
  bool _isSaving = false;
  bool _isUploadingImage = false;

  final List<String> _categories = ['Medicine', 'Skincare', 'Haircare', 'Food'];
  final ImagePicker _picker = ImagePicker();
  XFile? _pickedImage;
  String? _imageUrl;

  final Color mainColor = const Color(0xFF1E7A8D);

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.instance.productName;
    _quantityController.text = widget.instance.quantity.toString();
    _selectedCategory = widget.instance.category;
    _selectedDate = widget.instance.expirationDate;
    _imageUrl = widget.instance.imageData;
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _isUploadingImage = true);
      final uploadService = UploadService();
      final uploadedUrl = await uploadService.uploadImage(pickedFile);
      setState(() {
        _pickedImage = pickedFile;
        _imageUrl = uploadedUrl;
        _isUploadingImage = false;
      });
    }
  }

  Future<void> _saveChanges() async {
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

    final quantity = int.tryParse(_quantityController.text.trim());
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantity must be a positive number.')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final now = DateTime.now();
      final difference = _selectedDate!.difference(now).inDays;

      String status;
      if (difference < 0) {
        status = 'expired';
      } else if (difference <= 30) {
        status = 'expiring';
      } else {
        status = 'safe';
      }

      await FirebaseFirestore.instance
          .collection('product_instance')
          .doc(widget.instance.instanceId)
          .update({
        'product_name': _nameController.text.trim(),
        'category': _selectedCategory,
        'quantity': quantity,
        'expiration_date': Timestamp.fromDate(_selectedDate!),
        'image_data': _imageUrl ?? '',
        'expiration_status': status,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product updated successfully!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _deleteProduct() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context, true);
              await FirebaseFirestore.instance
                  .collection('product_instance')
                  .doc(widget.instance.instanceId)
                  .delete();
              if (!mounted) return;
              Navigator.pop(context, true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Product deleted successfully')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;
  }

  Widget _buildImageWidget() {
    if (_isUploadingImage) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    if (_imageUrl == null || _imageUrl!.isEmpty) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo, size: 40, color: Colors.white),
          SizedBox(height: 8),
          Text("Tap to add image", style: TextStyle(color: Colors.white)),
        ],
      );
    }

    return Image.network(
      _imageUrl!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.broken_image, size: 100, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Edit Product'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _buildImageWidget(),
                ),
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: Text(_selectedDate == null
                  ? 'Select Expiration Date'
                  : '${_selectedDate!.day}-${_selectedDate!.month}-${_selectedDate!.year}'),
              onTap: _pickDate,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCategory = val),
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: mainColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Save Changes',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: _deleteProduct,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Delete Product'),
            ),
          ],
        ),
      ),
    );
  }
}


