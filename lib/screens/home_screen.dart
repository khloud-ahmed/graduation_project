import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_instance_model.dart';
import '../services/product_instance_service.dart';
import '../widgets/product_status_widget.dart';
import '../widgets/product_instance_card.dart';
import 'add_product_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userId;
  final String userName;
  const HomeScreen({super.key, required this.userId, required this.userName});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String userName = "User";

  List<ProductInstanceModel> safeProducts = [];
  List<ProductInstanceModel> expiringProducts = [];
  List<ProductInstanceModel> expiredProducts = [];

  @override
  void initState() {
    super.initState();
    print('🟢 Current userId: ${widget.userId}');
    fetchUserNameFromFirestore().then((_) {
      loadData();
      testPrintProducts();
    });
  }

  Future<void> fetchUserNameFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = snapshot.data();
      if (data != null && data['firstName'] != null) {
        setState(() {
          userName = data['firstName'];
        });
      }
    }
  }

  Future<void> loadData() async {
    final products = await ProductInstanceService().getInstances(widget.userId);
    setState(() {
      safeProducts = products.where((p) => p.expirationStatus == 'safe').toList();
      expiringProducts = products.where((p) => p.expirationStatus == 'expiring').toList();
      expiredProducts = products.where((p) => p.expirationStatus == 'expired').toList();
    });
  }

Future<void> testPrintProducts() async {
  final snapshot = await FirebaseFirestore.instance
      .collection('product_instance')
      .where('user_id', isEqualTo: widget.userId) // يتأكد إنه بيشوف بس بيانات اليوزر الحالي
      .get();

  if (snapshot.docs.isEmpty) {
    print('🔥 No products found for this user.');
  } else {
    print('🔥 Products found:');
    for (var doc in snapshot.docs) {
      print('👉 ${doc.data()}');
    }
  }
}
  void _onItemTapped(int index) async {
    if (index == 2) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddProductScreen(userId: widget.userId,userName: userName),
        ),
      );
      // بعد الرجوع من صفحة الإضافة، حدث البيانات
      await loadData();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none))
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("ExpiSave", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                      const SizedBox(height: 4),
                      const Text("Track your household items", style: TextStyle(color: Colors.black54)),
                      const SizedBox(height: 16),
                      Text("Welcome, $userName", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const CircleAvatar(radius: 24, backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 20),
            const Text("Product Status", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            ProductStatusWidget(
              safeCount: safeProducts.length,
              expiringCount: expiringProducts.length,
              expiredCount: expiredProducts.length,
            ),
            const SizedBox(height: 20),
            _buildSection("Expiring Soon", expiringProducts),
            _buildSection("Safe Zone", safeProducts),
            _buildSection("Expired Items", expiredProducts),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'All Products'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle, size: 36), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.volunteer_activism), label: 'Donate'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reports'),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddProductScreen(userId: widget.userId,userName: userName),
            ),
          );
          await loadData();
        
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSection(String title, List<ProductInstanceModel> products) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (products.isEmpty)
          const Text("No products found."),
        ...products.map((p) => ProductInstanceCard(instance: p))
      ],
    );
  }
}