import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'theme/app_theme.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/otp_verification_page.dart';

import 'pages/main_shell.dart';
import 'pages/post_need_page.dart';
import 'pages/specification_safety_page.dart';
import 'pages/my_claims_page.dart';
import 'pages/my_requests_page.dart';
import 'pages/history_page.dart';
import 'pages/settings_page.dart';
import 'pages/profile_page.dart';
import 'pages/merit_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables for Firebase configuration
  await dotenv.load(fileName: '.env');

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    // Check if user is already authenticated
    final user = FirebaseAuth.instance.currentUser;
    final initialRoute = user != null ? '/home' : '/login';

    return MaterialApp(
      title: 'TrueNeighbour',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: AppTheme.theme,
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/otp': (context) => const OtpVerificationPage(),
        '/home': (context) => const MainShell(),
        '/post-need': (context) => const PostNeedPage(),
        '/spec-safety': (context) => const SpecificationSafetyPage(),
        '/my-requests': (context) => const MyRequestsPage(),
        '/my-claims': (context) => const MyClaimsPage(),
        '/history': (context) => const HistoryPage(),
        '/settings': (context) => const SettingsPage(),
        '/profile': (context) => const ProfilePage(),
        '/merit': (context) => const MeritPage(),
      },
    );
  }
}
