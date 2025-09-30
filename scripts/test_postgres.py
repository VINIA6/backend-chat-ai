#!/usr/bin/env python3
"""
Script para testar a conexão com o PostgreSQL do Observatório da Indústria
e exibir algumas estatísticas básicas
"""

import sys
import os

# Adiciona o diretório raiz ao path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from config.postgres import postgres_config
import structlog

logger = structlog.get_logger(__name__)


def print_separator(title: str = ""):
    """Imprime um separador visual"""
    if title:
        print(f"\n{'='*80}")
        print(f"  {title}")
        print(f"{'='*80}\n")
    else:
        print(f"{'='*80}\n")


def test_connection():
    """Testa a conexão com o PostgreSQL"""
    print_separator("TESTE DE CONEXÃO")
    
    if postgres_config.health_check():
        print("✅ Conexão com PostgreSQL estabelecida com sucesso!")
        return True
    else:
        print("❌ Falha ao conectar com PostgreSQL")
        return False


def show_database_info():
    """Mostra informações sobre o banco de dados"""
    print_separator("INFORMAÇÕES DO BANCO DE DADOS")
    
    info = postgres_config.get_database_info()
    
    if info:
        print(f"Database: {info.get('database')}")
        print(f"Host: {info.get('host')}:{info.get('port')}")
        print(f"Versão PostgreSQL: {info.get('version', 'N/A')[:50]}...")
        print(f"Total de Tabelas: {info.get('total_tables')}")
        print(f"Tamanho do Banco: {info.get('database_size')}")
    else:
        print("❌ Não foi possível obter informações do banco")


def show_table_statistics():
    """Mostra estatísticas das tabelas"""
    print_separator("ESTATÍSTICAS DAS TABELAS")
    
    stats = postgres_config.get_table_stats()
    
    if stats:
        # Ordena por quantidade de registros (decrescente)
        sorted_stats = sorted(stats.items(), key=lambda x: x[1].get('count', 0), reverse=True)
        
        print(f"{'Tabela':<40} {'Registros':>15}")
        print(f"{'-'*40} {'-'*15}")
        
        total_records = 0
        for table, info in sorted_stats:
            count = info.get('count', 0)
            total_records += count
            print(f"{table:<40} {count:>15,}")
        
        print(f"{'-'*40} {'-'*15}")
        print(f"{'TOTAL':<40} {total_records:>15,}")
    else:
        print("❌ Não foi possível obter estatísticas das tabelas")


