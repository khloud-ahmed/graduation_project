import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardController extends ChangeNotifier {
  final String userId;

  int totalProducts = 0;
  int expiringSoon = 0;
  int expiredProducts = 0;
  int safeProducts = 0;
  int donatedProducts = 0;
  int soldProducts = 0;

  final categories = ['medicine', 'skincare', 'haircare', 'food'];
  final labels = {
    'medicine': 'Medicine',
    'skincare': 'Skincare',
    'haircare': 'Haircare',
    'food': 'Food',
  };

  Map<String, int> safeByCat = {};
  Map<String, int> expiringByCat = {};
  Map<String, int> expiredByCat = {};

  List<Map<String, dynamic>> expiringProducts = [];
  List<RecentItem> recentItems = [];

  int trendRangeDays = 7;
  String mostAddedCategoryName = '';
  int mostAddedCategoryExpiring = 0;

  List<Map<String, dynamic>> allProductsData = []; // <-- هنا نحفظ كل المنتجات بعد الجلب

  DashboardController({required this.userId}) {
    safeByCat = {for (var c in categories) c: 0};
    expiringByCat = {for (var c in categories) c: 0};
    expiredByCat = {for (var c in categories) c: 0};
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    await fetchStats();
    await fetchRecentItems();
    notifyListeners();
  }

  Future<void> fetchStats() async {
    final fs = FirebaseFirestore.instance;
    final prodSnap = await fs
        .collection('product_instance')
        .where('user_id', isEqualTo: userId)
        .get();

    final products = prodSnap.docs;

    // احفظ المنتجات كلها
    allProductsData = products.map((e) {
      final data = e.data();
      data['id'] = e.id;
      return data;
    }).toList();

    safeByCat.updateAll((k, v) => 0);
    expiringByCat.updateAll((k, v) => 0);
    expiredByCat.updateAll((k, v) => 0);

    Map<String, int> categoryCount = {};
    expiringProducts.clear();

    int exp = 0, expSoon = 0, safe = 0;

    for (var d in allProductsData) {
      final status = (d['expiration_status'] as String?) ?? 'safe';
      final rawCat = ((d['category'] as String?) ?? '').toLowerCase();
      final cat = categories.contains(rawCat) ? rawCat : '';

      if (status == 'expired') {
        exp++;
      } else if (status == 'expiring') {
        expSoon++;
        expiringProducts.add(d);
      } else {
        safe++;
      }

      if (cat.isNotEmpty) {
        categoryCount[cat] = (categoryCount[cat] ?? 0) + 1;
        if (status == 'expired') {
          expiredByCat[cat] = expiredByCat[cat]! + 1;
        } else if (status == 'expiring') {
          expiringByCat[cat] = expiringByCat[cat]! + 1;
        } else {
          safeByCat[cat] = safeByCat[cat]! + 1;
        }
      }
    }

    mostAddedCategoryName = '';
    int max = 0;
    categoryCount.forEach((k, v) {
      if (v > max) {
        max = v;
        mostAddedCategoryName = k;
      }
    });
    mostAddedCategoryExpiring = expiringByCat[mostAddedCategoryName] ?? 0;

    final donaCount = await fs
        .collection('donation_trans')
        .where('donator_id', isEqualTo: userId)
        .get()
        .then((snap) => snap.docs.length);

    final sellCount = await fs
        .collection('sell_trans')
        .where('seller_id', isEqualTo: userId)
        .get()
        .then((snap) => snap.docs.length);

    totalProducts = products.length;
    expiredProducts = exp;
    expiringSoon = expSoon;
    safeProducts = safe;
    donatedProducts = donaCount;
    soldProducts = sellCount;
    notifyListeners();
  }

  Future<void> fetchRecentItems() async {
    final fs = FirebaseFirestore.instance;
    List<RecentItem> items = [];

    final donaSnap = await fs
        .collection('donation_trans')
        .where('donator_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .limit(3)
        .get();

    for (var doc in donaSnap.docs) {
      final data = doc.data();
      final ref = data['instance_id'] as DocumentReference;
      final instSnap = await ref.get();
      final inst = instSnap.data() as Map<String, dynamic>;
      final ts = data['created_at'] as Timestamp?;
      items.add(RecentItem(
        productName: inst['product_name'] ?? '',
        imageData: inst['image_data'] ?? '',
        type: 'Donated',
        date: ts?.toDate() ?? DateTime.now(),
      ));
    }

    final sellSnap = await fs
        .collection('sell_trans')
        .where('seller_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .limit(3)
        .get();

    for (var doc in sellSnap.docs) {
      final data = doc.data();
      final ref = data['instance_id'] as DocumentReference;
      final instSnap = await ref.get();
      final inst = instSnap.data() as Map<String, dynamic>;
      final ts = data['created_at'] as Timestamp?;
      items.add(RecentItem(
        productName: inst['product_name'] ?? '',
        imageData: inst['image_data'] ?? '',
        type: 'Sold',
        date: ts?.toDate() ?? DateTime.now(),
      ));
    }

    items.sort((a, b) => b.date.compareTo(a.date));
    recentItems = items.take(3).toList();
    notifyListeners();
  }

  void setTrendRange(int days) {
    trendRangeDays = days;
    notifyListeners();
  }

  /// ✅ Trend Counts
  int get trendAddedCount {
    final cutoff = DateTime.now().subtract(Duration(days: trendRangeDays));
    return allProductsData.where((p) {
      final ts = p['added_date'] as Timestamp?;
      final date = ts?.toDate();
      return date != null && date.isAfter(cutoff);
    }).length;
  }

  int get trendDonatedCount {
    final cutoff = DateTime.now().subtract(Duration(days: trendRangeDays));
    return recentItems.where((p) =>
        p.type == 'Donated' &&
        p.date.isAfter(cutoff)
    ).length;
  }

  int get trendSoldCount {
    final cutoff = DateTime.now().subtract(Duration(days: trendRangeDays));
    return recentItems.where((p) =>
        p.type == 'Sold' &&
        p.date.isAfter(cutoff)
    ).length;
  }
}

class RecentItem {
  final String productName, imageData, type;
  final DateTime date;
  RecentItem({
    required this.productName,
    required this.imageData,
    required this.type,
    required this.date,
  });
}