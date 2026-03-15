# Panduan Lengkap Teknologi AI - Proyek Factify

> Dokumen ini berisi penjelasan komprehensif tentang teknologi AI yang digunakan dalam proyek Factify, dari pembuatan hingga proses analisis.

---

## BAGIAN 1: ARSITEKTUR SISTEM AI

### 1.1 Overview Arsitektur

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              FACTIFY AI SYSTEM                              │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│  ┌─────────────────┐    HTTP Request    ┌─────────────────────────────────┐ │
│  │  FLUTTER APP    │ ─────────────────→ │         FLASK REST API          │ │
│  │  (Frontend)     │ ←───────────────── │         (app.py)                │ │
│  └─────────────────┘    HTTP Response   └──────────────┬──────────────────┘ │
│                                                        │                    │
│                                                        ▼                    │
│                              ┌─────────────────────────────────────────┐    │
│                              │      VERIFICATION ENGINE                │    │
│                              │      (Orkestrator Utama)                │    │
│                              └──────────────────┬──────────────────────┘    │
│                                                 │                           │
│                    ┌────────────────────────────┼────────────────────────┐  │
│                    │                            │                        │  │
│                    ▼                            ▼                        ▼  │
│     ┌──────────────────────┐   ┌──────────────────────┐   ┌─────────────────┐
│     │   TEXT ANALYZER      │   │   IMAGE ANALYZER     │   │  VIDEO ANALYZER │
│     │   - Rule-based       │   │   - OpenCV           │   │  - Frame extract│
│     │   - IndoBERT         │   │   - Pillow           │   │  - Gemini Vision│
│     │   - Gemini LLM       │   │   - Gemini Vision    │   │                 │
│     └──────────────────────┘   └──────────────────────┘   └─────────────────┘
│                    │                            │                        │  │
│                    └────────────────────────────┼────────────────────────┘  │
│                                                 │                           │
│                                                 ▼                           │
│                              ┌─────────────────────────────────────────┐    │
│                              │         GOOGLE GEMINI API              │    │
│                              │         (gemini-1.5-pro)               │    │
│                              └─────────────────────────────────────────┘    │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 Komponen Utama

| Komponen | Teknologi | Fungsi |
|----------|-----------|--------|
| Frontend | Flutter (Dart) | Antarmuka pengguna mobile & web |
| Backend API | Python Flask | RESTful API server |
| Verification Engine | Python | Orkestrator semua analyzer |
| Text Analyzer | IndoBERT + Gemini | Analisis teks untuk deteksi hoaks |
| Image Analyzer | OpenCV + Gemini Vision | Deteksi manipulasi gambar |
| Video Analyzer | FFmpeg + Gemini Vision | Analisis video/deepfake |
| Challenge Analyzer | Gemini | Evaluasi jawaban pengguna |

---

## BAGIAN 2: PENDEKATAN AI YANG DIGUNAKAN

### 2.1 Pendekatan Hybrid (3 Layer)

Sistem kami menggunakan pendekatan **HYBRID** yang menggabungkan 3 lapisan teknologi:

```
┌─────────────────────────────────────────────────────────────────┐
│                    HYBRID AI APPROACH                           │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  LAYER 1: RULE-BASED (Cepat & Murah)                           │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │ • Pattern matching kata-kata hoaks                        │ │
│  │ • Regex untuk clickbait                                   │ │
│  │ • Indikator kredibilitas                                  │ │
│  │ • Tidak perlu GPU, sangat cepat                           │ │
│  └───────────────────────────────────────────────────────────┘ │
│                            ↓                                    │
│  LAYER 2: PRE-TRAINED MODELS (Transfer Learning)               │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │ • IndoBERT untuk sentiment analysis                       │ │
│  │ • Model sudah dilatih, kita hanya pakai                   │ │
│  │ • Akurasi tinggi untuk bahasa Indonesia                   │ │
│  └───────────────────────────────────────────────────────────┘ │
│                            ↓                                    │
│  LAYER 3: LARGE LANGUAGE MODEL (Cerdas & Kontekstual)          │
│  ┌───────────────────────────────────────────────────────────┐ │
│  │ • Google Gemini 1.5 Pro                                   │ │
│  │ • Multimodal (teks, gambar, video)                        │ │
│  │ • Verifikasi fakta dengan pengetahuan luas                │ │
│  │ • Penjelasan logis dan terstruktur                        │ │
│  └───────────────────────────────────────────────────────────┘ │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 Mengapa Pendekatan Hybrid?

| Pendekatan | Kelebihan | Kekurangan |
|------------|-----------|------------|
| Rule-based saja | Cepat, murah, transparan | Tidak fleksibel, mudah diakali |
| ML tradisional saja | Bisa belajar pola | Butuh dataset besar, bisa outdated |
| LLM saja | Sangat cerdas | Mahal, lambat, rate limit |
| **HYBRID (Kami)** | Gabungan semua kelebihan | Kompleksitas implementasi |

---

## BAGIAN 3: PROSES PEMBUATAN MODEL

### 3.1 Langkah Pembuatan

```
STEP 1: DEFINISI MASALAH
────────────────────────
"Bagaimana mendeteksi hoaks dalam teks, gambar, dan video berbahasa Indonesia?"

            ↓

