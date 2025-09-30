#!/bin/bash

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║        🤖 Instalador de Modelos Ollama                      ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "Escolha qual modelo deseja instalar:"
echo ""
echo "1) TinyLlama 1.1B    (637 MB)  - Mais leve, respostas rápidas"
echo "2) Phi 2.7B          (1.6 GB)  - Equilibrado, boa qualidade"
echo "3) Gemma2 2B         (1.6 GB)  - Google, boa qualidade"
echo "4) Llama 3.2 3B      (2.0 GB)  - Meta, muito bom"
echo "5) Todos os leves    (1-3)     - Instala TinyLlama, Phi e Gemma2"
echo "6) Cancelar"
echo ""
read -p "Digite sua escolha (1-6): " choice

case $choice in
    1)
        echo ""
        echo "📦 Baixando TinyLlama 1.1B (637 MB)..."
        docker exec observatorio_ollama ollama pull tinyllama:1.1b
        echo "✅ TinyLlama instalado!"
        ;;
    2)
        echo ""
        echo "📦 Baixando Phi 2.7B (1.6 GB)..."
        docker exec observatorio_ollama ollama pull phi:2.7b
        echo "✅ Phi instalado!"
        ;;
    3)
        echo ""
        echo "📦 Baixando Gemma2 2B (1.6 GB)..."
        docker exec observatorio_ollama ollama pull gemma2:2b
        echo "✅ Gemma2 instalado!"
        ;;
    4)
        echo ""
        echo "📦 Baixando Llama 3.2 3B (2.0 GB)..."
        docker exec observatorio_ollama ollama pull llama3.2:3b
        echo "✅ Llama 3.2 instalado!"
        ;;
    5)
        echo ""
        echo "📦 Baixando TinyLlama 1.1B (637 MB)..."
        docker exec observatorio_ollama ollama pull tinyllama:1.1b
        echo ""
        echo "📦 Baixando Phi 2.7B (1.6 GB)..."
        docker exec observatorio_ollama ollama pull phi:2.7b
        echo ""
        echo "📦 Baixando Gemma2 2B (1.6 GB)..."
        docker exec observatorio_ollama ollama pull gemma2:2b
        echo "✅ Todos os modelos leves instalados!"
        ;;
    6)
        echo "❌ Cancelado."
        exit 0
        ;;
    *)
        echo "❌ Opção inválida."
        exit 1
        ;;
esac

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║        ✅ Instalação Concluída!                             ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "📋 Modelos instalados:"
docker exec observatorio_ollama ollama list
echo ""
echo "🔍 Para testar um modelo:"
echo "   docker exec -it observatorio_ollama ollama run tinyllama:1.1b"
echo ""
echo "📚 Documentação completa: OLLAMA_GUIDE.md"
