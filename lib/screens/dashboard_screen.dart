import 'package:provider/provider.dart';
import 'dashboard_controller.dart';
import 'dashboard_view.dart';
import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';
//import 'dashboard_controller.dart';
//import 'dashboard_view.dart';


class DashboardScreen extends StatelessWidget {
  final String userId;
  const DashboardScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardController(userId: userId),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard', style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: const DashboardView(),
      ),
    );
  }
}