"""
Entities - Camada de entidades do domínio

Esta camada contém as entidades de negócio fundamentais do sistema.
As entidades representam objetos de negócio e não devem depender de
frameworks externos ou detalhes de implementação.
"""

from .user import User
from .talk import Talk
from .message import Message

__all__ = ['User', 'Talk', 'Message']
