"""
Database Configuration - Configuração do banco de dados
"""

from pymongo import MongoClient
from pymongo.database import Database
from typing import Optional
import structlog

from .settings import settings

logger = structlog.get_logger(__name__)


class DatabaseConfig:
    """Configuração e conexão com MongoDB"""
    
    def __init__(self):
        self._client: Optional[MongoClient] = None
        self._database: Optional[Database] = None
    
    def connect(self) -> Database:
        """Conecta ao MongoDB e retorna a instância do banco"""
        try:
            if not self._client:
                logger.info("Conectando ao MongoDB", uri=settings.MONGODB_URI.replace(
                    settings.MONGODB_URI.split('@')[0].split('//')[1], "***:***"
                ))
                
                self._client = MongoClient(
                    settings.MONGODB_URI,
                    serverSelectionTimeoutMS=5000,  # 5 segundos timeout
                    connectTimeoutMS=5000,
                    socketTimeoutMS=5000,
                    maxPoolSize=50,
                    minPoolSize=5,
                    maxIdleTimeMS=30000,
                )
                
                # Testar conexão
                self._client.admin.command('ping')
                logger.info("Conexão com MongoDB estabelecida com sucesso")
            
            if not self._database:
                self._database = self._client[settings.MONGODB_DATABASE]
                logger.info("Database selecionado", database=settings.MONGODB_DATABASE)
            
            return self._database
            
        except Exception as e:
            logger.error("Erro ao conectar com MongoDB", error=str(e))
            raise
    
    def disconnect(self):
        """Desconecta do MongoDB"""
        if self._client:
            self._client.close()
            self._client = None
            self._database = None
            logger.info("Conexão com MongoDB encerrada")
    
    def get_database(self) -> Database:
        """Retorna a instância do banco de dados"""
        if self._database is None:
            return self.connect()
        return self._database
    
    def health_check(self) -> bool:
        """Verifica se a conexão com o banco está saudável"""
        try:
            if not self._client:
                return False
            
            # Ping no servidor
            self._client.admin.command('ping')
            return True
            
        except Exception as e:
            logger.error("Health check do MongoDB falhou", error=str(e))
            return False
    
    def get_collections_info(self) -> dict:
        """Retorna informações sobre as coleções"""
        try:
            db = self.get_database()
            collections = db.list_collection_names()
            
            info = {}
            for collection_name in collections:
                collection = db[collection_name]
                info[collection_name] = {
                    'count': collection.count_documents({}),
                    'indexes': list(collection.list_indexes())
                }
            
            return info
            
        except Exception as e:
            logger.error("Erro ao obter informações das coleções", error=str(e))
            return {}


# Instância global da configuração do banco
db_config = DatabaseConfig()
