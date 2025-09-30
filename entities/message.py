"""
Message Entity - Entidade de mensagem do domínio
"""

from dataclasses import dataclass
from datetime import datetime
from typing import Optional
from bson import ObjectId


@dataclass
class Message:
    """Entidade Message representando uma mensagem na conversa"""
    
    type: str  # "user" ou "bot"
    content: str
    talk_id: ObjectId
    user_id: ObjectId
    create_at: Optional[datetime] = None
    update_at: Optional[datetime] = None
    is_deleted: bool = False
    
    def __post_init__(self):
        """Inicializar campos de data se não fornecidos"""
        if self.create_at is None:
            self.create_at = datetime.utcnow()
        if self.update_at is None:
            self.update_at = datetime.utcnow()
    
    def is_user_message(self) -> bool:
        """Verifica se é uma mensagem do usuário"""
        return self.type == "user"
    
    def is_bot_message(self) -> bool:
        """Verifica se é uma mensagem do bot"""
        return self.type == "bot"
    
    def update_content(self, new_content: str):
        """Atualiza o conteúdo da mensagem"""
        self.content = new_content
        self.update_at = datetime.utcnow()
    
    def delete(self):
        """Marca a mensagem como deletada (soft delete)"""
        self.is_deleted = True
        self.update_at = datetime.utcnow()
    
    def restore(self):
        """Restaura a mensagem deletada"""
        self.is_deleted = False
        self.update_at = datetime.utcnow()
    
    def get_word_count(self) -> int:
        """Retorna o número de palavras na mensagem"""
        return len(self.content.split()) if self.content else 0
    
    def get_char_count(self) -> int:
        """Retorna o número de caracteres na mensagem"""
        return len(self.content) if self.content else 0
    
    def to_dict(self) -> dict:
        """Converte a entidade para dicionário"""
        return {
            'type': self.type,
            'content': self.content,
            'talk_id': self.talk_id,
            'user_id': self.user_id,
            'create_at': self.create_at.isoformat() if self.create_at else None,
            'update_at': self.update_at.isoformat() if self.update_at else None,
            'is_deleted': self.is_deleted,
        }
    
    @classmethod
    def from_dict(cls, data: dict) -> 'Message':
        """Cria uma instância Message a partir de um dicionário"""
        return cls(
            type=data['type'],
            content=data['content'],
            talk_id=data['talk_id'],
            user_id=data['user_id'],
            create_at=datetime.fromisoformat(data['create_at']) if data.get('create_at') else None,
            update_at=datetime.fromisoformat(data['update_at']) if data.get('update_at') else None,
            is_deleted=data.get('is_deleted', False),
        )
