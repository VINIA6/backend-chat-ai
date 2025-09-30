from repositories.talk_repository import TalkRepository
from typing import List, Dict, Any
from bson import ObjectId
from datetime import datetime

class TalkUseCase:
    def __init__(self, talk_repository: TalkRepository):
        self.talk_repository = talk_repository

    def get_talks_by_user_id(self, user_id: str) -> List[Dict[str, Any]]:
        return self.talk_repository.get_talks_by_user_id(user_id)

    def create_talk(self, name: str, user_id: str) -> Dict[str, Any]:
        """
        Cria uma nova conversa (talk) para o usuário
        """
        talk_data = {
            'name': name,
            'user_id': ObjectId(user_id),
            'create_at': datetime.utcnow(),
            'update_at': datetime.utcnow(),
            'is_deleted': False
        }
        return self.talk_repository.create(talk_data)

    def update_talk(self, talk_id: str, user_id: str, new_name: str) -> Dict[str, Any]:
        """
        Atualiza o nome de uma conversa (talk)
        """
        return self.talk_repository.update_by_id_and_user(
            talk_id=talk_id,
            user_id=user_id,
            update_data={'name': new_name, 'update_at': datetime.utcnow()}
        )

    def delete_talk(self, talk_id: str, user_id: str) -> bool:
        """
        Deleta logicamente uma conversa (talk) e suas mensagens
        """
        # 1. Deletar logicamente a conversa
        talk_deleted = self.talk_repository.soft_delete_by_id_and_user(talk_id, user_id)
        
        if talk_deleted:
            # 2. Deletar logicamente todas as mensagens da conversa
            from repositories.message_repository import MessageRepository
            from config.database import db_config
            
            message_repository = MessageRepository(db_config.get_database())
            
            # Deletar mensagens em cascata
            message_repository.soft_delete_by_talk_id(talk_id)
            
        return talk_deleted
