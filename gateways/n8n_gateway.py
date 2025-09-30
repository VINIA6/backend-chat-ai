import requests
import logging
import os
from typing import Dict, Any, Optional

logger = logging.getLogger(__name__)

class N8nGateway:
    """
    Gateway para comunicação com o n8n via webhook
    
    IMPORTANTE: Quando rodando dentro do Docker, use o nome do container (observatorio_n8n)
    para comunicação interna entre containers na mesma rede.
    """
    
    def __init__(self, base_url: str = None):
        """
        Inicializa o gateway do n8n
        
        Args:
            base_url: URL base do n8n. Se None, usa variável de ambiente N8N_URL
                     ou padrão 'http://observatorio_n8n:5678' para Docker
        """
        if base_url is None:
            # Prioridade: variável de ambiente > nome do container Docker > localhost
            base_url = os.getenv('N8N_URL', 'http://observatorio_n8n:5678')
        
        self.base_url = base_url
        self.webhook_init_url = f"{base_url}/webhook-test/n8n/init"
        
        logger.info(f"N8nGateway inicializado com URL: {self.base_url}")
    
    def send_chat_input(self, chat_input: str, timeout: int = 30) -> Dict[str, Any]:
        """
        Envia uma mensagem para o webhook do n8n
        
        Args:
            chat_input: Texto da mensagem do usuário
            timeout: Timeout da requisição em segundos (padrão: 30)
            
        Returns:
            Dict contendo a resposta do n8n
            
        Raises:
            Exception: Se houver erro na comunicação com o n8n
        """
        try:
            payload = {
                "chatInput": chat_input
            }
            
            logger.info(f"Enviando mensagem para n8n: {chat_input[:50]}...")
            
            response = requests.post(
                self.webhook_init_url,
                json=payload,
                timeout=timeout,
                headers={'Content-Type': 'application/json'}
            )
            
            # Verificar se a resposta foi bem-sucedida
            response.raise_for_status()
            
            # Tentar parsear a resposta JSON
            try:
                response_data = response.json()
                logger.info(f"Resposta recebida do n8n com sucesso")
                return {
                    'success': True,
                    'data': response_data,
                    'status_code': response.status_code
                }
            except ValueError:
                # Se não for JSON, retornar o texto da resposta
                logger.warning("Resposta do n8n não é JSON válido")
                return {
                    'success': True,
                    'data': {'response': response.text},
                    'status_code': response.status_code
                }
                
        except requests.exceptions.Timeout:
            error_msg = f"Timeout ao conectar com n8n (>{timeout}s)"
            logger.error(error_msg)
            return {
                'success': False,
                'error': error_msg,
                'data': None
            }
            
        except requests.exceptions.ConnectionError:
            error_msg = "Erro de conexão com n8n. Verifique se o serviço está rodando."
            logger.error(error_msg)
            return {
                'success': False,
                'error': error_msg,
                'data': None
            }
            
        except requests.exceptions.HTTPError as e:
            error_msg = f"Erro HTTP do n8n: {e.response.status_code} - {e.response.text}"
            logger.error(error_msg)
            return {
                'success': False,
                'error': error_msg,
                'status_code': e.response.status_code,
                'data': None
            }
            
        except Exception as e:
            error_msg = f"Erro inesperado ao comunicar com n8n: {str(e)}"
            logger.error(error_msg)
            return {
                'success': False,
                'error': error_msg,
                'data': None
            }
    
    def check_health(self) -> bool:
        """
        Verifica se o n8n está disponível
        
        Returns:
            bool: True se o n8n está respondendo, False caso contrário
        """
        try:
            response = requests.get(self.base_url, timeout=5)
            return response.status_code in [200, 302, 404]  # 404 pode ser ok se a rota raiz não existir
        except Exception as e:
            logger.error(f"n8n health check falhou: {str(e)}")
            return False
