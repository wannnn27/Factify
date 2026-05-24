import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _emailError;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    setState(() {
      final email = _emailController.text.trim();
      if (email.isEmpty) {
        _emailError = null;
      } else if (!RegExp(r'^[\w\-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        _emailError = "Format email tidak valid";
      } else {
        _emailError = null;
      }
    });
  }

  Future<void> _handleResetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showSnackBar("Masukkan email Anda", isError: true);
      return;
    }

    if (_emailError != null) {
      _showSnackBar(_emailError!, isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.sendPasswordResetEmail(email);

      if (!mounted) return;

      _showSnackBar(
        "✅ Link reset password telah dikirim ke $email. Silakan cek inbox atau folder spam Anda.",
        isError: false,
      );

      // Kembali ke login setelah berhasil
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = "Email tidak terdaftar. Silakan periksa kembali.";
          break;
        case 'invalid-email':
          message = "Format email tidak valid.";
          break;
        case 'too-many-requests':
          message = "Terlalu banyak percobaan. Coba lagi nanti.";
          break;
        case 'network-request-failed':
          message = "Koneksi internet bermasalah.";
          break;
        default:
          message = "Gagal mengirim email reset: ${e.message}";
      }
      _showSnackBar(message, isError: true);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar("Gagal mengirim email reset. Silakan coba lagi.", isError: true);
      debugPrint('Reset password error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFFF6B6B) : const Color(0xFF00C9A7),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: Duration(seconds: isError ? 3 : 4),
      ),
    );
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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Lupa Password",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Masukkan email yang terdaftar. Kami akan mengirimkan link untuk mereset password Anda.",
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            CustomTextField(
              controller: _emailController,
              hintText: "Masukkan email anda",
              labelText: "Email",
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              errorText: _emailError,
              onChanged: (_) => _validateEmail(),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(color: Color(0xFF00C9A7)),
              )
            else
              PrimaryButton(
                text: "Kirim Reset Link",
                onPressed: _handleResetPassword,
              ),
          ],
        ),
      ),
    );
  }
}