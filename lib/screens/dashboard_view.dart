import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dashboard_controller.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardController>(
      builder: (context, controller, child) {
        return RefreshIndicator(
          onRefresh: controller.fetchAllData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (controller.expiringSoon > 0)
                  _ExpiringAlert(controller: controller),
                if (controller.mostAddedCategoryName.isNotEmpty)
                  _MostAddedCategory(controller: controller),
                _TrendsWidget(controller: controller),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      _buildCard('Total Products', controller.totalProducts, Icons.check_circle, Colors.green),
                      const SizedBox(width: 10),
                      _buildCard('Expiring Soon', controller.expiringSoon, Icons.warning, Colors.orange),
                      const SizedBox(width: 10),
                      _buildCard('Expired Products', controller.expiredProducts, Icons.close, Colors.red),
                      const SizedBox(width: 10),
                      _buildCard('Donated Products', controller.donatedProducts, Icons.card_giftcard, Colors.blue),
                      const SizedBox(width: 10),
                      _buildCard('Sold Products', controller.soldProducts, Icons.sell, Colors.purple),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _CategoryStatusOverview(controller: controller),
                const SizedBox(height: 8),
                _ProductStatusDistribution(controller: controller),
                const SizedBox(height: 8),
                _RecentItems(controller: controller),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ---- Take Action (Expiring Products Bottom Sheet) ----
class _ExpiringAlert extends StatelessWidget {
  final DashboardController controller;
  const _ExpiringAlert({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.orange.shade100,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: const Icon(Icons.warning, color: Colors.orange),
        title: Text('${controller.expiringSoon} products are expiring this week'),
        trailing: ElevatedButton(
          onPressed: () => showModalBottomSheet(
            context: context,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
            builder: (_) => Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Expiring Products', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...controller.expiringProducts.map((e) => ListTile(
                        leading: const Icon(Icons.timer, color: Colors.orange),
                        title: Text(e['product_name'] ?? ''),
                        subtitle: Text(
                          'Expires: ${e['expiration_date'] != null && e['expiration_date'] is Timestamp
                              ? (e['expiration_date'] as Timestamp).toDate().toString().split(' ')[0]
                              : ''}',
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (v) {
                            if (v == 'sell') {
                              Navigator.pop(context);
                              Navigator.pushNamed(
                                context,
                                '/add_sell_from_existing_screen',
                                arguments: {'instanceId': e['id'],
          'productName': e['product_name'],},
                              );
                            } else if (v == 'donate') {
                              Navigator.pop(context);
                              Navigator.pushNamed(
                                context,
                                '/add_donation_from_existing_screen',
                                arguments: {'instanceId': e['id'],
          'productName': e['product_name'],},
                              );
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'donate', child: Text('Donate')),
                            const PopupMenuItem(value: 'sell', child: Text('Sell')),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange, foregroundColor: Colors.white),
          child: const Text('Take Action'),
        ),
      ),
    );
  }
}

// ---- باقي Widgets زي ما وضحتها لك ----

class _MostAddedCategory extends StatelessWidget {
  final DashboardController controller;
  const _MostAddedCategory({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('MOST ADDED CATEGORY', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            controller.mostAddedCategoryName[0].toUpperCase() + controller.mostAddedCategoryName.substring(1),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (controller.mostAddedCategoryExpiring > 0)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
              child: Text(
                'Review your ${controller.mostAddedCategoryName} stock, you have ${controller.mostAddedCategoryExpiring} items expiring soon!',
              ),
            ),
        ]),
      ),
    );
  }
}

class _TrendsWidget extends StatelessWidget {
  final DashboardController controller;
  const _TrendsWidget({required this.controller});

  @override
  Widget build(BuildContext context) {
    final added = controller.trendAddedCount;
final donated = controller.trendDonatedCount;
final sold = controller.trendSoldCount;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Trends', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ToggleButtons(
                borderRadius: BorderRadius.circular(8),
                selectedColor: Colors.white,
                fillColor: const Color(0xFF1E7A8D),
                color: Colors.black,
                isSelected: [controller.trendRangeDays == 7, controller.trendRangeDays == 30],
                onPressed: (index) {
                  controller.setTrendRange(index == 0 ? 7 : 30);
                },
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('7 Days'),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('30 Days'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            Text('Added: $added'),
            Text('Donated: $donated'),
            Text('Sold: $sold'),
          ]),
        ]),
      ),
    );
  }
}

