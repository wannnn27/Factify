import 'package:factify/screens/main_navigation.dart';
import 'package:factify/services/guest_service.dart';
import 'package:factify/utils/timeago_init.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';
import 'screens/intro/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Load .env file
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Continue running app even if .env fails to load
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization skipped: $e');
  }

  // Initialize Google Sign-In (MANDATORY for google_sign_in v7.x)
  // Must be called once before using authenticate()
  try {
    await GoogleSignIn.instance.initialize();
  } catch (e) {
    debugPrint('Google Sign-In initialization skipped: $e');
  }

  // Initialize guest service
  await guestService.init();

  // Initialize timeago locale for Bahasa Indonesia
  TimeAgoInit.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Factify',
      theme: ThemeData(
        fontFamily: 'Poppins',
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF1E232C),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    Stream<User?> authStream;
    try {
      authStream = FirebaseAuth.instance.authStateChanges();
    } catch (e) {
      debugPrint('Firebase Auth unavailable, showing unauthenticated flow: $e');
      return const SplashScreen();
    }

    return StreamBuilder<User?>(
      stream: authStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF1E232C),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF00C9A7)),
            ),
          );
        }

        // If user is authenticated, go to main navigation
        if (snapshot.hasData && snapshot.data != null) {
          return const MainNavigationScreen();
        }

        // Check if guest mode is enabled
        if (guestService.isGuestMode) {
          return const MainNavigationScreen();
        }

        // Otherwise, show splash/onboarding
        return const SplashScreen();
      },
    );
  }
}
