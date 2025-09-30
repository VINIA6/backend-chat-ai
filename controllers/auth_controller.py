import os
import jwt
import datetime
import bcrypt
from flask import request, jsonify, g
from config.database import db_config
from auth import token_required

class AuthController:
    def login(self):
        auth = request.get_json()

        if not auth or not auth.get('username') or not auth.get('password'):
            return jsonify({'message': 'Could not verify'}), 401, {'WWW-Authenticate': 'Basic realm="Login required!"'}

        username = auth.get('username')
        password = auth.get('password')

        try:
            # Conectar ao MongoDB
            db = db_config.get_database()
            
            # Buscar usuário por email
            user = db.user.find_one({
                "email": f"{username}",
                "is_deleted": False
            })
            
            # Se não encontrar, tentar buscar só pelo nome
            if not user:
                user = db.user.find_one({
                    "name": {"$regex": username, "$options": "i"},
                    "is_deleted": False
                })
                
            # Se ainda não encontrar, tentar buscar pelo email exato
            if not user:
                user = db.user.find_one({
                    "email": username,
                    "is_deleted": False
                })

            # Verificar senha usando bcrypt
            if user and user.get('password') and bcrypt.checkpw(password.encode('utf-8'), user['password'].encode('utf-8')):
                token = jwt.encode({
                    'user': user['email'],
                    'user_id': str(user['_id']),
                    'name': user['name'],
                    'exp': datetime.datetime.utcnow() + datetime.timedelta(minutes=30)
                }, os.getenv('JWT_SECRET_KEY', 'your-super-secret-jwt-key'), algorithm='HS256')

                return jsonify({
                    'token': token,
                    'user': {
                        'id': str(user['_id']),
                        'name': user['name'],
                        'email': user['email'],
                        'setor': user['setor'],
                        'cargo': user['cargo']
                    }
                })

            return jsonify({'message': 'Could not verify'}), 401, {'WWW-Authenticate': 'Basic realm="Login required!"'}
            
        except Exception as e:
            return jsonify({'message': f'Error: {str(e)}'}), 500

    @token_required
    def get_current_user(self):
        if not g.current_user:
            return jsonify({'message': 'User not found'}), 404
        
        return jsonify(g.current_user)
