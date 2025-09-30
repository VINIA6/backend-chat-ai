# 🤖 ChatAI Backend

Backend completo para aplicação de chat com inteligência artificial, desenvolvido em Python com Flask e MongoDB.

## 📋 Sobre o Projeto

O **ChatAI Backend** é uma API RESTful robusta e escalável que gerencia conversas entre usuários e assistentes virtuais. O sistema foi construído seguindo os princípios de **Clean Architecture**, garantindo separação de responsabilidades, testabilidade e manutenibilidade do código.

### 🏭 Observatório da Indústria - Simulação de Dados

Este projeto inclui um **banco de dados PostgreSQL completo** simulando o cenário de negócios do **Observatório da Indústria**, com **200.000+ registros** distribuídos em 18 tabelas, integrando dados de:
- **ERP**: Faturamento e Notas Fiscais
- **CRM**: Gestão de Clientes e Oportunidades
- **Planilhas Manuais**: Dados do time comercial em campo

### 🤖 IA Local com Ollama

Ambiente completo com **modelos de linguagem rodando localmente**:
- **Gemma 3 1B** e **Gemma 2 2B** instalados e funcionais
- API REST para integração com Python, N8N e outros serviços
- Análise de dados, geração de relatórios e assistente SQL com IA

👉 **Documentação completa**: Ver `POSTGRES_SETUP.md`, `N8N_GUIDE.md` e `OLLAMA_GUIDE.md`

### Principais Funcionalidades

- 🔐 **Autenticação JWT** - Sistema seguro de login e gestão de tokens
- 💬 **Gerenciamento de Conversas** - CRUD completo de talks (conversas)
- 📨 **Sistema de Mensagens** - Envio e recuperação de mensagens entre usuário e bot
- 👥 **Gerenciamento de Usuários** - Perfis com informações detalhadas
- 🔄 **Soft Delete** - Deleção lógica de registros para recuperação posterior
- 🐳 **Docker Ready** - Containerização completa com Docker Compose
- 🏥 **Health Checks** - Monitoramento de saúde da aplicação e banco de dados
- 🤖 **Gateway N8N Inteligente** - Integração robusta com workflows automatizados
- ⏱️ **Timeout Configurável** - Timeouts personalizáveis para requisições longas
- 📝 **Resposta Padronizada** - Formato consistente para facilitar integração frontend

## 🛠️ Tecnologias Utilizadas

### Core
- **Python 3.11+** - Linguagem de programação
- **Flask 3.0** - Framework web minimalista e flexível
- **MongoDB 7.0** - Banco de dados NoSQL orientado a documentos
- **PyMongo** - Driver oficial do MongoDB para Python

### Segurança
- **Flask-JWT-Extended** - Autenticação e autorização via JWT
- **bcrypt** - Hash seguro de senhas
- **Flask-CORS** - Controle de Cross-Origin Resource Sharing

### Validação e Serialização
- **Marshmallow** - Serialização e validação de objetos
- **Pydantic** - Validação de dados com type hints
- **email-validator** - Validação de endereços de e-mail

### Desenvolvimento
- **pytest** - Framework de testes
- **black** - Formatador de código
- **flake8** - Linter para verificação de qualidade de código
- **isort** - Organizador de imports

### Infraestrutura
- **Docker & Docker Compose** - Containerização e orquestração
- **Gunicorn** - Servidor WSGI para produção
- **PostgreSQL 15** - Banco de dados relacional (Observatório da Indústria)
- **N8N** - Workflow automation e integrações com gateway inteligente
- **Ollama** - LLMs locais (Gemma 3, Gemma 2)
- **Mongo Express** - Interface administrativa para MongoDB

### Futuras Integrações
- **OpenAI API** - Integração com modelos de IA (GPT)
- **structlog** - Logging estruturado

## 🏗️ Arquitetura

O projeto segue os princípios de **Clean Architecture**, organizando o código em camadas bem definidas:

```
┌─────────────────────────────────────────────────────────┐
│                     Presentation                        │
│         (routes.py, controllers, auth.py)               │
├─────────────────────────────────────────────────────────┤
│                    Application                          │
│              (use_cases, business logic)                │
├─────────────────────────────────────────────────────────┤
│                      Domain                             │
│           (entities: User, Talk, Message)               │
├─────────────────────────────────────────────────────────┤
│                  Infrastructure                         │
│        (repositories, config, database.py)              │
└─────────────────────────────────────────────────────────┘
```

### Estrutura de Diretórios

