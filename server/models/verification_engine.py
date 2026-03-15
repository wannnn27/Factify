"""
Verification Engine - Main orchestrator untuk semua analyzer
"""
import time
import json
from typing import Any, Dict, List, Optional, Union
from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum

from .base_model import AnalysisResult
from .text_analyzer import TextAnalyzer
from .url_analyzer import URLAnalyzer
from .image_analyzer import ImageAnalyzer
from .video_analyzer import VideoAnalyzer
from .challenge_analyzer import ChallengeAnalyzer


class ContentType(Enum):
    TEXT = "text"
    URL = "url"
    IMAGE = "image"
    VIDEO = "video"


@dataclass
class VerificationRequest:
    """Request object untuk verifikasi"""
    content_type: ContentType
    content: Any  
    metadata: Dict[str, Any] = field(default_factory=dict)
    request_id: str = field(default_factory=lambda: datetime.now().strftime('%Y%m%d%H%M%S%f'))


@dataclass
class VerificationResponse:
    """Response object dari verifikasi"""
    request_id: str
    content_type: str
    score: float
    confidence: float
    status: str
    status_color: str
    source: str
    ai_summary: str
    main_findings: str
    need_attention: str
    about_source: str
    detailed_analysis: Dict[str, Any]
    analysis_time: float
    timestamp: str = field(default_factory=lambda: datetime.now().isoformat())
    
    def to_dict(self) -> Dict[str, Any]:
        return {
            'request_id': self.request_id,
            'content_type': self.content_type,
            'score': round(self.score, 1),
            'confidence': round(self.confidence, 3),
            'status': self.status,
            'status_color': self.status_color,
            'source': self.source,
            'ai_summary': self.ai_summary,
            'main_findings': self.main_findings,
            'need_attention': self.need_attention, 
            'about_source': self.about_source,
            'detailed_analysis': self.detailed_analysis,
            'analysis_time': round(self.analysis_time, 3),
            'timestamp': self.timestamp
        }
    
    def to_json(self) -> str:
        return json.dumps(self.to_dict(), ensure_ascii=False, indent=2)


