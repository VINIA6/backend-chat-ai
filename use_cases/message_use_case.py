from repositories.message_repository import MessageRepository
from typing import List, Dict, Any
from bson import ObjectId
from datetime import datetime

class MessageUseCase:
    def __init__(self, message_repository: MessageRepository):
        self.message_repository = message_repository

    def get_messages_by_talk_and_user(self, talk_id: str, user_id: str) -> List[Dict[str, Any]]:
        """
        Retorna mensagens de uma conversa específica para um usuário específico
        """
        return self.message_repository.get_messages_by_talk_and_user(talk_id, user_id)

    def create_message(self, content: str, message_type: str, talk_id: str, user_id: str) -> Dict[str, Any]:
        """
        Cria uma nova mensagem na conversa
        """
        message_data = {
            'content': content,
            'type': message_type,
            'talk_id': ObjectId(talk_id),
            'user_id': ObjectId(user_id),
            'create_at': datetime.utcnow(),
            'update_at': datetime.utcnow(),
            'is_deleted': False
        }
        return self.message_repository.create(message_data)

    def soft_delete_by_talk_id(self, talk_id: str) -> bool:
        """
        Deleta logicamente todas as mensagens de uma conversa
        """
        return self.message_repository.soft_delete_by_talk_id(talk_id)
