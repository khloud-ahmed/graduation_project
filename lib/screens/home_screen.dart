import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/services/local_notification_service.dart';
import 'package:intl/intl.dart';

import '../models/product_instance_model.dart';
import '../services/product_instance_service.dart';
import '../screens/all_products_screen.dart';
import '../screens/donation_page.dart';
import '../screens/add_product_screen.dart';
import '../screens/sell_page.dart';
import '../screens/dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userId;
  const HomeScreen({super.key, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  String userName = 'User';
  List<ProductInstanceModel> safeProducts = [];
  List<ProductInstanceModel> expiringProducts = [];
  List<ProductInstanceModel> expiredProducts = [];
  int _selectedIndex = 0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    LocalNotificationService.initialize();

    _fetchUserName();
    _loadData();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snap = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final data = snap.data();
      if (data != null && data['firstName'] != null) {
        setState(() => userName = data['firstName']);
      }
    }
  }

  Future<void> _loadData() async {
    final all = await ProductInstanceService().getInstances(widget.userId);
    setState(() {
      safeProducts = all.where((p) => p.expirationStatus == 'safe').toList();
      expiringProducts = all.where((p) => p.expirationStatus == 'expiring').toList();
      expiredProducts = all.where((p) => p.expirationStatus == 'expired').toList();
    });
  }

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _controller.forward(from: 0);

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (context) => AllProductsScreen(userId: widget.userId)));
        break;
      case 2:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const DonationPage()));
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (context) => const SellPage()));
        break;
      case 4:
        Navigator.push(context, MaterialPageRoute(builder: (context) => DashboardScreen(userId: widget.userId)));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                Text('Welcome, $userName', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1F2C4E))),
                const SizedBox(height: 4),
                const Text('Track your household items', style: TextStyle(fontSize: 16, color: Color(0xFF4A5A78))),
                const SizedBox(height: 24),
                const Text('Product Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1F2C4E))),
                const SizedBox(height: 12),
                _buildStatusCard(),
                const SizedBox(height: 24),
                //const Text('Expiring Soon', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2C4E))),
                const SizedBox(height: 12),
                _buildExpiringList(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => AddProductScreen(userId: widget.userId, userName: userName),
          ));
        },
        backgroundColor: const Color(0xFF22A9C2),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Image.asset('assets/images/logo.jpg', width: 40, height: 40),
        const SizedBox(width: 8),
        const Text('ExpiSave', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1F2C4E))),
        const Spacer(),
        // ✅ Notification Icon with Navigation
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/notification_center'),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_outlined, color: Color(0xFF1F2C4E), size: 24),
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/settings'),
          child: const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Color(0xFF1F2C4E)),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF22A9C2), Color(0xFF1B8EA5)], 
          begin: Alignment.topCenter, 
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statusCircle(safeProducts.length, 'Valid', Colors.teal[400]!),
          _statusCircle(expiringProducts.length, 'Expiring', Colors.amber),
          _statusCircle(expiredProducts.length, 'Expired', Colors.red),
        ],
      ),
    );
  }

  Widget _statusCircle(int count, String label, Color bg) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Center(
            child: Text('$count', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white)),
      ],
    );
  }

  Widget _buildExpiringList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (safeProducts.isNotEmpty) ...[
          const Text('Valid', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...safeProducts.map((p) => _buildProductCard(p)),
          const SizedBox(height: 16),
        ],
        if (expiringProducts.isNotEmpty) ...[
          const Text('Expiring Soon', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...expiringProducts.map((p) => _buildProductCard(p)),
          const SizedBox(height: 16),
        ],
        if (expiredProducts.isNotEmpty) ...[
          const Text('Expired', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...expiredProducts.map((p) => _buildProductCard(p)),
        ],
      ],
    );
  }

  Widget _buildProductCard(ProductInstanceModel p) {
    final status = p.expirationStatus;
    Color color;
    String label;

    if (status == 'safe') {
      color = Colors.green;
      label = 'Valid';
    } else if (status == 'expiring') {
      color = Colors.amber;
      label = 'Soon';
    } else {
      color = Colors.red;
      label = 'Expired';
    }

    final daysLeft = p.expirationDate.difference(DateTime.now()).inDays;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: p.imageData.isNotEmpty
              ? Image.network(p.imageData, width: 40, height: 40, fit: BoxFit.cover)
              : Container(width: 40, height: 40, color: Colors.grey.shade200, child: const Icon(Icons.image_not_supported)),
        ),
        title: Text(p.productName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Expires on ${DateFormat('d-M-yyyy').format(p.expirationDate)}', style: const TextStyle(fontSize: 12)),
            if (status != 'expired')
              Text('$daysLeft day(s) remaining', style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
          child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    const Color tealColor = Color(0xFF22A9C2);
    
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      currentIndex: _selectedIndex,
      selectedItemColor: tealColor,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      elevation: 8.0,
      onTap: _onNavTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'All'),
        BottomNavigationBarItem(icon: Icon(Icons.volunteer_activism), label: 'Donations'),
        BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Marketplace'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reports'),
      ],
    );
  }
}
