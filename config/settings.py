"""
Application Settings - Configurações da aplicação
"""

import os
from typing import List
from dataclasses import dataclass, field


@dataclass
class Settings:
    """Configurações centralizadas da aplicação"""
    
    # Flask
    FLASK_ENV: str = os.getenv('FLASK_ENV', 'development')
    SECRET_KEY: str = os.getenv('SECRET_KEY', 'dev-secret-key-change-in-production')
    DEBUG: bool = os.getenv('FLASK_ENV') == 'development'
    
    # JWT
    JWT_SECRET_KEY: str = os.getenv('JWT_SECRET_KEY', 'jwt-secret-key-change-in-production')
    JWT_ACCESS_TOKEN_EXPIRES: int = int(os.getenv('JWT_ACCESS_TOKEN_EXPIRES', '86400'))  # 24 horas
    JWT_REFRESH_TOKEN_EXPIRES: int = int(os.getenv('JWT_REFRESH_TOKEN_EXPIRES', '604800'))  # 7 dias
    
    # MongoDB
    MONGODB_URI: str = os.getenv('MONGODB_URI', 'mongodb://admin:admin123@localhost:27017/chatai?authSource=admin')
    MONGODB_DATABASE: str = os.getenv('MONGODB_DATABASE', 'chatai')
    
    # CORS
    CORS_ORIGINS: List[str] = field(default_factory=lambda: os.getenv('CORS_ORIGINS', 'http://localhost:3000,http://localhost:5173,http://localhost:5174').split(','))
    
    # API
    API_PREFIX: str = '/api/v1'
    
    # Pagination
    DEFAULT_PAGE_SIZE: int = 20
    MAX_PAGE_SIZE: int = 100
    
    # Chat
    MAX_MESSAGE_LENGTH: int = 4000
    MAX_CONVERSATION_TITLE_LENGTH: int = 100
    
    # File Upload
    MAX_CONTENT_LENGTH: int = 16 * 1024 * 1024  # 16MB
    
    # Logging
    LOG_LEVEL: str = os.getenv('LOG_LEVEL', 'INFO')
    
    # Rate Limiting
    RATELIMIT_DEFAULT: str = "100 per hour"
    RATELIMIT_LOGIN: str = "5 per minute"
    
    # OpenAI (para futuras integrações)
    OPENAI_API_KEY: str = os.getenv('OPENAI_API_KEY', '')
    OPENAI_MODEL: str = os.getenv('OPENAI_MODEL', 'gpt-3.5-turbo')
    
    @property
    def is_development(self) -> bool:
        """Verifica se está em ambiente de desenvolvimento"""
        return self.FLASK_ENV == 'development'
    
    @property
    def is_production(self) -> bool:
        """Verifica se está em ambiente de produção"""
        return self.FLASK_ENV == 'production'
    
    @property
    def is_testing(self) -> bool:
        """Verifica se está em ambiente de teste"""
        return self.FLASK_ENV == 'testing'


# Instância global das configurações
settings = Settings()
