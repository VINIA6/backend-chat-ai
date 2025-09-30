from bson import ObjectId
from pymongo.database import Database
from typing import List, Dict, Any, Optional

class TalkRepository:
    def __init__(self, db: Database):
        self.db = db
        self.collection = db.get_collection('talk')

    def get_talks_by_user_id(self, user_id: str) -> List[Dict[str, Any]]:
        return list(self.collection.find({'user_id': ObjectId(user_id), 'is_deleted': False}))

    def get_by_id(self, talk_id: str) -> Optional[Dict[str, Any]]:
        return self.collection.find_one({'_id': ObjectId(talk_id), 'is_deleted': False})

    def create(self, talk_data: Dict[str, Any]) -> Dict[str, Any]:
        result = self.collection.insert_one(talk_data)
        talk_data['_id'] = result.inserted_id
        return talk_data

    def update(self, talk_id: str, talk_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        self.collection.update_one({'_id': ObjectId(talk_id)}, {'$set': talk_data})
        return self.get_by_id(talk_id)

    def delete(self, talk_id: str) -> bool:
        result = self.collection.update_one({'_id': ObjectId(talk_id)}, {'$set': {'is_deleted': True}})
        return result.modified_count > 0

    def update_by_id_and_user(self, talk_id: str, user_id: str, update_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """
        Atualiza uma conversa específica de um usuário específico
        """
        result = self.collection.update_one(
            {'_id': ObjectId(talk_id), 'user_id': ObjectId(user_id), 'is_deleted': False},
            {'$set': update_data}
        )
        if result.modified_count > 0:
            return self.get_by_id(talk_id)
        return None

    def soft_delete_by_id_and_user(self, talk_id: str, user_id: str) -> bool:
        """
        Deleta logicamente uma conversa específica de um usuário específico
        """
        from datetime import datetime
        result = self.collection.update_one(
            {'_id': ObjectId(talk_id), 'user_id': ObjectId(user_id), 'is_deleted': False},
            {'$set': {'is_deleted': True, 'update_at': datetime.utcnow()}}
        )
        return result.modified_count > 0
