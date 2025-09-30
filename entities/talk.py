"""
Talk Entity - Entidade de conversa do domínio
"""

from dataclasses import dataclass
from datetime import datetime
from typing import Optional
from bson import ObjectId


@dataclass
class Talk:
    """Entidade Talk representando uma conversa do usuário"""
    
    name: str
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
    
    def update_name(self, new_name: str):
        """Atualiza o nome da conversa"""
        self.name = new_name.strip()
        self.update_at = datetime.utcnow()
    
    def delete(self):
        """Marca a conversa como deletada (soft delete)"""
        self.is_deleted = True
        self.update_at = datetime.utcnow()
    
    def restore(self):
        """Restaura a conversa deletada"""
        self.is_deleted = False
        self.update_at = datetime.utcnow()
    
    def to_dict(self) -> dict:
        """Converte a entidade para dicionário"""
        return {
            'name': self.name,
            'user_id': self.user_id,
            'create_at': self.create_at.isoformat() if self.create_at else None,
            'update_at': self.update_at.isoformat() if self.update_at else None,
            'is_deleted': self.is_deleted,
        }
    
    @classmethod
    def from_dict(cls, data: dict) -> 'Talk':
        """Cria uma instância Talk a partir de um dicionário"""
        return cls(
            name=data['name'],
            user_id=data['user_id'],
            create_at=datetime.fromisoformat(data['create_at']) if data.get('create_at') else None,
            update_at=datetime.fromisoformat(data['update_at']) if data.get('update_at') else None,
            is_deleted=data.get('is_deleted', False),
        )
