---
description: Menjalankan Verysense dengan AI full integration
---

# Workflow: Menjalankan Verysense dengan AI Full Integration

## Prerequisites
1. Flutter SDK terinstall dan dalam PATH
2. Python 3.9+ terinstall
3. Dependencies ML Backend sudah terinstall

## Step 1: Start ML Backend Server

// turbo
```bash
cd server
venv\Scripts\activate
python app.py --debug
```

Server akan berjalan di `http://localhost:5000`

## Step 2: Configure Flutter App

Pastikan file `.env` memiliki konfigurasi:
```
GEMINI_API_KEY=<your-gemini-api-key>
VERYSENSE_API_URL=http://localhost:5000
```

Untuk Android emulator, gunakan:
```
VERYSENSE_API_URL=http://10.0.2.2:5000
```

## Step 3: Run Flutter App

// turbo
```bash
flutter pub get
flutter run
```

## Step 4: Test Verifikasi

1. Buka tab "Scan" di bottom navigation
2. Pilih tipe konten (Teks, URL, Foto, Video)
3. Masukkan konten yang ingin diverifikasi
4. Klik "Verifikasi Sekarang"
5. Lihat hasil analisis AI

## Troubleshooting

### API Offline
- Pastikan server ML berjalan di port 5000
- Cek koneksi jaringan
- Refresh dengan tap status indicator "AI Online/Offline"

### Timeout Error
- Video analysis membutuhkan waktu lebih lama (hingga 5 menit)
- Pastikan file tidak terlalu besar (max 50MB)

### Image/Video Not Detected
- Pastikan format file didukung (PNG, JPG, JPEG, GIF, WEBP untuk gambar)
- Untuk video: MP4, AVI, MOV, WEBM, MKV
