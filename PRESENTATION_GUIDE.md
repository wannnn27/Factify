# Panduan Presentasi Kode - Proyek Factify

> Panduan ini fokus pada **kode-kode kunci** yang perlu dipresentasikan untuk menjelaskan arsitektur dan cara kerja sistem.

---

## STRUKTUR PROYEK

```
📁 Factify/
├── 📁 lib/                      # FRONTEND (Flutter/Dart)
│   ├── main.dart                # Entry point aplikasi
│   ├── 📁 services/             # Layer komunikasi ke backend
│   │   └── verysense_service.dart
│   ├── 📁 screens/              # Halaman UI
│   └── 📁 widgets/              # Komponen UI reusable
│
├── 📁 server/                   # BACKEND (Python/Flask)
│   ├── app.py                   # REST API Server
│   ├── 📁 models/               # AI Analyzers
│   │   ├── verification_engine.py  # Orkestrator utama
│   │   ├── text_analyzer.py        # Analisis teks
│   │   ├── image_analyzer.py       # Analisis gambar
│   │   ├── video_analyzer.py       # Analisis video
│   │   └── challenge_analyzer.py   # Evaluasi challenge
│   └── requirements.txt
│
└── pubspec.yaml                 # Dependencies Flutter
```

---

## KODE-KODE YANG PERLU DIPRESENTASIKAN

### 🔷 BAGIAN 1: BACKEND (Python) - "Otak Sistem"

#### 1.1. `server/app.py` - REST API Server
**Lokasi:** `server/app.py`
**Fungsi:** Titik masuk semua request dari aplikasi mobile/web.

**Poin yang dibahas:**
- Inisialisasi Flask app dengan CORS
- Endpoint utama:
  - `/verify/text` - Verifikasi teks
  - `/verify/image` - Verifikasi gambar
  - `/verify/video` - Verifikasi video
  - `/chat` - Chatbot
  - `/challenge/evaluate` - Evaluasi kuis

```python
# Contoh potongan kode yang bisa ditunjukkan (baris 66-95):
@app.route('/verify/text', methods=['POST'])
def verify_text():
    """Verify text content"""
    try:
        data = request.get_json()
        text = data['text']
        result = engine.verify_text(text)  
        return jsonify(result.to_dict())
    except Exception as e:
        return jsonify({'error': str(e)}), 500
```

---

#### 1.2. `server/models/verification_engine.py` - Orkestrator Utama
**Lokasi:** `server/models/verification_engine.py`
**Fungsi:** Mengkoordinasikan semua analyzer (teks, gambar, video).

**Poin yang dibahas:**
- Lazy loading untuk performa
- Alur verifikasi: Request → Analyzer → Response
- Struktur `VerificationResponse` (skor, status, AI summary)

**Class/Method penting:**
- `VerificationEngine.__init__()` - Inisialisasi
- `VerificationEngine.verify_text()` - Shortcut verifikasi teks
- `VerificationEngine._generate_ai_summary()` - Membuat ringkasan AI

---

#### 1.3. `server/models/text_analyzer.py` - Analisis Teks 
**Lokasi:** `server/models/text_analyzer.py`
**Fungsi:** Mendeteksi hoaks, clickbait, dan sentimen dalam teks.

**Poin yang dibahas:**
- **Pendekatan Hybrid:** Rule-based + LLM (Gemini)
- Indikator hoaks yang dicari (contoh: "VIRAL!!!", "SHARE SEBELUM DIHAPUS!")
- Cara kerja analisis dengan Gemini AI

**Method penting untuk ditunjukkan:**
- `HOAX_INDICATORS` - Daftar pola hoaks (baris ~18-75)
- `analyze()` - Method utama (baris ~148-243)
- `_analyze_with_llm()` - Analisis dengan Gemini (baris ~245-375)

```python
# Contoh potongan HOAX_INDICATORS:
HOAX_INDICATORS = [
    # Urgency & Viral
    r'(?i)(viral|tersebar|beredar|share|bagikan)',
    r'(?i)(segera|cepat|buruan|sebelum.*dihapus)',
    # Unverified sources
    r'(?i)(kata.*teman|menurut.*dokter|sumber.*terpercaya)',
    # Sensational
    r'(?i)(mengejutkan|luar.*biasa|tidak.*percaya)',
    ...
]
```

---

#### 1.4. `server/models/image_analyzer.py` - Analisis Gambar
**Lokasi:** `server/models/image_analyzer.py`
**Fungsi:** Mendeteksi manipulasi gambar dan gambar buatan AI.

**Poin yang dibahas:**
- Teknik forensik: ELA (Error Level Analysis), EXIF metadata
- Integrasi dengan Gemini Vision untuk analisis visual
- Deteksi gambar AI-generated

**Method penting:**
- `analyze()` - Method utama
- `_analyze_with_ai_vision()` - Analisis dengan Gemini Vision

---

#### 1.5. `server/models/challenge_analyzer.py` - Evaluasi Challenge
**Lokasi:** `server/models/challenge_analyzer.py`
**Fungsi:** Menilai jawaban pengguna pada fitur Challenge/Kuis.