```
backend-chat-ai/
│
├── app.py                      # Ponto de entrada da aplicação
├── routes.py                   # Definição de rotas da API
├── auth.py                     # Middleware de autenticação JWT
│
├── config/                     # Configurações da aplicação
│   ├── __init__.py
│   ├── settings.py            # Configurações centralizadas
│   └── database.py            # Configuração do MongoDB
│
├── entities/                   # Entidades de domínio
│   ├── __init__.py
│   ├── user.py                # Entidade User
│   ├── talk.py                # Entidade Talk (conversa)
│   └── message.py             # Entidade Message
│
├── controllers/                # Controllers da API
│   ├── auth_controller.py     # Autenticação e usuários
│   ├── talk_controller.py     # Gerenciamento de conversas
│   └── message_controller.py  # Gerenciamento de mensagens
│
├── use_cases/                  # Casos de uso/regras de negócio
│   ├── talk_use_case.py       # Lógica de negócio de talks
│   └── message_use_case.py    # Lógica de negócio de messages
│
├── repositories/               # Camada de acesso a dados
│   ├── talk_repository.py     # Repositório de talks
│   └── message_repository.py  # Repositório de messages
│
├── data/                       # Scripts de dados
│   └── init_database.py       # Inicialização do banco
│
├── utils/                      # Utilitários e helpers
│
├── gateways/                   # Gateways para integrações externas
│   ├── n8n_gateway.py         # Gateway inteligente para N8N
│   ├── test_n8n_gateway.py    # Testes do gateway N8N
│   └── GATEWAY_USAGE.md       # Documentação de uso do gateway
│
├── docker-compose.yml          # Orquestração de containers
├── Dockerfile                  # Imagem Docker da aplicação
├── requirements.txt            # Dependências Python
├── .env                        # Variáveis de ambiente (não versionado)
├── env.example                 # Exemplo de variáveis de ambiente
└── README.md                   # Esta documentação
```

### Fluxo de Dados

```
Request → Routes → Controller → Use Case → Repository → Database
                                    ↓
Response ← Routes ← Controller ← Use Case ← Repository

Integração N8N:
Controller → Gateway N8N → N8N Workflow → Ollama/PostgreSQL
                                    ↓
Response ← Controller ← Gateway N8N ← N8N Workflow
```

## 📡 Endpoints da API

### Autenticação

| Método | Endpoint | Descrição | Autenticação |
|--------|----------|-----------|--------------|
| `POST` | `/api/login` | Autentica usuário e retorna token JWT | Não |
| `GET` | `/api/me` | Retorna dados do usuário autenticado | Sim |

### Conversas (Talks)

| Método | Endpoint | Descrição | Autenticação |
|--------|----------|-----------|--------------|
| `GET` | `/api/talk-user` | Lista todas as conversas do usuário | Sim |
| `POST` | `/api/talk` | Cria nova conversa com mensagem inicial | Sim |
| `PUT` | `/api/talk` | Atualiza nome de uma conversa | Sim |
| `DELETE` | `/api/talk` | Remove uma conversa (soft delete) | Sim |

### Mensagens

| Método | Endpoint | Descrição | Autenticação |
|--------|----------|-----------|--------------|
| `GET` | `/api/messages-by-talk` | Lista mensagens de uma conversa | Sim |
| `POST` | `/api/message` | Envia nova mensagem para uma conversa | Sim |

### Health Check

| Método | Endpoint | Descrição | Autenticação |
|--------|----------|-----------|--------------|
| `GET` | `/` | Health check básico | Não |
| `GET` | `/health` | Health check com status do MongoDB | Não |
| `GET` | `/api/health` | Health check detalhado da API | Não |

## 🚀 Instalação e Execução

### Pré-requisitos

- **Docker** e **Docker Compose** (recomendado)
- **Python 3.11+** (para desenvolvimento local)
- **MongoDB 7.0+** (para desenvolvimento local sem Docker)

### Opção 1: Execução com Docker (Recomendado)

```bash
# 1. Clone o repositório
git clone <url-do-repositorio>
cd backend-chat-ai

# 2. Configure as variáveis de ambiente
cp env.example .env
# Edite o arquivo .env conforme necessário

# 3. Construir e iniciar todos os serviços
docker-compose up --build

# 4. Executar em background
docker-compose up -d --build

# 5. Parar os serviços
docker-compose down

# 6. Remover volumes (reseta banco de dados)
docker-compose down -v
```

### Opção 2: Desenvolvimento Local

```bash
# 1. Clone o repositório
git clone <url-do-repositorio>
cd backend-chat-ai

# 2. Criar ambiente virtual
python -m venv venv

# 3. Ativar ambiente virtual
source venv/bin/activate          # Linux/Mac
# ou
venv\Scripts\activate             # Windows

# 4. Instalar dependências
pip install -r requirements.txt

# 5. Configurar variáveis de ambiente
cp env.example .env
# Edite o arquivo .env conforme necessário

# 6. Inicializar banco de dados
python init_db.py

# 7. Executar aplicação
python app.py
```

