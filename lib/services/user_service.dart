import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  String name;
  String email;
  String phone;
  String bio;
  String? photoBase64;

  UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.bio,
    this.photoBase64,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      bio: json['bio'] ?? '',
      photoBase64: json['photoBase64'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'bio': bio,
      'photoBase64': photoBase64,
    };
  }
}

class UserService {
  static const String _userKey = 'user_profile_data';

  // Save User Profile
  static Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(profile.toJson());
    await prefs.setString(_userKey, jsonString);
  }

  // Get User Profile
  static Future<UserProfile?> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(_userKey);
    if (jsonString != null) {
      try {
        Map<String, dynamic> jsonMap = jsonDecode(jsonString);
        return UserProfile.fromJson(jsonMap);
      } catch (e) {
        print("Error parsing user profile: $e");
        return null;
      }
    }
    return null;
  }

  // Clear User Data (Logout)
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
