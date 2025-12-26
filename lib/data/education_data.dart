// lib/data/education_data.dart
import 'package:flutter/material.dart';

class EducationData {
  static final List<Map<String, dynamic>> articles = [
    {
      'icon': Icons.lightbulb_outline,
      'title': 'Berpikir Kritis di Era Digital',
      'subtitle': 'Menyaring Informasi dan Menghindari Manipulasi Opini',
      'color': const Color(0xFF4ECDC4),
      'category': 'Semua',
      'readTime': '7 menit',
      'objective':
          'Membekali pembaca dengan kemampuan berpikir kritis untuk menavigasi banjir informasi digital, mengenali manipulasi, serta membuat keputusan yang rasional dan mandiri.',
      'sections': [
        {
          'title': 'Pendahuluan',
          'content':
              'Era digital membawa kemudahan akses informasi yang belum pernah ada sebelumnya. Namun, di balik kecepatan penyebaran itu, tersembunyi risiko besar: hoaks, propaganda, dan manipulasi opini yang dirancang secara sistematis. Menurut laporan We Are Social 2025, rata-rata orang Indonesia menghabiskan lebih dari 8 jam per hari di internet. Berpikir kritis bukan lagi pilihan, melainkan keharusan untuk melindungi diri dan masyarakat dari dampak negatif informasi yang menyesatkan.',
        },
        {
          'title': '1. Verifikasi Sumber Informasi',
          'content':
              'Langkah pertama adalah menilai kredibilitas sumber. Banyak situs berita palsu sengaja meniru desain media terpercaya.',
          'points': [
            'Periksa domain dan kredibilitas media (misalnya, apakah terdaftar di Dewan Pers Indonesia)',
            'Baca bagian “Tentang Kami” atau “Redaksi” untuk memahami latar belakang dan misi',
            'Waspadai situs dengan domain aneh seperti .co.cc atau yang menyerupai media resmi (contoh: “kompas.com.co”)',
            'Pastikan ada informasi kontak, alamat redaksi, dan identitas penanggung jawab yang jelas',
          ],
        },
        {
          'title': '2. Lakukan Cross-Check Secara Aktif',
          'content':
              'Jangan pernah mengandalkan satu sumber saja, terutama untuk isu sensitif.',
          'points': [
            'Bandingkan dengan minimal tiga sumber independen dan bereputasi baik',
            'Gunakan media arus utama yang memiliki standar jurnalistik tinggi',
            'Manfaatkan situs pemeriksa fakta seperti cekfakta.com, turnbackhoax.id, atau Mafindo',
            'Cari konfirmasi dari lembaga resmi pemerintah atau organisasi internasional',
          ],
        },
        {
          'title': '3. Kenali Bias dan Teknik Manipulasi',
          'content':
              'Setiap informasi memiliki sudut pandang. Tugas kita adalah mengenali bias tersebut.',
          'points': [
            'Perhatikan judul sensasional atau clickbait yang memancing emosi',
            'Waspadai bahasa yang terlalu emosional, memecah belah, atau provokatif',
            'Cek tanggal publikasi—informasi lama sering dibagikan ulang untuk tujuan tertentu',
            'Identifikasi apakah konten mendorong reaksi impulsif daripada pemikiran rasional',
          ],
        },
        {
          'title': '4. Evaluasi Bukti dan Logika',
          'content':
              'Klaim tanpa bukti yang kuat patut dipertanyakan.',
          'points': [
            'Apakah ada data, riset, atau studi yang mendukung klaim?',
            'Apakah sumber data disebutkan secara transparan dan dapat diverifikasi?',
            'Adakah kutipan dari ahli yang relevan dan kredibel?',
            'Apakah argumen logis atau justru mengandalkan fallacy (misalnya ad hominem atau strawman)?',
          ],
        },
        {
          'title': 'Refleksi & Takeaway',
          'content':
              'Biasakan diri untuk selalu bertanya: “Apa bukti yang mendukung ini?”, “Siapa yang diuntungkan dari penyebaran informasi ini?”, dan “Apakah saya bereaksi karena fakta atau emosi?”. Kebiasaan sederhana ini dapat secara signifikan mengurangi penyebaran misinformasi dan melindungi ruang publik digital kita.',
        },
      ],
    },
    {
      'icon': Icons.search,
      'title': 'Menganalisis Kebenaran Informasi',
      'subtitle': 'Pendekatan Sistematis untuk Verifikasi Fakta',
      'color': const Color(0xFF5B9BD5),
      'category': 'Misinformasi',
      'readTime': '9 menit',
      'objective':
          'Memberikan kerangka kerja praktis dan terstruktur bagi pembaca untuk memverifikasi kebenaran informasi sebelum mempercayai atau membagikannya.',
      'sections': [
        {
          'title': 'Pendahuluan',
          'content':
              'Di tengah ledakan konten digital, kemampuan memverifikasi fakta menjadi keterampilan esensial. Tanpa pendekatan yang sistematis, kita mudah terjebak dalam confirmation bias—kecenderungan hanya menerima informasi yang sesuai dengan keyakinan kita. Metode berikut membantu kita tetap objektif dan berbasis bukti.',
        },
        {
          'title': 'Metode 5W + 1H untuk Analisis Mendalam',
          'points': [
            'Who → Siapa sumber utama? Apakah penulis memiliki keahlian di bidang tersebut?',
            'What → Apa pesan inti dan klaim spesifik yang dibuat?',
            'When → Kapan informasi ini dipublikasikan atau peristiwa terjadi? Apakah masih relevan?',
            'Where → Di mana informasi ini pertama kali muncul? Platform apa yang digunakan?',
            'Why → Apa motif di balik informasi ini? Apakah untuk mengedukasi, memengaruhi, atau menipu?',
            'How → Bagaimana klaim ini dapat dibuktikan atau disanggah? Adakah metode verifikasi independen?',
          ],
        },
        {
          'title': 'Alat Bantu Verifikasi Digital',
          'content':
              'Teknologi menyediakan berbagai tools gratis yang sangat efektif.',
          'points': [
            'Google Reverse Image Search dan TinEye → melacak asal-usul gambar',
            'Wayback Machine (archive.org) → melihat versi lama situs web',
            'Cekfakta.com dan Turnbackhoax.id → basis data hoaks Indonesia',
            'FactCheck.org, Snopes.com → untuk isu internasional',
            'WHOIS lookup → memeriksa pemilik domain',
          ],
        },
        {
          'title': 'Checklist Verifikasi Cepat',
          'points': [
            '✓ Identitas penulis/redaksi jelas',
            '✓ Tanggal publikasi relevan',
            '✓ Gambar/video tidak dimanipulasi',
            '✓ Klaim didukung sumber independen',
            '✓ Ada referensi ahli',
            '✓ Tidak ada kontradiksi logis',
          ],
        },
        {
          'title': 'Refleksi & Takeaway',
          'content':
              'Verifikasi bukan proses panjang jika dijadikan kebiasaan. Luangkan 2–3 menit sebelum membagikan—dampaknya besar. Ingat: “Kebenaran tidak takut diperiksa.”',
        },
      ],
    },
    {
      'icon': Icons.shield_outlined,
      'title': 'Mengenali Akun Palsu dan Bot di Media Sosial',
      'subtitle': 'Strategi Perlindungan dari Manipulasi Opini Publik',
      'color': const Color(0xFF9B9B9B),
      'category': 'Keamanan Digital',
      'readTime': '6 menit',
      'objective':
          'Membantu pengguna mengidentifikasi akun palsu serta bot otomatis yang sering digunakan untuk menyebarkan propaganda dan hoaks.',
      'sections': [
        {
          'title': 'Pendahuluan',
          'content':
              'Menurut studi MIT 2018, informasi palsu menyebar 6 kali lebih cepat daripada fakta—sebagian besar dibantu bot dan akun palsu. Mengenali cirinya adalah benteng pertahanan pertama.',
        },
        {
          'title': 'Ciri-Ciri Akun Palsu',
          'points': [
            'Foto profil generik atau hasil steal',
            'Username acak dengan angka',
            'Bio kosong atau klise',
            'Following >> Followers',
            'Posting hanya repost',
          ],
        },
        {
          'title': 'Ciri-Ciri Bot Otomatis',
          'points': [
            'Posting teratur setiap jam',
            'Konten identik/copy-paste',
            'Komentar generik tidak relevan',
            'Hashtag berlebihan',
            'Aktivitas 24/7 tanpa pola manusia',
          ],
        },
        {
          'title': 'Langkah Praktis Perlindungan',
          'points': [
            'Periksa profil sebelum interaksi',
            'Gunakan Botometer atau Foller.me',
            'Laporkan akun mencurigakan',
            'Batasi pesan dan tag',
            'Aktifkan 2FA',
          ],
        },
        {
          'title': 'Refleksi & Takeaway',
          'content':
              'Media sosial memicu engagement cepat, bukan pemikiran mendalam. Waspada terhadap bot membantu menjaga diskursus publik tetap sehat.',
        },
      ],
    },
    {
      'icon': Icons.lock_outline,
      'title': 'Panduan Privasi Digital yang Komprehensif',
      'subtitle': 'Melindungi Data Pribadi di Era Pengawasan Massal',
      'color': const Color(0xFFE74C3C),
      'category': 'Privasi',
      'readTime': '10 menit',
      'objective':
          'Meningkatkan kesadaran dan memberikan langkah praktis perlindungan privasi digital.',
      'sections': [
        {
          'title': 'Pendahuluan',
          'content':
              'Privasi digital adalah hak asasi. Setiap klik meninggalkan jejak yang bisa dieksploitasi. Skandal seperti Cambridge Analytica membuktikan kerentanan data kita.',
        },
        {
          'title': 'Keamanan Password dan Autentikasi',
          'points': [
            'Password unik minimal 16 karakter per akun',
            'Gunakan password manager (Bitwarden, 1Password)',
            'Aktifkan 2FA di semua layanan',
            'Hindari info pribadi sebagai password',
          ],
        },
        {
          'title': 'Keamanan Perangkat dan Aplikasi',
          'points': [
            'Update OS dan app secara rutin',
            'Unduh hanya dari store resmi',
            'Batasi izin aplikasi',
            'Gunakan antivirus dan enkripsi',
          ],
        },
        {
          'title': 'Praktik Aman Saat Berinternet',
          'points': [
            'Pastikan HTTPS (ikon gembok)',
            'Gunakan VPN di WiFi publik',
            'Nonaktifkan pelacakan lintas situs',
            'Hapus cookies rutin',
            'Waspada phishing',
          ],
        },
        {
          'title': 'Refleksi & Takeaway',
          'content':
              'Privasi adalah kontrol atas data diri sendiri. Mulai dari password manager dan VPN, lalu tingkatkan kebiasaan digital hygiene. “Jika gratis, Anda adalah produknya.”',
        },
      ],
    },
    {
      'icon': Icons.warning_amber_outlined,
      'title': 'Memahami Disinformasi',
      'subtitle': 'Bedanya dengan Misinformasi dan Strategi Penanggulangannya',
      'color': const Color(0xFFF39C12),
      'category': 'Disinformasi',
      'readTime': '8 menit',
      'objective':
          'Memberikan pemahaman mendalam tentang disinformasi serta cara mengenali dan melawannya secara efektif.',
      'sections': [
        {
          'title': 'Pendahuluan',
          'content':
              'Disinformasi adalah informasi palsu yang disebarkan sengaja untuk menipu. Berbeda dengan misinformasi (salah tapi tidak disengaja), disinformasi adalah senjata informasi.',
        },
        {
          'title': 'Perbedaan Utama',
          'points': [
            'Misinformasi → Salah, tapi tanpa niat buruk',
            'Disinformasi → Salah, dibuat sengaja untuk menipu',
            'Malinformasi → Benar, tapi digunakan untuk merugikan',
          ],
        },
        {
          'title': 'Ciri-Ciri Kampanye Disinformasi',
          'points': [
            'Koordinasi masif oleh bot',
            'Narasi hitam-putih ekstrem',
            'Pemanfaatan emosi kuat',
            'Deepfake atau kutipan out of context',
            'Targeting untuk polarisasi',
          ],
        },
        {
          'title': 'Strategi Penanggulangan',
          'points': [
            'Prebunking: edukasi sebelum terpapar',
            'Verifikasi proaktif',
            'Jangan amplifikasi (meski membantah)',
            'Dukung jurnalisme berkualitas',
            'Bangun literasi media komunitas',
          ],
        },
        {
          'title': 'Refleksi & Takeaway',
          'content':
              'Melawan disinformasi adalah tanggung jawab kolektif. Tanyakan selalu: “Siapa yang diuntungkan dari narasi ini?”',
        },
      ],
    },
  ];

