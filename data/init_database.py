#!/usr/bin/env python3
"""
Inicialização completa do banco de dados ChatAI
Paridade com o script JavaScript original
"""

import os
import sys
from datetime import datetime
from pathlib import Path
from bson import ObjectId

# Configurar path e environment
project_root = Path(__file__).parent.parent
sys.path.insert(0, str(project_root))

from dotenv import load_dotenv
load_dotenv(project_root / 'env.example')

from config.database import db_config
from entities.user import User
from entities.talk import Talk  
from entities.message import Message


def create_database_user(db):
    """Cria usuário da aplicação no banco"""
    try:
        # Verificar se usuário já existe
        try:
            db.command("usersInfo", "chatai_user")
            print("ℹ️  Usuário 'chatai_user' já existe")
        except:
            # Criar usuário se não existir
            db.command("createUser", 
                      "chatai_user",
                      pwd="chatai_password",
                      roles=[{"role": "readWrite", "db": "chatai"}])
            print("✅ Usuário 'chatai_user' criado com sucesso")
    except Exception as e:
        print(f"⚠️  Aviso ao criar usuário: {e}")


def create_collections(db):
    """Cria as coleções principais"""
    collections = ['user', 'talk', 'message']
    
    for collection_name in collections:
        if collection_name not in db.list_collection_names():
            db.create_collection(collection_name)
            print(f"✅ Coleção '{collection_name}' criada")
        else:
            print(f"ℹ️  Coleção '{collection_name}' já existe")


def create_indexes(db):
    """Cria índices para performance"""
    print("📊 Criando índices...")
    
    # Índices para user
    db.user.create_index([("email", 1)], unique=True)
    db.user.create_index([("cpf", 1)], unique=True)
    db.user.create_index([("create_at", 1)])
    db.user.create_index([("is_deleted", 1)])
    
    # Índices para talk
    db.talk.create_index([("user_id", 1), ("create_at", -1)])
    db.talk.create_index([("update_at", -1)])
    db.talk.create_index([("is_deleted", 1)])
    
    # Índices para message
    db.message.create_index([("talk_id", 1), ("create_at", 1)])
    db.message.create_index([("user_id", 1), ("create_at", -1)])
    db.message.create_index([("is_deleted", 1)])
    
    print("✅ Índices criados")


def insert_demo_users(db):
    """Insere usuários demo"""
    print("👥 Inserindo usuários demo...")
    
    # ObjectIds fixos para referências consistentes
    user_id_1 = ObjectId("64a1b2c3d4e5f6789a0b1c2d")
    user_id_2 = ObjectId("64a1b2c3d4e5f6789a0b1c2e")
    user_id_3 = ObjectId("64a1b2c3d4e5f6789a0b1c2f")
    
    # Verificar se usuários já existem
    existing_users = db.user.count_documents({"is_deleted": False})
    if existing_users > 0:
        print(f"ℹ️  {existing_users} usuários já existem no banco")
        return user_id_1, user_id_2, user_id_3
    
    demo_users = [
        {
            "_id": user_id_1,
            "name": "Administrador FIEC",
            "idade": 35,
            "setor": "Observatório da Indústria",
            "cargo": "Administrador",
            "cpf": "12345678901",
            "email": "admin@observatorio.fiec.org.br",
            "password": "$2b$12$PfdIBqe/3YuXAb1Y3bdE2uQ5PeErK2neBeyLqR/WeezVa5HTHHClG",  # admin123
            "create_at": datetime(2024, 1, 1),
            "update_at": datetime.utcnow(),
            "is_deleted": False
        },
        {
            "_id": user_id_2,
            "name": "Maria Silva",
            "idade": 28,
            "setor": "Análise de Dados",
            "cargo": "Analista Sênior",
            "cpf": "23456789012",
            "email": "maria.silva@observatorio.fiec.org.br",
            "password": "$2b$12$gTV9Sx3gtjG4yW8mBkERKuEvSMyHQdGfq6YOPlE/2XkSkO5wJ7aE.",  # analyst123
            "create_at": datetime(2024, 1, 15),
            "update_at": datetime.utcnow(),
            "is_deleted": False
        },
        {
            "_id": user_id_3,
            "name": "João Santos",
            "idade": 42,
            "setor": "Comercial",
            "cargo": "Gerente Comercial",
            "cpf": "34567890123",
            "email": "joao.santos@empresa.com.br",
            "password": "$2b$12$LMjihNPcq6n1sZwz44tXTeo5Bu5foHkv0KYnBtbu6IjX.jUloWQ0a",  # user123
            "create_at": datetime(2024, 2, 1),
            "update_at": datetime.utcnow(),
            "is_deleted": False
        }
    ]
    
    try:
        result = db.user.insert_many(demo_users)
        print(f"✅ {len(result.inserted_ids)} usuários demo inseridos")
        return user_id_1, user_id_2, user_id_3
    except Exception as e:
        print(f"❌ Erro ao inserir usuários demo: {e}")
        return user_id_1, user_id_2, user_id_3


