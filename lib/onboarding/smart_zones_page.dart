import 'package:flutter/material.dart';

class SmartZonesPage extends StatefulWidget {
  const SmartZonesPage({super.key});

  @override
  State<SmartZonesPage> createState() => _SmartZonesPageState();
}

class _SmartZonesPageState extends State<SmartZonesPage> with TickerProviderStateMixin {
  final List<Map<String, dynamic>> items = [
    {
      'dotColor': Colors.green,
      'squareColor': Colors.green,
      'label': 'Safe',
      'icon': Icons.check_circle_outline,
    },
    {
      'dotColor': Colors.orange,
      'squareColor': Colors.orange,
      'label': 'Expiring Soon',
      'icon': Icons.access_time,
    },
    {
      'dotColor': Colors.red,
      'squareColor': Colors.red,
      'label': 'Expired',
      'icon': Icons.cancel_outlined,
    },
  ];

  late final List<AnimationController> _controllers;
  late final List<Animation<Offset>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      items.length,
      (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );

    _animations = _controllers.map((controller) {
      return Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeOut,
      ));
    }).toList();

    _startAnimations();
  }

  void _startAnimations() async {
    for (int i = 0; i < _controllers.length; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      _controllers[i].forward();
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const SizedBox.shrink(), // ✅ شيلنا العنوان من فوق
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Smart Zones for Your Products',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E7A8D),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Your items are grouped into Safe, Expiring Soon, and Expired zones based on expiry dates.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),

            // ✅ Color Legend Section (Larger squares with icons)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildColorLegend('Safe', Colors.green, Icons.check),
                const SizedBox(height: 24),
                _buildColorLegend('Expiring Soon', Colors.orange, Icons.access_time),
                const SizedBox(height: 24),
                _buildColorLegend('Expired', Colors.red, Icons.cancel),
              ],
            ),
            const SizedBox(height: 40),

            // ✅ Animated Cards Section
            ...List.generate(items.length, (index) {
              final item = items[index];
              return AnimatedSlide(
                offset: _animations[index].value,
                duration: const Duration(milliseconds: 500),
                child: AnimatedOpacity(
                  opacity: _controllers[index].isCompleted ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: (item['squareColor'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Icon(
                        item['icon'] as IconData,
                        color: item['squareColor'] as Color,
                        size: 36,
                      ),
                      title: Text(
                        item['label'] as String,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: item['squareColor'] as Color,
                        ),
                      ),
                      subtitle: const Text(
                        'Tap to view products in this zone.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                      onTap: () {
                        // Add navigation logic if needed.
                      },
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildColorLegend(String label, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          width: 90, // ✅ Increased Size
          height: 90,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: Colors.white, size: 40),
        ),
        const SizedBox(width: 16),
        Text(
          label,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
