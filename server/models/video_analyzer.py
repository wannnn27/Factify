"""
Video Analyzer - Deteksi deepfake dan manipulasi video
"""
from __future__ import annotations
import io
import time
import tempfile
import os
from urllib.parse import urlparse
from typing import Any, Dict, List, Tuple, Optional
from pathlib import Path

from .base_model import BaseAnalyzer, AnalysisResult
from .image_analyzer import ImageAnalyzer

# Lazy imports
PIL = None
np = None
cv2 = None
torch = None


class VideoAnalyzer(BaseAnalyzer):
    """
    Analyzer untuk video - mendeteksi:
    - Deepfake (face manipulation)
    - Audio-visual sync issues
    - Frame manipulation
    - Temporal inconsistencies
    - Metadata analysis
    """
    
    def __init__(self):
        super().__init__("VideoAnalyzer")
        self.image_analyzer = ImageAnalyzer()
        self.face_detector = None
        self.frame_sample_rate = 30  # Sample every N frames
        self.max_frames = 50  # Maximum frames to analyze
        self.max_download_size = 50 * 1024 * 1024
        
    def initialize(self) -> bool:
        """Initialize video processing libraries"""
        try:
            global cv2, np, FaceDetector, dlib
            import os
            
            # Setup Gemini Vision if API key exists
            api_key = os.getenv('GEMINI_API_KEY')
            if api_key:
                try:
                    import google.generativeai as genai
                    genai.configure(api_key=api_key)
                    model_name = os.getenv('GEMINI_VIDEO_MODEL', 'gemini-1.5-pro')
                    self.genai_model = genai.GenerativeModel(model_name)
                    print(f"[VideoAnalyzer] Gemini Multimodal AI initialized: {model_name}")
                except Exception as e:
                    print(f"[VideoAnalyzer] Failed to initialize Gemini: {e}")
                    self.genai_model = None
            else:
                self.genai_model = None
            
            import numpy as _np
            np = _np
            
            try:
                import cv2 as _cv2
                cv2 = _cv2
            except ImportError:
                print("[VideoAnalyzer] OpenCV not available")
                cv2 = None
                
            # Initialize ImageAnalyzer for frame analysis
            from .image_analyzer import ImageAnalyzer
            self.image_analyzer = ImageAnalyzer()
            self.image_analyzer.initialize()
            
            self.is_initialized = True
            print("[VideoAnalyzer] Initialization complete")
            return True
            
        except Exception as e:
            print(f"[VideoAnalyzer] Initialization failed: {e}")
            self.is_initialized = False
            return False
    
    def analyze(self, video_source: Any) -> AnalysisResult:
        """
        Analisis video untuk deepfake dan manipulasi
        Hybrid: Frame-by-frame analysis + Gemini Multimodal Video Analysis
        """
        start_time = time.time()

        try:
            video_path, temp_paths = self._prepare_video_source(video_source)
        except Exception as e:
            return self._create_result(
                score=0,
                confidence=0,
                findings=[],
                warnings=[f"Gagal memproses input video: {e}"],
                analysis_time=time.time() - start_time,
            )
            
        findings = []
        warnings = []
        
        # 1. Traditional Frame Extraction & Analysis
        frames = []
        video_info = {'fps': 0, 'frame_count': 0, 'width': 0, 'height': 0}
        
        if cv2:
            try:
                cap = cv2.VideoCapture(video_path)
                if not cap.isOpened():
                    raise ValueError("Could not open video")
                
                video_info = {
                    'fps': cap.get(cv2.CAP_PROP_FPS),
                    'frame_count': int(cap.get(cv2.CAP_PROP_FRAME_COUNT)),
                    'width': int(cap.get(cv2.CAP_PROP_FRAME_WIDTH)),
                    'height': int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT)),
                }
                fps = video_info['fps'] or 0
                video_info['duration'] = (
                    round(video_info['frame_count'] / fps, 2)
                    if fps > 0 else 0
                )
                
                # Extract frames (limit to 10 spread out frames for local checks)
                frames = self._extract_frames(cap, video_info['frame_count'])
                cap.release()
                
                findings.append(f"Resolusi Video: {video_info['width']}x{video_info['height']} @ {video_info['fps']:.1f}fps")
            except Exception as e:
                warnings.append(f"Gagal membaca video secara lokal: {e}")

        # 2. Heuristic Analysis
        face_result = self._analyze_faces(frames)
        temporal_result = self._check_temporal_consistency(frames)
        deepfake_result = self._detect_deepfake_indicators(frames, face_result)
        audio_result = self._analyze_audio_sync(video_path)
        
        if deepfake_result['is_deepfake']:
            warnings.append(f"Indikator Deepfake terdeteksi (heuristic): {deepfake_result['indicators_found']} tanda")
        if audio_result.get('warning'):
            warnings.append(audio_result['warning'])
        
        # 3. Gemini Multimodal Analysis (The Heavy Lifter)
        ai_video_result = {'performed': False}
        if self.genai_model:
            ai_video_result = self._analyze_with_gemini_video(video_path)
            if ai_video_result['performed']:
                if ai_video_result['is_deepfake']:
                    warnings.append(f"AI Multimodal: {ai_video_result['reasoning']}")
                else:
                    findings.append(f"AI Multimodal: {ai_video_result['reasoning']}")
        else:
            warnings.append("Gemini model tidak tersedia untuk analisis video mendalam")

        # Cleanup temp file
        for temp_path in temp_paths:
            try:
                if os.path.exists(temp_path):
                    os.remove(temp_path)
            except OSError:
                pass

        # Calculate Scores
        heuristic_score = 1.0 - deepfake_result.get('confidence', 0.35)
        
        final_score = heuristic_score
        confidence = 0.6
        
        if ai_video_result['performed']:
            ai_score = ai_video_result['score']
            ai_conf = ai_video_result['confidence']
            
            # 70% AI, 30% Heuristic (Video analysis by AI is much stronger than simple heuristics)
            final_score = (heuristic_score * 0.3) + (ai_score * 0.7)
            confidence = max(confidence, ai_conf)
        
        analysis_time = time.time() - start_time
        
        return self._create_result(
            score=final_score * 100,
            confidence=confidence,
            findings=findings,
            warnings=warnings,
            metadata={
                'video_info': video_info,
                'heuristic_deepfake': deepfake_result,
                'ai_multimodal': ai_video_result,
                'temporal_consistency': temporal_result,
                'audio_analysis': audio_result,
            },
            analysis_time=analysis_time
        )

    def _prepare_video_source(self, video_source: Any) -> Tuple[str, List[str]]:
        """Return a local path for a path, upload bytes/stream, or remote URL."""
        temp_paths: List[str] = []

        if isinstance(video_source, (str, Path)):
            source = str(video_source).strip()
            parsed = urlparse(source)
            if parsed.scheme in {"http", "https"}:
                path = self._download_video_url(source)
                temp_paths.append(path)
                return path, temp_paths
            return source, temp_paths

        suffix = ".mp4"
        with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as temp_file:
            payload = video_source.read() if hasattr(video_source, "read") else video_source
            temp_file.write(payload)
            temp_paths.append(temp_file.name)
            return temp_file.name, temp_paths

    def _download_video_url(self, url: str) -> str:
        """Download a direct video URL, or use yt-dlp for common video platforms."""
        parsed = urlparse(url)
        host = (parsed.netloc or "").lower()
        platform_hosts = ("youtube.com", "youtu.be", "vimeo.com", "tiktok.com")

        if any(platform in host for platform in platform_hosts):
            return self._download_with_ytdlp(url)

        suffix = Path(parsed.path).suffix.lower()
        if suffix not in {".mp4", ".mov", ".avi", ".webm", ".mkv"}:
            suffix = ".mp4"

        try:
            import requests

            with requests.get(url, stream=True, timeout=30) as response:
                response.raise_for_status()
                content_type = response.headers.get("content-type", "").lower()
                if content_type and not (
                    content_type.startswith("video/")
                    or "octet-stream" in content_type
                ):
                    raise ValueError(
                        "URL tidak mengarah ke file video langsung. "
                        "Gunakan URL file video atau pasang yt-dlp untuk platform video."
                    )

                content_length = response.headers.get("content-length")
                if content_length and int(content_length) > self.max_download_size:
                    raise ValueError("Ukuran video melebihi batas 50MB")

                downloaded = 0
                with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as temp_file:
                    for chunk in response.iter_content(chunk_size=1024 * 1024):
                        if not chunk:
                            continue
                        downloaded += len(chunk)
                        if downloaded > self.max_download_size:
                            temp_file.close()
                            os.remove(temp_file.name)
                            raise ValueError("Ukuran video melebihi batas 50MB")
                        temp_file.write(chunk)
                    return temp_file.name
        except ValueError:
            raise
        except Exception as e:
            raise ValueError(f"Gagal mengunduh video dari URL: {e}") from e

    def _download_with_ytdlp(self, url: str) -> str:
        """Download a video-platform URL with yt-dlp when the dependency exists."""
        try:
            import yt_dlp
        except ImportError as e:
            raise ValueError(
                "URL YouTube/Vimeo/TikTok membutuhkan dependency yt-dlp. "
                "Install dengan `pip install yt-dlp` atau unggah file video langsung."
            ) from e

        output_template = os.path.join(
            tempfile.gettempdir(),
            f"factify_video_{int(time.time() * 1000)}.%(ext)s",
        )
        options = {
            "format": "best[ext=mp4][filesize<50M]/best[filesize<50M]/best",
            "outtmpl": output_template,
            "quiet": True,
            "noplaylist": True,
            "max_filesize": self.max_download_size,
        }

        try:
            with yt_dlp.YoutubeDL(options) as ydl:
                info = ydl.extract_info(url, download=True)
                downloaded = ydl.prepare_filename(info)
                if not os.path.exists(downloaded):
                    base, _ = os.path.splitext(downloaded)
                    matches = [
                        f"{base}{ext}"
                        for ext in (".mp4", ".webm", ".mkv", ".mov")
                        if os.path.exists(f"{base}{ext}")
                    ]
                    if matches:
                        downloaded = matches[0]
                if not os.path.exists(downloaded):
                    raise ValueError("yt-dlp tidak menghasilkan file video")
                if os.path.getsize(downloaded) > self.max_download_size:
                    os.remove(downloaded)
                    raise ValueError("Ukuran video melebihi batas 50MB")
                return downloaded
        except Exception as e:
            raise ValueError(f"Gagal mengunduh video platform: {e}") from e

    def _analyze_with_gemini_video(self, video_path: str) -> Dict[str, Any]:
        """Upload and analyze video with Gemini - ENHANCED VERSION"""
        print(f"[VideoAnalyzer] Uploading video to Gemini: {video_path}")
        try:
            import google.generativeai as genai
            import time
            import re
            
            # 1. Upload file
            video_file = genai.upload_file(path=video_path)
            
            # 2. Wait for processing
            print("Processing video...", end="", flush=True)
            while video_file.state.name == "PROCESSING":
                print(".", end="", flush=True)
                time.sleep(1)
                video_file = genai.get_file(video_file.name)
                
            if video_file.state.name == "FAILED":
                raise ValueError("Gemini video processing failed")
                
            print("\n[VideoAnalyzer] Video processed by Gemini. Generating analysis...")
            
            # 3. Generate content with ADVANCED PROMPT
            prompt = """
            Peran: Kamu adalah Unit Khusus Deteksi Deepfake & Manipulasi Video Elit (Video Forensics Expert).
            
            Tugas: Analisis frame-by-frame (visual) dan audio untuk mendeteksi tanda-tanda manipulasi AI (Deepfake/Faceswap) atau editing berbahaya.

            CHECKLIST FORENSIK (Lakukan Secara Menyeluruh):
            
            1. ANALISIS WAJAH & EKSPRESI (Utama):
               □ Sinkronisasi Bibir (Lip-sync): Apakah gerak mulut pas 100% dengan fonem suara? (AI sering meleset).
               □ Mata: Apakah subjek berkedip dengan frekuensi wajar?
               □ Emosi: Apakah ekspresi mata (micro-expression) sesuai dengan senyum/mulut? (Deepfake sering memiliki mata kosong).
               □ Outline Wajah: Adakah artifak kabur/kotak di sekitar dagu dan rambut?
               
            2. FISIKA & CAHAYA:
               □ Pencahayaan: Apakah bayangan di wajah konsisten dengan lingkungan?
               □ Warping: Apakah latar belakang ikut bergerak/meleleh saat kepala subjek bergerak?
               
            3. AUDIO FORENSIK:
               □ Nafas: Apakah ada suara nafas alami? (AI sering menghapus nafas).
               □ Intonasi: Apakah nada bicara terlalu datar atau robotik?
               □ Noise Gating: Apakah suara latar belakang tiba-tiba bisu total saat subjek diam?

            PENILAIAN AKHIR:
            SKOR 0-30: DEEPFAKE KONFIRMASI (Tanda jelas di bibir/mata/suara)
            SKOR 31-60: MENCURIGAKAN (Terlihat tidak natural tapi low res)
            SKOR 61-100: VIDEO ASLI / ORGANIK

            OUTPUT JSON (WAJIB VALID):
            {
                "score": <0-100>,
                "is_deepfake": <boolean>,
                "detected_issues": ["<masalah 1>", "<masalah 2>"],
                "reasoning": "<Sebutkan timestamp atau detail visual spesifik (misal: 'Di detik 0:05 bibir tidak sinkron dengan kata 'saya', dan mata tidak berkedip selama 10 detik').>"
            }
            """
            
            response = self.genai_model.generate_content([video_file, prompt])
            
            # 4. Clean up
            try:
                genai.delete_file(video_file.name)
            except: pass
            
            # Parse result
            import json
            content = response.text.strip()
            
            # Robust JSON extraction
            match = re.search(r'\{.*\}', content, re.DOTALL)
            if match:
                content = match.group(0)
            
            content = content.replace("```json", "").replace("```", "")
                
            ai_json = json.loads(content)
            
            # Normalize score
            score = ai_json.get('score', 50)
            if score < 0 or score > 100: score = 50
            
            return {
                'performed': True,
                'score': score / 100.0, # Convert to 0.0-1.0
                'confidence': 0.95,
                'is_deepfake': ai_json.get('is_deepfake', score < 40),
                'reasoning': ai_json.get('reasoning', '')
            }
            
        except Exception as e:
            print(f"[VideoAnalyzer] Gemini Video Analysis Error: {e}")
            return {'performed': False, 'error': str(e)}

    def _extract_frames(self, cap, total_frames: int) -> List[np.ndarray]:
        """Extract sample frames from video"""
        frames = []
        if total_frames <= 0: return frames
        
        # Determine sampling
        num_frames = min(getattr(self, 'max_frames', 10), total_frames)
        
        # Safe sampling across the video
        end_index = max(0, total_frames - 1)
        indices = np.linspace(0, end_index, num_frames, dtype=int)
        
        for idx in indices:
            cap.set(cv2.CAP_PROP_POS_FRAMES, idx)
            ret, frame = cap.read()
            if ret:
                frames.append(frame)
        
        return frames

    # ... (Rest of existing methods _analyze_faces, _check_temporal_consistency, etc. follow below here, but I will include them to be safe since I am replacing a big chunk) ...
    
    def _analyze_faces(self, frames: List[np.ndarray]) -> Dict[str, Any]:
        """Analyze faces across frames"""
        findings = []
        warnings = []
        
        if not cv2 or not frames:
            return {'score': 0.5, 'findings': [], 'warnings': [], 'faces_per_frame': []}
        
        # Load cascade if not loaded (using default opencv path if valid, else skip)
        cascade_path = cv2.data.haarcascades + 'haarcascade_frontalface_default.xml'
        if not os.path.exists(cascade_path):
             return {'score': 0.5, 'warnings': ["Face detector model missing"], 'faces_per_frame': []}
             
        face_detector = cv2.CascadeClassifier(cascade_path)
        
        faces_per_frame = []
        face_positions = []
        
        for i, frame in enumerate(frames):
            gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
            faces = face_detector.detectMultiScale(gray, 1.1, 5, minSize=(30, 30))
            
            faces_per_frame.append(len(faces))
            if len(faces) > 0:
                face_positions.append(faces[0])
        
        total_faces = sum(faces_per_frame)
        frames_with_faces = sum(1 for f in faces_per_frame if f > 0)
        
        if total_faces > 0:
            findings.append(f"Wajah terdeteksi di {frames_with_faces}/{len(frames)} frame")
        
        score = 0.5
        if frames_with_faces > 0:
            score = 0.8
            
        return {
            'score': score,
            'findings': findings,
            'warnings': warnings,
            'faces_per_frame': faces_per_frame,
            'frames_with_faces': frames_with_faces
        }
    
    def _check_temporal_consistency(self, frames: List[np.ndarray]) -> Dict[str, Any]:
        """Check for temporal inconsistencies between frames"""
        if not cv2 or np is None or len(frames) < 2:
            return {'inconsistent': False, 'score': 0.8, 'avg_frame_delta': 0}
        
        differences = []
        for i in range(1, len(frames)):
            diff = cv2.absdiff(frames[i-1], frames[i])
            diff_score = np.mean(diff) / 255
            differences.append(diff_score)
        
        avg_diff = float(np.mean(differences)) if differences else 0.0
        consistency_score = max(0.0, min(1.0, 1.0 - min(avg_diff * 1.5, 1.0)))
        return {
            'inconsistent': avg_diff > 0.75,
            'score': consistency_score,
            'avg_frame_delta': avg_diff,
        }
    
    def _detect_deepfake_indicators(self, frames: List[np.ndarray], face_result: Dict[str, Any]) -> Dict[str, Any]:
        """Detect heuristic deepfake indicators"""
        indicators = 0
        # Simple heuristic: if face count varies wildly, it's suspicious
        if 'faces_per_frame' in face_result:
            counts = face_result['faces_per_frame']
            if counts and np.var(counts) > 0.5:
                indicators += 1
                
        if not frames:
            risk = 0.35
        else:
            risk = min(0.9, indicators * 0.35)

        return {
            'is_deepfake': risk >= 0.5,
            'confidence': risk,
            'indicators_found': indicators
        }
    
    def _analyze_audio_sync(self, video_path: str) -> Dict[str, Any]:
        """Analyze audio-visual synchronization — detect missing/mismatched audio"""
        try:
            import subprocess
            import shutil

            # Check if ffprobe is available
            ffprobe_path = shutil.which('ffprobe')
            if ffprobe_path is None:
                # Fallback: check if video has audio stream via OpenCV metadata
                # (OpenCV can't directly check audio, so use a heuristic)
                return {'score': 0.5, 'has_audio': None, 'method': 'no_ffprobe'}

            # Use ffprobe to check audio streams
            cmd = [
                ffprobe_path, '-v', 'quiet',
                '-print_format', 'json',
                '-show_streams',
                '-select_streams', 'a',
                video_path
            ]
            result = subprocess.run(cmd, capture_output=True, text=True, timeout=10)
            
            import json
            probe_data = json.loads(result.stdout)
            audio_streams = probe_data.get('streams', [])
            
            if not audio_streams:
                # No audio track — common in manipulated videos
                return {
                    'score': 0.3,
                    'has_audio': False,
                    'warning': 'Video tidak memiliki audio track',
                }
            
            # Has audio — check basic properties
            audio = audio_streams[0]
            sample_rate = int(audio.get('sample_rate', 0))
            channels = int(audio.get('channels', 0))
            
            score = 0.7
            if sample_rate >= 44100 and channels >= 2:
                score = 0.8  # Good quality audio
            elif sample_rate >= 22050:
                score = 0.6  # Acceptable
            else:
                score = 0.4  # Low quality, potentially re-encoded
            
            return {
                'score': score,
                'has_audio': True,
                'sample_rate': sample_rate,
                'channels': channels,
                'codec': audio.get('codec_name', 'unknown'),
            }
        except Exception as e:
            print(f"[VideoAnalyzer] Audio sync analysis error: {e}")
            return {'score': 0.5}

    def _calculate_final_score(self, face, temporal, quality, deepfake, audio) -> float:
        """Calculate weighted final score from all sub-analyses"""
        # Weights: face consistency(20%), temporal(20%), quality(10%), deepfake detection(35%), audio(15%)
        score = (
            face * 0.20 +
            temporal * 0.20 +
            quality * 0.10 +
            deepfake * 0.35 +
            audio * 0.15
        )
        return round(max(0.0, min(100.0, score * 100)), 1)

