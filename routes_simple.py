from flask import Blueprint, request, jsonify
from config.database import db_config
import bcrypt

api_bp = Blueprint('api', __name__)

@api_bp.route('/login', methods=['POST'])
def login():
    """Endpoint de login simples"""
    try:
        data = request.get_json()
        
        if not data or not data.get('username') or not data.get('password'):
            return jsonify({"error": "Username e password são obrigatórios"}), 400
        
        username = data['username']
        password = data['password']
        
        # Conectar ao MongoDB
        db = db_config.get_database()
        
        # Buscar usuário por email
        user = db.user.find_one({
            "email": f"{username}@observatorio.fiec.org.br",
            "is_deleted": False
        })
        
        # Se não encontrar, tentar buscar só pelo nome
        if not user:
            user = db.user.find_one({
                "name": {"$regex": username, "$options": "i"},
                "is_deleted": False
            })
        
        if not user:
            return jsonify({"error": "Usuário não encontrado"}), 401
        
        # Verificar senha (simplificado para demo)
        if password == "admin123":  # Demo password
            return jsonify({
                "message": "Login realizado com sucesso",
                "user": {
                    "id": str(user["_id"]),
                    "name": user["name"],
                    "email": user["email"],
                    "setor": user["setor"],
                    "cargo": user["cargo"]
                },
                "token": "demo-jwt-token-12345"
            }), 200
        else:
            return jsonify({"error": "Senha incorreta"}), 401
            
    except Exception as e:
        return jsonify({"error": f"Erro interno: {str(e)}"}), 500

@api_bp.route('/health', methods=['GET'])
def health():
    """Health check da API"""
    try:
        # Testar conexão com MongoDB
        db = db_config.get_database()
        if db is not None:
            db.command('ping')
            return jsonify({
                "status": "healthy",
                "database": "connected",
                "service": "ChatAI API"
            }), 200
        else:
            return jsonify({
                "status": "unhealthy",
                "database": "disconnected",
                "error": "Database connection is None"
            }), 500
    except Exception as e:
        return jsonify({
            "status": "unhealthy",
            "database": "disconnected",
            "error": str(e)
        }), 500
