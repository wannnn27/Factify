# 🧠 Factify ML Server

Backend ML API untuk verifikasi konten Factify menggunakan Flask dan berbagai model AI/ML.

## 🚀 Quick Start

```bash
# Create virtual environment
python -m venv venv

# Activate (Windows)
venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run server
python app.py --debug
```

Server akan berjalan di `http://localhost:5000`

## 📡 API Endpoints

### Health Check
```bash
GET /health
```

### Verify Text
```bash
POST /verify/text
Content-Type: application/json

{
    "text": "Berita yang akan diverifikasi..."
}
```

### Verify URL
```bash
POST /verify/url
Content-Type: application/json

{
    "url": "https://example.com/article"
}
```

### Verify Image
```bash
# Via URL
POST /verify/image
Content-Type: application/json
{
    "image_url": "https://example.com/image.jpg"
}

# Via File Upload
POST /verify/image
Content-Type: multipart/form-data
image: [file]

# Via Base64
POST /verify/image
Content-Type: application/json
{
    "image_base64": "data:image/jpeg;base64,..."
}
```

### Verify Video
```bash
# Via URL
POST /verify/video
Content-Type: application/json
{
    "video_url": "https://youtube.com/watch?v=..."
}

# Via File Upload
POST /verify/video
Content-Type: multipart/form-data
video: [file]
```

## 📊 Response Format

```json
{
    "request_id": "uuid",
    "content_type": "text|url|image|video",
    "score": 75.5,
    "confidence": 0.85,
    "status": "Kredibel|Cukup Kredibel|Perlu Perhatian|Tidak Kredibel",
    "status_color": "#4ECDC4",
    "source": "analyzed content source",
    "ai_summary": "AI generated summary...",
    "main_findings": "Key findings...",
    "need_attention": "Warning items...",
    "about_source": "Source information...",
    "detailed_analysis": {},
    "analysis_time": 2.5,
    "timestamp": "2024-01-01T00:00:00"
}
```

## 🔧 Configuration

Environment variables (optional):
```env
GEMINI_API_KEY=your-key  # For AI summaries
PORT=5000                # Server port
DEBUG=true               # Debug mode
```

## 📁 Structure

```
server/
├── app.py                  # Flask API server
├── models/
│   ├── verification_engine.py  # Main orchestrator
│   ├── text_analyzer.py        # Text analysis
│   ├── url_analyzer.py         # URL analysis
│   ├── image_analyzer.py       # Image analysis
│   └── video_analyzer.py       # Video analysis
├── requirements.txt
└── README.md
```

## 🧪 Testing

```bash
# Health check
curl http://localhost:5000/health

# Test text verification
curl -X POST http://localhost:5000/verify/text \
  -H "Content-Type: application/json" \
  -d '{"text": "Sample text to verify"}'
```