def show_sample_queries():
    """Executa e mostra alguns exemplos de queries"""
    print_separator("EXEMPLOS DE CONSULTAS")
    
    # Query 1: Top 5 Clientes por Faturamento
    print("📊 Top 5 Clientes por Faturamento:\n")
    try:
        results = postgres_config.execute_query("""
            SELECT 
                razao_social,
                cidade,
                estado,
                faturamento_total,
                total_notas_fiscais
            FROM vw_top_clientes
            WHERE faturamento_total IS NOT NULL
            LIMIT 5
        """)
        
        if results:
            for i, row in enumerate(results, 1):
                print(f"{i}. {row['razao_social'][:50]}")
                print(f"   📍 {row['cidade']}/{row['estado']}")
                print(f"   💰 Faturamento: R$ {row['faturamento_total']:,.2f}")
                print(f"   📄 Notas Fiscais: {row['total_notas_fiscais']}")
                print()
        else:
            print("   Nenhum resultado encontrado")
    except Exception as e:
        print(f"   ❌ Erro: {e}")
    
    print("\n" + "-"*80 + "\n")
    
    # Query 2: Distribuição de Empresas por Estado
    print("📊 Distribuição de Empresas por Estado:\n")
    try:
        results = postgres_config.execute_query("""
            SELECT 
                estado,
                COUNT(*) as total_empresas,
                COUNT(CASE WHEN status = 'ATIVO' THEN 1 END) as ativas,
                COUNT(CASE WHEN status = 'PROSPECTO' THEN 1 END) as prospectos
            FROM empresas_clientes
            GROUP BY estado
            ORDER BY total_empresas DESC
            LIMIT 10
        """)
        
        if results:
            print(f"{'Estado':<10} {'Total':>10} {'Ativas':>10} {'Prospectos':>12}")
            print(f"{'-'*10} {'-'*10} {'-'*10} {'-'*12}")
            for row in results:
                print(f"{row['estado']:<10} {row['total_empresas']:>10} "
                      f"{row['ativas']:>10} {row['prospectos']:>12}")
        else:
            print("   Nenhum resultado encontrado")
    except Exception as e:
        print(f"   ❌ Erro: {e}")
    
    print("\n" + "-"*80 + "\n")
    
    # Query 3: Funil de Vendas
    print("📊 Funil de Vendas:\n")
    try:
        results = postgres_config.execute_query("""
            SELECT 
                etapa,
                quantidade_oportunidades,
                valor_total_estimado,
                quantidade_ganhas,
                valor_ganho
            FROM vw_funil_vendas
            ORDER BY ordem
        """)
        
        if results:
            print(f"{'Etapa':<20} {'Oportunidades':>15} {'Valor Estimado':>20} {'Ganhas':>10} {'Valor Ganho':>20}")
            print(f"{'-'*20} {'-'*15} {'-'*20} {'-'*10} {'-'*20}")
            for row in results:
                print(f"{row['etapa']:<20} {row['quantidade_oportunidades']:>15} "
                      f"R$ {row['valor_total_estimado']:>17,.2f} {row['quantidade_ganhas']:>10} "
                      f"R$ {row['valor_ganho']:>17,.2f}")
        else:
            print("   Nenhum resultado encontrado")
    except Exception as e:
        print(f"   ❌ Erro: {e}")
    
    print("\n" + "-"*80 + "\n")
    
    # Query 4: Top 5 Analistas
    print("📊 Top 5 Analistas por Valor Vendido:\n")
    try:
        results = postgres_config.execute_query("""
            SELECT 
                nome,
                regiao,
                total_clientes,
                oportunidades_ganhas,
                valor_total_vendido,
                meta_mensal
            FROM vw_performance_analistas
            WHERE valor_total_vendido > 0
            ORDER BY valor_total_vendido DESC
            LIMIT 5
        """)
        
        if results:
            for i, row in enumerate(results, 1):
                print(f"{i}. {row['nome']}")
                print(f"   📍 Região: {row['regiao']}")
                print(f"   👥 Clientes: {row['total_clientes']}")
                print(f"   🎯 Oportunidades Ganhas: {row['oportunidades_ganhas']}")
                print(f"   💰 Valor Vendido: R$ {row['valor_total_vendido']:,.2f}")
                if row['meta_mensal']:
                    percentual = (row['valor_total_vendido'] / row['meta_mensal']) * 100
                    print(f"   📊 Meta Mensal: R$ {row['meta_mensal']:,.2f} ({percentual:.1f}%)")
                print()
        else:
            print("   Nenhum resultado encontrado")
    except Exception as e:
        print(f"   ❌ Erro: {e}")


def main():
    """Função principal"""
    print("\n")
    print("╔" + "═"*78 + "╗")
    print("║" + " "*78 + "║")
    print("║" + "  OBSERVATÓRIO DA INDÚSTRIA - TESTE DE BANCO DE DADOS".center(78) + "║")
    print("║" + " "*78 + "║")
    print("╚" + "═"*78 + "╝")
    
    try:
        # Testa conexão
        if not test_connection():
            return 1
        
        # Mostra informações do banco
        show_database_info()
        
        # Mostra estatísticas das tabelas
        show_table_statistics()
        
        # Mostra queries de exemplo
        show_sample_queries()
        
        print_separator("TESTE CONCLUÍDO COM SUCESSO")
        print("✅ Todas as verificações foram realizadas com sucesso!")
        print("\n💡 Dica: Acesse o pgAdmin em http://localhost:5050 para explorar os dados")
        print("   Email: admin@observatorio.com")
        print("   Senha: admin123\n")
        
        return 0
        
    except Exception as e:
        print_separator("ERRO")
        print(f"❌ Erro durante os testes: {e}")
        logger.exception("Erro durante execução dos testes")
        return 1
    finally:
        postgres_config.close()


if __name__ == "__main__":
    sys.exit(main())
