"""
Base Analyzer - Abstract base class for all analyzers
"""
from abc import ABC, abstractmethod
from dataclasses import dataclass, field
from typing import List, Dict, Any, Optional
from datetime import datetime
import json


@dataclass
class AnalysisResult:
    """Data class untuk hasil analisis"""
    score: float  # 0-100
    confidence: float  # 0-1
    status: str  # 'kredibel', 'cukup_kredibel', 'perlu_perhatian', 'tidak_kredibel'
    status_color: str  # hex color
    findings: List[str] = field(default_factory=list)
    warnings: List[str] = field(default_factory=list)
    metadata: Dict[str, Any] = field(default_factory=dict)
    analysis_time: float = 0.0
    timestamp: str = field(default_factory=lambda: datetime.now().isoformat())
    
    def to_dict(self) -> Dict[str, Any]:
        return {
            'score': round(self.score, 1),
            'confidence': round(self.confidence, 3),
            'status': self.status,
            'status_color': self.status_color,
            'findings': self.findings,
            'warnings': self.warnings,
            'metadata': self.metadata,
            'analysis_time': round(self.analysis_time, 3),
            'timestamp': self.timestamp
        }
    
    def to_json(self) -> str:
        return json.dumps(self.to_dict(), ensure_ascii=False, indent=2)
    
    @staticmethod
    def get_status_from_score(score: float) -> tuple:
        """Return (status, color) based on score"""
        if score >= 80:
            return ('kredibel', '#4ECDC4')  # Green/Teal
        elif score >= 60:
            return ('cukup_kredibel', '#4ECDC4')  # Teal
        elif score >= 40:
            return ('perlu_perhatian', '#FFD93D')  # Yellow
        else:
            return ('tidak_kredibel', '#FF6B6B')  # Red


class BaseAnalyzer(ABC):
    """Abstract base class untuk semua analyzer"""
    
    def __init__(self, name: str):
        self.name = name
        self.is_initialized = False
        self.model = None
    
    @abstractmethod
    def initialize(self) -> bool:
        """Initialize model dan resources"""
        pass
    
    @abstractmethod
    def analyze(self, content: Any) -> AnalysisResult:
        """Analyze content dan return hasil"""
        pass
    
    def _create_result(
        self,
        score: float,
        confidence: float,
        findings: List[str] = None,
        warnings: List[str] = None,
        metadata: Dict[str, Any] = None,
        analysis_time: float = 0.0
    ) -> AnalysisResult:
        """Helper untuk membuat AnalysisResult"""
        status, color = AnalysisResult.get_status_from_score(score)
        
        return AnalysisResult(
            score=score,
            confidence=confidence,
            status=status,
            status_color=color,
            findings=findings or [],
            warnings=warnings or [],
            metadata=metadata or {},
            analysis_time=analysis_time
        )
    
    def get_status(self) -> Dict[str, Any]:
        """Get analyzer status"""
        return {
            'name': self.name,
            'initialized': self.is_initialized,
            'model_loaded': self.model is not None
        }
