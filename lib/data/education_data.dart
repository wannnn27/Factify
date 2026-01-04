import 'package:flutter/material.dart';

class EducationData {
  static final List<Map<String, dynamic>> articles = [
    {
      'icon': Icons.lightbulb_outline,
      'imageUrl': 'https://images.unsplash.com/photo-1456324504439-367cee3b3c32?w=800&auto=format&fit=crop&q=80',
      'title': 'Berpikir Kritis di Era Digital',
      'subtitle': 'Menyaring Informasi dan Menghindari Manipulasi Opini',
      'color': const Color(0xFF4ECDC4),
      'category': 'Semua',
      'readTime': '12 menit',
      'author': 'Tim Factify',
      'publishDate': '20 Des 2024',
      'objective':
          'Membekali pembaca dengan kemampuan berpikir kritis untuk menavigasi banjir informasi digital, mengenali manipulasi, serta membuat keputusan yang rasional dan mandiri.',
      'sections': [
        {
          'title': 'Pendahuluan',
          'content':
              'Era digital telah mengubah cara kita mengonsumsi informasi secara fundamental. Jika dulu informasi adalah komoditas langka yang dikontrol oleh gatekeeper tradisional seperti editor surat kabar dan produser televisi, kini siapa pun dengan smartphone bisa menjadi produsen dan distributor konten.\n\nMenurut laporan We Are Social & Kepios 2024, rata-rata orang Indonesia menghabiskan 7 jam 38 menit per hari mengakses internet—salah satu yang tertinggi di dunia. Dengan volume informasi sebesar ini, otak kita tidak dirancang untuk memproses semuanya secara kritis.\n\nDaniel Kahneman, pemenang Nobel Ekonomi, membedakan dua sistem berpikir: Sistem 1 (cepat, otomatis, emosional) dan Sistem 2 (lambat, deliberatif, logis). Sayangnya, konsumsi media sosial mengaktifkan Sistem 1—membuat kita rentan terhadap manipulasi.\n\nArtikel ini akan memandu Anda mengaktifkan Sistem 2 dalam mengonsumsi informasi digital.',
        },
        {
          'title': '1. Memahami Ekosistem Informasi Digital',
          'content':
              'Sebelum bisa berpikir kritis, kita perlu memahami bagaimana informasi mengalir di era digital.',
          'points': [
            'ALGORITMA FILTER BUBBLE: Platform seperti Facebook, TikTok, dan YouTube menggunakan algoritma yang mempelajari preferensi Anda dan menyajikan konten serupa—menciptakan "ruang gema" yang memperkuat keyakinan yang sudah ada',
            'EKONOMI PERHATIAN: Konten yang memancing emosi kuat (marah, takut, terkejut) mendapat engagement lebih tinggi, membuat platform memprioritaskan sensasionalisme di atas akurasi',
            'ASYMMETRIC WARFARE: Memproduksi hoaks jauh lebih mudah dan murah daripada membantahnya—satu klaim palsu membutuhkan 10x lebih banyak effort untuk dikoreksi',
            'NETWORK EFFECTS: Informasi palsu yang dibagikan oleh teman atau keluarga dipercaya 3x lebih tinggi daripada dari sumber tidak dikenal',
            'CONFIRMATION BIAS: Otak kita secara alami mencari informasi yang mengkonfirmasi keyakinan yang sudah ada dan mengabaikan yang bertentangan',
          ],
        },
        {
          'title': '2. Framework SIFT untuk Evaluasi Cepat',
          'content':
              'Mike Caulfield dari University of Washington mengembangkan metode SIFT yang praktis untuk evaluasi informasi dalam hitungan detik.',
          'points': [
            'S - STOP: Berhenti sebelum bereaksi. Tanyakan: "Apakah saya tahu dan mempercayai sumber ini?" Jika tidak, lanjutkan ke langkah berikutnya',
            'I - INVESTIGATE the source: Siapa yang memproduksi informasi ini? Apa rekam jejak dan keahlian mereka? Gunakan Wikipedia atau Google untuk mencari tahu reputasi sumber',
            'F - FIND better coverage: Cari apakah sumber lain yang lebih terpercaya juga melaporkan hal yang sama. Jika hanya satu sumber yang melaporkan klaim besar, waspadai',
            'T - TRACE claims to origin: Seringkali berita adalah interpretasi dari sumber primer. Temukan sumber asli untuk memahami konteks penuh',
          ],
        },
        {
          'title': '3. Mengenali Teknik Manipulasi Umum',
          'content':
              'Propagandis dan penyebar hoaks menggunakan teknik psikologi yang sudah dipelajari sejak lama. Kenali pola ini untuk membangun imunitas.',
          'points': [
            'APPEAL TO EMOTION: Menggunakan cerita menyentuh, gambar mengejutkan, atau bahasa provokatif untuk bypass pemikiran rasional',
            'FALSE DICHOTOMY: Menyajikan isu kompleks sebagai pilihan hitam-putih ("Anda bersama kami atau melawan kami")',
            'GISH GALLOP: Membanjiri dengan banyak klaim palsu sekaligus sehingga mustahil dibantah satu per satu',
            'CHERRY PICKING: Memilih data yang mendukung narasi sambil mengabaikan bukti yang bertentangan',
            'APPEAL TO AUTHORITY: Mengutip "pakar" yang sebenarnya tidak memiliki keahlian di bidang yang dibahas',
            'MANUFACTURED CONSENSUS: Menggunakan bot dan akun palsu untuk menciptakan ilusi bahwa "semua orang setuju"',
            'FIREHOSE OF FALSEHOOD: Teknik propaganda Rusia yang membanjiri ruang informasi dengan banyak narasi berbeda untuk menciptakan kebingungan',
          ],
        },
        {
          'title': '4. Membangun Kebiasaan Konsumsi Informasi Sehat',
          'content':
              'Berpikir kritis bukan hanya tentang mengevaluasi, tapi juga tentang membangun kebiasaan yang mendukung.',
          'points': [
            'DIVERSIFIKASI SUMBER: Sengaja ikuti akun dan media dengan perspektif berbeda untuk menghindari filter bubble',
            'SLOW NEWS: Tidak semua berita membutuhkan respons instan. Tunggu 24-48 jam untuk isu kontroversial agar fakta lebih lengkap',
            'LATERAL READING: Saat membaca artikel, buka tab baru untuk memeriksa sumber—bukan hanya membaca konten situs itu sendiri',
            'EMOTIONAL PAUSE: Jika sebuah konten memicu emosi kuat, itu justru alasan untuk BERHENTI dan memeriksa, bukan langsung membagikan',
            'PREBUNKING: Pelajari teknik manipulasi SEBELUM terpapar, sehingga Anda memiliki "antibodi mental"',
            'DIGITAL DETOX: Jadwalkan waktu tanpa media sosial untuk memberikan otak waktu memproses informasi dengan lebih mendalam',
          ],
        },
        {
          'title': 'Refleksi & Takeaway',
          'content':
              'Berpikir kritis di era digital bukan tentang cynicism—meragukan segalanya—melainkan tentang skeptisisme sehat yang berbasis bukti.\n\nIngat tiga pertanyaan kunci sebelum mempercayai atau membagikan informasi:\n\n1. "Dari mana saya tahu ini benar?"\n2. "Siapa yang diuntungkan jika saya percaya atau membagikan ini?"\n3. "Bagaimana perasaan saya sekarang, dan apakah emosi ini mempengaruhi penilaian saya?"\n\nSeperti kata Carl Sagan: "Extraordinary claims require extraordinary evidence." Di dunia di mana siapa pun bisa mempublikasikan apa pun, kemampuan membedakan sinyal dari noise adalah superpower yang harus Anda kembangkan.\n\nMulai hari ini: evaluasi SATU informasi yang Anda terima menggunakan framework SIFT sebelum membagikannya.',
        },
      ],
    },
    {
      'icon': Icons.search,
      'imageUrl': 'https://images.unsplash.com/photo-1586281380349-632531db7ed4?w=800&auto=format&fit=crop&q=80',
      'title': 'Panduan Lengkap Verifikasi Fakta',
      'subtitle': 'Toolkit Profesional untuk Mengecek Kebenaran Informasi',
      'color': const Color(0xFF5B9BD5),
      'category': 'Misinformasi',
      'readTime': '15 menit',
      'author': 'Tim Factify',
      'publishDate': '18 Des 2024',
      'objective':
          'Memberikan kerangka kerja lengkap dan toolkit praktis untuk memverifikasi berbagai jenis informasi: teks, gambar, video, dan klaim sosial media.',
      'sections': [
        {
          'title': 'Pendahuluan',
          'content':
              'Fact-checking atau verifikasi fakta dulunya adalah domain eksklusif jurnalis profesional. Namun di era di mana setiap orang adalah publisher potensial, kemampuan ini menjadi life skill yang esensial.\n\nStudi dari MIT (2018) yang dipublikasikan di jurnal Science menemukan bahwa berita palsu di Twitter menyebar 6x lebih cepat daripada berita benar, dan mencapai 1.500 orang 6x lebih cepat. Manusia, bukan bot, adalah driver utama penyebaran ini.\n\nKabar baiknya: Anda tidak memerlukan gelar jurnalistik untuk melakukan verifikasi dasar. Artikel ini akan membekali Anda dengan toolkit yang sama yang digunakan oleh fact-checker profesional di organisasi seperti AFP Fact Check, Reuters, dan Mafindo.',
        },
        {
          'title': '1. Verifikasi Gambar: Apakah Foto Ini Asli?',
          'content':
              'Gambar adalah salah satu medium yang paling sering dimanipulasi karena dampak emosionalnya yang kuat.',
          'points': [
            'REVERSE IMAGE SEARCH: Upload gambar ke Google Images, TinEye, atau Yandex untuk menemukan penggunaan sebelumnya. Jika foto "terbaru" muncul dari tahun lalu, itu red flag',
            'METADATA CHECK: Gunakan Jeffrey\'s EXIF Viewer atau FotoForensics untuk memeriksa kapan dan di mana foto diambil. Metadata bisa dihapus, jadi ketiadaannya juga patut dicurigai',
            'FORENSIC ANALYSIS: FotoForensics.com dapat mengidentifikasi area yang diedit melalui Error Level Analysis (ELA). Area yang dimanipulasi akan menunjukkan level berbeda',
            'GEOGRAPHIC VERIFICATION: Gunakan Google Maps, Google Earth, atau Wikimapia untuk memverifikasi lokasi yang diklaim. Perhatikan landmark, papan jalan, dan arsitektur',
            'WEATHER CHECK: Wolfram Alpha atau Weather Underground dapat mengkonfirmasi kondisi cuaca historis. Jika klaim menyebut hujan lebat tapi foto menunjukkan langit cerah, itu kontradiksi',
            'SHADOW ANALYSIS: Bayangan yang tidak konsisten dalam foto bisa mengindikasikan composite image',
          ],
        },
        {
          'title': '2. Verifikasi Video: Lebih Kompleks, Tetap Bisa',
          'content':
              'Video lebih sulit diverifikasi daripada foto, tetapi prinsip dasarnya sama.',
          'points': [
            'INVID/WEVERIFY: Plugin browser gratis yang dapat memecah video menjadi keyframes dan melakukan reverse image search pada masing-masing',
            'YOUTUBE DATAVIEWER: Tool dari Amnesty International untuk mengekstrak thumbnail dan metadata dari video YouTube',
            'AUDIO ANALYSIS: Perhatikan apakah audio sinkron dengan visual. Deepfake sering memiliki lip sync yang sedikit off',
            'CONTEXT CHECK: Apakah video dipotong dari konteks lebih panjang? Cari versi lengkapnya',
            'SOURCE TRACING: Siapa yang pertama kali mengupload video ini? Akun dengan track record terpercaya atau akun anonim baru?',
            'GEOLOCASI VIDEO: Seperti foto, verifikasi lokasi melalui landmark, tanda jalan, bahasa di papan, dan arsitektur bangunan',
          ],
        },
        {
          'title': '3. Verifikasi Klaim Teks dan Kutipan',
          'content':
              'Klaim tekstual dan kutipan sering dimanipulasi atau dibuat-buat sepenuhnya.',
          'points': [
            'QUOTE VERIFICATION: Gunakan Google dengan tanda kutip ("...") untuk mencari apakah kutipan benar-benar pernah diucapkan. Jika tidak ada sumber kredibel, skeptislah',
            'DATABASE FACT-CHECK: Cek cekfakta.com, turnbackhoax.id, kominfo.go.id/hoaks, atau factcheck.org untuk melihat apakah klaim sudah pernah diverifikasi',
            'PRIMARY SOURCE: Selalu cari sumber primer. Jika berita mengklaim "menurut studi...", temukan studi aslinya dan baca abstraknya',
            'EXPERT CONSULTATION: Untuk klaim ilmiah atau teknis, cek apakah klaim didukung oleh konsensus ahli atau hanya satu-dua outlier',
            'TEMPORAL CHECK: Apakah berita ini baru atau daur ulang? Gunakan filter waktu di Google Search untuk melihat kapan klaim ini pertama muncul',
            'DOMAIN CHECK: Gunakan WHOIS lookup untuk memeriksa kapan domain dibuat. Situs berita palsu sering menggunakan domain baru',
          ],
        },
        {
          'title': '4. Toolkit Lengkap Fact-Checker',
          'content':
              'Bookmark tools ini untuk akses cepat saat memverifikasi informasi.',
          'points': [
            'GAMBAR: Google Images, TinEye, Yandex, FotoForensics, Jeffrey\'s EXIF Viewer',
            'VIDEO: InVID/WeVerify, YouTube DataViewer, Amnesty Citizen Evidence Lab',
            'WEBSITE: WHOIS Lookup, Wayback Machine (archive.org), BuiltWith',
            'SOSIAL MEDIA: Botometer (cek akun bot), Social Blade (analisis pertumbuhan akun), Foller.me',
            'FAKTA INDONESIA: Cekfakta.com, Turnbackhoax.id, Mafindo, Kominfo Hoaks',
            'FAKTA INTERNASIONAL: Snopes, FactCheck.org, PolitiFact, AFP Fact Check, Full Fact',
            'CUACA & LOKASI: Wolfram Alpha, Google Earth, SunCalc (posisi matahari)',
          ],
        },
        {
          'title': 'Refleksi & Takeaway',
          'content':
              'Verifikasi fakta bukanlah proses yang memakan waktu lama jika dijadikan kebiasaan. Sebagian besar hoaks bisa diidentifikasi dalam 60-90 detik menggunakan teknik sederhana seperti reverse image search.\n\nPrinsip utama yang harus diingat:\n\n• Informasi yang viral BUKAN berarti benar—justru sebaliknya, viralitas sering berbanding terbalik dengan akurasi\n• Burden of proof ada pada pembuat klaim, bukan pada Anda untuk menyangkalnya\n• "Tidak ada bukti" BUKAN sama dengan "terbukti salah"—tapi cukup untuk menahan diri dari menyebarkan\n• Lebih baik terlambat dan benar daripada cepat tapi menyebarkan hoaks\n\nSeperti kata pepatah jurnalis: "If your mother says she loves you, check it out." Skeptisisme profesional adalah tanda kematangan digital.',
        },
      ],
    },
    {
      'icon': Icons.shield_outlined,
      'imageUrl': 'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?w=800&auto=format&fit=crop&q=80',
      'title': 'Mengenali Akun Palsu dan Bot',
      'subtitle': 'Pertahanan dari Manipulasi Opini Publik Terorganisir',
      'color': const Color(0xFF9B59B6),
      'category': 'Keamanan Digital',
      'readTime': '10 menit',
      'author': 'Tim Factify',
      'publishDate': '15 Des 2024',
      'objective':
          'Membantu pengguna mengidentifikasi akun palsu dan bot yang digunakan dalam operasi pengaruh terkoordinasi.',
      'sections': [
        {
          'title': 'Pendahuluan',
          'content':
              'Pada tahun 2017, Twitter mengungkapkan bahwa sekitar 50.000 akun bot Rusia memposting konten terkait pemilu AS 2016, menjangkau 677.775 orang Amerika. Di Indonesia, fenomena serupa terjadi—buzzer dan akun palsu menjadi senjata dalam pertarungan naratif politik dan komersial.\n\nOperasi pengaruh (influence operations) menggunakan kombinasi akun palsu, bot otomatis, dan koordinasi terorganisir untuk menciptakan ilusi dukungan massal, memviralkan narasi tertentu, atau menyerang lawan.\n\nMemahami cara kerja operasi ini adalah langkah pertama untuk tidak menjadi korban—atau tanpa sadar menjadi amplifier.',
        },
        {
          'title': '1. Taksonomi Akun Tidak Autentik',
          'content':
              'Tidak semua akun palsu sama. Pahami perbedaannya untuk deteksi yang lebih akurat.',
          'points': [
            'BOT OTOMATIS: Akun yang dioperasikan sepenuhnya oleh software. Posting dengan interval teratur, respons template, aktif 24/7',
            'CYBORG: Akun semi-otomatis yang dioperasikan kombinasi manusia dan bot. Lebih sulit dideteksi karena memiliki elemen human-like',
            'SOCKPUPPET: Akun palsu yang dioperasikan manusia untuk menyamar sebagai orang berbeda. Sering digunakan untuk astroturfing',
            'TROLL: Akun (asli atau palsu) yang sengaja memancing konflik dan polarisasi untuk mengganggu diskusi konstruktif',
            'BUZZER: Istilah Indonesia untuk akun bayaran yang mempromosikan atau menyerang narasi tertentu—bisa asli atau palsu',
            'COORDINATED NETWORK: Kumpulan akun yang beroperasi terkoordinasi, sering posting konten identik dalam waktu berdekatan',
          ],
        },
        {
          'title': '2. Red Flags Akun Palsu',
          'content':
              'Indikator-indikator berikut patut dicurigai, terutama jika muncul bersamaan.',
          'points': [
            'PROFIL: Foto stock/AI-generated, bio generik atau kosong, nama dengan angka acak (user38274619)',
            'AKTIVITAS: Posting sangat tinggi (ratusan tweet/hari), aktif jam-jam tidak wajar, pola posting terlalu teratur',
            'KONTEN: Hanya repost/retweet tanpa konten original, hashtag berlebihan, bahasa template/robotic',
            'NETWORK: Following/followers ratio tidak wajar, followers sebagian besar juga akun mencurigakan',
            'SEJARAH: Akun baru (<6 bulan) dengan ribuan posting, perubahan topik drastis, gaps aktivitas yang aneh',
            'ENGAGEMENT: Komentar tidak relevan dengan konten, respons instan terhadap topik trending',
          ],
        },
        {
          'title': '3. Tools Deteksi Bot',
          'content':
              'Gunakan alat bantu ini untuk analisis yang lebih objektif.',
          'points': [
            'BOTOMETER (botometer.osome.iu.edu): Tool dari Indiana University yang memberikan skor probabilitas bot untuk akun Twitter',
            'BOTSENTINEL (botsentinel.com): Menganalisis perilaku akun dan memberikan rating keaslian',
            'FOLLER.ME: Analisis komprehensif akun Twitter termasuk pola posting dan sumber',
            'SOCIAL BLADE: Melacak pertumbuhan followers—lonjakan tidak natural mengindikasikan pembelian followers',
            'HOAXY: Memvisualisasikan bagaimana informasi menyebar dan akun mana yang menjadi amplifier utama',
            'SPARKTORO: Mengaudit kualitas followers dan mengidentifikasi fake followers',
          ],
        },
        {
          'title': 'Refleksi & Takeaway',
          'content':
              'Operasi pengaruh mengeksploitasi kecenderungan alami manusia untuk social proof—kita cenderung mempercayai sesuatu jika "banyak orang" mempercayainya. Bot dan akun palsu memanipulasi sinyal sosial ini.\n\nLangkah perlindungan praktis:\n\n• Jangan engage dengan konten provokatif dari akun yang tidak jelas—engagement apapun (termasuk bantahan) membantu amplifikasi\n• Perhatikan SIAPA yang menyebarkan, bukan hanya APA yang disebarkan\n• Waspadai narasi yang terlalu polarizing—operasi pengaruh sengaja memecah belah\n• Laporkan akun mencurigakan ke platform—ini membantu pembersihan ekosistem\n\nIngat: di media sosial, Anda bukan hanya konsumen informasi—Anda juga adalah node dalam jaringan penyebaran. Pilih dengan bijak apa yang Anda amplifikasi.',
        },
      ],
    },
    {
      'icon': Icons.lock_outline,
      'imageUrl': 'https://images.unsplash.com/photo-1563013544-824ae1b704d3?w=800&auto=format&fit=crop&q=80',
      'title': 'Keamanan Digital Personal',
      'subtitle': 'Melindungi Identitas dan Data di Era Pengawasan',
      'color': const Color(0xFFE74C3C),
      'category': 'Privasi',
      'readTime': '14 menit',
      'author': 'Tim Factify',
      'publishDate': '12 Des 2024',
      'objective':
          'Panduan lengkap implementasi keamanan digital personal dari level dasar hingga advanced.',
      'sections': [
        {
          'title': 'Pendahuluan',
          'content':
              'Setiap tahun, miliaran data pribadi bocor melalui peretasan, kebocoran database, dan social engineering. Pada 2023 saja, lebih dari 8 miliar records terekspos secara global. Di Indonesia, kasus kebocoran data BPJS, eHAC, dan berbagai marketplace membuktikan tidak ada yang kebal.\n\nPrivasi digital bukan tentang "menyembunyikan sesuatu"—ini tentang kontrol atas informasi pribadi Anda. Seperti kata Edward Snowden: "Arguing that you don\'t care about privacy because you have nothing to hide is like arguing that you don\'t care about free speech because you have nothing to say."\n\nArtikel ini memberikan roadmap praktis untuk mengamankan kehidupan digital Anda, dari langkah paling dasar hingga praktik advanced.',
        },
        {
          'title': '1. Password & Autentikasi: Fondasi Keamanan',
          'content':
              'Password yang lemah adalah pintu masuk utama bagi attackers. Ini adalah area yang harus diprioritaskan.',
          'points': [
            'PASSWORD MANAGER: Gunakan Bitwarden (gratis, open-source), 1Password, atau Dashlane. JANGAN simpan password di browser atau catatan',
            'PASSPHRASE: Buat password dari 4-5 kata acak yang panjang, contoh: "kuda-baterai-stapler-correct" (25+ karakter) lebih kuat dan mudah diingat',
            '2FA/MFA WAJIB: Aktifkan di SEMUA akun penting. Prioritas: Email utama, bank, sosmed. Gunakan app (Google/Microsoft Authenticator), hindari SMS',
            'HARDWARE KEY: Untuk keamanan maksimal, gunakan YubiKey atau Google Titan untuk akun paling sensitif',
            'UNIQUE PASSWORD: Setiap akun HARUS punya password berbeda. Jika satu bocor, yang lain tetap aman',
            'CHECK BREACHES: Cek haveibeenpwned.com secara berkala untuk melihat apakah email Anda terlibat dalam kebocoran data',
          ],
        },
        {
          'title': '2. Keamanan Perangkat',
          'content':
              'Perangkat fisik adalah fortress yang harus dijaga ketat.',
          'points': [
            'UPDATE OTOMATIS: Aktifkan auto-update untuk OS dan aplikasi. 60% serangan sukses karena vulnerability yang sudah ada patch-nya',
            'ENKRIPSI DISK: Aktifkan FileVault (Mac) atau BitLocker (Windows). Android dan iOS sudah terenkripsi by default jika pakai lock screen',
            'LOCK SCREEN: Gunakan PIN minimal 6 digit atau biometrik. Jangan gunakan pattern yang mudah ditebak',
            'APP PERMISSIONS: Audit izin aplikasi secara berkala. Apakah game perlu akses kontak? Apakah kalkulator perlu akses lokasi?',
            'OFFICIAL STORES ONLY: Download aplikasi hanya dari Play Store/App Store. Hindari APK dari sumber tidak jelas',
            'FIND MY DEVICE: Aktifkan fitur pelacakan agar bisa remote wipe jika perangkat hilang/dicuri',
          ],
        },
        {
          'title': '3. Privasi Browsing dan Network',
          'content':
              'Aktivitas online Anda meninggalkan jejak yang bisa dilacak. Minimalisasi exposure.',
          'points': [
            'HTTPS EVERYWHERE: Pastikan semua situs yang Anda kunjungi menggunakan HTTPS. Install extension HTTPS Everywhere',
            'VPN TERPERCAYA: Gunakan VPN berbayar bereputasi (Mullvad, ProtonVPN, IVPN) saat di WiFi publik. VPN gratis sering menjual data Anda',
            'BROWSER PRIVACY: Gunakan Firefox dengan privacy settings ketat, atau Brave. Chrome sangat invasif terhadap privasi',
            'AD/TRACKER BLOCKER: Install uBlock Origin untuk memblokir iklan dan tracker. Pertimbangkan Pi-hole untuk level network',
            'DNS PRIVACY: Ganti DNS ke Cloudflare (1.1.1.1) atau Quad9 (9.9.9.9) yang lebih privat dari ISP default',
            'WIFI PUBLIK: Anggap SEMUA WiFi publik tidak aman. Selalu gunakan VPN, hindari transaksi sensitif',
          ],
        },
        {
          'title': '4. Minimalisasi Jejak Digital',
          'content':
              'Prinsip privasi: minimalisasi data yang Anda berikan.',
          'points': [
            'EMAIL ALIAS: Gunakan SimpleLogin atau AnonAddy untuk membuat alias email berbeda untuk setiap layanan',
            'DATA MINIMIZATION: Jangan berikan informasi yang tidak diperlukan. Tanggal lahir asli tidak perlu untuk semua situs',
            'SOCIAL MEDIA AUDIT: Review pengaturan privasi di semua platform. Siapa yang bisa melihat postingan, foto, lokasi Anda?',
            'GOOGLE ALTERNATIVES: Pertimbangkan alternatif yang lebih privat: DuckDuckGo (search), ProtonMail (email), Signal (messaging)',
            'OPT-OUT: Gunakan justdeleteme.xyz untuk panduan menghapus akun dari berbagai layanan',
            'DIGITAL DETOX: Hapus akun dan aplikasi yang tidak digunakan—setiap akun adalah potential attack surface',
          ],
        },
        {
          'title': 'Refleksi & Takeaway',
          'content':
              'Keamanan digital adalah spektrum, bukan binary. Anda tidak harus mengimplementasikan semuanya sekaligus. Mulai dari yang paling berdampak:\n\nPRIORITAS 1 (Hari ini): Password manager + 2FA untuk email utama\nPRIORITAS 2 (Minggu ini): 2FA untuk semua akun penting, update semua perangkat\nPRIORITAS 3 (Bulan ini): Audit app permissions, pasang VPN, ganti ke browser privat\nPRIORITAS 4 (Ongoing): Review dan minimalisasi jejak digital secara berkala\n\nIngat: keamanan sempurna tidak ada—yang ada adalah risk management yang proporsional dengan threat model Anda. Seorang aktivis atau jurnalis membutuhkan tingkat keamanan berbeda dari pengguna biasa.\n\nYang terpenting: mulai sekarang, jangan tunggu sampai menjadi korban.',
        },
      ],
    },
    {
      'icon': Icons.warning_amber_outlined,
      'imageUrl': 'https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=800&auto=format&fit=crop&q=80',
      'title': 'Anatomi Disinformasi',
      'subtitle': 'Memahami Struktur dan Strategi Kampanye Informasi Palsu',
      'color': const Color(0xFFF39C12),
      'category': 'Disinformasi',
      'readTime': '13 menit',
      'author': 'Tim Factify',
      'publishDate': '10 Des 2024',
      'objective':
          'Memberikan pemahaman mendalam tentang bagaimana kampanye disinformasi dirancang, dieksekusi, dan bisa dilawan.',
      'sections': [
        {
          'title': 'Pendahuluan',
          'content':
              'Disinformasi bukanlah fenomena baru—propaganda telah ada sejak zaman kuno. Yang baru adalah skala, kecepatan, dan presisi targeting yang dimungkinkan oleh teknologi digital.\n\nWorld Economic Forum menempatkan "misinformation and disinformation" sebagai risiko global nomor 1 untuk jangka pendek di 2024. Ini bukan lagi sekadar "berita palsu"—ini adalah ancaman terhadap demokrasi, kesehatan publik, dan kohesi sosial.\n\nUntuk melawan musuh, Anda harus memahaminya. Artikel ini membedah anatomi kampanye disinformasi: siapa pelakunya, apa motivasinya, bagaimana taktiknya, dan bagaimana kita bisa membangun pertahanan.',
        },
        {
          'title': '1. Terminologi yang Tepat',
          'content':
              'Presisi bahasa penting untuk pemahaman yang benar.',
          'points': [
            'MISINFORMATION: Informasi salah yang disebarkan TANPA niat jahat. Contoh: nenek membagikan hoaks kesehatan karena khawatir pada keluarga',
            'DISINFORMATION: Informasi salah yang SENGAJA dibuat dan disebarkan untuk menipu. Contoh: propaganda politik yang diketahui penciptanya sebagai kebohongan',
            'MALINFORMATION: Informasi BENAR yang disebarkan dengan niat merugikan. Contoh: doxing, membocorkan informasi pribadi seseorang',
            'INFORMATION DISORDER: Istilah payung untuk ketiga fenomena di atas—menggambarkan ekosistem informasi yang "sakit"',
            'INFLUENCE OPERATION: Kampanye terkoordinasi (sering melibatkan state actors) untuk mempengaruhi opini publik atau proses demokrasi',
            'COMPUTATIONAL PROPAGANDA: Penggunaan bot, algoritma, dan automasi untuk menyebarkan propaganda di skala besar',
          ],
        },
        {
          'title': '2. Aktor dan Motivasi',
          'content':
              'Disinformasi tidak muncul dari vacuum—ada aktor dengan motivasi spesifik.',
          'points': [
            'STATE ACTORS: Rusia, China, Iran dikenal menjalankan operasi pengaruh global. Motivasi: geopolitik, destabilisasi musuh',
            'POLITICAL OPERATIVES: Kampanye politik, partai, atau kandidat. Motivasi: memenangkan pemilu, mendiskreditkan lawan',
            'COMMERCIAL INTERESTS: Perusahaan atau industri. Motivasi: profit, melindungi reputasi, menyerang kompetitor',
            'IDEOLOGICAL GROUPS: Kelompok ekstremis, teori konspirasi. Motivasi: menyebarkan worldview, rekrutmen',
            'ATTENTION MERCHANTS: Content creators yang mencari viral. Motivasi: monetisasi, followers, fame',
            'FOREIGN INTERFERENCE: Aktor luar negeri yang ingin mempengaruhi urusan domestik. Motivasi bervariasi dari geopolitik sampai ekonomi',
          ],
        },
        {
          'title': '3. Playbook Disinformasi',
          'content':
              'Kampanye disinformasi mengikuti pola yang bisa dikenali.',
          'points': [
            'FABRICATION: Membuat konten palsu dari nol—berita fiktif, gambar doctored, video deepfake',
            'MANIPULATION: Mengubah konten asli—cropping, out of context, selective editing',
            'IMPERSONATION: Menyamar sebagai sumber terpercaya—akun palsu tokoh publik, situs tiruan media kredibel',
            'COORDINATED AMPLIFICATION: Menggunakan jaringan bot/akun palsu untuk memviralkan konten',
            'NARRATIVE LAUNDERING: Menanam narasi di media alternatif/fringe, lalu membuatnya "picked up" oleh media mainstream',
            'FLOODING THE ZONE: Membanjiri ruang informasi dengan banyak narasi berbeda untuk menciptakan kebingungan dan apathy',
            'EXPLOITING DIVISIONS: Memperbesar konflik yang sudah ada—rasial, agama, politik—untuk memolarisasi masyarakat',
          ],
        },
        {
          'title': '4. Pertahanan Berlapis',
          'content':
              'Melawan disinformasi membutuhkan pendekatan multi-level.',
          'points': [
            'INDIVIDUAL: Media literacy, skeptisisme sehat, verifikasi sebelum share, diversifikasi sumber informasi',
            'COMMUNITY: Prebunking di komunitas, koreksi oleh peer yang dipercaya lebih efektif dari debunking anonim',
            'PLATFORM: Transparansi algoritma, pelabelan konten, demonetisasi misinformasi, kerjasama dengan fact-checkers',
            'MEDIA: Jurnalisme berkualitas, slow news movement, explainer journalism yang memberikan konteks',
            'GOVERNMENT: Regulasi yang seimbang (bukan sensor), transparansi iklan politik, pendidikan literasi media di sekolah',
            'RESEARCH: Studi berkelanjutan tentang taktik baru, berbagi intelligence antar peneliti dan platform',
          ],
        },
        {
          'title': 'Refleksi & Takeaway',
          'content':
              'Disinformasi berhasil karena mengeksploitasi kelemahan kognitif dan emosional manusia—confirmation bias, tribal instincts, dan need for certainty di dunia yang kompleks.\n\nYang bisa Anda lakukan sekarang:\n\n1. PAUSE sebelum bereaksi terhadap konten yang memicu emosi kuat\n2. VERIFY sebelum amplifikasi—Anda adalah gatekeeper dalam network Anda\n3. DIVERSIFY sumber informasi untuk keluar dari filter bubble\n4. SUPPORT jurnalisme berkualitas dan organisasi fact-checking\n5. EDUCATE lingkaran terdekat Anda tentang literasi media\n\nSeperti kata Jonathan Swift lebih dari 300 tahun lalu: "Falsehood flies, and the truth comes limping after it." Di era digital, kita semua bertanggung jawab untuk memperlambat kepalsuan dan mempercepat kebenaran.',
        },
      ],
    },
    {
      'icon': Icons.psychology_outlined,
      'imageUrl': 'https://images.unsplash.com/photo-1677442136019-21780ecad995?w=800&auto=format&fit=crop&q=80',
      'title': 'Deepfake dan AI-Generated Content',
      'subtitle': 'Navigasi Era Dimana Mata Tidak Lagi Bisa Dipercaya',
      'color': const Color(0xFF8E44AD),
      'category': 'Keamanan Digital',
      'readTime': '11 menit',
      'author': 'Tim Factify',
      'publishDate': '8 Des 2024',
      'objective':
          'Memahami teknologi deepfake, implikasinya terhadap kebenaran, dan cara mendeteksinya.',
      'sections': [
        {
          'title': 'Pendahuluan',
          'content':
              'Pada 2019, sebuah video viral menunjukkan Mark Zuckerberg mengaku menguasai "data miliaran orang" dan merasa "seperti dewa." Video itu adalah deepfake—dibuat oleh seniman untuk memperingatkan tentang bahaya teknologi ini.\n\nDeepfake menggunakan deep learning neural networks untuk membuat video sintetis yang sangat realistis. Nama "deepfake" sendiri berasal dari kombinasi "deep learning" dan "fake."\n\nTeknologi ini berevolusi dengan kecepatan mengkhawatirkan. Yang dulu membutuhkan komputer superkuat dan keahlian khusus, kini bisa dilakukan dengan aplikasi smartphone. Era "seeing is believing" telah berakhir.',
        },
        {
          'title': '1. Jenis-Jenis Synthetic Media',
          'content':
              'Deepfake hanyalah satu dari berbagai bentuk media sintetis yang perlu dipahami.',
          'points': [
            'FACE SWAP: Wajah seseorang ditempelkan ke tubuh orang lain. Teknologi deepfake paling umum',
            'LIP SYNC: Bibir dimanipulasi untuk mengatakan kata-kata yang tidak pernah diucapkan',
            'VOICE CLONING: AI meniru suara seseorang berdasarkan sample audio singkat. Bisa membuat "telepon" dari siapa saja',
            'FULL BODY SYNTHESIS: Seluruh tubuh dan gerakan dibuat sintetis—bukan hanya wajah',
            'AI-GENERATED IMAGES: Tools seperti Midjourney, DALL-E, Stable Diffusion dapat membuat gambar realistis dari teks',
            'AI-GENERATED TEXT: Large Language Models seperti GPT-4 dapat menulis artikel, komentar, atau bahkan jurnal akademik palsu',
          ],
        },
        {
          'title': '2. Cara Mendeteksi Deepfake',
          'content':
              'Meski semakin canggih, deepfake masih memiliki artefak yang bisa diidentifikasi.',
          'points': [
            'UNNATURAL BLINKING: Awal-awal deepfake jarang berkedip. Versi baru sudah lebih baik, tapi pola kedipan masih bisa off',
            'LIGHTING INCONSISTENCY: Pencahayaan pada wajah tidak match dengan environment sekitar',
            'EDGE ARTIFACTS: Perhatikan batas antara wajah dan rambut, telinga, atau leher—sering blur atau berkedut',
            'AUDIO-VISUAL MISMATCH: Lip sync yang sedikit off, emosi suara tidak sesuai ekspresi wajah',
            'UNNATURAL SKIN TEXTURE: Terlalu smooth atau terlalu uniform, terutama saat gerakan',
            'BIZARRE ARTIFACTS: Gigi yang aneh, perhiasan yang berubah bentuk, background yang "melting"',
            'CONTEXT CHECK: Apakah video ini masuk akal? Apakah orang ini akan mengatakan/melakukan ini?',
          ],
        },
        {
          'title': '3. Tools Deteksi',
          'content':
              'Teknologi counter-deepfake berkembang seiring dengan deepfake itu sendiri.',
          'points': [
            'MICROSOFT VIDEO AUTHENTICATOR: Memberikan confidence score apakah video sudah dimanipulasi',
            'SENSITY.AI: Platform deteksi deepfake komersial yang digunakan perusahaan media',
            'DEEPWARE SCANNER: App mobile untuk mengecek video di device Anda',
            'REALITY DEFENDER: Real-time detection untuk enterprise',
            'FotoForensics + InVID: Untuk analisis manual frame-by-frame',
            'REVERSE SEARCH: Kadang video asli bisa ditemukan, membuktikan yang beredar adalah manipulasi',
          ],
        },
        {
          'title': '4. Implikasi dan Respons',
          'content':
              'Deepfake bukan hanya masalah teknis—ini adalah masalah sosial yang membutuhkan respons multi-dimensional.',
          'points': [
            'LIAR\'S DIVIDEND: Ironisnya, keberadaan deepfake memungkinkan orang menyangkal video ASLI dengan klaim "itu deepfake!"',
            'TRUST EROSION: Skeptisisme yang berlebihan sama berbahayanya dengan mudah percaya—keduanya merusak discourse',
            'CONSENT & ABUSE: >90% deepfake adalah pornografi non-consensual, sebagian besar menargetkan perempuan',
            'POLITICAL MANIPULATION: Sebuah deepfake yang viral di momen kritis bisa mengubah hasil pemilu',
            'RESPONSE: Content provenance standards (C2PA), digital watermarking, media literacy education, regulasi platform',
            'PERSONAL PROTECTION: Batasi foto/video publik yang bisa digunakan untuk training, gunakan privacy settings ketat',
          ],
        },
        {
          'title': 'Refleksi & Takeaway',
          'content':
              'Era deepfake membutuhkan evolusi dalam cara kita mengonsumsi media. "Seeing" tidak lagi cukup untuk "believing."\n\nFramework baru yang harus diterapkan:\n\n1. PROVENANCE: Dari mana video ini berasal? Siapa yang pertama mempostingnya?\n2. PLAUSIBILITY: Apakah masuk akal orang ini mengatakan/melakukan ini?\n3. CORROBORATION: Apakah ada sumber independen yang memverifikasi?\n4. DETECTION: Apakah ada tanda-tanda manipulasi teknis?\n\nSampai teknologi authentication dan detection lebih matang, skeptisisme terhadap konten viral yang sensasional adalah respons yang sehat—bukan paranoid.\n\nDan ingat: kemampuan untuk membuat deepfake akan terus demokratis. Yang membedakan masyarakat yang sehat adalah kemampuan kolektif untuk mendeteksi dan tidak mengamplifikasi.',
        },
      ],
    },
  ];

