"""
Text Analyzer - Analisis teks untuk deteksi hoax/misinformasi
Menggunakan IndoBERT untuk bahasa Indonesia dan sentiment analysis
"""
import re
import time
from typing import Any, Dict, List, Optional
import numpy as np

from .base_model import BaseAnalyzer, AnalysisResult

# Lazy imports untuk performa
transformers = None
torch = None
Sastrawi = None


class TextAnalyzer(BaseAnalyzer):
    """
    Analyzer untuk teks - mendeteksi:
    - Hoax/misinformasi
    - Clickbait
    - Sentiment negatif berlebihan
    - Bahasa manipulatif
    """
    
    # Kata-kata yang sering muncul di hoax (Indonesia)
    HOAX_INDICATORS = [
        # Urgency & Viral
        'viral', 'geger', 'heboh', 'mengejutkan', 'terbongkar',
        'rahasia', 'disembunyikan', 'pemerintah tutup-tutupi',
        'ternyata', 'sebarkan', 'jangan sampai tidak tahu',
        'baru saja', 'breaking', 'penting!!!', 'waspada',
        'wajib baca', 'wajib share', 'sebelum dihapus',
        'viralkan', 'bagikan', 'sebarluaskan', 'awas',
        
        # Health & Miracle Cures
        'menyembuhkan semua', 'obat ajaib', 'keajaiban',
        'dokter terkejut', 'dokter tidak bisa menjelaskan',
        'dokter pun diam', 'rahasia dokter', 'tak perlu ke dokter',
        'lebih ampuh dari', 'solusi akhir', 'sembuh total',
        'tanpa operasi', 'dalam waktu singkat', 'langsung sembuh',
        'kanker sembuh', 'diabetes sembuh', 'jantung sembuh',
        'mengubah makanan menjadi lemak', 'chip', 'mikrochip',
        
        # Emotional & Fear Mongering
        'menyesal', 'akibat fatal', 'bahaya', 'mengerikan',
        'jangan abaikan', 'nyawa', 'kematian', 'azab',
        'konspirasi', 'antek', 'rezim', 'elite global',
        'bumi datar', 'flat earth', 'chemtrail'
    ]
    
    # Pola clickbait
    CLICKBAIT_PATTERNS = [
        r'tidak.*percaya',
        r'anda.*tidak.*tahu',
        r'rahasia.*terungkap',
        r'\d+\s*hal.*yang',
        r'cara.*ampuh',
        r'dijamin.*berhasil',
        r'terbukti.*\d+%',
        r'menyesal.*karena',
        r'dokter.*(terkejut|kaget|bingung)',
        r'menyembuhkan.*(kanker|penyakit)',
        r'bikin.*(syok|nangis|marah)',
    ]
    
    # Credential indicators (positif)
    CREDIBILITY_INDICATORS = [
        'menurut', 'berdasarkan', 'penelitian', 'studi',
        'sumber', 'data', 'statistik', 'laporan resmi',
        'dikutip dari', 'mengutip', 'pakar', 'ahli',
        'jurnal', 'universitas', 'laboratorium', 'konfirmasi',
        'juru bicara', 'kemenkes', 'who', 'pbb'
    ]
    
    def __init__(self):
        super().__init__("TextAnalyzer")
        self.tokenizer = None
        self.sentiment_model = None
        self.stemmer = None
        
    def initialize(self) -> bool:
        """Initialize NLP models"""
        try:
            global transformers, torch, Sastrawi
            import os
            
            # Setup Gemini if API key exists
            api_key = os.getenv('GEMINI_API_KEY')
            if api_key:
                try:
                    import google.generativeai as genai
                    genai.configure(api_key=api_key)
                    
                    # Configure safety settings to allow all content for analysis purposes
                    safety_settings = [
                        {"category": "HARM_CATEGORY_HARASSMENT", "threshold": "BLOCK_NONE"},
                        {"category": "HARM_CATEGORY_HATE_SPEECH", "threshold": "BLOCK_NONE"},
                        {"category": "HARM_CATEGORY_SEXUALLY_EXPLICIT", "threshold": "BLOCK_NONE"},
                        {"category": "HARM_CATEGORY_DANGEROUS_CONTENT", "threshold": "BLOCK_NONE"},
                    ]
                    
                    self.genai_model = genai.GenerativeModel('gemini-1.5-pro', safety_settings=safety_settings)
                    print("[TextAnalyzer] Gemini AI initialized for semantic analysis")
                except Exception as e:
                    print(f"[TextAnalyzer] Failed to initialize Gemini: {e}")
                    self.genai_model = None
            else:
                print("[TextAnalyzer] No GEMINI_API_KEY found. Skipping LLM initialization.")
                self.genai_model = None
            
            # Import libraries
            import torch as _torch
            torch = _torch
            
            from transformers import AutoTokenizer, AutoModelForSequenceClassification
            transformers = True
            
            # Load Indonesian BERT untuk sentiment analysis
            model_name = "mdhugol/indonesia-bert-sentiment-classification"
            
            print(f"[TextAnalyzer] Loading model: {model_name}")
            
            self.tokenizer = AutoTokenizer.from_pretrained(model_name)
            self.sentiment_model = AutoModelForSequenceClassification.from_pretrained(model_name)
            self.sentiment_model.eval()
            
            # Load Sastrawi stemmer untuk Indonesian
            try:
                from Sastrawi.Stemmer.StemmerFactory import StemmerFactory
                factory = StemmerFactory()
                self.stemmer = factory.createStemmer()
                print("[TextAnalyzer] Sastrawi stemmer loaded")
            except ImportError:
                print("[TextAnalyzer] Sastrawi not available, using basic preprocessing")
                self.stemmer = None
            
            self.is_initialized = True
            print("[TextAnalyzer] Initialization complete")
            return True
            
        except Exception as e:
            print(f"[TextAnalyzer] Initialization failed: {e}")
            self.is_initialized = False
            return False
    
    def analyze(self, text: str) -> AnalysisResult:
        """
        Analisis teks untuk kredibilitas
        Menggunakan Hybrid approach: Rule-based + LLM (jika tersedia)
        """
        start_time = time.time()
        
        if not text or not text.strip():
            return self._create_result(score=0, confidence=0, findings=["Teks kosong"], warnings=["Tidak ada teks"], analysis_time=0)
        
        # 1. Rule-based Analysis (Cepat & Murah)
        cleaned_text = self._preprocess_text(text)
        hoax_score = self._analyze_hoax_indicators(cleaned_text)
        clickbait_score = self._analyze_clickbait(cleaned_text)
        credibility_score = self._analyze_credibility_indicators(cleaned_text)
        sentiment_result = self._analyze_sentiment(text)
        writing_quality = self._analyze_writing_quality(text)
        
        findings = []
        warnings = []
        
        # 2. LLM Analysis (Cerdas & Kontekstual)
        llm_score = None
        llm_confidence = 0
        llm_analysis = None
        
        if self.genai_model:
            try:
                llm_analysis = self._analyze_with_llm(text)
                if llm_analysis:
                    llm_score = llm_analysis.get('score', 50)
                    llm_confidence = llm_analysis.get('confidence', 0.5)
                    
                    # Add LLM insights
                    if llm_analysis.get('is_hoax'):
                        warnings.append(f"AI: {llm_analysis.get('reasoning', 'Terdeteksi indikasi hoax')}")
                    else:
                        findings.append(f"AI: {llm_analysis.get('reasoning', 'Terlihat kredibel')}")
            except Exception as e:
                print(f"[TextAnalyzer] LLM Analysis failed: {e}")
        
        # Compile rule-based findings if LLM didn't cover them
        if hoax_score > 0.4:
            warnings.append(f"Terdeteksi {int(hoax_score * 100)}% indikator kata kunci hoax")
        
        if clickbait_score > 0.6:
            warnings.append("Pola judul/bahasa clickbait terdeteksi")
            
        if sentiment_result['label'] == 'negative' and sentiment_result['score'] > 0.7:
            warnings.append("Tone bahasa sangat negatif/provokatif")

        rule_based_score = self._calculate_final_score(
            hoax_score, clickbait_score, credibility_score,
            sentiment_result['score'] if sentiment_result['label'] == 'positive' else 1 - sentiment_result['score'],
            writing_quality
        )
        
        if llm_score is not None:
            # Jika LLM sangat yakin atau mendeteksi hoax, beri bobot lebih tinggi
            if llm_confidence > 0.8 or llm_score < 55:
                final_score = llm_score
                final_confidence = llm_confidence
            else:
                final_score = (rule_based_score * 0.15) + (llm_score * 0.85)
                final_confidence = max(llm_confidence, 0.75)
            
            # ATURAN ABSOLUT: Jika AI mendeteksi Hoax, skor maksimal 35
            if llm_analysis and llm_analysis.get('is_hoax'):
                final_score = min(final_score, 35.0)
                
            # Jika terdeteksi "Mixed/Incoherent", paksa skor ke rentang tengah (40-60)
            if llm_analysis and llm_analysis.get('is_mixed'):
                final_score = max(40, min(final_score, 60))
                
        else:
            final_score = rule_based_score
            final_confidence = min(0.95, 0.6 + (len(text) / 1000) * 0.2)
            
        analysis_time = time.time() - start_time
        
        return self._create_result(
            score=final_score,
            confidence=final_confidence,
            findings=findings,
            warnings=warnings,
            metadata={
                'text_length': len(text),
                'word_count': len(text.split()),
                'hoax_score': round(hoax_score, 3),
                'clickbait_score': round(clickbait_score, 3),
                'ai_analysis': True if llm_score is not None else False,
                'sentiment': sentiment_result,
                'llm_raw': llm_analysis
            },
            analysis_time=analysis_time
        )

    def _analyze_with_llm(self, text: str) -> Optional[Dict[str, Any]]:
        """Menggunakan Gemini untuk analisis semantik mendalam - ENHANCED VERSION"""
        if not self.genai_model:
            return None
         
        content = ""
        # Enhanced Prompt Strategy for maximum accuracy
        prompt = f"""
        Peran: Kamu adalah Tim Verifikasi Fakta Elite Indonesia (Verification AI Expert) yang sangat teliti, skeptis, dan cerdas. Kamu memiliki pengetahuan luas tentang hoax yang beredar di Indonesia.
        
        Tugas: Analisis teks berikut untuk menentukan kredibilitas dan kebenaran faktualnya.

        TEKS INPUT:
        \"\"\"{text[:5000]}\"\"\"

        FRAMEWORK ANALISIS (IKUTI URUTAN INI):
        
        ═══════════════════════════════════════════
        TAHAP 1: IDENTIFIKASI JENIS KONTEN
        ═══════════════════════════════════════════
        Tentukan jenis konten:
        A) FAKTA ILMIAH/SEJARAH - Klaim yang dapat diverifikasi dengan sumber kredibel
        B) OPINI/EDITORIAL - Pendapat seseorang (boleh subjektif)
        C) BERITA/LAPORAN - Informasi tentang kejadian
        D) KLAIM KESEHATAN - Informasi medis/kesehatan
        E) KONSPIRASI/PROPAGANDA - Narasi yang menyebarkan ketakutan atau kebencian
        F) SATIR/PARODI - Konten humor (harus jelas konteksnya)
        
        ═══════════════════════════════════════════
        TAHAP 2: DETEKSI CIRI HOAX INDONESIA
        ═══════════════════════════════════════════
        Periksa tanda-tanda hoax yang umum:
        □ Clickbait berlebihan ("VIRAL!", "TERBONGKAR!", "SEBARKAN!")
        □ Klaim kesehatan ajaib ("Sembuhkan kanker dalam 3 hari")
        □ Teori konspirasi (elite global, chip vaksin, bumi datar)
        □ Fear mongering (azab, kiamat, tragedi palsu)
        □ Manipulasi emosi tanpa bukti
        □ Menyebut sumber tidak jelas ("Menurut pakar...")
        □ Desakan untuk menyebarkan ("Bagikan sebelum dihapus!")
        
        ═══════════════════════════════════════════
        TAHAP 3: VERIFIKASI FAKTA
        ═══════════════════════════════════════════
        - Apakah klaim dapat diverifikasi?
        - Apakah sesuai dengan konsensus ilmiah?
        - Apakah ada sumber yang disebutkan dan kredibel?
        - Apakah framing berita netral atau bias?
        
        ═══════════════════════════════════════════
        TAHAP 4: PENILAIAN AKHIR (SANGAT KETAT)
        ═══════════════════════════════════════════
        SKOR 0-20: HOAX KONFIRMASI
        - Konten sepenuhnya palsu atau menyesatkan
        - Konspirasi tanpa bukti
        - Klaim kesehatan berbahaya
        
        SKOR 21-40: SANGAT MERAGUKAN
        - Campuran fakta dan fiksi
        - Framing sangat bias
        - Sumber tidak kredibel
        
        SKOR 41-60: PERLU VERIFIKASI
        - Klaim belum terverifikasi
        - Opini disajikan sebagai fakta
        - Konteks tidak lengkap
        
        SKOR 61-80: CUKUP KREDIBEL
        - Sebagian besar akurat
        - Mungkin ada bias minor
        - Perlu cross-check
        
        SKOR 81-100: KREDIBEL/FAKTA
        - Didukung bukti kuat
        - Sesuai konsensus ilmiah
        - Sumber jelas dan kredibel

        ═══════════════════════════════════════════
        OUTPUT (FORMAT JSON YANG VALID):
        ═══════════════════════════════════════════
        {{
            "content_type": "<jenis konten dari Tahap 1>",
            "hoax_indicators_found": ["<indikator 1>", "<indikator 2>"],
            "score": <0-100>,
            "is_hoax": <true jika score <= 40>,
            "is_mixed": <true jika konten inkonsisten atau campur fakta-hoax>,
            "confidence": <0.0-1.0>,
            "reasoning": "<Penjelasan 1-2 kalimat tentang MENGAPA skor tersebut diberikan. Spesifik dan langsung.>"
        }}
        """
        
        try:
            response = self.genai_model.generate_content(prompt)
            content = response.text.strip()
            
            # Clean up markdown
            import json
            import re
            
            json_str = content
            # Strategy 1: Markdown code block
            if "```json" in content:
                json_str = content.split("```json")[1].split("```")[0]
            elif "```" in content:
                json_str = content.split("```")[1].split("```")[0]
            else:
                # Strategy 2: Regex find outermost braces
                match = re.search(r'\{.*\}', content, re.DOTALL)
                if match:
                    json_str = match.group(0)
            
            result = json.loads(json_str)
            
            # Validate and normalize score
            score = result.get('score', 50)
            if not isinstance(score, (int, float)):
                score = 50
            score = max(0, min(100, score))
            result['score'] = score
            
            # Auto-set is_hoax based on score if not present
            if 'is_hoax' not in result:
                result['is_hoax'] = score <= 40
                
            return result
            
        except Exception as e:
            msg = f"Error: {e}\nRaw Content: {content}"
            print(f"[TextAnalyzer] Error parsing LLM response: {e}")
            print(f"[TextAnalyzer] Raw LLM response for debugging: {content[:500]}")
            return None

    def _preprocess_text(self, text: str) -> str:
        """Preprocess text untuk analisis"""
        # Lowercase
        text = text.lower()
        
        # Remove URLs
        text = re.sub(r'https?://\S+|www\.\S+', '', text)
        
        # Remove extra whitespace
        text = re.sub(r'\s+', ' ', text).strip()
        
        # Stem if available
        if self.stemmer:
            text = self.stemmer.stem(text)
        
        return text
    
    def _analyze_hoax_indicators(self, text: str) -> float:
        """Analisis indikator hoax dalam teks"""
        text_lower = text.lower()
        
        found_indicators = []
        for indicator in self.HOAX_INDICATORS:
            if indicator in text_lower:
                found_indicators.append(indicator)
        
        # Score based on percentage of indicators found
        if not found_indicators:
            return 0.0
        
        # Weight by frequency and severity
        base_score = len(found_indicators) / len(self.HOAX_INDICATORS)
        
        # Boost score if multiple critical indicators
        critical_indicators = ['sebarkan', 'viral', 'terbongkar', 'rahasia', 'menyembuhkan']
        critical_count = sum(1 for i in found_indicators if i in critical_indicators)
        
        return min(1.0, base_score + (critical_count * 0.1))
    
    def _analyze_clickbait(self, text: str) -> float:
        """Analisis pola clickbait"""
        text_lower = text.lower()
        
        matches = 0
        for pattern in self.CLICKBAIT_PATTERNS:
            if re.search(pattern, text_lower):
                matches += 1
        
        # Check for excessive punctuation (!!!, ???, etc.)
        excessive_punct = len(re.findall(r'[!?]{2,}', text))
        
        # Check for ALL CAPS words
        caps_words = len(re.findall(r'\b[A-Z]{3,}\b', text))
        
        score = (matches / len(self.CLICKBAIT_PATTERNS)) * 0.6
        score += min(0.2, excessive_punct * 0.05)
        score += min(0.2, caps_words * 0.03)
        
        return min(1.0, score)
    
    def _analyze_credibility_indicators(self, text: str) -> float:
        """Analisis indikator kredibilitas (sumber, data, dll)"""
        text_lower = text.lower()
        
        found_indicators = []
        for indicator in self.CREDIBILITY_INDICATORS:
            if indicator in text_lower:
                found_indicators.append(indicator)
        
        # Check for numbers/statistics (often indicates data-backed claims)
        has_statistics = bool(re.search(r'\d+[,.]?\d*\s*(%|persen|ribu|juta|miliar)', text_lower))
        
        # Check for quotes (citing sources)
        has_quotes = '"' in text or '"' in text or "'" in text
        
        base_score = len(found_indicators) / len(self.CREDIBILITY_INDICATORS)
        
        if has_statistics:
            base_score += 0.15
        if has_quotes:
            base_score += 0.1
        
        return min(1.0, base_score)
    
    def _analyze_sentiment(self, text: str) -> Dict[str, Any]:
        """Analisis sentiment menggunakan model"""
        if not self.is_initialized or self.sentiment_model is None:
            # Fallback ke rule-based
            return self._rule_based_sentiment(text)
        
        try:
            # Tokenize
            inputs = self.tokenizer(
                text[:512],  
                return_tensors="pt",
                truncation=True,
                padding=True,
                max_length=512
            )
            
            # Predict
            with torch.no_grad():
                outputs = self.sentiment_model(**inputs)
                probs = torch.softmax(outputs.logits, dim=-1)
                
            # Get prediction
            predicted_class = torch.argmax(probs, dim=-1).item()
            confidence = probs[0][predicted_class].item()
            
            labels = ['negative', 'neutral', 'positive']
            
            return {
                'label': labels[predicted_class],
                'score': confidence,
                'all_scores': {
                    'negative': probs[0][0].item(),
                    'neutral': probs[0][1].item(),
                    'positive': probs[0][2].item()
                }
            }
            
        except Exception as e:
            print(f"[TextAnalyzer] Sentiment analysis error: {e}")
            return self._rule_based_sentiment(text)
    
    def _rule_based_sentiment(self, text: str) -> Dict[str, Any]:
        """Fallback rule-based sentiment analysis"""
        text_lower = text.lower()
        
        positive_words = ['baik', 'bagus', 'senang', 'sukses', 'berhasil', 'positif', 'untung']
        negative_words = ['buruk', 'jelek', 'gagal', 'rugi', 'negatif', 'bohong', 'tipu', 'palsu']
        
        pos_count = sum(1 for w in positive_words if w in text_lower)
        neg_count = sum(1 for w in negative_words if w in text_lower)
        
        total = pos_count + neg_count
        if total == 0:
            return {'label': 'neutral', 'score': 0.5}
        
        if pos_count > neg_count:
            return {'label': 'positive', 'score': pos_count / total}
        elif neg_count > pos_count:
            return {'label': 'negative', 'score': neg_count / total}
        else:
            return {'label': 'neutral', 'score': 0.5}
    
    def _analyze_writing_quality(self, text: str) -> float:
        """Analisis kualitas penulisan"""
        score = 1.0
        
        # Check for excessive typos (repeated chars)
        repeated_chars = len(re.findall(r'(.)\1{3,}', text))
        score -= min(0.3, repeated_chars * 0.05)
        
        # Check for proper capitalization at sentence start
        sentences = re.split(r'[.!?]+', text)
        proper_caps = sum(1 for s in sentences if s.strip() and s.strip()[0].isupper())
        if len(sentences) > 1:
            score -= (1 - proper_caps / len(sentences)) * 0.2
        
        # Check for excessive special characters
        special_chars = len(re.findall(r'[^\w\s.,!?;:\'-]', text))
        score -= min(0.2, special_chars / len(text) if text else 0)
        
        # Average word length (too short might indicate informal writing)
        words = text.split()
        if words:
            avg_word_len = sum(len(w) for w in words) / len(words)
            if avg_word_len < 3:
                score -= 0.1
        
        return max(0, score)
    
    def _calculate_final_score(
        self,
        hoax_score: float,
        clickbait_score: float,
        credibility_score: float,
        sentiment_score: float,
        writing_quality: float
    ) -> float:
        """Hitung skor akhir kredibilitas (0-100)"""
        
        # Convert hoax and clickbait to credibility (inverse)
        hoax_credibility = 1 - hoax_score
        clickbait_credibility = 1 - clickbait_score
        
        # Weighted average
        weights = {
            'hoax': 0.35,
            'clickbait': 0.20,
            'credibility': 0.25,
            'sentiment': 0.10,
            'quality': 0.10
        }
        
        score = (
            hoax_credibility * weights['hoax'] +
            clickbait_credibility * weights['clickbait'] +
            credibility_score * weights['credibility'] +
            sentiment_score * weights['sentiment'] +
            writing_quality * weights['quality']
        )
        
        return round(score * 100, 1)
