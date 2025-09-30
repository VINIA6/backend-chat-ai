from flask import jsonify, g, request
from use_cases.talk_use_case import TalkUseCase
from use_cases.message_use_case import MessageUseCase
from repositories.talk_repository import TalkRepository
from repositories.message_repository import MessageRepository
from config.database import db_config
from auth import token_required
from bson import json_util
import json
from gateways.n8n_gateway import N8nGateway

class TalkController:
    def __init__(self):
        db = db_config.get_database()
        talk_repository = TalkRepository(db)
        message_repository = MessageRepository(db)
        self.talk_use_case = TalkUseCase(talk_repository)
        self.message_use_case = MessageUseCase(message_repository)
        self.n8n_gateway = N8nGateway()

    @token_required
    def get_talks_by_user(self):
        try:
            user_id = g.current_user.get('user_id')
            if not user_id:
                return jsonify({'message': 'User ID not found in token'}), 400

            talks = self.talk_use_case.get_talks_by_user_id(user_id)
            
            # Convert ObjectId to string for JSON serialization
            talks_json = json.loads(json_util.dumps(talks))

            return jsonify(talks_json), 200
        except Exception as e:
            return jsonify({'message': f'An error occurred: {str(e)}'}), 500

    @token_required
    def create_talk_with_message(self):
        """
        Cria uma nova conversa (talk) e envia a primeira mensagem com resposta do bot
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

            message = data.get('message')
            if not message:
                return jsonify({'message': 'Message is required'}), 400

            # Gerar nome da conversa baseado na primeira mensagem
            talk_name = message[:50] + '...' if len(message) > 50 else message

            # 1. Criar a conversa (talk)
            talk = self.talk_use_case.create_talk(talk_name, user_id)
            talk_id = str(talk['_id'])

            # 2. Criar mensagem do usuário
            user_message = self.message_use_case.create_message(
                content=message,
                message_type='user',
                talk_id=talk_id,
                user_id=user_id
            )

            # 3. Enviar para o n8n e obter resposta
            n8n_response = self.n8n_gateway.send_chat_input(message)
            
            # 4. Processar resposta do n8n
            if n8n_response['success']:
                # Extrair a resposta do n8n
                n8n_data = n8n_response.get('data', {})
                # Tentar extrair a resposta do campo 'output' ou 'response' ou usar o data completo
                bot_response = n8n_data.get('output', n8n_data.get('response', str(n8n_data)))
            else:
                # Se falhar, usar mensagem de erro amigável
                bot_response = f"Desculpe, não consegui processar sua mensagem no momento. Erro: {n8n_response.get('error', 'Erro desconhecido')}"
            
            # 5. Criar mensagem do bot com a resposta
            bot_message = self.message_use_case.create_message(
                content=bot_response,
                message_type='bot',
                talk_id=talk_id,
                user_id=user_id
            )

            # 6. Buscar todas as mensagens da conversa para retornar
            all_messages = self.message_use_case.get_messages_by_talk_and_user(talk_id, user_id)
            messages_json = json.loads(json_util.dumps(all_messages))

            # 7. Retornar resposta com dados da conversa e mensagens
            response = {
                'talk': {
                    'talk_id': talk_id,
                    'name': talk_name,
                    'created_at': talk['create_at'].isoformat()
                },
                'messages': messages_json,
                'n8n_status': 'success' if n8n_response['success'] else 'error'
            }

            return jsonify(response), 201

        except Exception as e:
            return jsonify({'message': f'An error occurred: {str(e)}'}), 500

    @token_required
    def update_talk(self):
        """
        Atualiza o nome de uma conversa (talk)
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
            new_name = data.get('name')

            if not talk_id:
                return jsonify({'message': 'talk_id is required'}), 400
            if not new_name:
                return jsonify({'message': 'name is required'}), 400

            # Atualizar a conversa
            updated_talk = self.talk_use_case.update_talk(talk_id, user_id, new_name)
            
            if not updated_talk:
                return jsonify({'message': 'Talk not found or access denied'}), 404

            return jsonify({
                'message': 'Talk updated successfully',
                'talk': {
                    'talk_id': str(updated_talk['_id']),
                    'name': updated_talk['name'],
                    'updated_at': updated_talk['update_at'].isoformat()
                }
            }), 200

        except Exception as e:
            return jsonify({'message': f'An error occurred: {str(e)}'}), 500

    @token_required
    def delete_talk(self):
        """
        Deleta logicamente uma conversa (talk) e suas mensagens
        """
        try:
            # Pegar user_id do token JWT
            user_id = g.current_user.get('user_id')
            if not user_id:
                return jsonify({'message': 'User ID not found in token'}), 400

            # Pegar talk_id da URL
            talk_id = request.args.get('talk_id')
            if not talk_id:
                return jsonify({'message': 'talk_id is required'}), 400

            # Deletar a conversa e suas mensagens
            deleted = self.talk_use_case.delete_talk(talk_id, user_id)
            
            if not deleted:
                return jsonify({'message': 'Talk not found or access denied'}), 404

            return jsonify({
                'message': 'Talk and its messages deleted successfully'
            }), 200

        except Exception as e:
            return jsonify({'message': f'An error occurred: {str(e)}'}), 500
