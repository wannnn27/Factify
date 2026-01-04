# Factify: Platform Verifikasi Informasi Berbasis Kecerdasan Buatan dan Edukasi Literasi Digital

## Problem Statement

Di era digital saat ini, penyebaran informasi palsu (hoaks) dan misinformasi menjadi tantangan global yang serius. Masyarakat sering kali kesulitan membedakan antara fakta dan opini yang dimanipulasi, serta tidak memiliki akses mudah ke alat verifikasi yang cepat dan akurat. Kurangnya literasi digital juga memperburuk kemampuan individu dalam mengevaluasi kredibilitas sumber informasi secara kritis.

Factify hadir sebagai solusi komprehensif untuk mengatasi masalah tersebut dengan menyediakan platform yang tidak hanya memverifikasi kebenaran informasi secara otomatis, tetapi juga mendidik pengguna melalui fitur edukasi yang interaktif. Target pengguna aplikasi ini mencakup masyarakat umum, pelajar, dan siapa saja yang ingin memastikan validitas informasi yang mereka terima.

## Dataset

Proyek ini menggunakan pendekatan pemrosesan data real-time dan tidak bergantung pada dataset pelatihan statis tunggal untuk inferensi utamanya. Data yang diproses meliputi:

1.  **Input Pengguna:** Teks berita, tautan artikel (URL), gambar, dan video yang diunggah oleh pengguna untuk diverifikasi.
2.  **Basis Pengetahuan Dinamis:** Integrasi dengan Google Gemini API memungkinkan akses ke basis pengetahuan luas dan terkini untuk melakukan fact-checking kontekstual.
3.  **Data Edukasi:** Kumpulan materi pembelajaran, kuis, dan video edukasi yang dikurasi untuk meningkatkan literasi digital (disimpan dan dikelola melalui Firebase Firestore).

Data dimuat secara dinamis saat pengguna melakukan permintaan verifikasi atau mengakses modul pembelajaran.

## Exploratory Data Analysis (EDA)

Dalam konteks pengembangan sistem ini, analisis awal difokuskan pada karakteristik konten misinformasi:

1.  **Pola Teks:** Berita palsu sering menggunakan bahasa yang emotif, judul "clickbait", dan struktur kalimat yang provokatif.
2.  **Manipulasi Visual:** Gambar yang dimanipulasi sering kali memiliki inkonsistensi metadata atau jejak penyuntingan digital yang dapat dideteksi.
3.  **Distribusi Topik:** Misinformasi cenderung meningkat pada topik-topik sensitif seperti politik, kesehatan, dan bencana alam.

Temuan ini menjadi dasar perancangan logika verifikasi pada mesin AI Factify ("Verysense").

## Preprocessing

Sebelum data diproses oleh model utama, dilakukan tahapan prapemrosesan sebagai berikut:

1.  **Ekstraksi Teks dan Metadata:** Mengambil konten utama dari URL artikel dan memisahkan elemen non-konten (iklan, navigasi).
2.  **Normalisasi Format:** Menstandarisasi format input gambar dan video (kompresi, resizing) agar sesuai dengan spesifikasi input API.
3.  **Pembersihan Data:** Menghapus karakter yang tidak relevan dan noise dari input teks pengguna untuk meningkatkan akurasi analisis semantik.

## Modeling

Inti dari kemampuan verifikasi Factify dibangun di atas arsitektur model hybrid:

1.  **Model Utama (Large Language Model):** Menggunakan **Google Gemini (1.5 Pro/Flash)**.
    *   **Alasan Pemilihan:** Kemampuan penalaran multimodal (teks, gambar, video) yang superior, jendela konteks yang besar, dan pengetahuan terkini yang krusial untuk verifikasi fakta.
    *   **Fungsi:** Menganalisis konteks, melakukan pengecekan silang fakta, mendeteksi sentimen, dan memberikan penjelasan logis atas hasil verifikasi.