### Serviços Disponíveis

Após executar com Docker Compose:

- **Backend API**: http://localhost:5001
- **MongoDB**: mongodb://localhost:27017
- **Mongo Express** (Admin UI): http://localhost:8081
  - Usuário: `admin`
  - Senha: `admin123`
- **N8N Workflows**: http://localhost:5678
  - Usuário: `admin`
  - Senha: `admin123`
- **PostgreSQL** (Observatório): localhost:5432
  - Usuário: `admin`
  - Senha: `admin123`
  - Database: `observatorio_industria`
- **Ollama LLMs**: http://localhost:11434

## ⚙️ Configuração

### Variáveis de Ambiente

Crie um arquivo `.env` baseado no `env.example`:

```env
# Flask
FLASK_ENV=development
SECRET_KEY=your-secret-key-change-in-production

# JWT
JWT_SECRET_KEY=your-super-secret-jwt-key-change-in-production
JWT_ACCESS_TOKEN_EXPIRES=86400       # 24 horas
JWT_REFRESH_TOKEN_EXPIRES=604800     # 7 dias

# MongoDB
MONGODB_URI=mongodb://admin:admin123@localhost:27017/chatai?authSource=admin
MONGODB_DATABASE=chatai

# CORS
CORS_ORIGINS=http://localhost:3000,http://localhost:5173

# OpenAI (opcional - para futuras integrações)
OPENAI_API_KEY=your-openai-api-key
OPENAI_MODEL=gpt-3.5-turbo

# N8N Gateway
N8N_TIMEOUT=120                    # Timeout em segundos (padrão: 2 minutos)

# Logging
LOG_LEVEL=INFO
```

### Configuração de Produção

Para ambiente de produção, utilize o arquivo `env.production.example` como referência e:

1. **Altere todas as chaves secretas** (`SECRET_KEY`, `JWT_SECRET_KEY`)
2. **Configure CORS** com as origens permitidas
3. **Use HTTPS** para comunicação segura
4. **Configure backup** regular do MongoDB
5. **Implemente rate limiting** em produção
6. **Monitore logs** e métricas de performance

## 👥 Dados de Demonstração

O script de inicialização cria 3 usuários de exemplo:

### Usuários Demo

| Nome | Email | Senha | Perfil |
|------|-------|-------|--------|
| Admin User | admin@observatorio.fiec.org.br | `admin123` | Administrador |
| Maria Silva | maria.silva@observatorio.fiec.org.br | `analyst123` | Analista |
| João Santos | joao.santos@empresa.com.br | `user123` | Usuário |

### Estrutura do Banco

**Collections:**
- `user` - Usuários do sistema
- `talk` - Conversas/chats dos usuários
- `message` - Mensagens dentro das conversas

**Campos Comuns:**
- `_id` - ObjectId do MongoDB (gerado automaticamente)
- `create_at` - Data de criação
- `update_at` - Data de última atualização
- `is_deleted` - Flag de soft delete

## 🤖 Gateway N8N - Integração Inteligente

### Visão Geral

O **Gateway N8N** é um componente inteligente que facilita a comunicação entre a API Flask e os workflows automatizados do N8N. Ele foi projetado para ser robusto, configurável e fácil de usar no frontend.

### ✨ Funcionalidades Principais

- **⏱️ Timeout Configurável**: Timeout padrão de 2 minutos (120s), configurável via variável de ambiente
- **📝 Resposta Padronizada**: Sempre retorna uma string única no campo `message` para facilitar o processamento no frontend
- **🔄 Processamento Inteligente**: Extrai automaticamente a mensagem de diferentes formatos de resposta do N8N
- **🛡️ Tratamento de Erros**: Gerenciamento robusto de timeouts, erros de conexão e falhas HTTP
- **🔍 Debug Completo**: Mantém dados completos no campo `data` para análise

### 📋 Formato de Resposta

```json
{
  "success": true,
  "message": "Resposta extraída do N8N como string única",
  "data": {
    "output": "Dados completos da resposta original"
  },
  "status_code": 200
}
```

### ⚙️ Configuração

```env
# Timeout do Gateway N8N (em segundos)
N8N_TIMEOUT=120                    # Padrão: 2 minutos
N8N_URL=http://observatorio_n8n:5678  # URL do N8N
```

### 🎯 Uso no Frontend

```javascript
// Simples e direto!
const response = await api.post('/api/message', {
  talk_id: "talk_123",
  content: "Mostre os dados de vendas"
});

if (response.success) {
  // Usar diretamente a string da resposta
  displayMessage(response.message);
} else {
  // Tratar erro
  showError(response.message);
}
```