def insert_demo_talks(db, user_id_2, user_id_3):
    """Insere conversas demo"""
    print("💬 Inserindo conversas demo...")
    
    # ObjectIds fixos para talks
    talk_id_1 = ObjectId("6750b1a1f4e2d3a4b5c6d7e8")
    talk_id_2 = ObjectId("6750b1a1f4e2d3a4b5c6d7e9")
    
    existing_talks = db.talk.count_documents({"is_deleted": False})
    if existing_talks > 0:
        print(f"ℹ️  {existing_talks} conversas já existem no banco")
        return talk_id_1, talk_id_2
    
    demo_talks = [
        {
            "_id": talk_id_1,
            "name": "Consulta sobre dados industriais",
            "user_id": user_id_2,
            "create_at": datetime(2024, 2, 15),
            "update_at": datetime(2024, 2, 15),
            "is_deleted": False
        },
        {
            "_id": talk_id_2,
            "name": "Análise de mercado",
            "user_id": user_id_3,
            "create_at": datetime(2024, 2, 16),
            "update_at": datetime(2024, 2, 16),
            "is_deleted": False
        }
    ]
    
    try:
        result = db.talk.insert_many(demo_talks)
        print(f"✅ {len(result.inserted_ids)} conversas demo inseridas")
        return talk_id_1, talk_id_2
    except Exception as e:
        print(f"❌ Erro ao inserir conversas demo: {e}")
        return talk_id_1, talk_id_2


def insert_demo_messages(db, talk_id_1, talk_id_2, user_id_2, user_id_3):
    """Insere mensagens demo"""
    print("📨 Inserindo mensagens demo...")
    
    existing_messages = db.message.count_documents({"is_deleted": False})
    if existing_messages > 0:
        print(f"ℹ️  {existing_messages} mensagens já existem no banco")
        return
    
    demo_messages = [
        {
            "_id": ObjectId(),
            "type": "user",
            "content": "Olá, preciso de dados sobre a indústria têxtil no Ceará",
            "talk_id": talk_id_1,
            "user_id": user_id_2,
            "create_at": datetime(2024, 2, 15, 10, 0, 0),
            "update_at": datetime(2024, 2, 15, 10, 0, 0),
            "is_deleted": False
        },
        {
            "_id": ObjectId(),
            "type": "bot",
            "content": "Olá! Posso ajudá-lo com dados sobre a indústria têxtil. Temos informações atualizadas sobre produção, empregos e exportações do setor no Ceará.",
            "talk_id": talk_id_1,
            "user_id": user_id_2,
            "create_at": datetime(2024, 2, 15, 10, 0, 30),
            "update_at": datetime(2024, 2, 15, 10, 0, 30),
            "is_deleted": False
        },
        {
            "_id": ObjectId(),
            "type": "user",
            "content": "Como está o mercado para novos produtos?",
            "talk_id": talk_id_2,
            "user_id": user_id_3,
            "create_at": datetime(2024, 2, 16, 14, 30, 0),
            "update_at": datetime(2024, 2, 16, 14, 30, 0),
            "is_deleted": False
        },
        {
            "_id": ObjectId(),
            "type": "bot",
            "content": "O mercado para novos produtos está em crescimento. Posso fornecer análises específicas por setor e tendências de consumo.",
            "talk_id": talk_id_2,
            "user_id": user_id_3,
            "create_at": datetime(2024, 2, 16, 14, 30, 45),
            "update_at": datetime(2024, 2, 16, 14, 30, 45),
            "is_deleted": False
        }
    ]
    
    try:
        result = db.message.insert_many(demo_messages)
        print(f"✅ {len(result.inserted_ids)} mensagens demo inseridas")
    except Exception as e:
        print(f"❌ Erro ao inserir mensagens demo: {e}")


def print_summary(db, user_ids, talk_ids):
    """Imprime resumo da inicialização"""
    print("\n" + "="*60)
    print("🎉 BANCO DE DADOS CHATAI INICIALIZADO COM SUCESSO!")
    print("="*60)
    
    # Contar documentos
    user_count = db.user.count_documents({"is_deleted": False})
    talk_count = db.talk.count_documents({"is_deleted": False})
    message_count = db.message.count_documents({"is_deleted": False})
    
    print(f"📊 Estatísticas:")
    print(f"   👥 Usuários: {user_count}")
    print(f"   💬 Conversas: {talk_count}")
    print(f"   📨 Mensagens: {message_count}")
    
    print(f"\n🏗️  Estrutura:")
    print(f"   - user: _id ObjectId (chave primária)")
    print(f"   - talk: _id ObjectId, user_id ObjectId (ref user._id)")
    print(f"   - message: _id ObjectId, talk_id ObjectId, user_id ObjectId")
    
    print(f"\n🔑 IDs Demo:")
    print(f"   User 1 (Admin): {user_ids[0]}")
    print(f"   User 2 (Maria): {user_ids[1]}")
    print(f"   User 3 (João): {user_ids[2]}")
    print(f"   Talk 1: {talk_ids[0]}")
    print(f"   Talk 2: {talk_ids[1]}")
    
    print(f"\n🔐 Credenciais Demo:")
    print(f"   admin@observatorio.fiec.org.br - senha: admin123")
    print(f"   maria.silva@observatorio.fiec.org.br - senha: analyst123")
    print(f"   joao.santos@empresa.com.br - senha: user123")
    
    print("="*60)


def main():
    """Função principal"""
    print("🚀 Inicializando banco de dados ChatAI...")
    
    try:
        # Conectar ao banco
        db = db_config.connect()
        print("✅ Conectado ao MongoDB")
        
        # Verificar conexão
        if not db_config.health_check():
            raise Exception("Health check do MongoDB falhou")
        
        # Executar inicialização
        create_database_user(db)
        create_collections(db)
        create_indexes(db)
        
        # Inserir dados demo
        user_ids = insert_demo_users(db)
        talk_ids = insert_demo_talks(db, user_ids[1], user_ids[2])
        insert_demo_messages(db, talk_ids[0], talk_ids[1], user_ids[1], user_ids[2])
        
        # Resumo
        print_summary(db, user_ids, talk_ids)
        
        return 0
        
    except Exception as e:
        print(f"❌ Erro: {e}")
        return 1
    
    finally:
        db_config.disconnect()


if __name__ == "__main__":
    exit_code = main()
    sys.exit(exit_code)