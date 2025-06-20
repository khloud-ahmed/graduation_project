import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/screens/DonationTypeSelectionScreen.dart';
import 'package:flutter_application_1/screens/edit_donation_screen.dart';
import 'package:flutter_application_1/screens/donation_details_screen.dart';
import '../services/donation_service.dart';
import '../models/donation_model.dart';
import '../models/product_instance_model.dart';
import '../services/product_instance_service.dart';
import '../widgets/donation_card.dart';

class DonationPage extends StatefulWidget {
  const DonationPage({super.key});

  @override
  State<DonationPage> createState() => _DonationPageState();
}

class _DonationPageState extends State<DonationPage> with TickerProviderStateMixin {
  final DonationService _donationService = DonationService();
  final ProductInstanceService _instanceService = ProductInstanceService();
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  late TabController _tabController;

  List<DonationModel> allDonations = [];
  List<DonationModel> myDonations = [];
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
    _loadDonations();
  }

  Future<void> _loadDonations() async {
    setState(() => isLoading = true);
    try {
      final all = await _donationService.getAllDonations();
      final instances = await _instanceService.getAllInstances();
      final instanceMapTemp = { for (var i in instances) i.instanceId: i };

      final userIds = all.map((d) => d.donatorId).where((id) => id.trim().isNotEmpty).toSet();
      final Map<String, String> tempUserNames = {};
      for (final id in userIds) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(id).get();
        tempUserNames[id] = doc.data()?['firstName'] ?? 'Unknown';
      }

      final my = userId != null
          ? all.where((d) => d.donatorId == userId).toList()
          : <DonationModel>[];

      setState(() {
        allDonations = all;
        myDonations = my;
        instanceMap = instanceMapTemp;
        userNames = tempUserNames;
        isLoading = false;
      });
    } catch (_) {
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

  Widget _buildDonationList(List<DonationModel> donations) {
    final filtered = donations.where((d) {
      final instance = instanceMap[d.instanceId];
      if (instance == null) return false;
      return selectedCategory == 'All'
          || instance.category.toLowerCase() == selectedCategory.toLowerCase();
    }).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text('No donations found'));
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final donation = filtered[index];
        final instance = instanceMap[donation.instanceId]!;
        final donatorName = userNames[donation.donatorId] ?? 'Unknown';
        final isMyDonation = donation.donatorId == userId;

        Widget card = TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 500),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, val, child) => Opacity(
            opacity: val,
            child: Transform.translate(
              offset: Offset(0, (1 - val) * 20),
              child: child,
            ),
          ),
          child: DonationCard(instance: instance, donatorName: donatorName),
        );

        card = GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => DonationDetailsScreen(
                donation: donation,
                instance: instance,
                donatorName: donatorName,
              ),
            ),
          ),
          child: card,
        );

        if (isMyDonation) {
          return Dismissible(
            key: ValueKey(donation.id),
            direction: DismissDirection.horizontal,
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
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Confirm Delete'),
                    content: const Text('Are you sure you want to delete this donation?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete')),
                    ],
                  ),
                );
                if (confirm == true) {
                  await _donationService.deleteDonation(donation.id);
                  await _loadDonations();
                  return true;
                }
              } else if (direction == DismissDirection.endToStart) {
                final updated = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                      builder: (_) => EditDonationScreen(donation: donation)),
                );
                if (updated == true) {
                  await _loadDonations();
                }
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

  Future<void> _navigateToAddDonation() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const DonationTypeSelectionScreen()),
    );
    if (result == true) await _loadDonations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E7A8D)),
        title: const Text('Donations',
            style: TextStyle(color: Color(0xFF1E7A8D), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Color(0xFF1E7A8D)),
            onPressed: () {
              showSearch(
                context: context,
                delegate: DonationSearchDelegate(),
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
            Tab(text: 'All Donations'),
            Tab(text: 'My Donations'),
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
                      _buildDonationList(allDonations),
                      _buildDonationList(myDonations),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddDonation,
        backgroundColor: const Color(0xFF1E7A8D),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

/// --------------------
/// Search Delegate
/// --------------------
class DonationSearchDelegate extends SearchDelegate {
  final DonationService _donationService = DonationService();
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

  Future<List<DonationModel>> _searchResults() async {
    final donations = await _donationService.getAllDonations();
    final instanceMap = await _getInstanceMap();

    return donations.where((donation) {
      final instance = instanceMap[donation.instanceId];
      if (instance == null) return false;
      return instance.productName.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  Widget _buildResultList(
    List<DonationModel> donations,
    Map<String, ProductInstanceModel> instanceMap,
    Map<String, String> userNames,
  ) {
    if (donations.isEmpty) {
      return const Center(child: Text('No donations found'));
    }

    return ListView.builder(
      itemCount: donations.length,
      itemBuilder: (context, index) {
        final donation = donations[index];
        final instance = instanceMap[donation.instanceId]!;
        final donatorName = userNames[donation.donatorId] ?? 'Unknown';

        Widget card = DonationCard(
          instance: instance,
          donatorName: donatorName,
        );

        card = GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DonationDetailsScreen(
                  donation: donation,
                  instance: instance,
                  donatorName: donatorName,
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
    return FutureBuilder<List<DonationModel>>(
      future: _searchResults(),
      builder: (context, donationSnapshot) {
        if (donationSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (donationSnapshot.hasError) {
          return Center(child: Text('Error: ${donationSnapshot.error}'));
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
                        donationSnapshot.data!,
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
    // البحث المباشر نفس buildResults
    return buildResults(context);
  }
}