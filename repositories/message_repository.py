from bson import ObjectId
from pymongo.database import Database
from typing import List, Dict, Any, Optional

class MessageRepository:
    def __init__(self, db: Database):
        self.db = db
        self.collection = db.get_collection('message')

    def get_messages_by_talk_and_user(self, talk_id: str, user_id: str) -> List[Dict[str, Any]]:
        """
        Busca mensagens por talk_id e user_id, ordenadas por data de criação
        """
        return list(self.collection.find({
            'talk_id': ObjectId(talk_id), 
            'user_id': ObjectId(user_id),
            'is_deleted': False
        }).sort('create_at', 1))

    def get_by_id(self, message_id: str) -> Optional[Dict[str, Any]]:
        return self.collection.find_one({'_id': ObjectId(message_id), 'is_deleted': False})

    def create(self, message_data: Dict[str, Any]) -> Dict[str, Any]:
        result = self.collection.insert_one(message_data)
        message_data['_id'] = result.inserted_id
        return message_data

    def update(self, message_id: str, message_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        self.collection.update_one({'_id': ObjectId(message_id)}, {'$set': message_data})
        return self.get_by_id(message_id)

    def delete(self, message_id: str) -> bool:
        result = self.collection.update_one({'_id': ObjectId(message_id)}, {'$set': {'is_deleted': True}})
        return result.modified_count > 0

    def soft_delete_by_talk_id(self, talk_id: str) -> bool:
        """
        Deleta logicamente todas as mensagens de uma conversa
        """
        from datetime import datetime
        result = self.collection.update_many(
            {'talk_id': ObjectId(talk_id), 'is_deleted': False},
            {'$set': {'is_deleted': True, 'update_at': datetime.utcnow()}}
        )
        return result.modified_count > 0
