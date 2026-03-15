"""
Verysense ML Configuration
"""
import os
from dotenv import load_dotenv

load_dotenv()

class Config:
    # Server Settings
    HOST = os.getenv('HOST', '0.0.0.0')
    PORT = int(os.getenv('PORT', 5000))
    DEBUG = os.getenv('DEBUG', 'True').lower() == 'true'
    
    # Model Paths
    MODEL_DIR = os.path.join(os.path.dirname(__file__), 'models', 'trained')
    
    # Text Analysis Settings
    TEXT_MODEL_NAME = 'indobenchmark/indobert-base-p1'  
    MAX_TEXT_LENGTH = 512
    
    # Image Analysis Settings
    IMAGE_MODEL_NAME = 'microsoft/resnet-50'
    MAX_IMAGE_SIZE = (1024, 1024)
    
    # Video Analysis Settings
    VIDEO_FRAME_SAMPLE_RATE = 30  
    MAX_VIDEO_DURATION = 300  
    
    # URL Analysis Settings
    TRUSTED_DOMAINS = [
        'kompas.com', 'detik.com', 'tempo.co', 'cnnindonesia.com',
        'bbc.com', 'reuters.com', 'apnews.com', 'liputan6.com',
        'tribunnews.com', 'antaranews.com', 'mediaindonesia.com'
    ]
    
    SUSPICIOUS_PATTERNS = [
        'hoax', 'viral', 'geger', 'heboh', 'terbongkar', 'rahasia',
        'mengejutkan', 'tidak disangka', 'shock', 'ternyata'
    ]
    
    # Credibility Score Weights
    WEIGHTS = {
        'text_analysis': 0.35,
        'source_credibility': 0.25,
        'fact_check': 0.25,
        'metadata_analysis': 0.15
    }