Widget _buildCard(String title, int value, IconData icon, Color color) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
    color: color,
    child: SizedBox(
      width: 150,
      height: 160,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: value.toDouble()),
              duration: const Duration(milliseconds: 800),
              builder: (_, v, __) => Text('${v.toInt()} Items', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    ),
  );
}

class _CategoryStatusOverview extends StatelessWidget {
  final DashboardController controller;
  const _CategoryStatusOverview({required this.controller});

  @override
  Widget build(BuildContext context) {
    final categories = controller.categories;
    final labels = controller.labels;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Category Status Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 1.7,
              child: BarChart(
                BarChartData(
                  barGroups: [
                    for (int i = 0; i < categories.length; i++)
                      BarChartGroupData(
                        x: i,
                        barsSpace: 4,
                        barRods: [
                          BarChartRodData(toY: controller.safeByCat[categories[i]]!.toDouble(), color: Colors.green),
                          BarChartRodData(toY: controller.expiringByCat[categories[i]]!.toDouble(), color: Colors.orange),
                          BarChartRodData(toY: controller.expiredByCat[categories[i]]!.toDouble(), color: Colors.red),
                        ],
                      ),
                  ],
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, meta) {
                        int idx = v.toInt();
                        return Text(idx >= 0 && idx < categories.length ? labels[categories[idx]]! : '');
                      },
                    )),
                  ),
                ),
                swapAnimationDuration: const Duration(milliseconds: 800),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _ProductStatusDistribution extends StatelessWidget {
  final DashboardController controller;
  const _ProductStatusDistribution({required this.controller});

  Widget _legendDot(Color color) => Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle));

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Product Status Distribution', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(children: [
                        _legendDot(Colors.green),
                        const SizedBox(width: 6),
                        const Text('Safe'),
                        const Spacer(),
                        Text('${controller.safeProducts} %'),
                      ]),
                      const SizedBox(height: 6),
                      Row(children: [
                        _legendDot(Colors.orange),
                        const SizedBox(width: 6),
                        const Text('Expiring'),
                        const Spacer(),
                        Text('${controller.expiringSoon} %'),
                      ]),
                      const SizedBox(height: 6),
                      Row(children: [
                        _legendDot(Colors.red),
                        const SizedBox(width: 6),
                        const Text('Expired'),
                        const Spacer(),
                        Text('${controller.expiredProducts} %'),
                      ]),
                    ],
                  )),
              Expanded(
                  flex: 1,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: PieChart(
                      PieChartData(
                        centerSpaceRadius: 0,
                        borderData: FlBorderData(show: false),
                        sections: [
                          PieChartSectionData(
                            value: controller.safeProducts.toDouble(),
                            color: Colors.green,
                            radius: 50,
                            title: '${controller.safeProducts}%',
                            titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          PieChartSectionData(
                            value: controller.expiringSoon.toDouble(),
                            color: Colors.orange,
                            radius: 50,
                            title: '${controller.expiringSoon}%',
                            titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          PieChartSectionData(
                            value: controller.expiredProducts.toDouble(),
                            color: Colors.red,
                            radius: 50,
                            title: '${controller.expiredProducts}%',
                            titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                        startDegreeOffset: -90,
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentItems extends StatelessWidget {
  final DashboardController controller;
  const _RecentItems({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Recent Donations & Sales', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (controller.recentItems.isEmpty)
                const Center(child: Text('No recent items')),
              ...controller.recentItems.asMap().entries.map((e) {
                final it = e.value;
                final i = e.key;
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 500 + 100 * i),
                  builder: (_, op, child) => Opacity(opacity: op, child: child),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(it.imageData, width: 50, height: 50, fit: BoxFit.cover),
                    ),
                    title: Text(it.productName),
                    subtitle: Text(it.type),
                    trailing: Text(DateFormat('MMM d').format(it.date)),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}