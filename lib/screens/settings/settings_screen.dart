import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class SettingsScreen extends StatefulWidget {
  final void Function(bool) toggleTheme;
  final ThemeMode themeMode;
  final void Function(String) changeLanguage;
  final String currentLanguage;

  const SettingsScreen({
    super.key,
    required this.toggleTheme,
    required this.themeMode,
    required this.changeLanguage,
    required this.currentLanguage,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String userName = 'User Name';
  String userEmail = '';
  String? userImage;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = snapshot.data();
      setState(() {
        userEmail = user.email ?? '';
        userName = data?['firstName'] ?? 'User Name';
        userImage = data?['profileImage'];
      });
    }
  }

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final user = FirebaseAuth.instance.currentUser;
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images/${user!.uid}.jpg');

      await storageRef.putFile(File(pickedFile.path));
      final imageUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'profileImage': imageUrl});

      setState(() {
        userImage = imageUrl;
      });
    }
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.themeMode == ThemeMode.dark;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.deepPurple,
                  child: userImage == null
                      ? const Icon(Icons.person, size: 50, color: Colors.white)
                      : ClipOval(
                          child: Image.network(
                            userImage!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
                Positioned(
                  bottom: 0,
                  right: 4,
                  child: GestureDetector(
                    onTap: pickAndUploadImage,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.white,
                      child: const Icon(Icons.edit, size: 16, color: Colors.deepPurple),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Text(userName,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(userEmail,
                    style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 30),
          _buildSectionTitle('Account Settings'),
          _buildListTile(Icons.person_outline, 'Edit Profile', () {
            Navigator.pushNamed(context, '/edit_profile');
          }),
          _buildListTile(Icons.lock_outline, 'Change Password', () {
            Navigator.pushNamed(context, '/change_password');
          }),
          _buildListTile(Icons.notifications_none, 'Notification Preferences', () {
            Navigator.pushNamed(context, '/notification_preferences');
          }),
          const SizedBox(height: 30),
          _buildSectionTitle('App Settings'),
          ListTile(
            title: const Text('Language'),
            subtitle:
                Text(widget.currentLanguage == 'en' ? 'English' : 'Arabic'),
            leading: const Icon(Icons.language),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Select Language'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        widget.changeLanguage('en');
                        Navigator.pop(context);
                      },
                      child: const Text('English'),
                    ),
                    TextButton(
                      onPressed: () {
                        widget.changeLanguage('ar');
                        Navigator.pop(context);
                      },
                      child: const Text('Arabic'),
                    ),
                  ],
                ),
              );
            },
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            secondary: const Icon(Icons.dark_mode),
            value: isDark,
            onChanged: (value) {
              widget.toggleTheme(value);
            },
          ),
          const SizedBox(height: 30),
       ElevatedButton.icon(
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF1E7A8D), // اللون الجديد
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  ),
  icon: const Icon(Icons.logout, color: Colors.white), // أيقونة بلون أبيض
  label: const Text(
    'Log Out',
    style: TextStyle(fontSize: 16, color: Colors.white), // نص أبيض
  ),
  onPressed: () => _logout(context),
),

        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildListTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