STEP 2: RISET KARAKTERISTIK HOAKS INDONESIA
────────────────────────────────────────────
• Kumpulkan pola umum hoaks Indonesia
• Identifikasi kata kunci: "viral", "sebarkan", "terbongkar"
• Pelajari pola clickbait lokal
• Pahami konteks budaya Indonesia

            ↓

STEP 3: DESAIN ARSITEKTUR
─────────────────────────
• Pilih pendekatan hybrid (rule + ML + LLM)
• Tentukan teknologi: Flask, IndoBERT, Gemini
• Rancang flow data dari input ke output

            ↓

STEP 4: IMPLEMENTASI RULE-BASED
───────────────────────────────
• Buat daftar HOAX_INDICATORS
• Buat pola regex CLICKBAIT_PATTERNS
• Buat daftar CREDIBILITY_INDICATORS

            ↓

STEP 5: INTEGRASI PRE-TRAINED MODEL
───────────────────────────────────
• Download IndoBERT dari Hugging Face
• Setup tokenizer dan model
• Implementasi sentiment analysis

            ↓

STEP 6: INTEGRASI GEMINI API
────────────────────────────
• Setup Google Generative AI SDK
• Desain prompt yang optimal
• Implementasi parsing response

            ↓

STEP 7: PEMBUATAN VERIFICATION ENGINE
─────────────────────────────────────
• Orkestrator untuk menggabungkan semua analyzer
• Logika penggabungan skor
• Format response yang konsisten

            ↓

