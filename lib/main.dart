import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
//import '/app_globals.dart'; 
// Screens
import 'screens/splash_screen.dart';
import 'onboarding/onboarding_screen.dart';
import 'auth/login_page.dart';
import 'auth/signup_page.dart';
import 'screens/home_screen.dart';
import '/models/product_instance_model.dart';
import 'screens/edit_product_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/settings/edit_profile_screen.dart';
import 'screens/settings/change_password_screen.dart';
import 'screens/settings/notification_preferences_screen.dart';
import 'screens/notification_center_screen.dart';
import 'services/fcm_service.dart';
import 'services/local_notification_service.dart';
import 'screens/add_donation_from_existing_screen.dart';
import 'screens/add_sell_from_existing_screen.dart';

// ✅ Global navigatorKey (the same one used in LocalNotificationService)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Firebase already initialized: $e');
  }

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // ✅ Initialize notification service here with no context
  LocalNotificationService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = const Locale('en');
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    // ✅ No need to pass context here either if you adjust FCMService the same way
    // Example: FCMService().initFCM(); 
    // Or pass navigatorKey if needed
    FCMService().initFCM();
  }

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _changeLanguage(String languageCode) {
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // ✅ Use the global key
      title: 'ExpiSave App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      locale: _locale,
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/home': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as String?;
          return HomeScreen(userId: args ?? '');
        },
        '/settings': (context) => SettingsScreen(
              toggleTheme: _toggleTheme,
              themeMode: _themeMode,
              changeLanguage: _changeLanguage,
              currentLanguage: _locale.languageCode,
            ),
        '/edit_profile': (context) => const EditProfileScreen(),
        '/change_password': (context) => const ChangePasswordScreen(),
        '/notification_preferences': (context) =>
            const NotificationPreferencesScreen(),
        '/notification_center': (context) =>
            const NotificationCenterScreen(),
        '/edit_product': (context) {
          final args =
              ModalRoute.of(context)!.settings.arguments as ProductInstanceModel;
          return EditProductScreen(instance: args);
        },
        '/add_donation_from_existing_screen': (context) =>
            const AddDonationFromExistingScreen(),
        '/add_sell_from_existing_screen': (context) =>
            const AddSellFromExistingScreen(),
      },
    );
  }
}