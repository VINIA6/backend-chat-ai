-- ============================================================================
-- OBSERVATÓRIO DA INDÚSTRIA - SCHEMA DO BANCO DE DADOS
-- ============================================================================
-- Este schema simula três fontes de dados:
-- 1. ERP: Faturamento e Notas Fiscais
-- 2. CRM: Gestão de Clientes e Oportunidades
-- 3. Planilhas Manuais: Dados do time comercial em campo
-- ============================================================================

-- Extensões úteis
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- Para busca fuzzy

-- ============================================================================
-- TABELAS COMPARTILHADAS
-- ============================================================================

-- Regiões geográficas
CREATE TABLE regioes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    sigla VARCHAR(10) NOT NULL,
    tipo VARCHAR(50) NOT NULL, -- 'MACRO_REGIAO', 'ESTADO', 'REGIAO_COMERCIAL'
    regiao_pai_id INTEGER REFERENCES regioes(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_regioes_tipo ON regioes(tipo);
CREATE INDEX idx_regioes_pai ON regioes(regiao_pai_id);

-- Analistas comerciais (usuários do sistema)
CREATE TABLE analistas_comerciais (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(200) NOT NULL,
    email VARCHAR(200) UNIQUE NOT NULL,
    telefone VARCHAR(20),
    cargo VARCHAR(100),
    regiao_id INTEGER REFERENCES regioes(id),
    ativo BOOLEAN DEFAULT TRUE,
    data_admissao DATE,
    meta_mensal DECIMAL(15,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_analistas_email ON analistas_comerciais(email);
CREATE INDEX idx_analistas_regiao ON analistas_comerciais(regiao_id);
CREATE INDEX idx_analistas_ativo ON analistas_comerciais(ativo);

-- ============================================================================
-- MÓDULO CRM - GESTÃO DE CLIENTES E OPORTUNIDADES
-- ============================================================================

-- Segmentos de mercado
CREATE TABLE segmentos_mercado (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    ativo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Empresas clientes (fonte principal do CRM)
CREATE TABLE empresas_clientes (
    id SERIAL PRIMARY KEY,
    cnpj VARCHAR(18) UNIQUE NOT NULL,
    razao_social VARCHAR(300) NOT NULL,
    nome_fantasia VARCHAR(300),
    email VARCHAR(200),
    telefone VARCHAR(20),
    celular VARCHAR(20),
    
    -- Endereço
    logradouro VARCHAR(300),
    numero VARCHAR(20),
    complemento VARCHAR(100),
    bairro VARCHAR(100),
    cidade VARCHAR(100),
    estado VARCHAR(2),
    cep VARCHAR(9),
    regiao_id INTEGER REFERENCES regioes(id),
    
    -- Classificação
    segmento_id INTEGER REFERENCES segmentos_mercado(id),
    porte VARCHAR(50), -- 'MEI', 'ME', 'EPP', 'MEDIA', 'GRANDE'
    faturamento_anual_estimado DECIMAL(15,2),
    numero_funcionarios INTEGER,
    
    -- Status CRM
    status VARCHAR(50) DEFAULT 'ATIVO', -- 'ATIVO', 'INATIVO', 'PROSPECTO', 'PERDIDO'
    origem VARCHAR(100), -- 'INDICACAO', 'MARKETING', 'PROSPECÇÃO', 'EVENTO', etc
    data_primeira_compra DATE,
    
    -- Relacionamento
    analista_responsavel_id INTEGER REFERENCES analistas_comerciais(id),
    score_cliente INTEGER DEFAULT 0, -- Score de engajamento 0-100
    
    -- Auditoria
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_empresas_cnpj ON empresas_clientes(cnpj);
CREATE INDEX idx_empresas_razao_social ON empresas_clientes USING gin(razao_social gin_trgm_ops);
CREATE INDEX idx_empresas_status ON empresas_clientes(status);
CREATE INDEX idx_empresas_regiao ON empresas_clientes(regiao_id);
CREATE INDEX idx_empresas_segmento ON empresas_clientes(segmento_id);
CREATE INDEX idx_empresas_analista ON empresas_clientes(analista_responsavel_id);

-- Contatos das empresas
CREATE TABLE contatos_empresas (
    id SERIAL PRIMARY KEY,
    empresa_id INTEGER NOT NULL REFERENCES empresas_clientes(id),
    nome VARCHAR(200) NOT NULL,
    cargo VARCHAR(100),
    email VARCHAR(200),
    telefone VARCHAR(20),
    celular VARCHAR(20),
    departamento VARCHAR(100),
    decisor BOOLEAN DEFAULT FALSE, -- É decisor de compra?
    ativo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_contatos_empresa ON contatos_empresas(empresa_id);
CREATE INDEX idx_contatos_email ON contatos_empresas(email);

-- Pipeline de vendas
CREATE TABLE pipeline_vendas (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    descricao TEXT,
    ordem INTEGER NOT NULL,
    taxa_conversao_media DECIMAL(5,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Oportunidades de vendas (CRM)
CREATE TABLE oportunidades_vendas (
    id SERIAL PRIMARY KEY,
    empresa_id INTEGER NOT NULL REFERENCES empresas_clientes(id),
    titulo VARCHAR(300) NOT NULL,
    descricao TEXT,
    
    -- Valores
    valor_estimado DECIMAL(15,2),
    valor_real DECIMAL(15,2),
    probabilidade_fechamento INTEGER, -- 0-100%
    
    -- Status
    pipeline_id INTEGER REFERENCES pipeline_vendas(id),
    status VARCHAR(50) DEFAULT 'EM_ANDAMENTO', -- 'EM_ANDAMENTO', 'GANHO', 'PERDIDO', 'CANCELADO'
    motivo_perda TEXT,
    
    -- Datas
    data_abertura DATE NOT NULL DEFAULT CURRENT_DATE,
    data_previsao_fechamento DATE,
    data_fechamento DATE,
    
    -- Relacionamento
    analista_id INTEGER REFERENCES analistas_comerciais(id),
    origem VARCHAR(100),
    
    -- Produtos/Serviços
    categoria_produto VARCHAR(100),
    quantidade_estimada INTEGER,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_oportunidades_empresa ON oportunidades_vendas(empresa_id);
CREATE INDEX idx_oportunidades_status ON oportunidades_vendas(status);
CREATE INDEX idx_oportunidades_analista ON oportunidades_vendas(analista_id);
CREATE INDEX idx_oportunidades_data_abertura ON oportunidades_vendas(data_abertura);
CREATE INDEX idx_oportunidades_data_fechamento ON oportunidades_vendas(data_fechamento);

-- Histórico de interações com clientes
CREATE TABLE interacoes_clientes (
    id SERIAL PRIMARY KEY,
    empresa_id INTEGER NOT NULL REFERENCES empresas_clientes(id),
    oportunidade_id INTEGER REFERENCES oportunidades_vendas(id),
    analista_id INTEGER REFERENCES analistas_comerciais(id),
    
    tipo VARCHAR(50) NOT NULL, -- 'REUNIAO', 'LIGACAO', 'EMAIL', 'VISITA', 'WHATSAPP'
    assunto VARCHAR(300),
    descricao TEXT,
    resultado VARCHAR(50), -- 'POSITIVO', 'NEUTRO', 'NEGATIVO'
    
    data_interacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    duracao_minutos INTEGER,
    
    proxima_acao VARCHAR(300),
    data_proxima_acao DATE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_interacoes_empresa ON interacoes_clientes(empresa_id);
CREATE INDEX idx_interacoes_oportunidade ON interacoes_clientes(oportunidade_id);
CREATE INDEX idx_interacoes_data ON interacoes_clientes(data_interacao);

-- ============================================================================
-- MÓDULO ERP - FATURAMENTO E NOTAS FISCAIS
-- ============================================================================

-- Produtos/Serviços
CREATE TABLE produtos (
    id SERIAL PRIMARY KEY,
    codigo VARCHAR(50) UNIQUE NOT NULL,
    nome VARCHAR(300) NOT NULL,
    descricao TEXT,
    categoria VARCHAR(100),
    subcategoria VARCHAR(100),
    unidade_medida VARCHAR(20), -- 'UN', 'KG', 'L', 'M', 'SERVIÇO'
    preco_base DECIMAL(15,2),
    custo DECIMAL(15,2),
    estoque_atual INTEGER DEFAULT 0,
    ativo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_produtos_codigo ON produtos(codigo);
CREATE INDEX idx_produtos_nome ON produtos USING gin(nome gin_trgm_ops);
CREATE INDEX idx_produtos_categoria ON produtos(categoria);
CREATE INDEX idx_produtos_ativo ON produtos(ativo);

-- Pedidos de venda
CREATE TABLE pedidos_venda (
    id SERIAL PRIMARY KEY,
    numero_pedido VARCHAR(50) UNIQUE NOT NULL,
    empresa_id INTEGER NOT NULL REFERENCES empresas_clientes(id),
    oportunidade_id INTEGER REFERENCES oportunidades_vendas(id),
    
    -- Valores
    valor_bruto DECIMAL(15,2) NOT NULL,
    valor_desconto DECIMAL(15,2) DEFAULT 0,
    valor_liquido DECIMAL(15,2) NOT NULL,
    
    -- Status
    status VARCHAR(50) DEFAULT 'PENDENTE', -- 'PENDENTE', 'APROVADO', 'FATURADO', 'CANCELADO'
    
    -- Datas
    data_pedido DATE NOT NULL DEFAULT CURRENT_DATE,
    data_previsao_entrega DATE,
    data_aprovacao DATE,
    
    -- Relacionamento
    analista_id INTEGER REFERENCES analistas_comerciais(id),
    
    -- Observações
    observacoes TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_pedidos_numero ON pedidos_venda(numero_pedido);
CREATE INDEX idx_pedidos_empresa ON pedidos_venda(empresa_id);
CREATE INDEX idx_pedidos_status ON pedidos_venda(status);
CREATE INDEX idx_pedidos_data ON pedidos_venda(data_pedido);

-- Itens do pedido
CREATE TABLE itens_pedido (
    id SERIAL PRIMARY KEY,
    pedido_id INTEGER NOT NULL REFERENCES pedidos_venda(id) ON DELETE CASCADE,
    produto_id INTEGER NOT NULL REFERENCES produtos(id),
    
    quantidade DECIMAL(15,3) NOT NULL,
    preco_unitario DECIMAL(15,2) NOT NULL,
    desconto DECIMAL(15,2) DEFAULT 0,
    valor_total DECIMAL(15,2) NOT NULL,
    
    observacoes TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_itens_pedido ON itens_pedido(pedido_id);
CREATE INDEX idx_itens_produto ON itens_pedido(produto_id);

-- Notas fiscais
CREATE TABLE notas_fiscais (
    id SERIAL PRIMARY KEY,
    numero_nota VARCHAR(50) NOT NULL,
    serie VARCHAR(10) NOT NULL,
    chave_acesso VARCHAR(44) UNIQUE,
    
    pedido_id INTEGER REFERENCES pedidos_venda(id),
    empresa_id INTEGER NOT NULL REFERENCES empresas_clientes(id),
    
    -- Tipo
    tipo VARCHAR(20) NOT NULL, -- 'SAIDA', 'ENTRADA', 'DEVOLUCAO'
    modelo VARCHAR(10) DEFAULT 'NFe', -- 'NFe', 'NFSe', 'NFCe'
    
    -- Valores
    valor_produtos DECIMAL(15,2) NOT NULL,
    valor_servicos DECIMAL(15,2) DEFAULT 0,
    valor_desconto DECIMAL(15,2) DEFAULT 0,
    valor_frete DECIMAL(15,2) DEFAULT 0,
    valor_icms DECIMAL(15,2) DEFAULT 0,
    valor_ipi DECIMAL(15,2) DEFAULT 0,
    valor_pis DECIMAL(15,2) DEFAULT 0,
    valor_cofins DECIMAL(15,2) DEFAULT 0,
    valor_total DECIMAL(15,2) NOT NULL,
    
    -- Status
    status VARCHAR(50) DEFAULT 'EMITIDA', -- 'EMITIDA', 'AUTORIZADA', 'CANCELADA', 'DENEGADA'
    
    -- Datas
    data_emissao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_saida TIMESTAMP,
    data_autorizacao TIMESTAMP,
    data_cancelamento TIMESTAMP,
    
    -- Observações
    natureza_operacao VARCHAR(100),
    observacoes TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(numero_nota, serie)
);

CREATE INDEX idx_nf_numero_serie ON notas_fiscais(numero_nota, serie);
CREATE INDEX idx_nf_chave ON notas_fiscais(chave_acesso);
CREATE INDEX idx_nf_empresa ON notas_fiscais(empresa_id);
CREATE INDEX idx_nf_pedido ON notas_fiscais(pedido_id);
CREATE INDEX idx_nf_data_emissao ON notas_fiscais(data_emissao);
CREATE INDEX idx_nf_status ON notas_fiscais(status);

-- Itens da nota fiscal
CREATE TABLE itens_nota_fiscal (
    id SERIAL PRIMARY KEY,
    nota_fiscal_id INTEGER NOT NULL REFERENCES notas_fiscais(id) ON DELETE CASCADE,
    produto_id INTEGER NOT NULL REFERENCES produtos(id),
    
    quantidade DECIMAL(15,3) NOT NULL,
    preco_unitario DECIMAL(15,2) NOT NULL,
    valor_total DECIMAL(15,2) NOT NULL,
    
    -- Impostos
    aliquota_icms DECIMAL(5,2),
    valor_icms DECIMAL(15,2),
    aliquota_ipi DECIMAL(5,2),
    valor_ipi DECIMAL(15,2),
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_itens_nf_nota ON itens_nota_fiscal(nota_fiscal_id);
CREATE INDEX idx_itens_nf_produto ON itens_nota_fiscal(produto_id);

-- Contas a receber (financeiro)
CREATE TABLE contas_receber (
    id SERIAL PRIMARY KEY,
    nota_fiscal_id INTEGER REFERENCES notas_fiscais(id),
    empresa_id INTEGER NOT NULL REFERENCES empresas_clientes(id),
    
    numero_titulo VARCHAR(50) UNIQUE NOT NULL,
    valor DECIMAL(15,2) NOT NULL,
    
    -- Datas
    data_emissao DATE NOT NULL,
    data_vencimento DATE NOT NULL,
    data_pagamento DATE,
    
    -- Status
    status VARCHAR(50) DEFAULT 'ABERTO', -- 'ABERTO', 'PAGO', 'VENCIDO', 'CANCELADO'
    
    -- Pagamento
    valor_pago DECIMAL(15,2),
    forma_pagamento VARCHAR(50), -- 'BOLETO', 'PIX', 'CARTAO', 'TRANSFERENCIA'
    
    observacoes TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_contas_receber_empresa ON contas_receber(empresa_id);
CREATE INDEX idx_contas_receber_status ON contas_receber(status);
CREATE INDEX idx_contas_receber_vencimento ON contas_receber(data_vencimento);

-- ============================================================================
-- MÓDULO PLANILHAS MANUAIS - DADOS DE CAMPO
-- ============================================================================

-- Visitas de campo (registradas manualmente)
CREATE TABLE visitas_campo (
    id SERIAL PRIMARY KEY,
    empresa_id INTEGER REFERENCES empresas_clientes(id),
    analista_id INTEGER NOT NULL REFERENCES analistas_comerciais(id),
    
    -- Informações da visita
    data_visita DATE NOT NULL,
    hora_inicio TIME,
    hora_fim TIME,
    
    -- Detalhes
    objetivo VARCHAR(300),
    resultado TEXT,
    observacoes TEXT,
    
    -- Checklist
    apresentou_produtos BOOLEAN DEFAULT FALSE,
    coletou_feedback BOOLEAN DEFAULT FALSE,
    identificou_necessidades BOOLEAN DEFAULT FALSE,
    
    -- Avaliação
    nivel_interesse VARCHAR(50), -- 'BAIXO', 'MEDIO', 'ALTO'
    potencial_compra DECIMAL(15,2),
    
    -- Geolocalização (caso tenha sido coletado no app mobile)
    latitude DECIMAL(10,8),
    longitude DECIMAL(11,8),
    
    -- Status
    status VARCHAR(50) DEFAULT 'REALIZADA', -- 'AGENDADA', 'REALIZADA', 'CANCELADA'
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_visitas_empresa ON visitas_campo(empresa_id);
CREATE INDEX idx_visitas_analista ON visitas_campo(analista_id);
CREATE INDEX idx_visitas_data ON visitas_campo(data_visita);

-- Pesquisas de mercado (campo)
CREATE TABLE pesquisas_mercado (
    id SERIAL PRIMARY KEY,
    empresa_id INTEGER REFERENCES empresas_clientes(id),
    analista_id INTEGER NOT NULL REFERENCES analistas_comerciais(id),
    
    data_pesquisa DATE NOT NULL,
    
    -- Informações competitivas
    concorrente_principal VARCHAR(200),
    preco_concorrente DECIMAL(15,2),
    diferenciais_concorrente TEXT,
    
    -- Demanda
    produtos_interesse TEXT,
    volume_compra_mensal DECIMAL(15,2),
    frequencia_compra VARCHAR(50),
    
    -- Decisão de compra
    criterios_decisao TEXT,
    prazo_decisao VARCHAR(100),
    
    observacoes TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_pesquisas_empresa ON pesquisas_mercado(empresa_id);
CREATE INDEX idx_pesquisas_analista ON pesquisas_mercado(analista_id);
CREATE INDEX idx_pesquisas_data ON pesquisas_mercado(data_pesquisa);

-- Metas e resultados (planilha de acompanhamento)
CREATE TABLE metas_vendas (
    id SERIAL PRIMARY KEY,
    analista_id INTEGER NOT NULL REFERENCES analistas_comerciais(id),
    regiao_id INTEGER REFERENCES regioes(id),
    
    -- Período
    ano INTEGER NOT NULL,
    mes INTEGER NOT NULL,
    
    -- Metas
    meta_faturamento DECIMAL(15,2),
    meta_novos_clientes INTEGER,
    meta_visitas INTEGER,
    meta_oportunidades INTEGER,
    
    -- Realizados
    realizado_faturamento DECIMAL(15,2) DEFAULT 0,
    realizado_novos_clientes INTEGER DEFAULT 0,
    realizado_visitas INTEGER DEFAULT 0,
    realizado_oportunidades INTEGER DEFAULT 0,
    
    -- Observações
    observacoes TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    UNIQUE(analista_id, ano, mes)
);

CREATE INDEX idx_metas_analista ON metas_vendas(analista_id);
CREATE INDEX idx_metas_periodo ON metas_vendas(ano, mes);

-- Propostas comerciais (rastreamento manual)
CREATE TABLE propostas_comerciais (
    id SERIAL PRIMARY KEY,
    numero_proposta VARCHAR(50) UNIQUE NOT NULL,
    empresa_id INTEGER NOT NULL REFERENCES empresas_clientes(id),
    oportunidade_id INTEGER REFERENCES oportunidades_vendas(id),
    analista_id INTEGER REFERENCES analistas_comerciais(id),
    
    -- Detalhes
    titulo VARCHAR(300),
    descricao TEXT,
    valor_proposta DECIMAL(15,2),
    
    -- Condições
    prazo_validade INTEGER, -- dias
    prazo_entrega INTEGER, -- dias
    forma_pagamento VARCHAR(200),
    condicoes_especiais TEXT,
    
    -- Status
    status VARCHAR(50) DEFAULT 'ENVIADA', -- 'RASCUNHO', 'ENVIADA', 'APROVADA', 'REJEITADA', 'NEGOCIACAO'
    
    -- Datas
    data_criacao DATE NOT NULL DEFAULT CURRENT_DATE,
    data_envio DATE,
    data_resposta DATE,
    data_validade DATE,
    
    -- Feedback
    motivo_rejeicao TEXT,
    observacoes TEXT,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_propostas_numero ON propostas_comerciais(numero_proposta);
CREATE INDEX idx_propostas_empresa ON propostas_comerciais(empresa_id);
CREATE INDEX idx_propostas_status ON propostas_comerciais(status);
CREATE INDEX idx_propostas_data ON propostas_comerciais(data_criacao);

-- ============================================================================
-- VIEWS ANALÍTICAS
-- ============================================================================

-- View consolidada de vendas
CREATE VIEW vw_vendas_consolidadas AS
SELECT 
    nf.id as nota_fiscal_id,
    nf.numero_nota,
    nf.data_emissao,
    nf.valor_total,
    e.id as empresa_id,
    e.cnpj,
    e.razao_social,
    e.cidade,
    e.estado,
    r.nome as regiao,
    s.nome as segmento,
    a.id as analista_id,
    a.nome as analista_nome,
    p.numero_pedido,
    EXTRACT(YEAR FROM nf.data_emissao) as ano,
    EXTRACT(MONTH FROM nf.data_emissao) as mes,
    EXTRACT(QUARTER FROM nf.data_emissao) as trimestre
FROM notas_fiscais nf
JOIN empresas_clientes e ON nf.empresa_id = e.id
LEFT JOIN regioes r ON e.regiao_id = r.id
LEFT JOIN segmentos_mercado s ON e.segmento_id = s.id
LEFT JOIN pedidos_venda p ON nf.pedido_id = p.id
LEFT JOIN analistas_comerciais a ON e.analista_responsavel_id = a.id
WHERE nf.status = 'AUTORIZADA' AND nf.tipo = 'SAIDA';

-- View de funil de vendas
CREATE VIEW vw_funil_vendas AS
SELECT 
    pv.id as pipeline_id,
    pv.nome as etapa,
    pv.ordem,
    COUNT(ov.id) as quantidade_oportunidades,
    SUM(ov.valor_estimado) as valor_total_estimado,
    AVG(ov.probabilidade_fechamento) as probabilidade_media,
    COUNT(CASE WHEN ov.status = 'GANHO' THEN 1 END) as quantidade_ganhas,
    SUM(CASE WHEN ov.status = 'GANHO' THEN ov.valor_real ELSE 0 END) as valor_ganho
FROM pipeline_vendas pv
LEFT JOIN oportunidades_vendas ov ON pv.id = ov.pipeline_id
GROUP BY pv.id, pv.nome, pv.ordem
ORDER BY pv.ordem;

-- View de performance de analistas
CREATE VIEW vw_performance_analistas AS
SELECT 
    a.id,
    a.nome,
    a.cargo,
    r.nome as regiao,
    COUNT(DISTINCT e.id) as total_clientes,
    COUNT(DISTINCT ov.id) as total_oportunidades,
    COUNT(DISTINCT CASE WHEN ov.status = 'GANHO' THEN ov.id END) as oportunidades_ganhas,
    SUM(CASE WHEN ov.status = 'GANHO' THEN ov.valor_real ELSE 0 END) as valor_total_vendido,
    COUNT(DISTINCT vf.id) as total_visitas,
    a.meta_mensal
FROM analistas_comerciais a
LEFT JOIN regioes r ON a.regiao_id = r.id
LEFT JOIN empresas_clientes e ON a.id = e.analista_responsavel_id
LEFT JOIN oportunidades_vendas ov ON a.id = ov.analista_id
LEFT JOIN visitas_campo vf ON a.id = vf.analista_id
WHERE a.ativo = TRUE
GROUP BY a.id, a.nome, a.cargo, r.nome, a.meta_mensal;

-- View de clientes com maior faturamento
CREATE VIEW vw_top_clientes AS
SELECT 
    e.id,
    e.cnpj,
    e.razao_social,
    e.cidade,
    e.estado,
    s.nome as segmento,
    COUNT(DISTINCT nf.id) as total_notas_fiscais,
    SUM(nf.valor_total) as faturamento_total,
    MAX(nf.data_emissao) as ultima_compra,
    a.nome as analista_responsavel
FROM empresas_clientes e
LEFT JOIN notas_fiscais nf ON e.id = nf.empresa_id AND nf.status = 'AUTORIZADA'
LEFT JOIN segmentos_mercado s ON e.segmento_id = s.id
LEFT JOIN analistas_comerciais a ON e.analista_responsavel_id = a.id
GROUP BY e.id, e.cnpj, e.razao_social, e.cidade, e.estado, s.nome, a.nome
ORDER BY faturamento_total DESC NULLS LAST;

-- ============================================================================
-- TRIGGERS PARA ATUALIZAÇÃO AUTOMÁTICA
-- ============================================================================

-- Função para atualizar updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Aplicar trigger em tabelas relevantes
CREATE TRIGGER update_empresas_updated_at BEFORE UPDATE ON empresas_clientes
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_oportunidades_updated_at BEFORE UPDATE ON oportunidades_vendas
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_pedidos_updated_at BEFORE UPDATE ON pedidos_venda
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notas_fiscais_updated_at BEFORE UPDATE ON notas_fiscais
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Comentários nas tabelas
COMMENT ON TABLE empresas_clientes IS 'Cadastro de empresas clientes do CRM';
COMMENT ON TABLE oportunidades_vendas IS 'Oportunidades de vendas gerenciadas no CRM';
COMMENT ON TABLE notas_fiscais IS 'Notas fiscais emitidas pelo ERP';
COMMENT ON TABLE visitas_campo IS 'Visitas de campo registradas manualmente pelos analistas';
COMMENT ON TABLE pesquisas_mercado IS 'Pesquisas de mercado realizadas em campo';
COMMENT ON TABLE metas_vendas IS 'Metas e resultados dos analistas (planilhas manuais)';
