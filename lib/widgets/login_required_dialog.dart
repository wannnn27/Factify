import 'package:flutter/material.dart';
import 'package:factify/screens/auth/login_screen.dart';
import 'package:factify/services/guest_service.dart';

class LoginRequiredDialog extends StatelessWidget {
  final String featureName;
  final String description;
  final IconData icon;
  final Color iconColor;
  
  const LoginRequiredDialog({
    super.key,
    required this.featureName,
    required this.description,
    this.icon = Icons.lock_outline,
    this.iconColor = const Color(0xFF4ECDC4),
  });
  
  /// Show the login required dialog
  static Future<bool?> show(
    BuildContext context, {
    required String featureName,
    required String description,
    IconData icon = Icons.lock_outline,
    Color iconColor = const Color(0xFF4ECDC4),
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => LoginRequiredDialog(
        featureName: featureName,
        description: description,
        icon: icon,
        iconColor: iconColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF2D2D44),
              Color(0xFF1A1A2E),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: iconColor.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: iconColor.withValues(alpha: 0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Container with Glow
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    iconColor.withValues(alpha: 0.3),
                    iconColor.withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withValues(alpha: 0.3),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 48,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Title
            Text(
              'Login Diperlukan',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Feature Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                featureName,
                style: TextStyle(
                  color: iconColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Description
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Benefits List
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildBenefitItem(
                    Icons.verified_user,
                    'Akses Verysense AI untuk cek fakta',
                    const Color(0xFF4ECDC4),
                  ),
                  const SizedBox(height: 12),
                  _buildBenefitItem(
                    Icons.emoji_events,
                    'Ikuti Challenge dan kumpulkan poin',
                    const Color(0xFFFFD93D),
                  ),
                  const SizedBox(height: 12),
                  _buildBenefitItem(
                    Icons.history,
                    'Simpan riwayat verifikasi',
                    const Color(0xFF6C5CE7),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action Buttons
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.grey[600]!,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Text(
                      'Nanti Saja',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Login Button
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () async {
                      await guestService.disableGuestMode();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (route) => false,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: iconColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.login, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Login Sekarang',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBenefitItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}
