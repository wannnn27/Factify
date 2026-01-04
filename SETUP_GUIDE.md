# 🚀 Panduan Menjalankan Factify dengan Integrasi AI

Dokumen ini menjelaskan langkah-langkah lengkap untuk menjalankan aplikasi Factify dengan fitur Verysense AI yang terintegrasi penuh.

---

### Software yang Dibutuhkan:
- **Python 3.9+** - [Download](https://python.org/downloads/)
- **Flutter SDK 3.0+** - [Install](https://docs.flutter.dev/get-started/install)
- **Git** - [Download](https://git-scm.com/downloads)
- **Visual Studio Code** (recommended) atau IDE lainnya

### Verifikasi Instalasi:
```bash
python --version    
flutter --version   
git --version
```

---

## 🔧 LANGKAH 1: Setup ML Server

### 1.1 Buka Terminal di folder project

```bash
cd d:\factify\Factify
```

### 1.2 Masuk ke folder server

```bash
cd server
```

### 1.3 Buat Virtual Environment (sekali saja)

```bash
# Windows
python -m venv venv

# Linux/Mac
python3 -m venv venv
```

### 1.4 Aktifkan Virtual Environment

```bash
# Windows (PowerShell)
.\venv\Scripts\Activate.ps1

# Windows (CMD)
venv\Scripts\activate.bat

# Linux/Mac
source venv/bin/activate
```

> Anda akan melihat `(venv)` di awal command prompt jika berhasil

### 1.5 Install Dependencies Python

```bash
pip install -r requirements.txt
```

### 1.6 Jalankan ML Server

```bash
python app.py --debug
```

**Output yang diharapkan:**
```
 * Running on http://127.0.0.1:5000
 * Debug mode: on
```

### 1.7 Test Server (Terminal baru)

```bash
curl http://localhost:5000/health
```

**Output:**
```json
{"status": "healthy", "message": "Verysense ML API is running"}
```

> **Server ML sudah berjalan!** Biarkan terminal ini tetap terbuka.

---

## LANGKAH 2: Setup Flutter App

### 2.1 Buka Terminal BARU (jangan tutup terminal server)

```bash
cd d:\factify\Factify
```

### 2.2 Konfigurasi Environment Variables

Copy template dan edit:
```bash
# Windows
copy .env.example .env

# Linux/Mac
cp .env.example .env
```

Edit file `.env`:
```env
GEMINI_API_KEY=your-gemini-api-key-here
VERYSENSE_API_URL=http://localhost:5000
```

> Untuk **Android Emulator**, gunakan:
> ```env
> VERYSENSE_API_URL=http://10.0.2.2:5000
> ```

### 2.3 Install Flutter Dependencies

```bash
flutter pub get
```

### 2.4 Jalankan Aplikasi

```bash
# Untuk Chrome (Web)
flutter run -d chrome

# Untuk Android Emulator
flutter run -d emulator-5554

# Untuk device fisik yang terhubung
flutter run
```

---

## LANGKAH 3: Testing Integrasi

### 3.1 Buka Aplikasi

1. Login atau buat akun baru
2. Navigasi ke tab **"Scan"** (ikon kaca pembesar di bottom navigation)

### 3.2 Cek Status AI

Di bagian kanan atas layar Verysense, Anda akan melihat:
- 🟢 **"AI Online"** = Server ML terhubung ✅
- 🔴 **"Offline"** = Server ML tidak terhubung ❌

### 3.3 Test Verifikasi Teks

1. Pilih tab **"Teks"**
2. Masukkan teks contoh:
   ```
   Breaking News: Vaksin COVID-19 menyebabkan chip 5G ditanam di tubuh manusia menurut penelitian terbaru.
   ```
3. Klik **"Verifikasi Sekarang"**
4. Tunggu hasil analisis AI

### 3.4 Test Verifikasi URL

1. Pilih tab **"URL"**
2. Masukkan URL:
   ```
   https://www.kompas.com
   ```
3. Klik **"Verifikasi Sekarang"**

### 3.5 Test Verifikasi Gambar

1. Pilih tab **"Foto"**
2. Pilih gambar dari galeri atau ambil foto
3. Tunggu hasil analisis (ELA, AI detection, dll)

---

## 🔄 Urutan Menjalankan (Quick Reference)

```
┌─────────────────────────────────────────────────┐
│  TERMINAL 1: ML Server                          │
│  ─────────────────────────────────────────────  │
│  cd d:\factify\Factify\server                   │
│  .\venv\Scripts\Activate.ps1                    │
│  python app.py --debug                          │
│                                                 │
│  [Biarkan berjalan]                             │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│  TERMINAL 2: Flutter App                        │
│  ─────────────────────────────────────────────  │
│  cd d:\factify\Factify                          │
│  flutter run                                    │
│                                                 │
│  [Pilih device dan jalankan]                    │
└─────────────────────────────────────────────────┘
```

---

## ❗ Troubleshooting

### Problem: "AI Offline" di aplikasi

**Solusi:**
1. Pastikan server ML berjalan di terminal 1
2. Cek URL di `.env` sudah benar
3. Untuk Android emulator, gunakan `http://10.0.2.2:5000`
4. Tap badge "Offline" untuk refresh koneksi

### Problem: `pip install` error

**Solusi:**
```bash
pip install --upgrade pip
pip install -r requirements.txt --no-cache-dir
```

### Problem: `flutter pub get` error

**Solusi:**
```bash
flutter clean
flutter pub cache repair
flutter pub get
```

### Problem: Timeout saat analisis video

**Ini normal!** Analisis video membutuhkan waktu lebih lama (1-5 menit) tergantung:
- Ukuran file video
- Spesifikasi komputer
- Kompleksitas analisis deepfake

### Problem: Port 5000 sudah digunakan

**Solusi:** Edit `server/app.py` dan ganti port:
```python
app.run(host='0.0.0.0', port=5001) 
```
Lalu update `.env`:
```env
VERYSENSE_API_URL=http://localhost:5001
```

---

## Deployment Production

### Deploy ML Server ke Cloud:
1. **Railway.app** (gratis tier tersedia)
2. **Render.com** (gratis tier tersedia)
3. **Google Cloud Run**
4. **AWS Lambda**

Setelah deploy, update `.env`:
```env
VERYSENSE_API_URL=https://your-deployed-api.railway.app
```


## Support

Jika mengalami masalah:
1. Buka Issue di GitHub repository
2. Sertakan error message lengkap
3. Sertakan langkah untuk reproduce