2.  **Sistem Pendukung:**
    *   **Computer Vision:** Algoritma pendukung untuk ekstraksi fitur visual dari gambar dan video sebelum diproses oleh LLM.
    *   **Verification Engine:** Sebuah orkestrator (Python backend) yang mengatur alur data antara input pengguna, preprocessing, dan inferensi model AI.

**Hasil Evaluasi:** Sistem mampu memberikan skor kredibilitas (0-100), mengidentifikasi kategori konten (Fakta, Hoaks, Opini, Satire), dan menyertakan referensi sumber yang valid dengan tingkat akurasi yang memadai untuk penggunaan umum.

## Proyek Akhir: Solusi AI End-to-End

Factify merupakan implementasi solusi AI dari hulu ke hilir yang terdiri dari:

1.  **Frontend (Mobile & Web):** Aplikasi **Flutter** yang responsif dan intuitif, menyediakan antarmuka untuk verifikasi (Verysense), edukasi, diskusi komunitas, dan gamifikasi (Challenge).
2.  **Backend (ML API):** Server **Python (Flask)** yang bertugas menangani logika bisnis kompleks, integrasi model AI, dan pemrosesan data multimedia.
3.  **Layanan Cloud:** **Firebase** digunakan untuk manajemen autentikasi pengguna, penyimpanan data real-time (Firestore), dan analisis aktivitas pengguna.

## Deployment

Proyek ini dirancang untuk dapat digunakan di berbagai platform:

*   **Platform:** Android, iOS, dan Web.
*   **Framework:** Flutter (Dart) untuk antarmuka pengguna; Python (Flask) untuk backend logis.
*   **Cara Deploy (Lokal):**
    1.  Siapkan environment Python dan instal dependensi (`pip install -r requirements.txt`).
    2.  Jalankan server backend (`python server/app.py`).
    3.  Jalankan aplikasi Flutter (`flutter run`).

## Dokumentasi

Dokumentasi teknis disusun secara terstruktur untuk memudahkan pengembangan dan pemeliharaan:

*   **Struktur Folder:**
    *   `/lib`: Kode sumber aplikasi Flutter (UI, Logic, Services).
    *   `/server`: Kode backend Python (API, Model Integrations).
    *   `/assets`: Aset statis (gambar, ikon).
*   **Panduan Instalasi:** Lihat file `SETUP_GUIDE.md` (jika tersedia) untuk instruksi rinci mengenai konfigurasi environment dan kunci API.

## Evaluasi & Feedback

**Pencapaian Positif:**
*   Integrasi fitur multimodal (Teks, URL, Gambar, Video) berjalan mulus dalam satu platform.
*   Antarmuka pengguna (UI) modern dan responsif, memberikan pengalaman pengguna yang positif.
*   Fitur edukasi memberikan nilai tambah yang membedakan aplikasi ini dari sekadar alat fact-checker biasa.

**Area Perbaikan:**
*   **Latensi:** Waktu respons verifikasi untuk konten video terkadang masih memerlukan optimasi lebih lanjut.
*   **Ketergantungan API:** Sistem sangat bergantung pada ketersediaan layanan pihak ketiga (Gemini Web API), yang memerlukan strategi mitigasi jika terjadi gangguan layanan.

## Langkah Uraian Checklist

| Komponen | Status | Keterangan |
| :--- | :---: | :--- |
| **Problem Statement** | ☑ | Rumusan masalah, target pengguna, dan nilai solusi telah didefinisikan. |
| **Dataset** | ☑ | Sumber data input dan integrasi knowledge base telah dijelaskan. |
| **EDA & Visualisasi** | ☑ | Analisis karakteristik data misinformasi telah dilakukan. |
| **Preprocessing** | ☑ | Pipa pemrosesan data untuk teks dan multimedia telah diimplementasikan. |
| **Modeling** | ☑ | Arsitektur model (Gemini + Backend Custom) telah diterapkan dan dievaluasi. |
| **Deployment** | ☑ | Aplikasi siap dijalankan di lingkungan lokal multi-platform. |
| **Dokumentasi** | ☑ | README dan dokumentasi kode tersedia. |
