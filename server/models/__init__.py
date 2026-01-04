"""
Verysense ML Models Package
"""
# Lazy imports to avoid circular dependencies
__all__ = [
    'BaseAnalyzer',
    'TextAnalyzer', 
    'URLAnalyzer',
    'ImageAnalyzer',
    'VideoAnalyzer',
    'VerificationEngine'
]

def __getattr__(name):
    if name == 'BaseAnalyzer':
        from .base_model import BaseAnalyzer
        return BaseAnalyzer
    elif name == 'TextAnalyzer':
        from .text_analyzer import TextAnalyzer
        return TextAnalyzer
    elif name == 'URLAnalyzer':
        from .url_analyzer import URLAnalyzer
        return URLAnalyzer
    elif name == 'ImageAnalyzer':
        from .image_analyzer import ImageAnalyzer
        return ImageAnalyzer
    elif name == 'VideoAnalyzer':
        from .video_analyzer import VideoAnalyzer
        return VideoAnalyzer
    elif name == 'VerificationEngine':
        from .verification_engine import VerificationEngine
        return VerificationEngine
    raise AttributeError(f"module {__name__!r} has no attribute {name!r}")
