// file: lib/main.dart
import 'package:factify/screens/main_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'screens/intro/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Load .env file
    await dotenv.load(fileName: ".env");
    print(".env file loaded successfully");
    print("GEMINI_API_KEY length: ${dotenv.env['GEMINI_API_KEY']?.length ?? 0}");
  } catch (e) {
    print("Error loading .env file: $e");
    // Continue running app even if .env fails to load
  }
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
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
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF1E232C),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF00C9A7)),
            ),
          );
        }
        
        if (snapshot.hasData && snapshot.data != null) {
          return const MainNavigationScreen();
        }
        
        return const SplashScreen();
      },
    );
  }
}