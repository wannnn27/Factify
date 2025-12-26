// file: lib/screens/auth/forgot_password_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/custom_textfield.dart';
import '../../widgets/primary_button.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E232C),
      appBar: AppBar(backgroundColor: Colors.transparent, iconTheme: const IconThemeData(color: Colors.white)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text("Lupa Password", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            const CustomTextField(hintText: "Masukkan email anda"),
            const SizedBox(height: 20),
            PrimaryButton(text: "Kirim Reset Link", onPressed: () => Navigator.pop(context)),
          ],
        ),
      ),
    );
  }
}