**Poin yang dibahas:**
- Struktur prompt untuk evaluasi AI
- Cara AI menilai jawaban (skor, feedback)

---

### 🔷 BAGIAN 2: FRONTEND (Flutter/Dart) - "Wajah Aplikasi"

#### 2.1. `lib/main.dart` - Entry Point Aplikasi
**Lokasi:** `lib/main.dart`
**Fungsi:** Inisialisasi aplikasi dan autentikasi.

**Poin yang dibahas:**
- Inisialisasi Firebase
- `AuthWrapper` untuk mengecek status login
- Tema aplikasi (dark mode)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await guestService.init();
  runApp(const MyApp());
}
```

---

#### 2.2. `lib/services/verysense_service.dart` - Koneksi ke Backend ⭐
**Lokasi:** `lib/services/verysense_service.dart`
**Fungsi:** Layer komunikasi antara Flutter dan backend Python.

**Poin yang dibahas:**
- Konfigurasi base URL API
- Method untuk setiap jenis verifikasi
- Handling response dan error

**Method penting:**
- `verifyText(String text)` - Kirim teks ke API
- `verifyImageBytes()` - Kirim gambar ke API
- `_handleResponse()` - Proses response

```dart
/// Verifikasi teks
Future<VerificationResult> verifyText(String text) async {
  final response = await http.post(
    Uri.parse('$baseUrl/verify/text'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'text': text}),
  );
  return _handleResponse(response);
}
```

---

#### 2.3. `lib/services/chatbot_service.dart` - Service Chatbot
**Lokasi:** `lib/services/chatbot_service.dart`
**Fungsi:** Mengelola komunikasi dengan chat endpoint.

---

#### 2.4. UI Screens (Opsional, jika waktu cukup)
- `lib/screens/verysense/` - Halaman verifikasi
- `lib/screens/tabs/` - Tab-tab utama (Home, Edukasi, Chat, dll)

---

## URUTAN PRESENTASI KODE YANG DISARANKAN

| No | File | Durasi | Alasan |
|:---:|---|:---:|---|
| 1 | `server/app.py` | 3-5 menit | Gambaran besar: "Ini adalah API yang menerima request" |
| 2 | `server/models/verification_engine.py` | 3-5 menit | "Ini mengatur semua proses verifikasi" |
| 3 | `server/models/text_analyzer.py` | 5-7 menit | **FOKUS UTAMA** - Jelaskan logic deteksi hoaks |
| 4 | `server/models/image_analyzer.py` | 3-5 menit | Jelaskan teknik forensik gambar |
| 5 | `lib/main.dart` | 2-3 menit | Entry point Flutter |
| 6 | `lib/services/verysense_service.dart` | 3-5 menit | "Cara Flutter memanggil backend" |
| 7 | **DEMO APLIKASI** | 5-10 menit | Tunjukkan kode bekerja secara real |

---

## TIPS PRESENTASI KODE

1. **Jangan baca baris per baris.** Fokus pada logic dan alur, bukan syntax.
2. **Gunakan analogi.** Contoh: "Verification Engine itu seperti manajer yang mendelegasikan tugas ke ahlinya (text analyzer, image analyzer)."
3. **Siapkan pertanyaan yang mungkin muncul:**
   - "Bagaimana cara AI mendeteksi hoaks?" → Jelaskan HOAX_INDICATORS dan prompt Gemini.
   - "Kenapa pakai Flask?" → Ringan, cepat, cocok untuk API ML.
   - "Kenapa pakai Gemini?" → Multimodal (bisa baca teks, gambar, video).
4. **Tunjukkan flow end-to-end:**
   - User ketik teks → Flutter kirim ke API → Backend proses → AI analisis → Response dikembalikan → UI tampilkan hasil.

---

## SNIPPET KODE PENTING UNTUK DITUNJUKKAN

### A. Daftar Indikator Hoaks (`text_analyzer.py`)
```python
HOAX_INDICATORS = [
    r'(?i)(viral|tersebar|beredar|share|bagikan)',
    r'(?i)(segera|cepat|buruan|sebelum.*dihapus)',
    r'(?i)(mengejutkan|luar.*biasa|tidak.*percaya)',
    # ... (jelaskan pola regex ini)
]
```

### B. Prompt AI untuk Analisis (`text_analyzer.py`)
```python
# Contoh prompt ke Gemini (disederhanakan)
prompt = f"""
Analisis teks berikut untuk menentukan kredibilitasnya:
---
{text}
---
Berikan skor 0-100, kategori (Fakta/Hoaks/Opini/Satire), dan penjelasan.
"""
```

### C. Flow Request-Response (`app.py` → `verification_engine.py`)
```python
# Di app.py
result = engine.verify_text(text)

# Di verification_engine.py
def verify_text(self, text: str):
    self._ensure_analyzer('text')
    result = self._text_analyzer.analyze(text)
    return self._build_response(result, 'text', text)
```

---