STEP 8: TESTING & REFINEMENT
────────────────────────────
• Uji dengan berbagai contoh hoaks
• Tuning bobot dan threshold
• Perbaiki prompt berdasarkan hasil
```

### 3.2 Tidak Ada Training dari Nol

**PENTING:** Proyek ini TIDAK melatih model dari nol (from scratch) karena:

1. **Efisiensi waktu** - Training butuh berminggu-minggu
2. **Tidak perlu dataset** - Gemini sudah memiliki pengetahuan
3. **Selalu update** - Gemini memiliki pengetahuan terkini
4. **Biaya rendah** - Tidak perlu GPU mahal

---

## BAGIAN 4: CARA KERJA ANALISIS (DETAIL)

### 4.1 Alur Analisis Teks

```
INPUT: "VIRAL! Minum air rebusan daun ini bisa sembuhkan kanker dalam 3 hari!"
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ STEP 1: PREPROCESSING                                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│ • Lowercase: "viral! minum air rebusan daun ini bisa sembuhkan..."         │
│ • Remove URL: (hapus link jika ada)                                         │
│ • Stemming (Sastrawi): "viral minum air rebus daun ini bisa sembuh..."     │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ STEP 2: RULE-BASED ANALYSIS                                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│ A. Hoax Indicators Check:                                                   │
│    ✓ "viral" → MATCH                                                        │
│    ✓ "sembuhkan" → MATCH                                                    │
│    ✓ "kanker sembuh" → MATCH                                                │
│    Hoax Score: 0.65 (65% indikator hoaks)                                   │
│                                                                             │
│ B. Clickbait Pattern Check:                                                 │
│    ✓ Pattern "menyembuhkan.*(kanker|penyakit)" → MATCH                      │
│    ✓ Excessive punctuation "!" → MATCH                                      │
│    Clickbait Score: 0.70                                                    │
│                                                                             │
│ C. Credibility Check:                                                       │
│    ✗ Tidak ada sumber ("menurut", "penelitian")                             │
│    ✗ Tidak ada data/statistik                                               │
│    Credibility Score: 0.05                                                  │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ STEP 3: SENTIMENT ANALYSIS (IndoBERT)                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│ Model: mdhugol/indonesia-bert-sentiment-classification                      │
│                                                                             │
│ Input: "VIRAL! Minum air rebusan daun ini bisa sembuhkan kanker..."        │
│ Output:                                                                     │
│   - Negative: 0.15                                                          │
│   - Neutral:  0.25                                                          │
│   - Positive: 0.60  ← Terdeteksi positif (klaim "sembuh")                   │
│                                                                             │
│ Catatan: Sentiment positif palsu (false promise)                            │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ STEP 4: LLM ANALYSIS (GEMINI)                                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│ Prompt yang dikirim:                                                        │
│ ┌─────────────────────────────────────────────────────────────────────────┐ │
│ │ Peran: Kamu adalah Tim Verifikasi Fakta Elite Indonesia...              │ │
│ │                                                                         │ │
│ │ TEKS INPUT:                                                             │ │
│ │ "VIRAL! Minum air rebusan daun ini bisa sembuhkan kanker dalam 3 hari!" │ │
│ │                                                                         │ │
│ │ Analisis dengan framework:                                              │ │
│ │ 1. Identifikasi jenis konten                                            │ │
│ │ 2. Deteksi ciri hoaks Indonesia                                         │ │
│ │ 3. Verifikasi fakta                                                     │ │
│ │ 4. Penilaian akhir (skor 0-100)                                         │ │
│ └─────────────────────────────────────────────────────────────────────────┘ │
│                                                                             │
│ Response dari Gemini:                                                       │
│ {                                                                           │
│   "content_type": "KLAIM KESEHATAN",                                        │
│   "hoax_indicators_found": ["viral", "miracle cure", "no source"],          │
│   "score": 12,                                                              │
│   "is_hoax": true,                                                          │
│   "confidence": 0.95,                                                       │
│   "reasoning": "Klaim ini adalah hoaks kesehatan berbahaya. Tidak ada       │ 
│                 bukti ilmiah bahwa air rebusan daun dapat menyembuhkan      │
│                 kanker. Klaim '3 hari' adalah ciri khas miracle cure hoax." │
│ }                                                                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ STEP 5: SCORE COMBINATION                                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│ Rule-based Score: 28/100                                                    │
│ LLM Score: 12/100                                                           │
│ LLM Confidence: 0.95 (sangat yakin)                                         │
│                                                                             │
│ Karena LLM confidence > 0.8, gunakan LLM score langsung:                    │
│ Final Score = 12                                                            │
│                                                                             │
│ Aturan absolut: is_hoax = true → max score = 35                             │
│ Final Score = min(12, 35) = 12                                              │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│ OUTPUT FINAL                                                                │
├─────────────────────────────────────────────────────────────────────────────┤
│ {                                                                           │
│   "score": 12,                                                              │
│   "status": "tidak_kredibel",                                               │
│   "status_color": "#FF6B6B",                                                │
│   "ai_summary": "Klaim ini adalah hoaks kesehatan berbahaya...",            │
│   "main_findings": "Tidak ada bukti ilmiah, pola miracle cure",             │
│   "warnings": ["AI: Terdeteksi indikasi hoax"],                             │
│   "confidence": 0.95                                                        │
│ }                                                                           │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.2 Penjelasan Setiap Tahap

#### TAHAP 1: Preprocessing
- **Tujuan:** Membersihkan dan menormalisasi teks
- **Tools:** NLTK, Sastrawi (stemmer Indonesia)
- **Proses:** Lowercase → Hapus URL → Stemming

#### TAHAP 2: Rule-Based Analysis
- **Tujuan:** Deteksi cepat pola hoaks yang sudah dikenal
- **Metode:** Pattern matching dengan daftar kata dan regex
- **Output:** Skor hoax, clickbait, dan kredibilitas (0-1)

#### TAHAP 3: Sentiment Analysis
- **Tujuan:** Mendeteksi tone emosional teks
- **Model:** IndoBERT (pre-trained untuk bahasa Indonesia)
- **Output:** Label (positive/negative/neutral) + confidence score

#### TAHAP 4: LLM Analysis
- **Tujuan:** Analisis semantik mendalam dan verifikasi fakta
- **Model:** Google Gemini 1.5 Pro
- **Metode:** Prompt engineering dengan framework analisis detail
- **Output:** Skor, kategori, penjelasan logis

#### TAHAP 5: Score Combination
- **Tujuan:** Menggabungkan semua hasil menjadi skor akhir
- **Bobot:** Rule-based 15% + LLM 85%
- **Aturan khusus:** Jika LLM yakin hoax → skor maksimal 35

---

## BAGIAN 5: TEKNOLOGI KUNCI

### 5.1 Google Gemini API

