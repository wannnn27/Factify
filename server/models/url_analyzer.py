"""
URL Analyzer - Analisis kredibilitas URL/website
"""
import re
import time
from typing import Any, Dict, List, Optional
from urllib.parse import urlparse
import socket

from .base_model import BaseAnalyzer, AnalysisResult

# Lazy imports
requests = None
BeautifulSoup = None
whois = None


class URLAnalyzer(BaseAnalyzer):
    """
    Analyzer untuk URL/website - menganalisis:
    - Domain reputation
    - SSL certificate
    - Website age
    - Content credibility
    - Malware/phishing indicators
    """
    
    # Trusted news domains (Indonesia & International)
    TRUSTED_DOMAINS = {
        # Indonesia - Tier 1 (Very Trusted)
        'kompas.com': 95, 'kompas.id': 95, 'tempo.co': 95,
        'detik.com': 85, 'liputan6.com': 85, 'cnnindonesia.com': 90,
        'tirto.id': 90, 'kumparan.com': 80, 'antaranews.com': 92,
        'mediaindonesia.com': 85, 'republika.co.id': 82,
        'bisnis.com': 85, 'kontan.co.id': 85,
        
        # Indonesia - Tier 2 (Trusted dengan catatan)
        'tribunnews.com': 70, 'okezone.com': 70, 'sindonews.com': 70,
        'merdeka.com': 72, 'suara.com': 70, 'viva.co.id': 70,
        
        # Government/Official
        'go.id': 90, 'or.id': 75, 'ac.id': 85,
        
        # International
        'bbc.com': 95, 'reuters.com': 95, 'apnews.com': 95,
        'nytimes.com': 90, 'theguardian.com': 88, 'washingtonpost.com': 88,
        'aljazeera.com': 85, 'dw.com': 88,
    }
    
    # Known fake news / hoax domains
    BLACKLISTED_DOMAINS = [
        'palsu', 'hoax', 'fake', 'beritabohong'
    ]
    
    # Suspicious TLDs
    SUSPICIOUS_TLDS = ['.xyz', '.tk', '.ml', '.ga', '.cf', '.gq', '.top', '.loan']
    
    # Phishing indicators in URL
    PHISHING_PATTERNS = [
        r'login.*secure', r'account.*verify', r'update.*info',
        r'confirm.*identity', r'suspended', r'verify.*account'
    ]
    
    def __init__(self):
        super().__init__("URLAnalyzer")
        self.session = None
        
    def initialize(self) -> bool:
        """Initialize HTTP session dan dependencies"""
        try:
            global requests, BeautifulSoup, whois
            import os
            
            # Setup Gemini if API key exists
            api_key = os.getenv('GEMINI_API_KEY')
            if api_key:
                try:
                    import google.generativeai as genai
                    genai.configure(api_key=api_key)
                    self.genai_model = genai.GenerativeModel('gemini-1.5-flash')
                    print("[URLAnalyzer] Gemini AI initialized for content analysis")
                except Exception as e:
                    print(f"[URLAnalyzer] Failed to initialize Gemini: {e}")
                    self.genai_model = None
            else:
                self.genai_model = None
                
            import requests as _requests
            requests = _requests
            
            from bs4 import BeautifulSoup as _BS
            BeautifulSoup = _BS
            
            try:
                import whois as _whois
                whois = _whois
            except ImportError:
                print("[URLAnalyzer] python-whois not available")
                whois = None
            
            # Create session dengan headers
            self.session = requests.Session()
            self.session.headers.update({
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
                'Accept-Language': 'id-ID,id;q=0.9,en-US;q=0.8,en;q=0.7',
            })
            
            self.is_initialized = True
            print("[URLAnalyzer] Initialization complete")
            return True
            
        except Exception as e:
            print(f"[URLAnalyzer] Initialization failed: {e}")
            self.is_initialized = False
            return False
    
    def analyze(self, url: str) -> AnalysisResult:
        """
        Analisis URL untuk kredibilitas
        Hybrid method: Technical checks + AI Content Analysis
        """
        start_time = time.time()
        
        # Validate URL
        if not url or not url.strip():
            return self._create_result(0, 0, ["URL kosong"], ["Tidak ada URL"], 0)
        
        # Parse URL
        try:
            parsed_url = urlparse(url)
            if not parsed_url.scheme:
                url = 'https://' + url
                parsed_url = urlparse(url)
            domain = parsed_url.netloc.lower()
            if domain.startswith('www.'):
                domain = domain[4:]
        except Exception as e:
            return self._create_result(0, 0.5, [], [f"URL tidak valid: {e}"], 0)
        
        findings = []
        warnings = []
        
        # 1. Technical Checks
        domain_score = self._check_domain_reputation(domain)
        blacklist_result = self._check_blacklist(domain)
        tld_score = self._check_tld(domain)
        ssl_result = self._check_ssl(url)
        domain_age = self._check_domain_age(domain)
        phishing_score = self._check_phishing_patterns(url)
        
        if blacklist_result['is_blacklisted']:
            warnings.append(f"Domain di-blacklist: {blacklist_result['reason']}")
        if ssl_result['has_ssl']:
            findings.append("Menggunakan HTTPS (Aman)")
        else:
            warnings.append("Tidak aman (HTTP)")
            
        # 2. Content Analysis
        content_result = self._analyze_content(url)
        
        # Merge AI findings
        findings.extend(content_result.get('findings', []))
        warnings.extend(content_result.get('warnings', []))
        
        # Intelligent confidence calculation
        confidence = 0.75
        if domain in self.TRUSTED_DOMAINS:
            confidence = 0.95
        elif content_result.get('ai_analysis', {}).get('performed'):
            confidence = 0.90  # AI analysis increases confidence
        
        # Calculate final score
        # AI score overrides technical score if critical issues found
        technical_score = self._calculate_final_score(
            domain_score, 
            1.0 if not blacklist_result['is_blacklisted'] else 0.0,
            tld_score,
            1.0 if ssl_result['has_ssl'] else 0.5,
            domain_age.get('score', 0.5),
            1.0 - phishing_score,
            content_result.get('score', 0.5)
        )
        
        final_score = technical_score
        
        # If AI detects specific issues, adjust score heavily
        ai_data = content_result.get('ai_analysis', {})
        if ai_data.get('performed'):
            ai_score = ai_data.get('score', 0)
            ai_confidence = ai_data.get('confidence', 0)
            
            # Hybrid weighting
            final_score = (technical_score * 0.4) + (ai_score * 0.6)
            confidence = max(confidence, ai_confidence)
            
        analysis_time = time.time() - start_time
        
        return self._create_result(
            score=final_score,
            confidence=confidence,
            findings=findings,
            warnings=warnings,
            metadata={
                'url': url,
                'domain': domain,
                'domain_score': domain_score,
                'ssl_enabled': ssl_result['has_ssl'],
                'domain_age': domain_age,
                'content_analysis': content_result
            },
            analysis_time=analysis_time
        )

    def _analyze_content(self, url: str) -> Dict[str, Any]:
        """Fetch and analyze page content using AI"""
        if not self.is_initialized or requests is None:
            return {'score': 0.5, 'findings': [], 'warnings': []}
        
        findings = []
        warnings = []
        score = 0.5
        ai_data = {'performed': False}
        
        try:
            # Fetch content with masqueraded generic user agent
            response = self.session.get(url, timeout=15, allow_redirects=True)
            
            if response.status_code == 200:
                soup = BeautifulSoup(response.text, 'html.parser')
                
                # Metadata extraction
                title = soup.find('title')
                title_text = title.string.strip() if title else ""
                
                # Extract main text (simple heuristic)
                paragraphs = soup.find_all('p')
                main_text = " ".join([p.get_text() for p in paragraphs])
                # Limit text length for AI context window
                main_text = main_text[:4000] 
                
                if len(main_text) < 200:
                    warnings.append("Konten halaman terlalu sedikit untuk dianalisis")
                    score = 0.4
                else:
                    # AI ANALYSIS
                    if self.genai_model:
                        ai_prompt = f"""
                        Peran: Cyber Security & News Verification Expert.
                        Tugas: Analisis Kredibilitas Halaman Web.
                        
                        Data URL:
                        - Judul: {title_text}
                        - Konten: {main_text[:2500]}...
                        
                        Lakukan investigasi mendalam (Chain of Thought):
                        1. IDENTITAS DOMAIN: Apakah ini situs berita sah, blog pribadi, atau situs tiruan (cybersquatting)?
                        2. ANALISIS KONTEN: Apakah isinya berkualitas jurnalistik, clickbait, atau scam (penipuan/jual beli mencurigakan)?
                        3. CEK FAKTA LOGIS: Apakah klaim yang dibuat masuk akal? 
                        4. INDIKASI BERBAHAYA: Adakah permintaan data pribadi, login palsu, atau unduhan paksa?
                        
                        Berikan skor keamanan & kredibilitas 0-100.
                        (0-20: Malware/Scam, 21-40: Hoax/Palsu, 41-60: Clickbait/Bias, 61-100: Kredibel)
                        
                        Format JSON:
                        {{
                            "step_logic": "Domain terlihat meniru kompas.com... Bahasa tidak baku...",
                            "score": <0-100>,
                            "is_suspicious": <boolean>,
                            "category": "<news/scam/blog/shopping/other>",
                            "reasoning": "<Kesimpulan utama>"
                        }}
                        """
                        try:
                            ai_resp = self.genai_model.generate_content(ai_prompt)
                            import json
                            content = ai_resp.text.strip()
                            if "```json" in content:
                                content = content.split("```json")[1].split("```")[0]
                            elif "```" in content:
                                content = content.split("```")[1].split("```")[0]
                                
                            ai_json = json.loads(content)
                            
                            ai_score = ai_json.get('score', 50)
                            ai_reason = ai_json.get('reasoning', '')
                            
                            score = ai_score / 100.0  # Normalize to 0-1
                            ai_data = {
                                'performed': True,
                                'score': score * 100,
                                'confidence': 0.85,
                                'raw': ai_json
                            }
                            
                            if ai_json.get('is_suspicious'):
                                warnings.append(f"AI: {ai_reason}")
                            else:
                                findings.append(f"AI: {ai_reason}")
                                
                        except Exception as e:
                            print(f"[URLAnalyzer] AI analysis error: {e}")
                            findings.append("Analisis AI gagal, menggunakan metode konvensional")
            else:
                warnings.append(f"Gagal akses URL (HTTP {response.status_code})")
                score = 0.3
                
        except Exception as e:
            warnings.append(f"Error akses URL: {str(e)[:50]}")
            score = 0.4
            
        return {
            'score': score,
            'findings': findings,
            'warnings': warnings,
            'ai_analysis': ai_data
        }

    # ... (Keep helper methods _check_domain_reputation, etc. as they are reliable filters) ...
    def _check_domain_reputation(self, domain: str) -> float:
        if domain in self.TRUSTED_DOMAINS:
            return self.TRUSTED_DOMAINS[domain] / 100
        parts = domain.split('.')
        for i in range(len(parts)):
            parent = '.'.join(parts[i:])
            if parent in self.TRUSTED_DOMAINS:
                return self.TRUSTED_DOMAINS[parent] / 100
        return 0.5
    
    def _check_blacklist(self, domain: str) -> Dict[str, Any]:
        for keyword in self.BLACKLISTED_DOMAINS:
            if keyword in domain.lower():
                return {'is_blacklisted': True, 'reason': keyword}
        return {'is_blacklisted': False}
    
    def _check_tld(self, domain: str) -> float:
        for tld in self.SUSPICIOUS_TLDS:
            if domain.endswith(tld): return 0.3
        return 0.8
        
    def _check_ssl(self, url: str) -> Dict[str, Any]:
        return {'has_ssl': url.startswith('https://')}
        
    def _check_domain_age(self, domain: str) -> Dict[str, Any]:
        """Check domain age via WHOIS — older domains are generally more trustworthy"""
        if whois is None:
            return {'score': 0.5}
        try:
            w = whois.whois(domain)
            creation = w.creation_date
            if isinstance(creation, list):
                creation = creation[0]
            if creation is None:
                return {'score': 0.5}
            from datetime import datetime
            age_days = (datetime.now() - creation).days
            age_years = age_days / 365.25
            # Score: <1 year = 0.2, 1-3 years = 0.5, 3-5 years = 0.7, >5 years = 0.9
            if age_years >= 5:
                score = 0.9
            elif age_years >= 3:
                score = 0.7
            elif age_years >= 1:
                score = 0.5
            else:
                score = 0.2
            return {'score': score, 'age_years': round(age_years, 1), 'creation_date': str(creation)}
        except Exception as e:
            print(f"[URLAnalyzer] WHOIS lookup failed for {domain}: {e}")
            return {'score': 0.5}

    def _check_phishing_patterns(self, url: str) -> float:
        count = 0
        if any(re.search(p, url.lower()) for p in self.PHISHING_PATTERNS): count += 1
        if url.count('.') > 3: count += 1
        return min(1.0, count * 0.3)

    def _calculate_final_score(self, domain_score, blacklist_penalty, tld_score, ssl_score, age_score, phishing_penalty, content_score):
        # Weighted formula including tld_score and age_score
        return round((domain_score * 0.25 + blacklist_penalty * 0.1 + tld_score * 0.05 + 
                      content_score * 0.35 + ssl_score * 0.1 + age_score * 0.05 + 
                      phishing_penalty * 0.1) * 100, 1)
