// file: lib/screens/main_navigation.dart
import 'package:flutter/material.dart';
import 'tabs/home_screen.dart';
import 'tabs/education_screen.dart';
import 'tabs/verysense_screen.dart';
import 'tabs/challenge_screen.dart';
import 'tabs/profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const EducationScreen(),
    const VerysenseScreen(),
    const ChallengeScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E232C),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1E232C),
        selectedItemColor: const Color(0xFF00C9A7),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.school_outlined), label: "Edu"),
          BottomNavigationBarItem(icon: Icon(Icons.center_focus_strong), label: "Scan"),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events_outlined), label: "Challenge"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profil"),
        ],
      ),
    );
  }
}