import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_instance_model.dart';
import '../widgets/product_instance_card.dart';

class AllProductsScreen extends StatefulWidget {
  final String userId;
  const AllProductsScreen({super.key, required this.userId});

  @override
  _AllProductsScreenState createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _categories = ['All', 'Medicine', 'Skincare', 'Haircare', 'Food'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(() => setState(() {}));

    // ✅ تحديث الحالات عند فتح الصفحة
    updateExpiredStatuses();
  }

  /// ✅ دالة لتحديث حالة المنتجات بناءً على تاريخ اليوم
  Future<void> updateExpiredStatuses() async {
    final now = DateTime.now();

    final querySnapshot = await FirebaseFirestore.instance
        .collection('product_instance')
        .where('expiration_status', isEqualTo: 'expiring')
        .get();

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final expirationDate = (data['expiration_date'] as Timestamp).toDate();

      if (expirationDate.isBefore(now)) {
        await doc.reference.update({'expiration_status': 'expired'});
      }
    }
  }

  Future<bool> _confirmDelete(BuildContext context, ProductInstanceModel instance) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('product_instance')
                  .doc(instance.instanceId)
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
    return confirm ?? false;
  }

  Stream<QuerySnapshot> _getCategoryStream(String category) {
    final baseQuery = FirebaseFirestore.instance
        .collection('product_instance')
        .where('user_id', isEqualTo: widget.userId);

    if (category == 'All') return baseQuery.snapshots();

    return baseQuery.where('category', isEqualTo: category).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('All Products', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelPadding: const EdgeInsets.symmetric(horizontal: 8),
              indicator: const BoxDecoration(),
              tabs: _categories.map((c) {
                final isSelected = _tabController.index == _categories.indexOf(c);
                return Tab(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF1E7A8D) : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      c,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _categories.map((category) {
          return StreamBuilder<QuerySnapshot>(
            stream: _getCategoryStream(category),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;
              final List<ProductInstanceModel> products = docs.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                return ProductInstanceModel.fromMap(data, doc.id);
              }).toList();

              if (products.isEmpty) {
                return const Center(child: Text('No products found.'));
              }

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  );
                },
                child: ListView.builder(
                  key: ValueKey(category),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final instance = products[index];
                    return Dismissible(
                      key: Key(instance.instanceId),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        color: Colors.blue,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.edit, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          return await _confirmDelete(context, instance);
                        } else {
                          final result = await Navigator.pushNamed(
                            context,
                            '/edit_product',
                            arguments: instance,
                          );
                          if (result == true && mounted) {
                            setState(() {});
                          }
                          return false;
                        }
                      },
                      child: ProductInstanceCard(instance: instance),
                    );
                  },
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
