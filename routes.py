from flask import Blueprint, jsonify
from controllers.auth_controller import AuthController
from controllers.talk_controller import TalkController
from controllers.message_controller import MessageController
from auth import token_required
from config.database import db_config

api_bp = Blueprint('api', __name__)

# Instanciando controllers
auth_controller = AuthController()
talk_controller = TalkController()
message_controller = MessageController()

# Rotas
@api_bp.route('/login', methods=['POST'])
def login():
    return auth_controller.login()

@api_bp.route('/me', methods=['GET'])
def get_current_user():
    return auth_controller.get_current_user()

@api_bp.route('/talk-user', methods=['GET'])
def get_talks_by_user():
    return talk_controller.get_talks_by_user()

@api_bp.route('/messages-by-talk', methods=['GET'])
def get_messages_by_talk():
    return message_controller.get_messages_by_talk()

@api_bp.route('/message', methods=['POST'])
def send_message():
    return message_controller.send_message_to_talk()

@api_bp.route('/talk', methods=['POST'])
def create_talk():
    return talk_controller.create_talk_with_message()

@api_bp.route('/talk', methods=['PUT'])
def update_talk():
    return talk_controller.update_talk()

@api_bp.route('/talk', methods=['DELETE'])
def delete_talk():
    return talk_controller.delete_talk()


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


