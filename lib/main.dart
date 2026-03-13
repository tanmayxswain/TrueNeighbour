import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'theme/app_theme.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/otp_verification_page.dart';
import 'pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables for Firebase configuration
  await dotenv.load(fileName: '.env');

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if user is already authenticated
    final user = FirebaseAuth.instance.currentUser;
    final initialRoute = user != null ? '/home' : '/login';

    return MaterialApp(
      title: 'TrueNeighbour',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/otp': (context) => const OtpVerificationPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}
