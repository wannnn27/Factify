"""
Verysense API - Flask REST API untuk verifikasi informasi
"""
import os
import io
import base64
import tempfile
from flask import Flask, request, jsonify
from flask_cors import CORS
from werkzeug.utils import secure_filename
from dotenv import load_dotenv
import warnings
warnings.filterwarnings("ignore")

# Load env from parent directory if not found in current
current_dir = os.path.dirname(os.path.abspath(__file__))
parent_dir = os.path.dirname(current_dir)
env_path = os.path.join(parent_dir, '.env')

if os.path.exists(env_path):
    print(f"Loading .env from {env_path}")
    load_dotenv(env_path)
else:
    print("Loading .env from default location")
    load_dotenv()

from models.verification_engine import VerificationEngine, ContentType, VerificationRequest


# Initialize Flask app
app = Flask(__name__)

# CORS - restrict to known origins
CORS(app, origins=[
    "http://localhost:*",
    "http://127.0.0.1:*",
    "https://arwnsyh-factify-models.hf.space",
])

# Rate Limiting (graceful fallback if flask-limiter not installed)
try:
    from flask_limiter import Limiter
    from flask_limiter.util import get_remote_address
    limiter = Limiter(
        get_remote_address,
        app=app,
        default_limits=["60 per minute"],
        storage_uri="memory://",
    )
    print("[App] Rate limiting enabled: 60 req/min")
except ImportError:
    limiter = None
    print("[App] flask-limiter not installed, rate limiting disabled")

# Configuration
app.config['MAX_CONTENT_LENGTH'] = 50 * 1024 * 1024  # 50MB max
app.config['UPLOAD_FOLDER'] = tempfile.gettempdir()

ALLOWED_IMAGE_EXTENSIONS = {'png', 'jpg', 'jpeg', 'gif', 'webp', 'bmp'}
ALLOWED_VIDEO_EXTENSIONS = {'mp4', 'avi', 'mov', 'webm', 'mkv'}

# Initialize verification engine (lazy load for faster startup)
engine = VerificationEngine(lazy_load=True)


def allowed_file(filename: str, allowed_extensions: set) -> bool:
    """Check if file extension is allowed"""
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in allowed_extensions


@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'service': 'Verysense ML API',
        'version': '1.0.0'
    })


@app.route('/status', methods=['GET'])
def get_status():
    """Get engine status"""
    return jsonify(engine.get_status())


@app.route('/verify/text', methods=['POST'])
def verify_text():
    """
    Verify text content
    
    Request body:
    {
        "text": "content to verify..."
    }
    """
    try:
        data = request.get_json()
        
        if not data or 'text' not in data:
            return jsonify({'error': 'Missing text field'}), 400
        
        text = data['text']
        
        if not text or not text.strip():
            return jsonify({'error': 'Text cannot be empty'}), 400
        
        if len(text) > 50000:  
            return jsonify({'error': 'Text too long (max 50000 characters)'}), 400
        
        result = engine.verify_text(text)
        
        return jsonify(result.to_dict())
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/verify/url', methods=['POST'])
def verify_url():
    """
    Verify URL/website
    
    Request body:
    {
        "url": "https://example.com/article"
    }
    """
    try:
        data = request.get_json()
        
        if not data or 'url' not in data:
            return jsonify({'error': 'Missing url field'}), 400
        
        url = data['url']
        
        if not url or not url.strip():
            return jsonify({'error': 'URL cannot be empty'}), 400
        
        # Basic URL validation
        if not url.startswith(('http://', 'https://')):
            url = 'https://' + url
        
        result = engine.verify_url(url)
        
        return jsonify(result.to_dict())
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/verify/image', methods=['POST'])
def verify_image():
    """
    Verify image for manipulation
    
    Accepts:
    - multipart/form-data with 'image' file
    - JSON with 'image_base64' (base64 encoded image)
    - JSON with 'image_url' (URL to image)
    """
    try:
        # Check for file upload
        if 'image' in request.files:
            file = request.files['image']
            
            if file.filename == '':
                return jsonify({'error': 'No file selected'}), 400
            
            if not allowed_file(file.filename, ALLOWED_IMAGE_EXTENSIONS):
                return jsonify({'error': 'Invalid file type'}), 400
            
            # Read image bytes
            image_bytes = file.read()
            result = engine.verify_image(image_bytes)
            
        # Check for base64 encoded image
        elif request.is_json:
            data = request.get_json()
            
            if 'image_base64' in data:
                image_data = data['image_base64']
                # Remove data URL prefix if present
                if ',' in image_data:
                    image_data = image_data.split(',')[1]
                
                image_bytes = base64.b64decode(image_data)
                result = engine.verify_image(image_bytes)
                
            elif 'image_url' in data:
                # Download and verify image from URL
                import requests
                response = requests.get(data['image_url'], timeout=30)
                response.raise_for_status()
                
                image_bytes = response.content
                result = engine.verify_image(image_bytes)
                
            else:
                return jsonify({'error': 'No image provided'}), 400
        else:
            return jsonify({'error': 'Invalid request format'}), 400
        
        return jsonify(result.to_dict())
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/verify/video', methods=['POST'])
def verify_video():
    """
    Verify video for deepfake/manipulation
    
    Accepts:
    - multipart/form-data with 'video' file
    - JSON with 'video_url' (URL to video)
    """
    try:
        # Check for file upload
        if 'video' in request.files:
            file = request.files['video']
            
            if file.filename == '':
                return jsonify({'error': 'No file selected'}), 400
            
            if not allowed_file(file.filename, ALLOWED_VIDEO_EXTENSIONS):
                return jsonify({'error': 'Invalid file type'}), 400
            
            # Save to temp file
            filename = secure_filename(file.filename)
            temp_path = os.path.join(app.config['UPLOAD_FOLDER'], filename)
            file.save(temp_path)
            
            try:
                result = engine.verify_video(temp_path)
            finally:
                # Cleanup temp file
                if os.path.exists(temp_path):
                    os.remove(temp_path)
            
        # Check for video URL
        elif request.is_json:
            data = request.get_json()
            
            if 'video_url' in data:
                result = engine.verify_video(data['video_url'])
            else:
                return jsonify({'error': 'No video provided'}), 400
        else:
            return jsonify({'error': 'Invalid request format'}), 400
        
        return jsonify(result.to_dict())
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/challenge/evaluate', methods=['POST'])
def evaluate_challenge():
    """
    Evaluate user challenge answer
    
    Request body:
    {
        "case": {
            "topic": "...",
            "title": "...",
            "problem": "...",
            "solution": "..." 
        },
        "user_answer": "...",
        "user_sources": "..."
    }
    """
    try:
        data = request.get_json()
        
        if not data or 'case' not in data or 'user_answer' not in data:
            return jsonify({'error': 'Missing required fields'}), 400
            
        result = engine.evaluate_challenge(
            data['case'],
            data['user_answer'],
            data.get('user_sources', '')
        )
        
        return jsonify(result)
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.route('/chat', methods=['POST'])
def chat():
    """
    Chat endpoint for Facti Assistant
    
    Request body:
    {
        "message": "Halo",
        "history": [
            {"role": "user", "text": "Hi"},
            {"role": "model", "text": "Halo! Ada yang bisa saya bantu?"}
        ]
    }
    """
    try:
        data = request.get_json()
        
        if not data or 'message' not in data:
            return jsonify({'error': 'Missing message field'}), 400
            
        message = data['message']
        history = data.get('history', [])
        
        # Call chat engine
        response_text = engine.chat(message, history)
        
        return jsonify({
            'status': 'success',
            'response': response_text
        })
        
    except Exception as e:
        print(f"Chat Endpoint Error: {e}")
        return jsonify({'error': str(e)}), 500


