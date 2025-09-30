"""
Configuration - Camada de configuração da aplicação

Esta camada contém todas as configurações da aplicação,
incluindo configurações de banco de dados, JWT, CORS, etc.
"""

from .database import db_config
from .settings import settings

def get_database_connection():
    """Retorna conexão com o banco de dados"""
    db_config.connect()  # Garante que está conectado
    return db_config._client

def get_settings():
    """Retorna as configurações da aplicação"""
    return settings

__all__ = ['db_config', 'settings', 'get_database_connection', 'get_settings']
