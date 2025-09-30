#!/bin/bash

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║          🔍 DIAGNÓSTICO COMPLETO DO N8N                      ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# 1. Verificar se container está rodando
echo "1️⃣  Verificando container N8N..."
if docker ps | grep -q observatorio_n8n; then
    echo "   ✅ Container está rodando"
else
    echo "   ❌ Container NÃO está rodando"
    echo "   Execute: docker-compose up -d n8n"
    exit 1
fi

# 2. Verificar status
echo ""
echo "2️⃣  Status do container:"
docker-compose ps n8n

# 3. Verificar logs recentes
echo ""
echo "3️⃣  Últimas linhas dos logs:"
docker logs observatorio_n8n --tail 10 2>&1

# 4. Verificar conectividade interna
echo ""
echo "4️⃣  Verificando conectividade com outros serviços..."

# PostgreSQL
if docker exec observatorio_n8n ping -c 1 postgres &>/dev/null; then
    echo "   ✅ N8N → PostgreSQL: OK"
else
    echo "   ❌ N8N → PostgreSQL: FALHOU"
fi

# Ollama
if docker exec observatorio_n8n ping -c 1 ollama &>/dev/null; then
    echo "   ✅ N8N → Ollama: OK"
else
    echo "   ❌ N8N → Ollama: FALHOU"
fi

# Backend
if docker exec observatorio_n8n ping -c 1 backend &>/dev/null; then
    echo "   ✅ N8N → Backend: OK"
else
    echo "   ⚠️  N8N → Backend: FALHOU (pode ser normal)"
fi

# 5. Testar API do N8N
echo ""
echo "5️⃣  Testando API do N8N..."
if curl -s http://localhost:5678/ &>/dev/null; then
    echo "   ✅ API N8N está acessível em http://localhost:5678"
else
    echo "   ❌ API N8N NÃO está acessível"
fi

# 6. Verificar variáveis de ambiente críticas
echo ""
echo "6️⃣  Variáveis de ambiente importantes:"
docker inspect observatorio_n8n | grep -A 50 "Env" | grep -E "WEBHOOK_URL|N8N_RUNNERS|EXECUTIONS_MODE" | sed 's/^/   /'

# 7. Verificar porta
echo ""
echo "7️⃣  Verificando porta 5678:"
if netstat -tuln 2>/dev/null | grep -q ":5678" || ss -tuln 2>/dev/null | grep -q ":5678"; then
    echo "   ✅ Porta 5678 está ABERTA"
else
    echo "   ⚠️  Não foi possível verificar a porta"
fi

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║          📋 POSSÍVEIS PROBLEMAS NO WORKFLOW                  ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "Se o N8N está rodando mas você NÃO consegue ativar o workflow:"
echo ""
echo "❌ PROBLEMA COMUM #1: Nó sem configuração"
echo "   → Clique em cada nó e verifique se tem campos vazios (*)"
echo "   → Webhook DEVE ter um PATH (ex: /meu-webhook)"
echo ""
echo "❌ PROBLEMA COMUM #2: Credenciais não configuradas"
echo "   → Vá em Settings > Credentials"
echo "   → Crie credenciais para PostgreSQL e Ollama"
echo "   → PostgreSQL: host=postgres, user=admin, pass=admin123, db=observatorio_industria"
echo "   → Ollama: URL=http://ollama:11434"
echo ""
echo "❌ PROBLEMA COMUM #3: Nós desconectados"
echo "   → Verifique se TODOS os nós têm linhas conectando eles"
echo "   → Não pode ter nó solto"
echo ""
echo "❌ PROBLEMA COMUM #4: Teste antes de ativar"
echo "   → Clique em 'Execute Workflow' primeiro"
echo "   → Veja se há erros"
echo "   → Corrija os erros"
echo "   → Só depois tente ativar"
echo ""
echo "📚 Documentação:"
echo "   • N8N_WEBHOOK_TROUBLESHOOTING.md"
echo "   • N8N_GUIDE.md"
echo ""
echo "🧪 Teste rápido - Criar workflow mínimo:"
echo "   1. Webhook (GET, path: /teste)"
echo "   2. Respond to Webhook"
echo "   3. Conecte os dois"
echo "   4. Salve e ative"
echo "   5. Teste: curl http://localhost:5678/webhook/teste"
echo ""
echo "✅ Se o teste acima funcionar, o problema está no SEU workflow!"
echo ""