class VerificationEngine:
    """
    Main engine untuk verifikasi informasi
    Mengkoordinasikan semua analyzer
    """
    
    def __init__(self, lazy_load: bool = True):
        """
        Initialize verification engine
        
        Args:
            lazy_load: If True, analyzers are loaded on first use
        """
        self.text_analyzer = None
        self.url_analyzer = None
        self.image_analyzer = None
        self.video_analyzer = None
        self.challenge_analyzer = None
        self.chat_model = None  
        self.chat_session = None 
        
        self.lazy_load = lazy_load
        self.initialized_analyzers = set()
        
        if not lazy_load:
            self.initialize_all()
    
    def initialize_all(self) -> Dict[str, bool]:
        """Initialize all analyzers"""
        results = {}
        
        for content_type in ContentType:
            try:
                self._ensure_analyzer(content_type)
                results[content_type.value] = True
            except Exception as e:
                print(f"[Engine] Failed to initialize {content_type.value}: {e}")
                results[content_type.value] = False
        
        # Init challenge analyzer explicitly
        try:
             self._ensure_analyzer("challenge")
             results["challenge"] = True
        except Exception as e:
             results["challenge"] = False

        return results
    
    def _ensure_analyzer(self, content_type: Union[ContentType, str]):
        """Ensure analyzer is initialized"""
        # Handle string or Enum
        type_str = content_type.value if isinstance(content_type, ContentType) else content_type

        if type_str in self.initialized_analyzers:
            return
        
        if content_type == ContentType.TEXT:
            self.text_analyzer = TextAnalyzer()
            self.text_analyzer.initialize()
        elif content_type == ContentType.URL:
            self.url_analyzer = URLAnalyzer()
            self.url_analyzer.initialize()
        elif content_type == ContentType.IMAGE:
            self.image_analyzer = ImageAnalyzer()
            self.image_analyzer.initialize()
        elif content_type == ContentType.VIDEO:
            self.video_analyzer = VideoAnalyzer()
            self.video_analyzer.initialize()
        elif type_str == "challenge":
            self.challenge_analyzer = ChallengeAnalyzer()
            self.challenge_analyzer.initialize()
        
        # Initialize Chat Model
        if type_str == "chat":
            if not self.chat_model:
                try:
                    import os
                    import google.generativeai as genai
                    api_key = os.getenv('GEMINI_API_KEY')
                    if api_key:
                        genai.configure(api_key=api_key)
                        # Use a model with good reasoning for chat
                        self.chat_model = genai.GenerativeModel('gemini-1.5-pro')
                        self.initialized_analyzers.add("chat")
                        print("[Engine] Chat model initialized")
                except Exception as e:
                    print(f"[Engine] Failed to init chat model: {e}")
        
        self.initialized_analyzers.add(type_str)

    def evaluate_challenge(self, case_context: Dict[str, str], user_answer: str, user_sources: str) -> Dict[str, Any]:
        """Evaluate challenge answer"""
        self._ensure_analyzer("challenge")
        self._ensure_analyzer("challenge")
        return self.challenge_analyzer.evaluate(case_context, user_answer, user_sources)

    def chat(self, message: str, history: List[Dict[str, str]] = []) -> str:
        """
        Chat functionality using Gemini
        """
        self._ensure_analyzer("chat")
        
        if not self.chat_model:
            return "Maaf, fitur chat sedang tidak tersedia karena konfigurasi AI (Chat Model) belum siap."

        try:
            # Convert simple history to Gemini format if needed
            # Valid roles: 'user', 'model'
            gemini_history = []
            for msg in history:
                role = "user" if msg.get("role") == "user" else "model"
                gemini_history.append({"role": role, "parts": [msg.get("text", "")]})

            # System instruction is implicit via initial context or system prompt feature 
            # (Gemini API system_instruction is supported in newer SDKs, but let's use context injection for safety)
            
            system_prompt = """
            Kamu adalah "Facti Assistant", asisten virtual cerdas untuk aplikasi Factify.
            
            KARAKTER:
            - Ramah, pintar, dan objektif.
            - Ahli dalam verifikasi fakta, literasi digital, dan keamanan siber.
            - Menggunakan Bahasa Indonesia yang baik dan gaul (sopan tapi santai).
            - Pendek dan padat! Jangan berikan jawaban panjang lebar kecuali diminta.
            - Gunakan emoji sesekali agar tidak kaku. 😊
            
            TUGAS UTAMA:
            1. Menjawab pertanyaan user seputar aplikasi Factify.
            2. Membantu menjelaskan cara verifikasi hoax.
            3. Memberikan tips keamanan digital.
            
            PENGETAHUAN APLIKASI:
            - Fitur "Verifikasi Berita": Bisa cek teks, link, gambar, dan video.
            - Fitur "Edukasi": Belajar lewat video dan artikel tentang literasi digital.
            - Fitur "Challenge": Uji skill detektif anti-hoax kamu.
            - Fitur "Diskusi": Ngobrol sama komunitas.
            
            JANGAN PERNAH:
            - Menyarankan hal ilegal.
            - Membuat hoax.
            - Menjawab kasar.
            """
            
            # Start chat session or send message with history
            chat = self.chat_model.start_chat(history=gemini_history)
            
            # Send message with system prompt prepended if it's a fresh session effectively (or treat as context)
            # A simple trick is to add context to the user message if history is empty
            final_message = message
            if not history:
                 final_message = f"{system_prompt}\n\nUser: {message}"
            
            response = chat.send_message(final_message)
            return response.text.strip()
            
        except Exception as e:
            print(f"[Engine] Chat Error: {e}")
            return "Waduh, aku lagi pusing sedikit. Coba tanya lagi nanti ya! 😵"
    
    def verify(self, request: VerificationRequest) -> VerificationResponse:
        """
        Main verification method
        
        Args:
            request: VerificationRequest object
            
        Returns:
            VerificationResponse with analysis results
        """
        start_time = time.time()
        
        # Ensure analyzer is ready
        self._ensure_analyzer(request.content_type)
        
        # Route to appropriate analyzer
        if request.content_type == ContentType.TEXT:
            result = self.text_analyzer.analyze(request.content)
            excerpt = request.content[:150].replace('\n', ' ')
            source = f"{excerpt}..." if len(request.content) > 150 else excerpt
        elif request.content_type == ContentType.URL:
            result = self.url_analyzer.analyze(request.content)
            source = request.content[:100]
        elif request.content_type == ContentType.IMAGE:
            result = self.image_analyzer.analyze(request.content)
            source = "Gambar yang diupload"
        elif request.content_type == ContentType.VIDEO:
            result = self.video_analyzer.analyze(request.content)
            source = "Video yang diupload"
        else:
            raise ValueError(f"Unknown content type: {request.content_type}")
        
        # Generate human-readable summaries
        ai_summary = self._generate_ai_summary(result, request.content_type)
        main_findings = self._format_findings(result.findings)
        need_attention = self._format_warnings(result.warnings)
        about_source = self._generate_source_info(result, request.content_type, source)
        
        analysis_time = time.time() - start_time
        
        return VerificationResponse(
            request_id=request.request_id,
            content_type=request.content_type.value,
            score=result.score,
            confidence=result.confidence,
            status=self._get_status_label(result.status),
            status_color=result.status_color,
            source=source,
            ai_summary=ai_summary,
            main_findings=main_findings,
            need_attention=need_attention,
            about_source=about_source,
            detailed_analysis=result.metadata,
            analysis_time=analysis_time
        )
    
    def verify_text(self, text: str) -> VerificationResponse:
        """Shortcut untuk verifikasi teks"""
        request = VerificationRequest(
            content_type=ContentType.TEXT,
            content=text
        )
        return self.verify(request)
    
    def verify_url(self, url: str) -> VerificationResponse:
        """Shortcut untuk verifikasi URL"""
        request = VerificationRequest(
            content_type=ContentType.URL,
            content=url
        )
        return self.verify(request)
    
    def verify_image(self, image_source: Any) -> VerificationResponse:
        """Shortcut untuk verifikasi gambar"""
        request = VerificationRequest(
            content_type=ContentType.IMAGE,
            content=image_source
        )
        return self.verify(request)
    
    def verify_video(self, video_source: Any) -> VerificationResponse:
        """Shortcut untuk verifikasi video"""
        request = VerificationRequest(
            content_type=ContentType.VIDEO,
            content=video_source
        )
        return self.verify(request)
    
    def _get_status_label(self, status: str) -> str:
        """Convert status code to human-readable label"""
        labels = {
            'kredibel': 'Kredibel',
            'cukup_kredibel': 'Cukup Kredibel',
            'perlu_perhatian': 'Perlu Perhatian',
            'tidak_kredibel': 'Tidak Kredibel'
        }
        return labels.get(status, status)
    
    def _generate_ai_summary(self, result: AnalysisResult, content_type: ContentType) -> str:
        """Generate AI summary berdasarkan hasil analisis"""
        score = result.score
        findings_count = len(result.findings)
        warnings_count = len(result.warnings)
        
        # 1. Try to get direct AI reasoning first
        ai_reasoning = ""
        
        # Check metadata for explicit AI results (Image/Video/URL often have it)
        meta = result.metadata
        if content_type == ContentType.IMAGE and 'ai_vision_analysis' in meta:
             ai_reasoning = meta['ai_vision_analysis'].get('reasoning', '')
        elif content_type == ContentType.VIDEO and 'ai_multimodal' in meta:
             ai_reasoning = meta['ai_multimodal'].get('reasoning', '')
        elif content_type == ContentType.URL and 'content_analysis' in meta:
             ai_reasoning = meta['content_analysis'].get('ai_analysis', {}).get('raw', {}).get('reasoning', '')
             
        # If not in metadata, look for "AI:" prefix in findings/warnings (TextAnalyzer way)
        if not ai_reasoning:
            all_notes = result.findings + result.warnings
            for note in all_notes:
                if note.startswith("AI: ") or note.startswith("AI Vision: ") or note.startswith("AI Multimodal: "):
                    ai_reasoning = note.split(": ", 1)[1]
                    break
        
        # 2. Construct Summary
        summary = ""
        
        if ai_reasoning:
            summary = f"Analisis AI: \"{ai_reasoning}\" "
        else:
            # Fallback to score-based template
            if score >= 80:
                summary = "Analisis menunjukkan konten ini memiliki kredibilitas tinggi. "
            elif score >= 60:
                summary = "Konten ini cukup kredibel namun tetap perlu diverifikasi. "
            elif score >= 40:
                summary = "Perlu kehati-hatian, terdeteksi indikator yang meragukan. "
            else:
                summary = "Peringatan: Konten ini memiliki indikator kuat sebagai misinformasi atau manipulasi. "
            
        # 3. Add Context Specifics (Verification details)
        if content_type == ContentType.TEXT:
            if meta.get('hoax_score', 0) > 0.5:
                summary += "Terdeteksi pola bahasa yang umum digunakan dalam hoax. "
            if meta.get('clickbait_score', 0) > 0.5:
                summary += "Judul atau konten menggunakan gaya clickbait. "
                
        elif content_type == ContentType.URL:
            if meta.get('domain_score', 0) < 0.4:
                summary += "Domain situs ini tidak memiliki reputasi yang jelas. "
            if meta.get('ssl_enabled'):
                summary += "Koneksi aman (HTTPS) terverifikasi. "
                
        elif content_type == ContentType.IMAGE:
            if meta.get('ai_generated', {}).get('is_ai_generated'):
                summary += "Analisis teknis juga mendeteksi jejak generasi AI. "
            elif meta.get('ela_score', 0) > 0.4:
                summary += "Analisis forensik digital (ELA) menemukan anomali kompresi. "
                
        elif content_type == ContentType.VIDEO:
            deepfake = meta.get('deepfake_analysis', {}) or meta.get('heuristic_deepfake', {})
            if deepfake.get('is_deepfake'):
                summary += "Indikator teknis konsisten dengan tanda-tanda deepfake. "
        
        # Add warning count if significant
        if warnings_count > 0 and "Peringatan" not in summary:
            summary += f"Ditemukan {warnings_count} catatan peringatan."
            
        return summary.strip()
    
    def _format_findings(self, findings: List[str]) -> str:
        """Format findings list to bullet points"""
        if not findings:
            return "Tidak ada temuan khusus."
        
        formatted = []
        for finding in findings[:10]:  # Limit to 10 items
            formatted.append(f"• {finding}")
        
        return "\n".join(formatted)
    
    def _format_warnings(self, warnings: List[str]) -> str:
        """Format warnings list to bullet points"""
        if not warnings:
            return "Tidak ada peringatan khusus."
        
        formatted = []
        for warning in warnings[:10]:  # Limit to 10 items
            formatted.append(f"• {warning}")
        
        return "\n".join(formatted)
    
    def _generate_source_info(
        self,
        result: AnalysisResult,
        content_type: ContentType,
        source: str
    ) -> str:
        """Generate info about the source"""
        info = []
        
        if content_type == ContentType.TEXT:
            word_count = result.metadata.get('word_count', 0)
            info.append(f"Teks berisi {word_count} kata.")
            
        elif content_type == ContentType.URL:
            domain = result.metadata.get('domain', '')
            info.append(f"Domain: {domain}")
            
            age = result.metadata.get('domain_age', {})
            if age.get('age_years'):
                info.append(f"Usia domain: {age['age_years']} tahun")
                
        elif content_type == ContentType.IMAGE:
            img_info = result.metadata.get('image_info', {})
            if img_info:
                info.append(f"Resolusi: {img_info.get('width', 0)}x{img_info.get('height', 0)} pixels")
                
            exif = result.metadata.get('exif', {})
            if exif.get('Make') or exif.get('Model'):
                camera = f"{exif.get('Make', '')} {exif.get('Model', '')}".strip()
                info.append(f"Kamera: {camera}")
                
        elif content_type == ContentType.VIDEO:
            video_info = result.metadata.get('video_info', {})
            if video_info:
                info.append(f"Durasi: {video_info.get('duration', 0):.1f} detik")
                info.append(f"Resolusi: {video_info.get('width', 0)}x{video_info.get('height', 0)}")
                info.append(f"FPS: {video_info.get('fps', 0)}")
        
        if not info:
            info.append(f"Sumber: {source}")
        
        return "\n".join(info)
    
    def get_status(self) -> Dict[str, Any]:
        """Get engine status"""
        return {
            'initialized_analyzers': list(self.initialized_analyzers),
            'lazy_load': self.lazy_load,
            'analyzers': {
                'text': self.text_analyzer.get_status() if self.text_analyzer else None,
                'url': self.url_analyzer.get_status() if self.url_analyzer else None,
                'image': self.image_analyzer.get_status() if self.image_analyzer else None,
                'video': self.video_analyzer.get_status() if self.video_analyzer else None
            }
        }
