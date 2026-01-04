
import 'package:shared_preferences/shared_preferences.dart';

class GuestService {
  static const String _guestModeKey = 'is_guest_mode';
  static GuestService? _instance;
  
  bool _isGuestMode = false;
  
  GuestService._();
  
  static GuestService get instance {
    _instance ??= GuestService._();
    return _instance!;
  }
  
  bool get isGuestMode => _isGuestMode;
  
  /// Initialize guest mode state from preferences
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isGuestMode = prefs.getBool(_guestModeKey) ?? false;
  }
  
  /// Enable guest mode (user chose to preview without login)
  Future<void> enableGuestMode() async {
    _isGuestMode = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_guestModeKey, true);
  }
  
  /// Disable guest mode (user logged in or chose to exit)
  Future<void> disableGuestMode() async {
    _isGuestMode = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_guestModeKey, false);
  }
  
  /// Check if user can access premium features
  /// Premium features: Challenge, Verysense
  bool canAccessPremiumFeatures() {
    return !_isGuestMode;
  }
  
  /// Get guest display name
  String get guestDisplayName => 'Tamu';
  
  /// Get guest avatar initial
  String get guestAvatarInitial => 'T';
}

// Global instance for easy access
final guestService = GuestService.instance;