  static final List<Map<String, dynamic>> videos = [
    // 1. Phishing (Original Local)
    {
      'title': 'Waspada Phishing dan Penipuan',
      'category': 'Keamanan Digital',
      'duration': '5:32',
      'views': 'Video Lokal',
      'thumbnail': 'https://images.unsplash.com/photo-1563986768609-322da13575f3?w=500&auto=format&fit=crop&q=60',
      'videoUrl': 'assets/videos/phishing.mp4',
      'description': 'Video edukasi lengkap tentang cara mengidentifikasi dan menghindari serangan phishing di internet.',
    },
    // 2. Hoaks (Original Local)
    {
      'title': 'Bahaya Berita Hoaks',
      'category': 'Misinformasi',
      'duration': '8:47',
      'views': 'Video Lokal',
      'thumbnail': 'https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=500&auto=format&fit=crop&q=60',
      'videoUrl': 'assets/videos/hoaks.mp4',
      'description': 'Memahami dampak buruk penyebaran berita bohong (hoaks) bagi masyarakat dan keutuhan bangsa.',
    },
    // 3. Disinformasi (Original Local)
    {
      'title': 'Memahami Apa Itu Disinformasi',
      'category': 'Disinformasi',
      'duration': '6:15',
      'views': 'Video Lokal',
      'thumbnail': 'https://images.unsplash.com/photo-1586253634026-8cb574908d1e?w=500&auto=format&fit=crop&q=60',
      'videoUrl': 'assets/videos/disinformasi.mp4',
      'description': 'Penjelasan mendalam mengenai disinformasi: informasi salah yang disebarkan dengan sengaja untuk menipu.',
    },
    // 4. Privasi (Original Local)
    {
      'title': 'Pentingnya Menjaga Privasi Data',
      'category': 'Privasi',
      'duration': '4:20',
      'views': 'Video Lokal',
      'thumbnail': 'https://images.unsplash.com/photo-1555949963-aa79dcee981c?w=500&auto=format&fit=crop&q=60',
      'videoUrl': 'assets/videos/privasi.mp4',
      'description': 'Tips menjaga data pribadi agar tidak bocor dan disalahgunakan oleh pihak tidak bertanggung jawab.',
    },

    // 5. Literasi Digital (Mapped to Hoaks Local)
    {
      'title': 'Literasi Digital: Melawan Hoaks',
      'category': 'Literasi Digital',
      'duration': '8:47',
      'views': 'Video Lokal',
      'thumbnail': 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=500&auto=format&fit=crop&q=60',
      'videoUrl': 'assets/videos/hoaks.mp4',
      'description': 'Pentingnya kemampuan literasi digital untuk menyaring informasi dan melawan penyebaran berita palsu.',
    },
    // 6. Deepfake (Mapped to Disinformasi Local)
    {
      'title': 'Deepfake sebagai Alat Disinformasi',
      'category': 'Keamanan Digital',
      'duration': '6:15',
      'views': 'Video Lokal',
      'thumbnail': 'https://images.unsplash.com/photo-1633265486064-084b953152c6?w=500&auto=format&fit=crop&q=60',
      'videoUrl': 'assets/videos/disinformasi.mp4',
      'description': 'Bagaimana teknologi Deepfake digunakan untuk menciptakan disinformasi yang meyakinkan dan berbahaya.',
    },
    // 7. Password (Mapped to Privasi Local)
    {
      'title': 'Keamanan Password dan Privasi',
      'category': 'Privasi',
      'duration': '4:20',
      'views': 'Video Lokal',
      'thumbnail': 'https://images.unsplash.com/photo-1614064641938-3bcee52636c4?w=500&auto=format&fit=crop&q=60',
      'videoUrl': 'assets/videos/privasi.mp4',
      'description': 'Hubungan antara kekuatan password dengan keamanan privasi data Anda di dunia maya.',
    },
    // 8. Jejak Digital (Mapped to Phishing/Safety Local)
    {
      'title': 'Jejak Digital dan Keamanan Online',
      'category': 'Literasi Digital',
      'duration': '5:32',
      'views': 'Video Lokal',
      'thumbnail': 'https://images.unsplash.com/photo-1563986768494-4dee46a385bd?w=500&auto=format&fit=crop&q=60',
      'videoUrl': 'assets/videos/phishing.mp4',
      'description': 'Bagaimana jejak digital yang kita tinggalkan bisa menjadi celah keamanan bagi penipu online.',
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