```python
# Inisialisasi Gemini
import google.generativeai as genai
genai.configure(api_key=os.getenv('GEMINI_API_KEY'))
self.genai_model = genai.GenerativeModel('gemini-1.5-pro')

# Penggunaan
response = self.genai_model.generate_content(prompt)
result = response.text
```

**Keunggulan Gemini:**
- Multimodal (bisa analisis teks, gambar, video)
- Pengetahuan up-to-date
- Reasoning capability tinggi
- Support bahasa Indonesia

### 5.2 IndoBERT (Hugging Face)

```python
# Load model dari Hugging Face
from transformers import AutoTokenizer, AutoModelForSequenceClassification

model_name = "mdhugol/indonesia-bert-sentiment-classification"
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForSequenceClassification.from_pretrained(model_name)

# Penggunaan
inputs = tokenizer(text, return_tensors="pt", truncation=True)
outputs = model(**inputs)
predictions = torch.softmax(outputs.logits, dim=-1)
```

**Keunggulan IndoBERT:**
- Dilatih khusus untuk bahasa Indonesia
- Akurasi tinggi (~85%)
- Cepat (tidak perlu API call)

### 5.3 Sastrawi (Stemmer Indonesia)

```python
from Sastrawi.Stemmer.StemmerFactory import StemmerFactory

factory = StemmerFactory()
stemmer = factory.createStemmer()

# Contoh
stemmer.stem("memakan")      # → "makan"
stemmer.stem("berlarian")    # → "lari"
stemmer.stem("pembelajaran") # → "ajar"
```

**Fungsi:** Mengubah kata berimbuhan ke bentuk dasar untuk normalisasi.

---

## BAGIAN 6: KATEGORI OUTPUT

### 6.1 Klasifikasi Skor

| Skor | Status | Warna | Keterangan |
|------|--------|-------|------------|
| 80-100 | `kredibel` | 🟢 Hijau | Konten dapat dipercaya |
| 60-79 | `cukup_kredibel` | 🟢 Teal | Sebagian besar akurat |
| 40-59 | `perlu_perhatian` | 🟡 Kuning | Perlu verifikasi lebih lanjut |
| 0-39 | `tidak_kredibel` | 🔴 Merah | Kemungkinan besar hoax |

### 6.2 Kategori Konten

- **FAKTA** - Klaim yang dapat diverifikasi dan benar
- **HOAX** - Informasi palsu atau menyesatkan
- **OPINI** - Pendapat subjektif (bukan fakta)
- **SATIRE** - Konten humor/parodi

---

## BAGIAN 7: RINGKASAN UNTUK PRESENTASI

### Poin-Poin Kunci:

1. **Arsitektur Hybrid:** Menggabungkan rule-based, pre-trained model, dan LLM untuk hasil optimal.

2. **Tidak Training dari Nol:** Menggunakan model pre-trained (IndoBERT) dan API (Gemini) untuk efisiensi.

3. **Prompt Engineering:** Kunci keberhasilan analisis adalah prompt yang terstruktur dan spesifik.

4. **Multi-Layer Verification:** Setiap input melewati beberapa tahap analisis untuk akurasi maksimal.

5. **Indonesia-Focused:** Menggunakan IndoBERT dan pattern hoaks lokal untuk konteks Indonesia.

6. **Real-Time Knowledge:** Gemini memiliki pengetahuan terkini untuk verifikasi fakta.

### Script Presentasi:

> "Sistem AI Factify kami menggunakan pendekatan **hybrid 3 layer**. Layer pertama adalah **rule-based** yang mencocokkan teks dengan pola hoaks Indonesia yang sudah kami identifikasi. Layer kedua adalah **IndoBERT** untuk analisis sentimen bahasa Indonesia. Layer ketiga adalah **Google Gemini** yang melakukan verifikasi fakta mendalam dengan pengetahuan luasnya.
>
> Kami **tidak melatih model dari nol** karena tidak efisien dan hoaks terus berkembang. Dengan menggunakan Gemini API, sistem kami selalu memiliki pengetahuan terkini.
>
> Hasil dari ketiga layer digabungkan dengan bobot: 15% rule-based dan 85% LLM. Jika Gemini sangat yakin suatu konten adalah hoaks, sistem akan membatasi skor maksimal di 35 untuk memastikan tidak ada hoaks yang lolos.
>
> Dengan pendekatan ini, kami berhasil membangun sistem deteksi hoaks yang cepat, akurat, dan selalu up-to-date."

---

**Dokumen ini siap digunakan untuk presentasi!**