@app.route('/verify', methods=['POST'])
def verify_auto():
    """
    Auto-detect content type and verify
    
    Request body:
    {
        "content_type": "text|url|image|video",
        "content": "...",  // for text/url
        "content_base64": "...",  // for image (optional)
        "content_url": "..."  // for image/video from URL (optional)
    }
    """
    try:
        data = request.get_json()
        
        if not data or 'content_type' not in data:
            return jsonify({'error': 'Missing content_type field'}), 400
        
        content_type = data['content_type'].lower()
        
        if content_type == 'text':
            if 'content' not in data:
                return jsonify({'error': 'Missing content field'}), 400
            result = engine.verify_text(data['content'])
            
        elif content_type == 'url':
            if 'content' not in data:
                return jsonify({'error': 'Missing content field'}), 400
            result = engine.verify_url(data['content'])
            
        elif content_type == 'image':
            if 'content_base64' in data:
                image_data = data['content_base64']
                if ',' in image_data:
                    image_data = image_data.split(',')[1]
                image_bytes = base64.b64decode(image_data)
                result = engine.verify_image(image_bytes)
            elif 'content_url' in data:
                import requests
                response = requests.get(data['content_url'], timeout=30)
                image_bytes = response.content
                result = engine.verify_image(image_bytes)
            else:
                return jsonify({'error': 'Missing image content'}), 400
                
        elif content_type == 'video':
            if 'content_url' in data:
                result = engine.verify_video(data['content_url'])
            else:
                return jsonify({'error': 'Video verification requires content_url'}), 400
        else:
            return jsonify({'error': f'Unknown content type: {content_type}'}), 400
        
        return jsonify(result.to_dict())
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500


@app.errorhandler(413)
def too_large(e):
    return jsonify({'error': 'File too large (max 50MB)'}), 413


@app.errorhandler(500)
def internal_error(e):
    return jsonify({'error': 'Internal server error'}), 500


if __name__ == '__main__':
    import argparse
    
    parser = argparse.ArgumentParser(description='Verysense ML API Server')
    parser.add_argument('--host', default='0.0.0.0', help='Host to bind')
    parser.add_argument('--port', type=int, default=5000, help='Port to bind')
    parser.add_argument('--debug', action='store_true', help='Debug mode')
    parser.add_argument('--preload', action='store_true', help='Preload all models')
    
    args = parser.parse_args()
    
    if args.preload:
        print("Preloading all models...")
        status = engine.initialize_all()
        print(f"Models loaded: {status}")
    
    print(f"Starting Verysense API on {args.host}:{args.port}")
    app.run(host=args.host, port=args.port, debug=args.debug)
