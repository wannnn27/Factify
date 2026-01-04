import 'package:flutter/material.dart';
import 'package:factify/services/guest_service.dart';
import 'package:factify/widgets/login_required_dialog.dart';
import 'tabs/home_screen.dart';
import 'tabs/education_screen.dart';
import 'verysense/verysense_screen_new.dart';
import 'tabs/challenge_screen.dart';
import 'tabs/profile_screen.dart';
import 'tabs/guest_profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  bool _isGuestMode = false;

  @override
  void initState() {
    super.initState();
    _checkGuestMode();
  }

  Future<void> _checkGuestMode() async {
    await guestService.init();
    if (mounted) {
      setState(() {
        _isGuestMode = guestService.isGuestMode;
      });
    }
  }

  List<Widget> get _authenticatedPages => [
    const HomeScreen(),
    const EducationScreen(),
    const VerysenseScreenNew(),
    const ChallengeScreen(),
    const ProfileScreen(),
  ];

  Widget _getPageForIndex(int index) {
    if (_isGuestMode) {
      switch (index) {
        case 0:
          return const HomeScreen();
        case 1:
          return const EducationScreen();
        case 2:
          return const VerysenseScreenNew();
        case 3:
          return const ChallengeScreen();
        case 4:
          return const GuestProfileScreen();
        default:
          return const HomeScreen();
      }
    } else {
      return _authenticatedPages[index];
    }
  }

  void _onTabTapped(int index) {
    if (_isGuestMode && (index == 2 || index == 3)) {
      _showPremiumFeatureDialog(index);
      return;
    }
    
    setState(() => _currentIndex = index);
  }

  void _showPremiumFeatureDialog(int featureIndex) {
    String featureName;
    String description;
    IconData icon;
    Color iconColor;

    switch (featureIndex) {
      case 2:
        featureName = 'Verysense AI';
        description = 'Fitur cek fakta dengan AI memerlukan akun untuk menyimpan riwayat verifikasi dan memberikan hasil yang lebih akurat.';
        icon = Icons.verified_user;
        iconColor = const Color(0xFF4ECDC4);
        break;
      case 3:
        featureName = 'Challenge Mode';
        description = 'Uji kemampuan literasi digitalmu dan kumpulkan poin! Login untuk melacak progress dan bersaing dengan pengguna lain.';
        icon = Icons.emoji_events;
        iconColor = const Color(0xFFFFD93D);
        break;
      default:
        return;
    }

    LoginRequiredDialog.show(
      context,
      featureName: featureName,
      description: description,
      icon: icon,
      iconColor: iconColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E232C),
      body: _getPageForIndex(_currentIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1E232C),
        selectedItemColor: const Color(0xFF00C9A7),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          const BottomNavigationBarItem(icon: Icon(Icons.school_outlined), label: "Edu"),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.center_focus_strong),
                if (_isGuestMode)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFD93D),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock,
                        size: 8,
                        color: Colors.black,
                      ),
                    ),
                  ),
              ],
            ),
            label: "Scan",
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.emoji_events_outlined),
                if (_isGuestMode)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFD93D),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock,
                        size: 8,
                        color: Colors.black,
                      ),
                    ),
                  ),
              ],
            ),
            label: "Challenge",
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profil"),
        ],
      ),
    );
  }
}