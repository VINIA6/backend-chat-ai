#!/usr/bin/env python3
"""
Script conveniente para inicializar o banco de dados
"""

import subprocess
import sys
from pathlib import Path

def main():
    """Executa o script de inicialização do banco"""
    script_path = Path(__file__).parent / "data" / "init_database.py"
    
    try:
        # Executar o script de inicialização
        result = subprocess.run([sys.executable, str(script_path)], 
                              capture_output=False, 
                              text=True)
        return result.returncode
    except Exception as e:
        print(f"❌ Erro ao executar inicialização: {e}")
        return 1

if __name__ == "__main__":
    exit_code = main()
    sys.exit(exit_code)
