import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:factify/services/guest_service.dart';
import 'package:factify/screens/auth/login_screen.dart';
import 'package:factify/screens/tabs/home/learn_more_screen.dart';
import 'package:factify/screens/tabs/home/tip_detail_screen.dart';
import 'package:factify/screens/tabs/home/all_articles_screen.dart';
import 'package:factify/screens/tabs/home/article_detail_screen.dart';
import 'package:factify/screens/tabs/home/all_tips_screen.dart';
import 'package:factify/widgets/home/hero_card.dart';
import 'package:factify/widgets/home/article_card.dart';
import 'package:factify/widgets/home/notification_bottom_sheet.dart';
import 'package:factify/widgets/home/search_filter_bottom_sheet.dart';
import 'package:factify/widgets/home/daily_quiz_card.dart';
import 'package:factify/widgets/home/quick_verify_widget.dart';

import 'package:factify/widgets/home/activity_stats_chart.dart';
import 'package:factify/widgets/chatbot/chatbot_bottom_sheet.dart';
import 'package:factify/services/user_stats_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  final TextEditingController _searchController = TextEditingController();
  
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _userName = 'User';
  bool _isLoadingUser = true;
  
  int _articlesRead = 0;
  int _challengesCompleted = 0;
  int _verificationsCount = 0;
  int _totalXP = 0;
  int _streak = 0;

  final List<Map<String, dynamic>> tips = [
    {
      'icon': Icons.search,
      'title': 'Verifikasi Sebelum Share',
      'subtitle': 'Luangkan 30 detik untuk cek fakta sebelum membagikan informasi ke orang lain',
      'shortDescription': 'Gunakan metode SIFT (Stop, Investigate, Find, Trace) untuk evaluasi cepat. Satu share hoaks bisa menjangkau ribuan orang dalam hitungan jam.',
      'color': const Color(0xFF4ECDC4),
      'imageUrl': 'https://images.unsplash.com/photo-1586281380349-632531db7ed4?w=600&auto=format&fit=crop&q=80',
      'content': '''Setiap kali Anda menerima informasi yang mengejutkan atau emosional, jangan langsung forward. Luangkan 30 detik untuk verifikasi sederhana yang bisa mencegah penyebaran hoaks.

METODE SIFT UNTUK VERIFIKASI CEPAT:

1. STOP (Berhenti)
Jangan langsung bereaksi. Tarik napas dan tahan keinginan untuk langsung share. Konten viral sering sengaja dirancang untuk memicu respons emosional impulsif.

2. INVESTIGATE THE SOURCE (Investigasi Sumber)
Siapa yang membuat konten ini? Apakah mereka kredibel? Cek profil akun: kapan dibuat, pola posting, follower vs following ratio. Akun baru dengan follower banyak tapi sedikit interaksi patut dicurigai.

3. FIND BETTER COVERAGE (Cari Sumber Lain)
Jangan bergantung pada satu sumber. Search topik yang sama di Google News atau media terpercaya. Jika hanya satu sumber yang memberitakan, itu red flag.

4. TRACE THE ORIGINAL (Lacak Sumber Asli)
Apakah ada kutipan? Cek langsung ke sumber aslinya. Screenshot bisa diedit. Video bisa dipotong out of context. Selalu cari versi lengkap.

TOOLS UNTUK VERIFIKASI:
• Google Reverse Image Search - cek apakah gambar sudah pernah digunakan sebelumnya
• InVID/WeVerify - plugin browser untuk analisis video
• cekfakta.com & turnbackhoax.id - database hoaks Indonesia

INGAT: Satu share hoaks dari Anda bisa menjangkau ratusan orang dalam hitungan jam. Jadilah gatekeeper yang bertanggung jawab dalam ekosistem informasi.''',
    },
    {
      'icon': Icons.verified_outlined,
      'title': 'Kenali Sumber Terpercaya',
      'subtitle': 'Tidak semua media online memiliki standar jurnalistik yang sama',
      'shortDescription': 'Cek apakah media terdaftar di Dewan Pers, memiliki redaksi jelas, dan track record kredibel. Waspadai domain tiruan seperti "kompas.com.co".',
      'color': const Color(0xFF5B9BD5),
      'imageUrl': 'https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=600&auto=format&fit=crop&q=80',
      'content': '''Di era digital, siapa saja bisa membuat website berita dalam hitungan menit. Kemampuan membedakan sumber terpercaya dari yang tidak adalah skill essential.

CIRI-CIRI MEDIA KREDIBEL:

1. Terdaftar di Dewan Pers
Cek di dewanpers.or.id apakah media tersebut terverifikasi. Media terverifikasi harus mematuhi Kode Etik Jurnalistik.

2. Memiliki Redaksi yang Jelas
Lihat halaman "Tentang Kami" atau "Redaksi". Media kredibel mencantumkan nama pemimpin redaksi, alamat kantor, dan kontak yang bisa dihubungi.

3. Memisahkan Berita dan Opini
Berita faktual harus terpisah jelas dari kolom opini/editorial. Pencampuradukan keduanya adalah tanda media tidak profesional.

4. Mencantumkan Sumber
Berita berkualitas selalu menyebutkan sumber informasi: "Menurut data BPS...", "Dalam wawancara dengan Reuters...". Klaim tanpa sumber patut dicurigai.

WASPADAI RED FLAGS:
• Domain mirip tapi beda (kompas.com.co, detik.net)
• Tidak ada halaman "Tentang Kami"
• Judul sensasional dengan banyak CAPSLOCK dan tanda seru
• Tidak ada tanggal publikasi
• Iklan berlebihan yang mengganggu

TIPS PRAKTIS:
Bookmark 5-10 media terpercaya sebagai sumber utama berita Anda. Untuk Indonesia: Kompas, Tempo, BBC Indonesia, Reuters, AFP. Jangan bergantung pada timeline media sosial sebagai sumber berita primer.''',
    },
    {
      'icon': Icons.shield_outlined,
      'title': 'Password Manager Wajib',
      'subtitle': 'Otak manusia tidak dirancang untuk mengingat 50+ password unik',
      'shortDescription': 'Gunakan Bitwarden, 1Password, atau Dashlane. Password berbeda untuk setiap akun mencegah efek domino jika satu akun diretas.',
      'color': const Color(0xFFFF6B6B),
      'imageUrl': 'https://images.unsplash.com/photo-1555949963-aa79dcee981c?w=600&auto=format&fit=crop&q=80',
      'content': '''Rata-rata orang memiliki 80-100 akun online. Menggunakan password yang sama untuk semua akun adalah resep bencana - jika satu bocor, semuanya terancam.

MENGAPA PASSWORD MANAGER ESSENTIAL:

1. Satu Password Cukup
Anda hanya perlu mengingat SATU master password yang kuat. Sisanya diurus oleh aplikasi.

2. Password Unik untuk Setiap Akun
Password manager bisa generate password random 20+ karakter yang berbeda untuk setiap akun.

3. Auto-fill yang Aman
Tidak perlu ketik manual - mengurangi risiko keylogger. Browser juga tidak menyimpan password Anda.

REKOMENDASI PASSWORD MANAGER:

• Bitwarden (GRATIS, open-source, sangat direkomendasikan)
• 1Password (berbayar, UI sangat baik)
• Dashlane (berbayar, fitur dark web monitoring)

CARA MULAI:
1. Download Bitwarden di semua device
2. Buat master password yang kuat (16+ karakter, kombinasi huruf-angka-simbol)
3. Import password dari browser
4. Ganti password akun-akun penting satu per satu dengan yang baru (dimulai dari email dan bank)

MASTER PASSWORD YANG KUAT:
Gunakan passphrase, bukan password. Contoh: "KucingKu-Makan-Ikan-Segar-2024!" lebih kuat dan mudah diingat daripada "Kc1ng@2024".

FAKTA: 81% peretasan terjadi karena password lemah atau reused. Password manager menghilangkan kedua risiko ini sekaligus.''',
    },
    {
      'icon': Icons.privacy_tip_outlined,
      'title': 'Audit Jejak Digital',
      'subtitle': 'Setiap like, komentar, dan share meninggalkan jejak permanen',
      'shortDescription': 'Google nama Anda secara berkala. Review pengaturan privasi di semua platform. Ingat: apa yang sudah online, selamanya online.',
      'color': const Color(0xFFFFD93D),
      'imageUrl': 'https://images.unsplash.com/photo-1563013544-824ae1b704d3?w=600&auto=format&fit=crop&q=80',
      'content': '''Jejak digital Anda adalah "CV kedua" yang dilihat oleh HR, calon pasangan, mitra bisnis, bahkan penipu. Kelola dengan bijak.

LANGKAH-LANGKAH AUDIT JEJAK DIGITAL:

1. Google Nama Anda
Search nama lengkap Anda (dalam tanda kutip). Lihat apa yang muncul di halaman pertama. Ini yang dilihat orang lain.

2. Review Semua Akun Media Sosial
• Hapus postingan lama yang memalukan atau kontroversial
• Untag foto yang tidak pantas
• Set profil ke private jika perlu

3. Cek Data Breach
Kunjungi haveibeenpwned.com dan masukkan email Anda. Jika pernah terkena breach, segera ganti password.

4. Review App Permissions
Di setiap platform, cek aplikasi apa saja yang terhubung ke akun Anda. Revoke yang tidak digunakan.

PENGATURAN PRIVASI PENTING:

Facebook:
• Settings > Privacy > Limit Past Posts
• Turn off face recognition
• Review timeline dan tag

Instagram:
• Private account jika tidak perlu publik
• Hapus story highlights lama
• Batasi siapa bisa tag Anda

LinkedIn:
• Kontrol siapa yang melihat koneksi Anda
• Matikan visibility ke recruiters jika tidak job hunting

PRINSIP PENTING:
Sebelum posting apapun, tanyakan: "Apakah saya nyaman jika bos, orang tua, atau calon mertua melihat ini?" Jika tidak, jangan posting.

Ingat: Internet tidak pernah lupa. Screenshot exist. Wayback Machine exist. Apa yang sudah online, berpotensi online selamanya.''',
    },
    {
      'icon': Icons.psychology,
      'title': 'Waspadai Emotional Trigger',
      'subtitle': 'Konten yang memicu emosi kuat sering kali dirancang untuk bypass logika',
      'shortDescription': 'Jika sebuah berita membuat Anda sangat marah atau takut, itu justru alasan untuk BERHENTI dan verifikasi, bukan langsung share.',
      'color': const Color(0xFF9B59B6),
      'imageUrl': 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=600&auto=format&fit=crop&q=80',
      'content': '''Otak manusia memiliki dua sistem: Sistem 1 (cepat, emosional, intuitif) dan Sistem 2 (lambat, logis, analitis). Hoaks dan propaganda sengaja menargetkan Sistem 1.

MENGAPA EMOSI MEMBUAT KITA RENTAN:

Ketika kita merasakan emosi kuat (marah, takut, jijik, atau bahkan euforia berlebihan), otak memprioritaskan respons cepat daripada analisis mendalam. Ini adalah mekanisme survival, tapi bisa dieksploitasi.

EMOSI YANG SERING DIEKSPLOITASI:

1. KEMARAHAN
"Lihat apa yang mereka lakukan!" - memicu ingroup vs outgroup

2. KETAKUTAN
"Bahaya! Ini bisa terjadi pada Anda!" - mengancam keamanan

3. RASA JIJIK
"Ini menjijikkan dan amoral!" - menyerang nilai-nilai

4. EUFORIA
"Akhirnya terbukti!" - konfirmasi bias dengan packaging positif

CARA MELAWAN MANIPULASI EMOSIONAL:

1. Kenali Respons Tubuh Anda
Jantung berdebar? Muka panas? Ingin langsung share? Itu tanda Sistem 1 mengambil alih. BERHENTI.

2. Terapkan Aturan 24 Jam
Untuk konten yang sangat emosional, tunggu 24 jam sebelum merespons atau share. Banyak hoaks terbongkar dalam timeframe ini.

3. Tanyakan: "Siapa yang Diuntungkan?"
Jika saya percaya dan menyebarkan ini, siapa yang benefitnya? Pertanyaan ini sering membuka perspektif baru.

4. Cari Sumber Alternatif
Jika benar, pasti banyak yang memberitakan. Jika hanya satu sumber viral, itu red flag.

INGAT: Semakin sebuah konten membuat Anda emosional, semakin Anda harus skeptis. Emosi kuat adalah sinyal untuk memperlambat, bukan mempercepat.''',
    },
    {
      'icon': Icons.security,
      'title': 'Aktifkan 2FA Sekarang',
      'subtitle': 'Two-Factor Authentication adalah pertahanan paling efektif dari peretasan',
      'shortDescription': 'Prioritaskan 2FA untuk email utama dan akun finansial. Gunakan app authenticator, bukan SMS yang lebih mudah dibobol.',
      'color': const Color(0xFFF39C12),
      'imageUrl': 'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?w=600&auto=format&fit=crop&q=80',
      'content': '''Two-Factor Authentication (2FA) menambahkan lapisan keamanan kedua setelah password. Bahkan jika password Anda bocor, akun tetap aman.

MENGAPA 2FA PENTING:

Password bisa bocor melalui:
• Data breach di website yang Anda gunakan
• Phishing attack
• Keylogger malware
• Social engineering

Dengan 2FA, peretas membutuhkan dua hal: password DAN device fisik Anda. Ini membuatnya jauh lebih sulit.

JENIS-JENIS 2FA (dari terlemah ke terkuat):

1. SMS OTP (Terlemah)
Kode dikirim via SMS. Masih lebih baik dari tanpa 2FA, tapi rentan SIM swapping attack.

2. Email OTP
Kode dikirim ke email. Hanya sekuat keamanan email Anda.

3. App Authenticator (DIREKOMENDASIKAN)
Google Authenticator, Microsoft Authenticator, atau Authy. Kode berubah setiap 30 detik, tidak bisa diintersep.

4. Hardware Key (Terkuat)
YubiKey atau Google Titan Key. Device fisik yang harus dicolok. Ideal untuk akun sangat sensitif.

PRIORITAS AKTIVASI 2FA:

Segera aktifkan untuk:
1. Email utama (jika ini diretas, semuanya bisa di-reset)
2. Akun bank dan e-wallet
3. Media sosial utama
4. Cloud storage (Google Drive, iCloud)

CARA AKTIVASI:
Buka Settings/Keamanan di setiap platform, cari "Two-Factor Authentication" atau "2-Step Verification", pilih App Authenticator, scan QR code.

BACKUP CODES:
Saat setup 2FA, Anda akan mendapat backup codes. SIMPAN DENGAN AMAN (print dan simpan di tempat aman, atau di password manager). Ini penyelamat jika Anda kehilangan device.

FAKTA: Akun dengan 2FA hingga 99.9% lebih aman dari serangan otomatis. Ini adalah single most impactful security measure yang bisa Anda lakukan hari ini.''',
    },
  ];

  final List<Map<String, dynamic>> articles = [
    {
      'title': '10 Langkah Praktis Melindungi Data Pribadi',
      'description': 'Panduan komprehensif keamanan digital personal dari seorang pakar cybersecurity',
      'category': 'Keamanan Digital',
      'readTime': '8 min read',
      'views': '15.2K views',
      'image': 'https://images.unsplash.com/photo-1563013544-824ae1b704d3?w=600&auto=format&fit=crop&q=80',
      'content': '''Di era dimana data adalah "minyak baru", melindungi informasi pribadi bukan lagi pilihan—ini adalah keharusan. Setiap tahun, miliaran data pribadi bocor melalui peretasan dan kebocoran database.

Berikut 10 langkah esensial yang harus Anda terapkan:

1. Gunakan Password Manager
Password manager seperti Bitwarden (gratis, open-source) atau 1Password memungkinkan Anda memiliki password unik minimal 16 karakter untuk setiap akun tanpa harus menghafalnya.

2. Aktifkan Two-Factor Authentication (2FA)
Prioritaskan aktivasi 2FA untuk email utama, akun bank, dan sosial media. Gunakan app authenticator seperti Google Authenticator atau Microsoft Authenticator—hindari SMS karena lebih mudah diretas.

3. Audit Permission Aplikasi
Buka Settings → Apps → Permissions di smartphone Anda. Pertanyakan: Apakah game perlu akses kontak? Apakah kalkulator perlu lokasi? Nonaktifkan izin yang tidak diperlukan.

4. Enkripsi Perangkat Anda
Aktifkan FileVault di Mac atau BitLocker di Windows. Smartphone modern sudah terenkripsi secara default jika Anda menggunakan lock screen.

5. Gunakan VPN di WiFi Publik
Anggap SEMUA WiFi publik tidak aman. Gunakan VPN berbayar bereputasi seperti ProtonVPN atau Mullvad untuk mengenkripsi traffic Anda.

6. Update Rutin = Patch Keamanan
60% serangan siber berhasil karena vulnerability yang sebenarnya sudah ada patch-nya. Aktifkan auto-update untuk OS dan semua aplikasi.

7. Gunakan Email Alias
Layanan seperti SimpleLogin atau AnonAddy memungkinkan Anda membuat email berbeda untuk setiap layanan. Jika satu bocor, yang lain tetap aman.

8. Tingkatkan Privasi Browser
Ganti browser Anda ke Firefox atau Brave. Install uBlock Origin untuk memblokir tracker. Nonaktifkan third-party cookies.

9. Backup Data Secara Rutin
Ikuti aturan 3-2-1: 3 salinan data, 2 media penyimpanan berbeda, 1 lokasi offsite. Ransomware tidak bisa memeras Anda jika Anda punya backup.

10. Praktikkan Digital Minimalism
Hapus akun dan aplikasi yang tidak digunakan. Setiap akun adalah potential attack surface yang bisa dieksploitasi.

Ingat: Keamanan digital adalah proses berkelanjutan, bukan produk sekali beli. Mulai dari langkah yang paling berdampak, lalu tingkatkan secara bertahap.''',
      'author': 'Andi Cyber, Pakar Keamanan IT',
      'date': '20 Des 2024',
    },
    {
      'title': 'Anatomi Hoaks: Memahami Cara Kerja Disinformasi',
      'description': 'Mengapa hoaks menyebar lebih cepat dari fakta dan bagaimana melindungi diri',
      'category': 'Media Literacy',
      'readTime': '10 min read',
      'views': '12.8K views',
      'image': 'https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=600&auto=format&fit=crop&q=80',
      'content': '''Studi MIT yang dipublikasikan di jurnal Science menemukan fakta mengejutkan: berita palsu menyebar 6 kali lebih cepat daripada fakta di media sosial. Mengapa demikian?

Mengapa Hoaks Lebih Viral?

Pertama, ada Novelty Factor. Otak kita secara alami tertarik pada informasi baru dan mengejutkan. Hoaks sengaja dirancang untuk memicu respons "Wow, saya harus bagikan ini!"

Kedua, Emotional Hijacking. Hoaks menargetkan emosi primitif kita: takut, marah, jijik, atau euforia. Emosi yang kuat mem-bypass pemikiran rasional dan mendorong sharing impulsif.

Ketiga, Confirmation Bias. Kita lebih mudah mempercayai informasi yang sesuai dengan keyakinan yang sudah ada. Hoaks mengeksploitasi ini dengan menargetkan worldview spesifik.

Keempat, Social Proof. "Kalau banyak orang share, pasti benar." Bot dan akun palsu memanipulasi sinyal sosial ini untuk menciptakan ilusi kredibilitas.

Teknik Manipulasi yang Umum Digunakan:

• Clickbait Emotional - Judul provokatif yang memancing klik sebelum berpikir
• Out of Context - Gambar atau video asli tapi dengan narasi yang berbeda
• Partial Truth - Mencampur fakta dengan kebohongan agar lebih credible
• Impersonation - Menyamar sebagai sumber berita terpercaya
• Gish Gallop - Membanjiri dengan banyak klaim sehingga mustahil dibantah

Cara Melindungi Diri:

Pertama, PAUSE sebelum share—terutama jika konten memicu emosi kuat. Kedua, tanyakan "Siapa yang diuntungkan jika saya percaya ini?" Ketiga, cek minimal 3 sumber independen sebelum mempercayai klaim besar.

Manfaatkan situs fact-checking seperti cekfakta.com, turnbackhoax.id, atau factcheck.org. Dan ingat: jangan menjadi amplifier—engagement apapun, termasuk bantahan, membantu viralitas konten.

Anda adalah gatekeeper dalam network sosial Anda. Pilih dengan bijak apa yang Anda amplifikasi.''',
      'author': 'Prof. Sari Dewi, Komunikasi',
      'date': '18 Des 2024',
    },
    {
      'title': 'Filter Bubble: Bagaimana Algoritma Membentuk Realitas Anda',
      'description': 'Memahami echo chamber digital dan strategi untuk keluar darinya',
      'category': 'Digital Ethics',
      'readTime': '7 min read',
      'views': '8.5K views',
      'image': 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=600&auto=format&fit=crop&q=80',
      'content': '''Setiap scroll, like, dan komentar yang Anda lakukan melatih algoritma untuk menyajikan lebih banyak konten serupa. Hasilnya? Filter bubble yang mempersempit worldview Anda tanpa Anda sadari.

Apa Itu Filter Bubble?

Istilah ini diciptakan oleh Eli Pariser untuk menggambarkan "ekosistem informasi personal" dimana seseorang hanya terpapar konten yang sesuai preferensinya. Algoritma platform sengaja melakukan ini untuk memaksimalkan engagement—dan tentu saja, profit iklan.

Dampak Filter Bubble:

Echo Chamber membuat Anda hanya mendengar opini yang sama, sehingga keyakinan menjadi semakin ekstrem tanpa tantangan.

Polarisasi terjadi karena Anda tidak pernah terpapar perspektif berbeda, sehingga mudah menganggap "yang berbeda pasti bodoh atau jahat."

Manipulability meningkat karena Anda lebih mudah dieksploitasi oleh disinformasi yang sesuai dengan bias existing.

False Consensus membuat Anda mengira "semua orang setuju dengan saya" padahal itu hanya bubble Anda.

Strategi Keluar dari Bubble:

1. Diversifikasi Sumber - Sengaja follow akun dan media dengan perspektif berbeda. Bukan untuk setuju, tapi untuk memahami.

2. Kurasi Feed Manual - Prioritaskan chronological feed daripada algorithmic. Gunakan fitur "see first" untuk sumber berkualitas.

3. Search dalam Mode Incognito - Algoritma search juga personalized. Gunakan incognito mode untuk hasil yang lebih netral.

4. Subscribe Newsletter - Email newsletter bypass algoritma platform dan memberikan Anda kontrol lebih atas konsumsi informasi.

5. Praktikkan Slow News - Tidak semua berita membutuhkan respons instan. Tunggu 24-48 jam untuk isu kontroversial agar fakta lebih lengkap.

6. Bicara dengan Manusia Nyata - Percakapan offline dengan orang dari background berbeda memberikan perspektif yang tidak bisa diberikan algoritma.

Refleksi: Algoritma adalah cermin preferensi Anda. Jika feed Anda penuh dengan konten polarizing, tanyakan pada diri sendiri: apa yang sudah saya latihkan ke algoritma ini?''',
      'author': 'Tim Factify',
      'date': '15 Des 2024',
    },
    {
      'title': 'Deepfake 101: Ketika Mata Tidak Lagi Bisa Dipercaya',
      'description': 'Memahami teknologi synthetic media dan cara melindungi diri di era AI',
      'category': 'AI & Technology',
      'readTime': '9 min read',
      'views': '11.3K views',
      'image': 'https://images.unsplash.com/photo-1677442136019-21780ecad995?w=600&auto=format&fit=crop&q=80',
      'content': '''Pada 2019, sebuah video viral menunjukkan Nancy Pelosi tampak mabuk dan berbicara melantur. Video itu adalah manipulasi—diperlambat secara digital untuk menciptakan ilusi tersebut. Selamat datang di era dimana "seeing is no longer believing."

Apa Itu Deepfake?

Deepfake adalah teknologi yang menggunakan artificial intelligence untuk membuat video atau audio sintetis yang sangat realistis. Nama ini berasal dari kombinasi "deep learning" dan "fake."

Jenis-Jenis Synthetic Media:

Face Swap menempelkan wajah seseorang ke tubuh orang lain dalam video.

Lip Sync memanipulasi gerakan bibir agar sesuai dengan audio yang berbeda.

Voice Cloning menggunakan AI untuk meniru suara seseorang berdasarkan sample audio singkat.

AI-Generated Images dari tools seperti Midjourney dan DALL-E dapat membuat gambar yang tidak bisa dibedakan dari foto asli.

Cara Mendeteksi Deepfake:

Perhatikan Visual Artifacts: kedipan mata yang tidak natural, tepi wajah yang blur atau berkedut terutama di area rambut dan telinga, lighting yang tidak konsisten, serta gigi atau perhiasan yang terdistorsi.

Cek Audio Mismatch: lip sync yang sedikit off, emosi suara yang tidak sesuai ekspresi wajah, atau kualitas audio yang tidak konsisten.

Lakukan Context Check: Apakah masuk akal orang ini mengatakan atau melakukan hal tersebut? Siapa yang pertama memposting? Apakah ada sumber independen yang memverifikasi?

Tools yang Bisa Membantu:

Microsoft Video Authenticator memberikan skor kepercayaan apakah video telah dimanipulasi. InVID/WeVerify adalah plugin browser untuk analisis video. Deepware Scanner tersedia sebagai aplikasi mobile untuk pengecekan cepat.

Implikasi yang Perlu Diwaspadai:

Liar's Dividend memungkinkan orang menyangkal video ASLI dengan klaim "itu deepfake." Lebih dari 90% deepfake adalah konten pornografi tanpa consent. Dan satu video palsu yang viral di momen kritis bisa mengubah hasil pemilu.

Prinsip baru di era AI: untuk video atau audio sensitif, SELALU verifikasi sumber asli sebelum mempercayainya. Skeptisisme adalah respons yang sehat, bukan paranoid.''',
      'author': 'Dr. Maya Teknologi, AI Researcher',
      'date': '12 Des 2024',
    },
  ];


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    
    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOut),
      ),
    );
    
    _animationController.forward();
    _loadUserData();
    _loadUserStats();
  }

  Future<void> _loadUserData() async {
    // Check if in guest mode
    await guestService.init();
    if (guestService.isGuestMode) {
      setState(() {
        _userName = 'Tamu';
        _isLoadingUser = false;
      });
      return;
    }
    
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot userData = await _firestore.collection('users').doc(user.uid).get();
        if (userData.exists) {
          setState(() {
            _userName = userData.get('username') ?? user.displayName ?? 'User';
            _isLoadingUser = false;
          });
        } else {
          setState(() {
            _userName = user.displayName ?? 'User';
            _isLoadingUser = false;
          });
        }
      } else {
        setState(() {
          _userName = 'Tamu';
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      setState(() {
        _userName = _auth.currentUser?.displayName ?? 'Tamu';
        _isLoadingUser = false;
      });
    }
  }
  
  Future<void> _loadUserStats() async {
    await userStats.init();
    await userStats.syncFromFirebase();
    
    final stats = await userStats.getAllStats();
    if (mounted) {
      setState(() {
        _articlesRead = stats['articlesRead'] ?? 0;
        _challengesCompleted = stats['challengesCompleted'] ?? 0;
        _verificationsCount = stats['verificationsCount'] ?? 0; // For chart
        _totalXP = stats['totalXP'] ?? 0;
        _streak = stats['streak'] ?? 0;
      });
    }
  }
  
  Future<void> _refreshStats() async {
    final stats = await userStats.getAllStats();
    if (mounted) {
      setState(() {
        _articlesRead = stats['articlesRead'] ?? 0;
        _challengesCompleted = stats['challengesCompleted'] ?? 0;
        _totalXP = stats['totalXP'] ?? 0;
        _streak = stats['streak'] ?? 0;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showNotifications() {
    showNotificationBottomSheet(context);
  }

  void _showSearchFilter() {
    showSearchFilterBottomSheet(context);
  }

  void _showChatbot() {
    showChatbotBottomSheet(context);
  }

  void _navigateToLearnMore() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LearnMoreScreen()),
    );
  }

  void _navigateToAllTips() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AllTipsScreen(tips: tips)),
    );
  }

  void _navigateToAllArticles() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AllArticlesScreen(articles: articles)),
    ).then((_) => _refreshStats()); // Refresh stats when returning
  }

  void _navigateToArticleDetail(Map<String, dynamic> article) async {
    final articleId = article['title'].toString().hashCode.toString();
    
    final isNew = await userStats.markArticleAsRead(articleId);
    
    if (isNew && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.auto_stories, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Artikel baru dibaca! +5 XP'),
            ],
          ),
          backgroundColor: const Color(0xFF4ECDC4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
      
      _refreshStats();
    }
    
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ArticleDetailScreen(article: article)),
      );
    }
  }

  void _navigateToTipDetail(Map<String, dynamic> tip) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TipDetailScreen(tip: tip)),
    );
  }
  
  // Handle Quick Verify
  void _handleQuickVerify(String text, String type) {
    HapticFeedback.mediumImpact();
    
    // Navigate to Verysense tab with pre-filled data
    // For now, show a snackbar confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.rocket_launch, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Memproses verifikasi ${type == 'url' ? 'URL' : 'teks'}...',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF4ECDC4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Lihat',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to Verysense screen
            // This would typically use a navigation callback or state management
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0F0F1E),
              const Color(0xFF1A1A2E),
              const Color(0xFF16213E).withValues(alpha: 0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // App Bar
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: _buildHeader(),
                      ),
                    );
                  },
                ),
              ),
              
              // Search Bar
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value * 1.5),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                          child: _buildSearchBar(),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Quick Stats
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value * 2),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                          child: _buildQuickStats(),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Hero Card
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value * 2.5),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: RepaintBoundary(
                            child: HeroCard(onTap: _navigateToLearnMore),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Activity Stats Chart (only for logged-in users with data)
              if (!guestService.isGuestMode)
                SliverToBoxAdapter(
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _slideAnimation.value * 2.6),
                        child: Opacity(
                          opacity: _fadeAnimation.value,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                            child: RepaintBoundary(
                              child: ActivityStatsChart(
                                articlesRead: _articlesRead,
                                verificationsCount: _verificationsCount,
                                challengesCompleted: _challengesCompleted,
                                totalXP: _totalXP,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              
              // Quick Verify Widget
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value * 2.7),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                          child: QuickVerifyWidget(
                            onVerify: (text, type) => _handleQuickVerify(text, type),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Daily Quiz Card
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value * 2.9),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                          child: DailyQuizCard(
                            onComplete: () => _refreshStats(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Tips Section Header
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value * 3),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                          child: _buildSectionHeader(
                            'Tips Literasi Digital',
                            'Lihat Semua',
                            _navigateToAllTips,
                            Icons.lightbulb,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Tips List (hanya tampilkan 2 di home)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final tip = tips[index];
                      return AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _slideAnimation.value * (3.5 + index * 0.3)),
                            child: Opacity(
                              opacity: _fadeAnimation.value,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildEnhancedTipCard(tip),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    childCount: 2,
                  ),
                ),
              ),
              
              // Articles Section Header
              SliverToBoxAdapter(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _slideAnimation.value * 4),
                      child: Opacity(
                        opacity: _fadeAnimation.value,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                          child: _buildSectionHeader(
                            'Artikel Terpercaya',
                            'Selengkapnya',
                            _navigateToAllArticles,
                            Icons.article,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Articles List
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final article = articles[index];
                      return AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _slideAnimation.value * (4.5 + index * 0.3)),
                            child: Opacity(
                              opacity: _fadeAnimation.value,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: ArticleCard(
                                  article: article,
                                  onTap: () => _navigateToArticleDetail(article),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    childCount: articles.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // ADD FLOATING ACTION BUTTON FOR CHATBOT
      floatingActionButton: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _fadeAnimation.value,
            child: FloatingActionButton(
              onPressed: _showChatbot,
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C5CE7).withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipOval(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          'assets/images/CHATBOT.webp',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4ECDC4),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ==================== WIDGETS ====================
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.wb_sunny, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Selamat Datang',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _isLoadingUser
                    ? Container(
                        height: 28,
                        width: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D2D44),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      )
                    : Text(
                        _userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Guest mode: show Login button | Logged-in: show notification icon (no badge)
          if (guestService.isGuestMode)
            // Login button for guest users
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  await guestService.disableGuestMode();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4ECDC4).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.login, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            // Notification icon for logged-in users (no badge)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _showNotifications,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF2D2D44).withValues(alpha: 0.6),
                        const Color(0xFF2D2D44).withValues(alpha: 0.3),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4ECDC4).withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    color: Color(0xFF4ECDC4),
                    size: 24,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.95),
            Colors.white.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4ECDC4).withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Icon(Icons.search, color: Colors.grey, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                style: const TextStyle(
                  color: Color(0xFF1A1A2E),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Cari tips, artikel, atau topik...',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.search, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text('Mencari: $value'),
                          ],
                        ),
                        backgroundColor: const Color(0xFF4ECDC4),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _showSearchFilter,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4ECDC4).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.tune,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.auto_stories,
            label: 'Artikel Dibaca',
            value: '$_articlesRead',
            color: const Color(0xFF4ECDC4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.stars,
            label: 'Total XP',
            value: '$_totalXP',
            color: const Color(0xFFFFD93D),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            icon: Icons.local_fire_department,
            label: 'Streak',
            value: '$_streak hari',
            color: const Color(0xFFFF6B6B),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    String actionText,
    VoidCallback onTap,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF4ECDC4).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF4ECDC4).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionText,
                    style: const TextStyle(
                      color: Color(0xFF4ECDC4),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF4ECDC4),
                    size: 12,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedTipCard(Map<String, dynamic> tip) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _navigateToTipDetail(tip),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (tip['color'] as Color).withValues(alpha: 0.15),
                (tip['color'] as Color).withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: (tip['color'] as Color).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: tip['color'],
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: (tip['color'] as Color).withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  tip['icon'],
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tip['title'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tip['subtitle'],
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.white.withValues(alpha: 0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}