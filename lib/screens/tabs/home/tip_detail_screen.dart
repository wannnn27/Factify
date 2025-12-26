// file: lib/screens/tabs/home/tip_detail_screen.dart
import 'package:flutter/material.dart';

class TipDetailScreen extends StatelessWidget {
  final Map<String, dynamic> tip;

  const TipDetailScreen({super.key, required this.tip});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = tip['color'] as Color;
    final IconData icon = tip['icon'] as IconData;
    final String title = tip['title'] as String;
    final String subtitle = tip['subtitle'] as String;

    String detailedContent;
    List<Widget> tipCards = [];

    switch (title) {
      case 'Cek Sumber Informasi':
        detailedContent =
            'Di era informasi yang melimpah, memeriksa sumber adalah langkah pertama untuk menghindari misinformasi dan disinformasi. Tanyakan pada diri sendiri sebelum mempercayai atau membagikan konten:';
        tipCards = [
          _buildTipCard('Siapa pembuat konten ini?', 'Apakah ada nama penulis, institusi, atau organisasi yang jelas?'),
          _buildTipCard('Apakah situs resmi dan terpercaya?', 'Periksa domain (.go.id, .ac.id untuk resmi), logo institusi, dan sertifikat SSL (gembok di browser).'),
          _buildTipCard('Ada informasi kontak atau "Tentang Kami"?', 'Situs kredibel biasanya menyediakan email, alamat, atau nomor telepon yang valid.'),
          _buildTipCard('Hindari sumber anonim', 'Akun media sosial tanpa identitas jelas sering menjadi sarang hoaks.'),
          const SizedBox(height: 16),
          const Text(
            'Tips tambahan: Gunakan tools seperti Whois.domaintools.com untuk cek kepemilikan domain.',
            style: TextStyle(color: Colors.white, fontSize: 16, height: 1.6),
          ),
        ];
        break;

      case 'Verifikasi Fakta':
        detailedContent =
            'Jangan langsung percaya berita sensasional atau emosional. Lakukan verifikasi mandiri dengan langkah-langkah berikut:';
        tipCards = [
          _buildTipCard('Gunakan situs fact-checking terpercaya di Indonesia (2025):',
              '• cekfakta.com (kolaborasi MAFINDO & media)\n• turnbackhoax.id (MAFINDO)\n• liputan6.com/cek-fakta\n• cekfakta.kompas.com\n• Google Fact Check Tools (factchecktools.google.com)'),
          _buildTipCard('Cari di media mainstream kredibel', 'Bandingkan dengan Kompas, Tempo, Detik, atau ANTARA. Jika tidak ada, kemungkinan hoaks.'),
          _buildTipCard('Perhatikan tanggal & update', 'Berita lama sering diputar ulang sebagai "baru". Cek apakah ada koreksi resmi.'),
          _buildTipCard('Reverse image search untuk foto/video', 'Gunakan Google Images, TinEye, atau Yandex untuk cek asal gambar.'),
          const SizedBox(height: 16),
          const Text(
            'Ingat: Hoaks sering memanfaatkan emosi (marah, takut). Berhenti sejenak sebelum share!',
            style: TextStyle(color: Colors.white, fontSize: 16, height: 1.6, fontStyle: FontStyle.italic),
          ),
        ];
        break;

      case 'Gunakan Password Kuat':
        detailedContent =
            'Password adalah benteng utama keamanan digital Anda. Menurut NIST 2025, panjang lebih penting daripada kompleksitas berlebih:';
        tipCards = [
          _buildTipCard('Minimal 16 karakter (ideal 20+)', 'Gunakan passphrase: gabungan 4-5 kata acak, misalnya "Bulan-Merah@Hijau2025!".'),
          _buildTipCard('Hindari data pribadi', 'Jangan pakai nama, tanggal lahir, nomor HP, atau kata umum seperti "password123".'),
          _buildTipCard('Unik untuk setiap akun', 'Jangan reuse password antar situs.'),
          _buildTipCard('Aktifkan Multi-Factor Authentication (MFA)', 'Prioritaskan passkeys/biometrik jika tersedia – lebih aman daripada password saja.'),
          _buildTipCard('Gunakan Password Manager', 'Rekomendasi gratis/aman: Bitwarden, Proton Pass, atau built-in di browser (Google/Apple).'),
          const SizedBox(height: 16),
          const Text(
            'Tips 2025: Ganti password hanya jika ada indikasi bocor (cek haveibeenpwned.com).',
            style: TextStyle(color: Colors.white, fontSize: 16, height: 1.6),
          ),
        ];
        break;

      case 'Jaga Privasi':
        detailedContent =
            'Privasi digital adalah hak Anda. Sekali data masuk internet, sulit dihapus total. Lindungi dengan kebiasaan berikut:';
        tipCards = [
          _buildTipCard('Batasi sharing di medsos', 'Hindari post lokasi real-time, alamat rumah, atau data sensitif (KTP, rekening).'),
          _buildTipCard('Periksa pengaturan privasi rutin', 'Di Instagram/Facebook: set "Private", batasi siapa lihat story/post.'),
          _buildTipCard('Jangan klik link/phishing mencurigakan', 'Verifikasi pengirim sebelum masukkan data.'),
          _buildTipCard('Aktifkan 2FA/MFA di semua akun penting', 'Gunakan app authenticator (Google Authenticator/Authy) daripada SMS.'),
          _buildTipCard('Gunakan VPN di Wi-Fi publik', 'Enkripsi koneksi untuk cegah pencurian data.'),
          _buildTipCard('Batasi izin aplikasi', 'Revoke akses kamera/mikrofon/lokasi yang tidak perlu.'),
          const SizedBox(height: 16),
          const Text(
            'Bonus: Gunakan browser privacy-focused seperti Firefox atau Brave, dan ad-blocker untuk kurangi tracking.',
            style: TextStyle(color: Colors.white, fontSize: 16, height: 1.6),
          ),
        ];
        break;

      default:
        detailedContent = subtitle;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F0F1E), Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Hero(
                    tag: 'tip-icon-${tip.hashCode}',
                    child: Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [primaryColor, primaryColor.withOpacity(0.7)]),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 5,
                          )
                        ],
                      ),
                      child: Icon(icon, color: Colors.white, size: 70),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  title,
                  style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16, height: 1.6),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Text(
                  detailedContent,
                  style: const TextStyle(color: Colors.white, fontSize: 17, height: 1.7),
                ),
                const SizedBox(height: 24),
                ...tipCards,
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTipCard(String title, String description) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 16, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}