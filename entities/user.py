"""
User Entity - Entidade de usuário do domínio
"""

from dataclasses import dataclass
from datetime import datetime
from typing import Optional


@dataclass
class User:
    """Entidade User representando um usuário do sistema
    
    Nota: O _id do MongoDB será o próprio ObjectId
    """
    
    name: str
    idade: int
    setor: str
    cargo: str
    cpf: str
    email: str
    password: str
    create_at: Optional[datetime] = None
    update_at: Optional[datetime] = None
    is_deleted: bool = False
    
    def __post_init__(self):
        """Inicializar campos de data se não fornecidos"""
        if self.create_at is None:
            self.create_at = datetime.utcnow()
        if self.update_at is None:
            self.update_at = datetime.utcnow()
    
    def delete(self):
        """Marca o usuário como deletado (soft delete)"""
        self.is_deleted = True
        self.update_at = datetime.utcnow()
    
    def restore(self):
        """Restaura o usuário deletado"""
        self.is_deleted = False
        self.update_at = datetime.utcnow()
    
    def update_info(self, **kwargs):
        """Atualiza informações do usuário"""
        for key, value in kwargs.items():
            if hasattr(self, key) and key not in ['create_at']:
                setattr(self, key, value)
        self.update_at = datetime.utcnow()
    
    def to_dict(self) -> dict:
        """Converte a entidade para dicionário (sem senha)"""
        return {
            'name': self.name,
            'idade': self.idade,
            'setor': self.setor,
            'cargo': self.cargo,
            'cpf': self.cpf,
            'email': self.email,
            'create_at': self.create_at.isoformat() if self.create_at else None,
            'update_at': self.update_at.isoformat() if self.update_at else None,
            'is_deleted': self.is_deleted,
        }
    
    @classmethod
    def from_dict(cls, data: dict) -> 'User':
        """Cria uma instância User a partir de um dicionário"""
        return cls(
            name=data['name'],
            idade=data['idade'],
            setor=data['setor'],
            cargo=data['cargo'],
            cpf=data['cpf'],
            email=data['email'],
            password=data['password'],
            create_at=datetime.fromisoformat(data['create_at']) if data.get('create_at') else None,
            update_at=datetime.fromisoformat(data['update_at']) if data.get('update_at') else None,
            is_deleted=data.get('is_deleted', False),
        )
