
"""
Challenge Analyzer - Analisis jawaban user di fitur Challenge
"""
import os
import json
import re
from typing import Dict, Any, Optional
from .base_model import BaseAnalyzer, AnalysisResult

# Lazy import - will be imported in initialize()
genai = None

class ChallengeAnalyzer(BaseAnalyzer):
    """
    Analyzer untuk mengevaluasi jawaban user pada challenge/studi kasus
    """
    
    def __init__(self):
        super().__init__("ChallengeAnalyzer")
        self.genai_model = None
        
    def initialize(self) -> bool:
        try:
            global genai
            import google.generativeai as _genai
            genai = _genai
            
            api_key = os.getenv('GEMINI_API_KEY')
            if not api_key:
                print("[ChallengeAnalyzer] No API Key found")
                return False
                
            genai.configure(api_key=api_key)
            self.genai_model = genai.GenerativeModel('gemini-1.5-pro')
            self.is_initialized = True
            print("[ChallengeAnalyzer] Gemini initialized")
            return True
        except Exception as e:
            print(f"[ChallengeAnalyzer] Init failed: {e}")
            return False

    def evaluate(self, case_context: Dict[str, str], user_answer: str, user_sources: str) -> Dict[str, Any]:
        """
        Evaluasi jawaban user - ENHANCED VERSION
        """
        if not self.is_initialized:
            return {"error": "Analyzer not initialized"}
            
        prompt = f"""
        Peran: Kamu adalah Sistem Evaluasi Verifikasi Fakta Tingkat Mahir (Advanced Fact-Checking Evaluation System).
        
        Tugas: Menilai akurasi dan kualitas investigasi pengguna terhadap kasus hoaks berikut.

        KONTEKS KASUS:
        [Topik]: {case_context.get('topic', 'General')}
        [Judul]: {case_context.get('title', '')}
        [Masalah]: {case_context.get('problem', '')}
        [Kebenaran (Kunci Jawaban)]: {case_context.get('solution', '')}
        
        JAWABAN PENGGUNA:
        [Analisis]: "{user_answer}"
        [Sumber]: "{user_sources}"
        
        INSTRUKSI PENILAIAN (STRICT):
        1. KETEPATAN FAKTA (40%): Apakah user berhasil menjelaskan KENAPA itu hoax sesuai kunci jawaban?
        2. KEDAULATAN LOGIKA (30%): Apakah argumennya masuk akal dan runtut?
        3. KUALITAS SUMBER (20%): Apakah user menyertakan sumber kredibel (cekfakta, kominfo, jurnal, berita mainstream)?
        4. SIKAP (10%): Bahasa netral dan objektif.

        SKORING:
        - 0-30: Gagal Total (Menjawab salah atau mendukung hoax)
        - 31-59: Kurang (Benar tapi alasan dangkal/salah)
        - 60-79: Cukup/Bagus (Benar dan alasan masuk akal)
        - 80-100: Sempurna (Analisis mendalam + sumber kuat)

        OUTPUT JSON (WAJIB VALID JSON):
        {{
            "thought_process": "<Analisis singkat kamu>",
            "score": <0-100>,
            "verdict": "<Sangat Bagus / Bagus / Cukup / Kurang / Gagal>",
            "strengths": ["<Poin 1>", "<Poin 2>"],
            "weaknesses": ["<Poin 1>", "<Poin 2>"],
            "feedback": "<Saran konstruktif dan ramah untuk user (gunakan 'Anda').>",
            "detailed_scores": {{
                "accuracy": <0-40>,
                "logic": <0-30>,
                "evidence": <0-20>,
                "attitude": <0-10>
            }}
        }}
        """
        
        try:
            response = self.genai_model.generate_content(prompt)
            text = response.text.strip()
            
            # Robust JSON extraction
            match = re.search(r'\{.*\}', text, re.DOTALL)
            if match:
                text = match.group(0)
            
            # Remove markdown code blocks if any remain
            text = text.replace("```json", "").replace("```", "")
            
            result = json.loads(text)
            
            # Validate score range
            result['score'] = max(0, min(100, result.get('score', 0)))
            
            return result
            
        except Exception as e:
            print(f"[ChallengeAnalyzer] Error: {e}")
            # Return safe fallback instead of 500
            return {
                "score": 0,
                "verdict": "Gagal Menilai",
                "strengths": [],
                "weaknesses": ["Terjadi kesalahan teknis pada sistem AI."],
                "feedback": "Maaf, sistem sedang sibuk. Silakan coba lagi nanti.",
                "detailed_scores": {"accuracy":0, "logic":0, "evidence":0, "attitude":0}
            }

    def analyze(self, content: Any) -> AnalysisResult:
        # Not used directly, but required by BaseAnalyzer
        return self._create_result(
            score=0, confidence=0,
            findings=[], warnings=["ChallengeAnalyzer.analyze() not implemented — use evaluate() instead"]
        )
