import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/sell_model.dart';
import '../models/product_instance_model.dart';
import '../services/sell_service.dart';
import '../services/product_instance_service.dart';
import '../widgets/sell_card.dart';
import 'sell_details_screen.dart';

import '../screens/sell_type_selection_screen.dart';
import '../screens/edit_sell_screen.dart'; // ✅ شاشة التعديل

class SellPage extends StatefulWidget {
  const SellPage({super.key});

  @override
  State<SellPage> createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> with TickerProviderStateMixin {
  final SellService _sellService = SellService();
  final ProductInstanceService _instanceService = ProductInstanceService();
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  late TabController _tabController;

  List<SellModel> allSells = [];
  List<SellModel> mySells = [];
  Map<String, ProductInstanceModel> instanceMap = {};
  Map<String, String> userNames = {};

  bool isLoading = true;
  String selectedCategory = 'All';

  final List<String> categories = ['All', 'medicine', 'skincare', 'haircare', 'food'];
  final Map<String, String> categoryLabels = {
    'All': 'All',
    'medicine': 'Medicine',
    'skincare': 'Skincare',
    'haircare': 'Haircare',
    'food': 'Food',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadSells();
  }

  Future<void> _loadSells() async {
    setState(() => isLoading = true);
    try {
      final all = await _sellService.getAllSells();
      final instances = await _instanceService.getAllInstances();
      final instanceMapTemp = { for (var i in instances) i.instanceId: i };

      final userIds = all.map((s) => s.sellerId).toSet();
      final Map<String, String> tempUserNames = {};
      for (final id in userIds) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(id).get();
        tempUserNames[id] = doc.data()?['firstName'] ?? 'Unknown';
      }

      final my = userId != null
          ? all.where((s) => s.sellerId == userId).toList()
          : <SellModel>[];

      setState(() {
        allSells = all;
        mySells = my;
        instanceMap = instanceMapTemp;
        userNames = tempUserNames;
        isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading sells: $e');
      setState(() => isLoading = false);
    }
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: categories.map((cat) {
          final isSelected = selectedCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = cat),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1E7A8D) : Colors.white,
                border: Border.all(color: const Color(0xFF1E7A8D)),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                categoryLabels[cat]!,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF1E7A8D),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSellList(List<SellModel> sells) {
    final filtered = sells.where((s) {
      final instance = instanceMap[s.instanceId];
      if (instance == null) return false;
      return selectedCategory == 'All' ||
          instance.category.toLowerCase() == selectedCategory.toLowerCase();
    }).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text('No items for sale'));
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final sell = filtered[index];
        final instance = instanceMap[sell.instanceId]!;
        final sellerName = userNames[sell.sellerId] ?? 'Unknown';
        final isMySell = sell.sellerId == userId;

        Widget card = GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SellDetailsScreen(
                  instance: instance,
                  sell: sell,
                  sellerName: sellerName,
                ),
              ),
            );
          },
          child: SellCard(
            instance: instance,
            sellerName: sellerName,
            price: sell.price,
          ),
        );

        if (isMySell) {
          card = Dismissible(
            key: ValueKey(sell.id),
            background: Container(
              color: Colors.green,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.edit, color: Colors.white),
            ),
            secondaryBackground: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditSellScreen(sell: sell),
                  ),
                );
                if (result == true) {
                  await _loadSells();
                }
                return false;
              }

              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Confirm Deletion'),
                  content: const Text('Are you sure you want to delete this sale?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await _sellService.deleteSell(sell.id);
                await _loadSells();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sale deleted')),
                );
                return true;
              }

              return false;
            },
            child: card,
          );
        }

        return card;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E7A8D)),
        title: const Text(
          'Sell Items',
          style: TextStyle(color: Color(0xFF1E7A8D), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF1E7A8D)),
            onPressed: () {
              showSearch(
                context: context,
                delegate: SellSearchDelegate(),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF1E7A8D),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF1E7A8D),
          tabs: const [
            Tab(text: 'All Items'),
            Tab(text: 'My Items'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildCategoryFilter(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSellList(allSells),
                      _buildSellList(mySells),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SellTypeSelectionScreen()),
          );
          if (result == true) await _loadSells();
        },
        backgroundColor: const Color(0xFF1E7A8D),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

/// ✅ SellSearchDelegate
class SellSearchDelegate extends SearchDelegate {
  final SellService _sellService = SellService();
  final ProductInstanceService _instanceService = ProductInstanceService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  Future<Map<String, ProductInstanceModel>> _getInstanceMap() async {
    final instances = await _instanceService.getAllInstances();
    return { for (var i in instances) i.instanceId: i };
  }

  Future<Map<String, String>> _getUserNames() async {
    final users = await _firestore.collection('users').get();
    return {
      for (var doc in users.docs)
        doc.id: (doc.data()['firstName'] ??
                doc.data()['first_name'] ??
                doc.data()['name'] ??
                'Unknown')
                .toString()
    };
  }

  Future<List<SellModel>> _searchResults() async {
    final sells = await _sellService.getAllSells();
    final instanceMap = await _getInstanceMap();

    return sells.where((sell) {
      final instance = instanceMap[sell.instanceId];
      if (instance == null) return false;
      return instance.productName.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  Widget _buildResultList(
    List<SellModel> sells,
    Map<String, ProductInstanceModel> instanceMap,
    Map<String, String> userNames,
  ) {
    if (sells.isEmpty) {
      return const Center(child: Text('No items found'));
    }

    return ListView.builder(
      itemCount: sells.length,
      itemBuilder: (context, index) {
        final sell = sells[index];
        final instance = instanceMap[sell.instanceId]!;
        final sellerName = userNames[sell.sellerId] ?? 'Unknown';

        Widget card = SellCard(
          instance: instance,
          sellerName: sellerName,
          price: sell.price,
        );

        card = GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SellDetailsScreen(
                  instance: instance,
                  sell: sell,
                  sellerName: sellerName,
                ),
              ),
            );
          },
          child: card,
        );

        return card;
      },
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<SellModel>>(
      future: _searchResults(),
      builder: (context, sellSnapshot) {
        if (sellSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (sellSnapshot.hasError) {
          return Center(child: Text('Error: ${sellSnapshot.error}'));
        } else {
          return FutureBuilder<Map<String, ProductInstanceModel>>(
            future: _getInstanceMap(),
            builder: (context, instanceSnapshot) {
              if (instanceSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (instanceSnapshot.hasError) {
                return Center(child: Text('Error: ${instanceSnapshot.error}'));
              } else {
                return FutureBuilder<Map<String, String>>(
                  future: _getUserNames(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (userSnapshot.hasError) {
                      return Center(child: Text('Error: ${userSnapshot.error}'));
                    } else {
                      return _buildResultList(
                        sellSnapshot.data!,
                        instanceSnapshot.data!,
                        userSnapshot.data!,
                      );
                    }
                  },
                );
              }
            },
          );
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}