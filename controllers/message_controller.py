from flask import jsonify, g, request
from use_cases.message_use_case import MessageUseCase
from repositories.message_repository import MessageRepository
from config.database import db_config
from auth import token_required
from bson import json_util
import json

class MessageController:
    def __init__(self):
        db = db_config.get_database()
        message_repository = MessageRepository(db)
        self.message_use_case = MessageUseCase(message_repository)

    @token_required
    def get_messages_by_talk(self):
        try:
            # Pegar user_id do token JWT
            user_id = g.current_user.get('user_id')
            if not user_id:
                return jsonify({'message': 'User ID not found in token'}), 400

            # Pegar talk_id da query string
            talk_id = request.args.get('talk_id')
            if not talk_id:
                return jsonify({'message': 'talk_id is required as query parameter'}), 400

            # Buscar mensagens
            messages = self.message_use_case.get_messages_by_talk_and_user(talk_id, user_id)
            
            # Convert ObjectId to string for JSON serialization
            messages_json = json.loads(json_util.dumps(messages))

            return jsonify(messages_json), 200
        except Exception as e:
            return jsonify({'message': f'An error occurred: {str(e)}'}), 500

    @token_required
    def send_message_to_talk(self):
        """
        Envia uma mensagem para uma conversa existente e retorna a resposta do bot
        """
        try:
            # Pegar user_id do token JWT
            user_id = g.current_user.get('user_id')
            if not user_id:
                return jsonify({'message': 'User ID not found in token'}), 400

            # Pegar dados da requisição
            data = request.get_json()
            if not data:
                return jsonify({'message': 'Request body is required'}), 400

            talk_id = data.get('talk_id')
            content = data.get('content')
            message_type = data.get('type', 'user')

            if not talk_id:
                return jsonify({'message': 'talk_id is required'}), 400
            if not content:
                return jsonify({'message': 'content is required'}), 400

            # 1. Criar mensagem do usuário
            user_message = self.message_use_case.create_message(
                content=content,
                message_type=message_type,
                talk_id=talk_id,
                user_id=user_id
            )

            # 2. Criar resposta do bot
            bot_response = "Aguardando fluxo n8n ser implementado."
            bot_message = self.message_use_case.create_message(
                content=bot_response,
                message_type='bot',
                talk_id=talk_id,
                user_id=user_id
            )

            # 3. Buscar todas as mensagens da conversa para retornar
            all_messages = self.message_use_case.get_messages_by_talk_and_user(talk_id, user_id)
            messages_json = json.loads(json_util.dumps(all_messages))

            # 4. Retornar resposta com as mensagens
            response = {
                'messages': messages_json
            }

            return jsonify(response), 201

        except Exception as e:
            return jsonify({'message': f'An error occurred: {str(e)}'}), 500