  static final List<Map<String, dynamic>> videos = [
    {
      'title': 'Apa Itu Phishing dan Cara Menghindarinya',
      'category': 'Keamanan Digital',
      'duration': '6:45',
      'views': '12.5K',
      'thumbnail': 'assets/thumbnails/phishing.jpg',
      'videoPath': 'assets/videos/phishing.mp4',
      'description':
          'Video ini menjelaskan pengertian phishing, jenis-jenis serangan yang paling umum, ciri-ciri email/SMS palsu, serta langkah praktis untuk melindungi akun dan data pribadi Anda dari penipuan online.',
    },
    {
      'title': 'Mengenali dan Melawan Hoaks di Media Sosial',
      'category': 'Misinformasi',
      'duration': '8:20',
      'views': '9.8K',
      'thumbnail': 'assets/thumbnails/hoaks.jpeg',
      'videoPath': 'assets/videos/hoaks.mp4',
      'description':
          'Pelajari teknik yang sering digunakan penyebar hoaks, contoh kasus nyata, dan metode cepat untuk memverifikasi informasi sebelum Anda membagikannya ke orang lain.',
    },
    {
      'title': 'Cara Mengamankan Privasi di Media Sosial',
      'category': 'Privasi',
      'duration': '10:15',
      'views': '14.3K',
      'thumbnail': 'assets/thumbnails/aman_medsos.png',
      'videoPath': 'assets/videos/privasi.mp4',
      'description':
          'Panduan lengkap: mengaktifkan 2FA, mengatur visibilitas postingan, membatasi data yang dibagikan ke aplikasi pihak ketiga, dan kebiasaan aman sehari-hari.',
    },
    {
      'title': 'Bedanya Misinformasi vs Disinformasi',
      'category': 'Disinformasi',
      'duration': '7:30',
      'views': '6.2K',
      'thumbnail': 'assets/thumbnails/disinformasi.png',
      'videoPath': 'assets/videos/disinformasi.mp4',
      'description':
          'Penjelasan sederhana tapi mendalam tentang perbedaan misinformasi, disinformasi, dan malinformasi, beserta contoh nyata serta cara masyarakat bisa melawannya.',
    },
  ];

  static final List<String> categories = [
    'Semua',
    'Misinformasi',
    'Disinformasi',
    'Keamanan Digital',
    'Privasi',
  ];
}