"""
Script de teste para o gateway N8N
Execute este script para testar se o N8N está respondendo corretamente
"""

from n8n_gateway import N8nGateway

def test_n8n_gateway():
    """
    Testa a conexão e funcionalidade do gateway N8N
    """
    print("="*60)
    print("Testando Gateway N8N")
    print("="*60)
    
    # Inicializar gateway
    gateway = N8nGateway()
    print(f"\n✓ Gateway inicializado")
    print(f"  URL: {gateway.webhook_init_url}")
    
    # Testar health check
    print("\n1. Testando health check...")
    is_healthy = gateway.check_health()
    if is_healthy:
        print("  ✓ N8N está respondendo")
    else:
        print("  ✗ N8N não está disponível")
        print("  Verifique se o N8N está rodando em http://localhost:5678")
        return
    
    # Testar envio de mensagem
    print("\n2. Testando envio de mensagem...")
    test_message = "Qual a média do valor total de vendas em 2025?"
    print(f"  Mensagem: {test_message}")
    
    response = gateway.send_chat_input(test_message)
    
    if response['success']:
        print("  ✓ Mensagem enviada com sucesso!")
        print(f"  Status Code: {response.get('status_code', 'N/A')}")
        print(f"\n  📝 Mensagem (para frontend): {response.get('message', 'N/A')}")
        print(f"\n  🔍 Dados completos (debug): {response.get('data', {})}")
    else:
        print("  ✗ Erro ao enviar mensagem")
        print(f"  Erro: {response.get('message', 'Erro desconhecido')}")
    
    print("\n" + "="*60)
    print("Teste concluído")
    print("="*60)

if __name__ == "__main__":
    test_n8n_gateway()
