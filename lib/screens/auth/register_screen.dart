// file: lib/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordObscure = true;
  bool _isConfirmPasswordObscure = true;
  bool _agreeToTerms = false;
  bool _isLoading = false;

  // Password validation states
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  bool _passwordsMatch = false;

  String? _emailError;
  String? _phoneError;
  String? _usernameError;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_checkPasswordMatch);
    _emailController.addListener(_validateEmail);
    _phoneController.addListener(_validatePhone);
    _usernameController.addListener(_validateUsername);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePassword() {
    setState(() {
      final password = _passwordController.text;
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
    });
    _checkPasswordMatch();
  }

  void _checkPasswordMatch() {
    setState(() {
      _passwordsMatch = _passwordController.text.isNotEmpty &&
          _passwordController.text == _confirmPasswordController.text;
    });
  }

  void _validateEmail() {
    setState(() {
      final email = _emailController.text;
      if (email.isEmpty) {
        _emailError = null;
      } else if (!RegExp(r'^[\w\-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        _emailError = "Format email tidak valid";
      } else {
        _emailError = null;
      }
    });
  }

  void _validatePhone() {
    setState(() {
      final phone = _phoneController.text;
      if (phone.isEmpty) {
        _phoneError = null;
      } else if (!RegExp(r'^(\+62|62|0)[0-9]{9,12}$').hasMatch(phone)) {
        _phoneError = "Format nomor HP tidak valid";
      } else {
        _phoneError = null;
      }
    });
  }

  void _validateUsername() {
    setState(() {
      final username = _usernameController.text;
      if (username.isEmpty) {
        _usernameError = null;
      } else if (username.length < 3) {
        _usernameError = "Nama minimal 3 karakter";
      } else {
        _usernameError = null;
      }
    });
  }

  bool _isFormValid() {
    return _usernameController.text.isNotEmpty &&
        _usernameError == null &&
        _emailController.text.isNotEmpty &&
        _emailError == null &&
        _phoneController.text.isNotEmpty &&
        _phoneError == null &&
        _hasMinLength &&
        _hasUppercase &&
        _hasLowercase &&
        _hasNumber &&
        _hasSpecialChar &&
        _passwordsMatch &&
        _agreeToTerms;
  }

  void _handleRegister() async {
    if (!_isFormValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Mohon lengkapi semua field dengan benar"),
          backgroundColor: const Color(0xFFFF6B6B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Buat akun baru
      UserCredential? userCredential = await _authService.signUpWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
        _usernameController.text.trim(),
        _phoneController.text.trim(),
      );

      if (!mounted) return;

      if (userCredential != null) {
        // LANGKAH 1: Logout user yang baru dibuat
        await _authService.signOut();
        
        if (!mounted) return;

        // LANGKAH 2: Kembali ke halaman login
        Navigator.of(context).pop();
        
        // LANGKAH 3: Tampilkan pesan sukses setelah kembali
        await Future.delayed(const Duration(milliseconds: 200));
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("✅ Akun berhasil dibuat! Silakan login"),
              backgroundColor: const Color(0xFF00C9A7),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 3),
            ),
          );
        }
        
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Gagal mendaftar. Silakan coba lagi."),
            backgroundColor: const Color(0xFFFF6B6B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = "Email ini sudah terdaftar. Silakan gunakan email lain.";
          break;
        case 'weak-password':
          message = "Password terlalu lemah.";
          break;
        case 'invalid-email':
          message = "Format email tidak valid.";
          break;
        case 'operation-not-allowed':
          message = "Registrasi dengan email tidak diizinkan.";
          break;
        case 'network-request-failed':
          message = "Koneksi internet bermasalah. Silakan coba lagi.";
          break;
        default:
          message = "Terjadi kesalahan: ${e.message}";
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: const Color(0xFFFF6B6B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: const Color(0xFFFF6B6B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E232C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Buat Akun Baru",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Daftar dan mulai perjalanan literasi digitalmu",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[400],
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              CustomTextField(
                controller: _usernameController,
                hintText: "Masukkan Nama Lengkap",
                labelText: "Nama Lengkap",
                prefixIcon: Icons.person_outline,
                errorText: _usernameError,
              ),

              const SizedBox(height: 16),

              CustomTextField(
                controller: _emailController,
                hintText: "Masukkan Email",
                labelText: "Email",
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                errorText: _emailError,
              ),

              const SizedBox(height: 16),

              CustomTextField(
                controller: _phoneController,
                hintText: "08xx xxxx xxxx",
                labelText: "Nomor HP",
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                errorText: _phoneError,
              ),

              const SizedBox(height: 16),

              CustomTextField(
                controller: _passwordController,
                hintText: "Masukkan Password",
                labelText: "Password",
                isPassword: true,
                isObscure: _isPasswordObscure,
                prefixIcon: Icons.lock_outline,
                onToggleVisibility: () => setState(() => _isPasswordObscure = !_isPasswordObscure),
              ),

              const SizedBox(height: 12),

              _buildPasswordRequirements(),

              const SizedBox(height: 16),

              CustomTextField(
                controller: _confirmPasswordController,
                hintText: "Konfirmasi Password",
                labelText: "Konfirmasi Password",
                isPassword: true,
                isObscure: _isConfirmPasswordObscure,
                prefixIcon: Icons.lock_outline,
                onToggleVisibility: () => setState(() => _isConfirmPasswordObscure = !_isConfirmPasswordObscure),
              ),

              const SizedBox(height: 8),

              if (_confirmPasswordController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Row(
                    children: [
                      Icon(
                        _passwordsMatch ? Icons.check_circle : Icons.cancel,
                        size: 16,
                        color: _passwordsMatch ? const Color(0xFF00C9A7) : const Color(0xFFFF6B6B),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _passwordsMatch ? "Password cocok" : "Password tidak cocok",
                        style: TextStyle(
                          color: _passwordsMatch ? const Color(0xFF00C9A7) : const Color(0xFFFF6B6B),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _agreeToTerms,
                      onChanged: (value) => setState(() => _agreeToTerms = value ?? false),
                      activeColor: const Color(0xFF00C9A7),
                      side: BorderSide(color: Colors.grey[400]!, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _agreeToTerms = !_agreeToTerms),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.grey[400], fontSize: 13),
                          children: const [
                            TextSpan(text: "Saya setuju dengan "),
                            TextSpan(
                              text: "Syarat & Ketentuan",
                              style: TextStyle(
                                color: Color(0xFF00C9A7),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(text: " dan "),
                            TextSpan(
                              text: "Kebijakan Privasi",
                              style: TextStyle(
                                color: Color(0xFF00C9A7),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              if (_isLoading)
                const Center(child: CircularProgressIndicator(color: Color(0xFF00C9A7)))
              else
                Opacity(
                  opacity: _isFormValid() ? 1.0 : 0.5,
                  child: PrimaryButton(
                    text: "Buat Akun",
                    onPressed: _isFormValid() ? _handleRegister : () {},
                  ),
                ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Sudah punya akun? ",
                    style: TextStyle(color: Colors.grey[400]),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      "Masuk",
                      style: TextStyle(
                        color: Color(0xFF00C9A7),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordRequirements() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2B3039),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color.fromRGBO(158, 158, 158, 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Password harus mengandung:",
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          _buildRequirementItem("Minimal 8 karakter", _hasMinLength),
          _buildRequirementItem("Huruf besar (A-Z)", _hasUppercase),
          _buildRequirementItem("Huruf kecil (a-z)", _hasLowercase),
          _buildRequirementItem("Angka (0-9)", _hasNumber),
          _buildRequirementItem("Karakter spesial (!@#\$%^&*)<>", _hasSpecialChar),
        ],
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14,
            color: isMet ? const Color(0xFF00C9A7) : Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isMet ? const Color(0xFF00C9A7) : Colors.grey[500],
              fontSize: 11,
              fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}