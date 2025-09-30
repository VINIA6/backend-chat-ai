"""
PostgreSQL Configuration - Configuração do PostgreSQL para Observatório da Indústria
"""

from sqlalchemy import create_engine, text
from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy.pool import QueuePool
from typing import Optional, Generator
import structlog

from .settings import settings

logger = structlog.get_logger(__name__)


class PostgresConfig:
    """Configuração e conexão com PostgreSQL"""
    
    def __init__(self):
        self._engine = None
        self._session_factory = None
    
    def get_engine(self):
        """Retorna a engine do SQLAlchemy"""
        if not self._engine:
            logger.info("Criando engine do PostgreSQL", 
                       host=settings.POSTGRES_HOST,
                       database=settings.POSTGRES_DB)
            
            self._engine = create_engine(
                settings.postgres_uri,
                poolclass=QueuePool,
                pool_size=10,
                max_overflow=20,
                pool_pre_ping=True,
                pool_recycle=3600,
                echo=settings.is_development  # Log SQL em desenvolvimento
            )
            
            # Testa conexão
            with self._engine.connect() as conn:
                conn.execute(text("SELECT 1"))
            
            logger.info("Engine do PostgreSQL criada com sucesso")
        
        return self._engine
    
    def get_session_factory(self):
        """Retorna a factory de sessões"""
        if not self._session_factory:
            engine = self.get_engine()
            self._session_factory = sessionmaker(
                bind=engine,
                autocommit=False,
                autoflush=False,
                expire_on_commit=False
            )
        return self._session_factory
    
    def get_session(self) -> Generator[Session, None, None]:
        """
        Generator que fornece uma sessão do SQLAlchemy
        
        Uso:
        with postgres_config.get_session() as session:
            result = session.execute(text("SELECT * FROM empresas_clientes"))
        """
        SessionFactory = self.get_session_factory()
        session = SessionFactory()
        try:
            yield session
            session.commit()
        except Exception as e:
            session.rollback()
            logger.error("Erro na sessão do PostgreSQL", error=str(e))
            raise
        finally:
            session.close()
    
    def health_check(self) -> bool:
        """Verifica se a conexão com o banco está saudável"""
        try:
            engine = self.get_engine()
            with engine.connect() as conn:
                conn.execute(text("SELECT 1"))
            return True
        except Exception as e:
            logger.error("Health check do PostgreSQL falhou", error=str(e))
            return False
    
    def get_database_info(self) -> dict:
        """Retorna informações sobre o banco de dados"""
        try:
            engine = self.get_engine()
            
            info = {
                'database': settings.POSTGRES_DB,
                'host': settings.POSTGRES_HOST,
                'port': settings.POSTGRES_PORT
            }
            
            with engine.connect() as conn:
                # Versão do PostgreSQL
                result = conn.execute(text("SELECT version()"))
                version = result.scalar()
                info['version'] = version
                
                # Número de tabelas
                result = conn.execute(text("""
                    SELECT COUNT(*) 
                    FROM information_schema.tables 
                    WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
                """))
                info['total_tables'] = result.scalar()
                
                # Tamanho do banco
                result = conn.execute(text("""
                    SELECT pg_size_pretty(pg_database_size(current_database()))
                """))
                info['database_size'] = result.scalar()
            
            return info
            
        except Exception as e:
            logger.error("Erro ao obter informações do banco", error=str(e))
            return {}
    
    def get_table_stats(self) -> dict:
        """Retorna estatísticas das tabelas"""
        try:
            engine = self.get_engine()
            stats = {}
            
            with engine.connect() as conn:
                # Lista todas as tabelas
                result = conn.execute(text("""
                    SELECT table_name 
                    FROM information_schema.tables 
                    WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
                    ORDER BY table_name
                """))
                
                tables = [row[0] for row in result]
                
                # Para cada tabela, obtém a contagem de registros
                for table in tables:
                    try:
                        count_result = conn.execute(text(f"SELECT COUNT(*) FROM {table}"))
                        count = count_result.scalar()
                        stats[table] = {
                            'count': count
                        }
                    except Exception as e:
                        logger.warning(f"Erro ao contar registros da tabela {table}", error=str(e))
                        stats[table] = {'count': 0, 'error': str(e)}
            
            return stats
            
        except Exception as e:
            logger.error("Erro ao obter estatísticas das tabelas", error=str(e))
            return {}
    
    def execute_query(self, query: str, params: dict = None) -> list:
        """
        Executa uma query SQL e retorna os resultados
        
        Args:
            query: Query SQL a ser executada
            params: Parâmetros da query (opcional)
        
        Returns:
            Lista de dicionários com os resultados
        """
        try:
            engine = self.get_engine()
            
            with engine.connect() as conn:
                if params:
                    result = conn.execute(text(query), params)
                else:
                    result = conn.execute(text(query))
                
                # Converte para lista de dicionários
                columns = result.keys()
                rows = []
                for row in result:
                    rows.append(dict(zip(columns, row)))
                
                return rows
                
        except Exception as e:
            logger.error("Erro ao executar query", query=query, error=str(e))
            raise
    
    def close(self):
        """Fecha as conexões com o banco"""
        if self._engine:
            self._engine.dispose()
            self._engine = None
            self._session_factory = None
            logger.info("Conexões com PostgreSQL encerradas")


# Instância global da configuração do PostgreSQL
postgres_config = PostgresConfig()
