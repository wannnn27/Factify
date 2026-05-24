import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/user_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;

  String? _base64Image; // Stores the image in Base64 format
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _bioController = TextEditingController();
    _loadCurrentProfile();
  }

  Future<void> _loadCurrentProfile() async {
    setState(() => _isLoading = true);
    UserProfile? profile = await UserService.getUserProfile();
    
    if (profile != null) {
      _nameController.text = profile.name;
      _emailController.text = profile.email;
      _phoneController.text = profile.phone;
      _bioController.text = profile.bio;
      _base64Image = profile.photoBase64;
    } else {
       // Default dummy data if empty
       _nameController.text = "User Factify";
       _bioController.text = "Digital Literacy Enthusiast";
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50); // Compress quality

    if (image != null) {
      // Read bytes and convert to Base64
      final bytes = await image.readAsBytes();
      final String base64String = base64Encode(bytes);

      setState(() {
        _base64Image = base64String;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      UserProfile newProfile = UserProfile(
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        bio: _bioController.text,
        photoBase64: _base64Image,
      );

      await UserService.saveUserProfile(newProfile);

      // Sync to Firestore if authenticated
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        try {
          final authService = AuthService();
          await authService.updateUserProfile(
            uid: currentUser.uid,
            username: newProfile.name,
            phone: newProfile.phone,
            bio: newProfile.bio,
            photoBase64: newProfile.photoBase64,
          );
        } catch (e) {
          debugPrint('Failed to sync profile to Firestore: $e');
        }
      }

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui!'),
          backgroundColor: Color(0xFF4ECDC4),
        ),
      );

      Navigator.pop(context, true); // Return true to signal refresh
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E232C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E232C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Edit Profil',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Color(0xFF4ECDC4)),
            onPressed: _isLoading ? null : _saveProfile,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF4ECDC4)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Profile Image
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF2B3039),
                              border: Border.all(
                                color: const Color(0xFF4ECDC4),
                                width: 2,
                              ),
                              image: _base64Image != null
                                  ? DecorationImage(
                                      image: MemoryImage(base64Decode(_base64Image!)),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: _base64Image == null
                                ? const Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF4ECDC4),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Forms
                    _buildTextField(
                      controller: _nameController,
                      label: 'Nama Lengkap',
                      icon: Icons.person_outline,
                      validator: (v) => v!.isEmpty ? 'Nama tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Nomor Telepon',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _bioController,
                      label: 'Bio Singkat',
                      icon: Icons.info_outline,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 40),
                    
                    // Save Button (Duplicate for convenience)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4ECDC4),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: Colors.grey,
                        ),
                        child: Text(
                          _isLoading ? 'Menyimpan...' : 'Simpan Perubahan',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF2B3039),
            prefixIcon: Icon(icon, color: const Color(0xFF4ECDC4)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            errorStyle: const TextStyle(color: Color(0xFFFF6B6B)),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }
}