### 🧪 Testando o Gateway

```bash
# Testar conexão e funcionalidade
cd gateways
python test_n8n_gateway.py

# Atualizar apenas o container backend
docker-compose up -d --build --force-recreate backend
```

### 📚 Documentação Detalhada

Para exemplos completos de uso, veja: `gateways/GATEWAY_USAGE.md`

## 🧪 Testes

```bash
# Ativar ambiente virtual
source venv/bin/activate

# Executar todos os testes
pytest

# Executar com cobertura
pytest --cov=. --cov-report=html

# Executar testes específicos
pytest tests/test_auth.py

# Testar Gateway N8N
python gateways/test_n8n_gateway.py
```

## 🔍 Desenvolvimento

### Formatação de Código

```bash
# Formatar com black
black .

# Organizar imports
isort .

# Verificar qualidade do código
flake8 .
```

### Logs e Debug

```bash
# Ver logs dos containers
docker-compose logs backend
docker-compose logs mongodb

# Logs em tempo real
docker-compose logs -f backend

# Entrar no container
docker-compose exec backend bash

# Executar comandos no MongoDB
docker-compose exec mongodb mongosh -u admin -p admin123 --authenticationDatabase admin

# Atualizar apenas o container backend (após mudanças no código)
docker-compose up -d --build --force-recreate backend

# Reiniciar apenas um serviço específico
docker-compose restart backend
docker-compose restart n8n
```

## 🐳 Docker

### Dockerfile

- **Base**: `python:3.11-slim`
- **Usuário não-root** para segurança
- **Multi-stage build** otimizado para tamanho da imagem
- **Health checks** integrados

### Docker Compose

**Serviços:**
- `mongodb` - Banco de dados principal
- `backend` - API Flask
- `db_init` - Inicialização automática do banco
- `mongo-express` - Interface administrativa (opcional)

**Volumes:**
- `mongodb_data` - Persistência de dados do MongoDB
- Bind mount do código fonte (para desenvolvimento)

**Networks:**
- `chatai_network` - Rede bridge para comunicação entre serviços

### Health Checks

- **MongoDB**: `mongosh --eval "db.adminCommand('ping')"`
- **Backend**: `curl -f http://localhost:5000/health`

## 🔐 Segurança

### Implementações de Segurança

- ✅ Senhas hasheadas com **bcrypt**
- ✅ Autenticação via **JWT tokens**
- ✅ CORS configurado para origens específicas
- ✅ Validação de inputs com Marshmallow/Pydantic
- ✅ Soft delete para recuperação de dados
- ✅ Variáveis de ambiente para credenciais
- ✅ Usuário não-root no Docker

### Recomendações para Produção

- 🔒 Use HTTPS/TLS para todas as conexões
- 🔒 Implemente rate limiting
- 🔒 Configure firewall e security groups
- 🔒 Rotacione secrets regularmente
- 🔒 Monitore tentativas de acesso não autorizado
- 🔒 Mantenha dependências atualizadas
- 🔒 Implemente backup e disaster recovery

## 📈 Melhorias Implementadas e Futuras

### ✅ Implementado Recentemente

- [x] **Gateway N8N Inteligente** - Integração robusta com workflows automatizados
- [x] **Timeout Configurável** - Timeouts personalizáveis para requisições longas (2 minutos)
- [x] **Resposta Padronizada** - Formato consistente com campo `message` único para frontend
- [x] **Processamento Inteligente** - Extração automática de mensagens de diferentes formatos
- [x] **Tratamento de Erros Robusto** - Gerenciamento completo de timeouts e falhas
- [x] **Documentação Detalhada** - Guias completos de uso e integração

### 🚀 Roadmap Futuro

- [ ] Integração com OpenAI GPT para respostas inteligentes
- [ ] Sistema de rate limiting
- [ ] Websockets para mensagens em tempo real
- [ ] Upload de arquivos/imagens
- [ ] Sistema de notificações
- [ ] Busca full-text nas conversas
- [ ] Exportação de conversas (PDF, JSON)
- [ ] Métricas e analytics
- [ ] Testes de integração e E2E
- [ ] CI/CD pipeline
- [ ] Documentação OpenAPI/Swagger
- [ ] Internacionalização (i18n)
- [ ] Cache inteligente para respostas do N8N
- [ ] Retry automático para falhas temporárias
- [ ] Monitoramento de performance do gateway

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/MinhaFeature`)
3. Commit suas mudanças (`git commit -m 'Adiciona MinhaFeature'`)
4. Push para a branch (`git push origin feature/MinhaFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo `LICENSE` para mais detalhes.

## 👨‍💻 Autor
Vinícius de Assis Azevedo

---

⭐ Se este projeto foi útil para você, considere dar uma estrela!