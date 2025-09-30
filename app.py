from flask import Flask, jsonify
from flask_cors import CORS
from routes import api_bp
from config.settings import settings

def create_app():
    app = Flask(__name__)
    
    # Configurar CORS
    CORS(app, 
         origins=['http://localhost:3000', 'http://localhost:5173', 'http://localhost:5174'],
         methods=['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
         allow_headers=['Content-Type', 'Authorization'],
         supports_credentials=True)
    
    app.register_blueprint(api_bp, url_prefix='/api')
    
    # Health check endpoint
    @app.route('/')
    @app.route('/health')
    def health_check():
        return jsonify({"status": "healthy", "service": "ChatAI Backend"}), 200
    
    return app

if __name__ == '__main__':
    app = create_app()
    app.run(host='0.0.0.0', port=5000, debug=True)
