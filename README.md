# 🤖 ChatAI Backend

Backend completo para aplicação de chat com inteligência artificial, desenvolvido em Python com Flask e MongoDB.

## 🚀 Como Rodar o Projeto Localmente

### 📋 Pré-requisitos

- **Docker** instalado ([Download aqui](https://docs.docker.com/get-docker/))
- **Docker Compose** instalado (vem junto com o Docker Desktop)

### ⚡ Passo a Passo Rápido

```bash
# 1. Clone o repositório
git clone <url-do-repositorio>
cd backend-chat-ai

# 2. Configure as variáveis de ambiente
cp env.example .env
# (opcional: edite o arquivo .env se necessário)

# 3. Inicie todos os serviços
docker compose up -d --build

# 4. Verifique se os containers estão rodando
docker compose ps

# 5. Teste a API
curl http://localhost:5001/health
```

### 🎯 URLs Importantes (Local)

Após executar `docker compose up -d --build`:

- **🌐 API Backend**: http://localhost:5001
- **📊 MongoDB Admin**: http://localhost:8081 (admin/admin123)
- **🤖 N8N Workflows**: http://localhost:5678 (admin/admin123)
- **🐘 PostgreSQL**: localhost:5432 (admin/admin123)
- **🧠 Ollama LLMs**: http://localhost:11434

### 🔧 Comandos Úteis

```bash
# Ver logs em tempo real
docker compose logs -f backend

# Parar todos os serviços
docker compose down

# Reiniciar apenas o backend
docker compose restart backend

# Limpar tudo (cuidado: apaga dados!)
docker compose down -v
```

## 🏭 Sobre o Projeto

O **ChatAI Backend** é uma API RESTful robusta que gerencia conversas entre usuários e assistentes virtuais, integrando:

- **🤖 IA Local**: Modelos Gemma 3 e Gemma 2 via Ollama
- **📊 Dados Industriais**: PostgreSQL com 200.000+ registros do Observatório da Indústria
- **🔄 Workflows**: N8N para automação e integrações
- **💬 Chat Inteligente**: Sistema completo de conversas com JWT e MongoDB

## 🌐 URLs de Produção

**Servidor**: `72.60.166.177` (mesmas portas do local)

- **🌐 API Backend**: http://72.60.166.177:5001
- **📊 MongoDB Admin**: http://72.60.166.177:8081 (admin/admin123)
- **🤖 N8N Workflows**: http://72.60.166.177:5678 (admin/admin123)
- **🐘 PostgreSQL**: 72.60.166.177:5432 (admin/admin123)
- **🧠 Ollama LLMs**: http://72.60.166.177:11434

## 🗄️ Bancos de Dados

### 📊 MongoDB (Chat e Usuários)

**Local:**
- **Host**: localhost:27017
- **Database**: chatai
- **Usuário**: admin
- **Senha**: admin123
- **Admin UI**: http://localhost:8081

**Produção:**
- **Host**: 72.60.166.177:27017
- **Database**: chatai
- **Usuário**: admin
- **Senha**: admin123
- **Admin UI**: http://72.60.166.177:8081

### 🐘 PostgreSQL (Dados Industriais)

**Local:**
- **Host**: localhost:5432
- **Database**: observatorio_industria
- **Usuário**: admin
- **Senha**: admin123

**Produção:**
- **Host**: 72.60.166.177:5432
- **Database**: observatorio_industria
- **Usuário**: admin
- **Senha**: admin123

**📋 Dados Disponíveis:**
- 200.000+ registros distribuídos em 18 tabelas
- Dados de ERP (Faturamento, Notas Fiscais)
- Dados de CRM (Clientes, Oportunidades)
- Dados comerciais de campo

## 🔧 Tecnologias Principais

- **Python 3.11** + **Flask 3.0** - Backend API
- **MongoDB 7.0** - Banco de dados principal (chat/usuários)
- **PostgreSQL 15** - Banco de dados industrial (200k+ registros)
- **N8N** - Workflows e automações
- **Ollama** - IA local (Gemma 3, Gemma 2)
- **Docker** - Containerização completa

## 📡 Endpoints da API

### 🔐 Autenticação
- `POST /api/login` - Login (retorna JWT token)
- `GET /api/me` - Dados do usuário logado

### 💬 Conversas
- `GET /api/talk-user` - Lista conversas do usuário
- `POST /api/talk` - Cria nova conversa
- `PUT /api/talk` - Atualiza conversa
- `DELETE /api/talk` - Remove conversa

### 📨 Mensagens
- `GET /api/messages-by-talk` - Lista mensagens de uma conversa
- `POST /api/message` - Envia mensagem (integra com N8N)

### 🏥 Health Check
- `GET /health` - Status da API e MongoDB

## 👥 Usuários Demo

| Nome | Email | Senha | Perfil |
|------|-------|-------|--------|
| Admin User | admin@observatorio.fiec.org.br | `admin123` | Administrador |
| Maria Silva | maria.silva@observatorio.fiec.org.br | `analyst123` | Analista |
| João Santos | joao.santos@empresa.com.br | `user123` | Usuário |

## ⚙️ Configuração

### Variáveis de Ambiente

Crie um arquivo `.env` baseado no `env.example`:

```env
# Flask
FLASK_ENV=development
SECRET_KEY=your-secret-key-change-in-production

# JWT
JWT_SECRET_KEY=your-super-secret-jwt-key-change-in-production

# MongoDB
MONGODB_URI=mongodb://admin:admin123@localhost:27017/chatai?authSource=admin

# N8N Gateway
N8N_TIMEOUT=120                    # Timeout em segundos (padrão: 2 minutos)
```

## 🤖 Gateway N8N

O sistema integra com N8N para processar mensagens usando IA local:

- **Timeout**: 2 minutos (configurável via `N8N_TIMEOUT`)
- **Resposta Padronizada**: Campo `message` sempre disponível
- **Tratamento de Erros**: Gerenciamento robusto de falhas

## 🔧 Comandos Úteis

```bash
# Ver logs em tempo real
docker compose logs -f backend

# Parar todos os serviços
docker compose down

# Reiniciar apenas o backend
docker compose restart backend

# Limpar tudo (cuidado: apaga dados!)
docker compose down -v

# ⚠️ Problema com Docker Compose Legacy
# Se encontrar erro "KeyError: 'ContainerConfig'", use:
docker compose up -d --build  # (nova versão)
# Em vez de:
docker-compose up -d --build  # (versão legada)
```

## 👨‍💻 Autor
Vinícius de Assis Azevedo

---

⭐ Se este projeto foi útil para você, considere dar uma estrela!