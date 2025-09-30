-- ============================================================================
-- OBSERVATÓRIO DA INDÚSTRIA - DADOS SIMULADOS
-- ============================================================================
-- Este script popula o banco com dados simulados para fins de teste e BI
-- ============================================================================

-- ============================================================================
-- 1. REGIÕES
-- ============================================================================

-- Macro Regiões
INSERT INTO regioes (nome, sigla, tipo) VALUES
('Norte', 'N', 'MACRO_REGIAO'),
('Nordeste', 'NE', 'MACRO_REGIAO'),
('Centro-Oeste', 'CO', 'MACRO_REGIAO'),
('Sudeste', 'SE', 'MACRO_REGIAO'),
('Sul', 'S', 'MACRO_REGIAO');

-- Estados (exemplos principais)
INSERT INTO regioes (nome, sigla, tipo, regiao_pai_id) VALUES
-- Sul
('Paraná', 'PR', 'ESTADO', (SELECT id FROM regioes WHERE sigla = 'S')),
('Santa Catarina', 'SC', 'ESTADO', (SELECT id FROM regioes WHERE sigla = 'S')),
('Rio Grande do Sul', 'RS', 'ESTADO', (SELECT id FROM regioes WHERE sigla = 'S')),
-- Sudeste
('São Paulo', 'SP', 'ESTADO', (SELECT id FROM regioes WHERE sigla = 'SE')),
('Rio de Janeiro', 'RJ', 'ESTADO', (SELECT id FROM regioes WHERE sigla = 'SE')),
('Minas Gerais', 'MG', 'ESTADO', (SELECT id FROM regioes WHERE sigla = 'SE')),
-- Centro-Oeste
('Goiás', 'GO', 'ESTADO', (SELECT id FROM regioes WHERE sigla = 'CO')),
('Distrito Federal', 'DF', 'ESTADO', (SELECT id FROM regioes WHERE sigla = 'CO')),
-- Nordeste
('Bahia', 'BA', 'ESTADO', (SELECT id FROM regioes WHERE sigla = 'NE')),
('Pernambuco', 'PE', 'ESTADO', (SELECT id FROM regioes WHERE sigla = 'NE')),
('Ceará', 'CE', 'ESTADO', (SELECT id FROM regioes WHERE sigla = 'NE'));

-- Regiões Comerciais
INSERT INTO regioes (nome, sigla, tipo, regiao_pai_id) VALUES
('Grande São Paulo', 'GSP', 'REGIAO_COMERCIAL', (SELECT id FROM regioes WHERE sigla = 'SP' AND tipo = 'ESTADO')),
('Interior SP Norte', 'ISP-N', 'REGIAO_COMERCIAL', (SELECT id FROM regioes WHERE sigla = 'SP' AND tipo = 'ESTADO')),
('Interior SP Sul', 'ISP-S', 'REGIAO_COMERCIAL', (SELECT id FROM regioes WHERE sigla = 'SP' AND tipo = 'ESTADO')),
('Grande Rio', 'GRJ', 'REGIAO_COMERCIAL', (SELECT id FROM regioes WHERE sigla = 'RJ' AND tipo = 'ESTADO')),
('Grande BH', 'GBH', 'REGIAO_COMERCIAL', (SELECT id FROM regioes WHERE sigla = 'MG' AND tipo = 'ESTADO')),
('Grande Curitiba', 'GCT', 'REGIAO_COMERCIAL', (SELECT id FROM regioes WHERE sigla = 'PR' AND tipo = 'ESTADO')),
('Grande POA', 'GPOA', 'REGIAO_COMERCIAL', (SELECT id FROM regioes WHERE sigla = 'RS' AND tipo = 'ESTADO')),
('Grande Florianópolis', 'GFLN', 'REGIAO_COMERCIAL', (SELECT id FROM regioes WHERE sigla = 'SC' AND tipo = 'ESTADO'));

-- ============================================================================
-- 2. SEGMENTOS DE MERCADO
-- ============================================================================

INSERT INTO segmentos_mercado (nome, descricao) VALUES
('Indústria Alimentícia', 'Fabricação de alimentos e bebidas'),
('Indústria Têxtil', 'Fabricação de produtos têxteis'),
('Indústria Metalúrgica', 'Fabricação de produtos de metal'),
('Indústria Química', 'Fabricação de produtos químicos'),
('Indústria Farmacêutica', 'Fabricação de produtos farmacêuticos'),
('Indústria Automotiva', 'Fabricação de veículos e peças'),
('Indústria de Máquinas', 'Fabricação de máquinas e equipamentos'),
('Indústria de Móveis', 'Fabricação de móveis'),
('Indústria de Plásticos', 'Fabricação de produtos de plástico'),
('Indústria Eletrônica', 'Fabricação de produtos eletrônicos'),
('Construção Civil', 'Construção de edifícios e obras'),
('Comércio Varejista', 'Varejo de produtos diversos'),
('Comércio Atacadista', 'Atacado de produtos diversos'),
('Serviços de TI', 'Tecnologia da informação'),
('Serviços de Consultoria', 'Consultoria empresarial'),
('Serviços de Logística', 'Transporte e armazenamento'),
('Agronegócio', 'Agricultura e pecuária'),
('Mineração', 'Extração de minerais'),
('Energia', 'Geração e distribuição de energia'),
('Telecomunicações', 'Serviços de telecomunicações');

-- ============================================================================
-- 3. ANALISTAS COMERCIAIS (500+)
-- ============================================================================

-- Função auxiliar para gerar analistas
DO $$
DECLARE
    v_regiao_id INTEGER;
    v_nome_base VARCHAR[];
    v_sobrenome_base VARCHAR[];
    v_cargo_base VARCHAR[];
    v_nome VARCHAR;
    v_sobrenome VARCHAR;
    v_cargo VARCHAR;
    i INTEGER;
BEGIN
    v_nome_base := ARRAY['João', 'Maria', 'Pedro', 'Ana', 'Carlos', 'Julia', 'Lucas', 'Fernanda', 'Rafael', 'Camila',
                         'Bruno', 'Mariana', 'Felipe', 'Juliana', 'Rodrigo', 'Patricia', 'Gabriel', 'Amanda', 'Thiago', 'Beatriz',
                         'Leonardo', 'Carolina', 'Gustavo', 'Larissa', 'Diego', 'Renata', 'Vinicius', 'Gabriela', 'Matheus', 'Aline',
                         'Marcelo', 'Cristina', 'Ricardo', 'Sandra', 'André', 'Claudia', 'Paulo', 'Monica', 'Fernando', 'Simone'];
    
    v_sobrenome_base := ARRAY['Silva', 'Santos', 'Oliveira', 'Souza', 'Lima', 'Pereira', 'Costa', 'Rodrigues', 'Almeida', 'Nascimento',
                              'Carvalho', 'Fernandes', 'Gomes', 'Martins', 'Rocha', 'Ribeiro', 'Araujo', 'Cavalcanti', 'Monteiro', 'Mendes',
                              'Barbosa', 'Cardoso', 'Melo', 'Freitas', 'Dias', 'Castro', 'Campos', 'Teixeira', 'Ramos', 'Moreira'];
    
    v_cargo_base := ARRAY['Analista Comercial Junior', 'Analista Comercial Pleno', 'Analista Comercial Senior', 
                          'Consultor de Vendas', 'Executivo de Contas', 'Gerente de Contas'];

    FOR i IN 1..550 LOOP
        -- Seleciona região aleatória
        SELECT id INTO v_regiao_id FROM regioes WHERE tipo = 'REGIAO_COMERCIAL' 
        ORDER BY random() LIMIT 1;
        
        -- Gera nome aleatório
        v_nome := v_nome_base[1 + floor(random() * array_length(v_nome_base, 1))];
        v_sobrenome := v_sobrenome_base[1 + floor(random() * array_length(v_sobrenome_base, 1))];
        v_cargo := v_cargo_base[1 + floor(random() * array_length(v_cargo_base, 1))];
        
        INSERT INTO analistas_comerciais (
            nome, 
            email, 
            telefone, 
            cargo, 
            regiao_id, 
            ativo,
            data_admissao,
            meta_mensal
        ) VALUES (
            v_nome || ' ' || v_sobrenome || ' ' || i,
            lower(regexp_replace(v_nome || '.' || v_sobrenome || i || '@observatorio.com.br', ' ', '', 'g')),
            '(' || lpad((11 + floor(random() * 89))::text, 2, '0') || ') ' || 
            lpad((90000 + floor(random() * 9999))::text, 5, '0') || '-' || 
            lpad((1000 + floor(random() * 8999))::text, 4, '0'),
            v_cargo,
            v_regiao_id,
            random() > 0.05, -- 95% ativos
            CURRENT_DATE - (random() * 2000)::integer,
            50000 + (random() * 150000)::numeric(15,2) -- Meta entre 50k e 200k
        );
    END LOOP;
END $$;

-- ============================================================================
-- 4. PIPELINE DE VENDAS
-- ============================================================================

INSERT INTO pipeline_vendas (nome, descricao, ordem, taxa_conversao_media) VALUES
('Prospecção', 'Identificação de potenciais clientes', 1, 25.00),
('Qualificação', 'Qualificação do lead', 2, 40.00),
('Proposta', 'Envio de proposta comercial', 3, 60.00),
('Negociação', 'Negociação de condições', 4, 75.00),
('Fechamento', 'Fechamento do negócio', 5, 85.00);

-- ============================================================================
-- 5. PRODUTOS (1000+)
-- ============================================================================

DO $$
DECLARE
    v_categorias VARCHAR[] := ARRAY['Matéria Prima', 'Componentes', 'Equipamentos', 'Ferramentas', 'Insumos', 
                                     'Serviços', 'Consultoria', 'Software', 'Hardware', 'Manutenção'];
    v_subcategorias VARCHAR[] := ARRAY['Industrial', 'Comercial', 'Residencial', 'Automotivo', 'Agrícola', 
                                        'Eletrônico', 'Mecânico', 'Elétrico', 'Hidráulico', 'Químico'];
    v_unidades VARCHAR[] := ARRAY['UN', 'KG', 'L', 'M', 'M2', 'M3', 'CX', 'PCT', 'TON', 'SERVIÇO'];
    i INTEGER;
BEGIN
    FOR i IN 1..1200 LOOP
        INSERT INTO produtos (
            codigo,
            nome,
            descricao,
            categoria,
            subcategoria,
            unidade_medida,
            preco_base,
            custo,
            estoque_atual,
            ativo
        ) VALUES (
            'PROD-' || lpad(i::text, 6, '0'),
            'Produto ' || i || ' - ' || v_categorias[1 + floor(random() * array_length(v_categorias, 1))],
            'Descrição detalhada do produto ' || i || ' para uso ' || 
            v_subcategorias[1 + floor(random() * array_length(v_subcategorias, 1))],
            v_categorias[1 + floor(random() * array_length(v_categorias, 1))],
            v_subcategorias[1 + floor(random() * array_length(v_subcategorias, 1))],
            v_unidades[1 + floor(random() * array_length(v_unidades, 1))],
            (50 + random() * 10000)::numeric(15,2),
            (30 + random() * 5000)::numeric(15,2),
            floor(random() * 1000)::integer,
            random() > 0.1 -- 90% ativos
        );
    END LOOP;
END $$;

-- ============================================================================
-- 6. EMPRESAS CLIENTES (5000+)
-- ============================================================================

DO $$
DECLARE
    v_razao_social_base VARCHAR[];
    v_sufixo VARCHAR[] := ARRAY[' Ltda', ' S.A.', ' EIRELI', ' ME', ' EPP'];
    v_portes VARCHAR[] := ARRAY['MEI', 'ME', 'EPP', 'MEDIA', 'GRANDE'];
    v_status VARCHAR[] := ARRAY['ATIVO', 'ATIVO', 'ATIVO', 'ATIVO', 'PROSPECTO', 'INATIVO'];
    v_origens VARCHAR[] := ARRAY['INDICACAO', 'MARKETING', 'PROSPECÇÃO', 'EVENTO', 'REDES_SOCIAIS', 'SITE'];
    v_cidades_sp VARCHAR[] := ARRAY['São Paulo', 'Campinas', 'Santos', 'Ribeirão Preto', 'Sorocaba', 'São José dos Campos'];
    v_cidades_rj VARCHAR[] := ARRAY['Rio de Janeiro', 'Niterói', 'Nova Iguaçu', 'Duque de Caxias'];
    v_cidades_mg VARCHAR[] := ARRAY['Belo Horizonte', 'Uberlândia', 'Contagem', 'Betim'];
    v_cidades_pr VARCHAR[] := ARRAY['Curitiba', 'Londrina', 'Maringá', 'Ponta Grossa'];
    v_cidades_rs VARCHAR[] := ARRAY['Porto Alegre', 'Caxias do Sul', 'Pelotas', 'Canoas'];
    i INTEGER;
    v_cnpj VARCHAR;
    v_segmento_id INTEGER;
    v_regiao_id INTEGER;
    v_analista_id INTEGER;
    v_estado VARCHAR;
    v_cidade VARCHAR;
BEGIN
    v_razao_social_base := ARRAY[
        'Indústria e Comércio', 'Metalúrgica', 'Distribuidora', 'Comércio', 'Serviços',
        'Tecnologia', 'Alimentos', 'Têxtil', 'Química', 'Farmacêutica', 'Automotiva',
        'Construção', 'Logística', 'Consultoria', 'Agropecuária', 'Mineração', 'Energia',
        'Comunicação', 'Transportes', 'Engenharia', 'Eletrônica', 'Plásticos', 'Máquinas',
        'Equipamentos', 'Ferramentas', 'Componentes', 'Materiais', 'Soluções', 'Sistemas'
    ];

    FOR i IN 1..5500 LOOP
        -- Gera CNPJ fictício
        v_cnpj := lpad(floor(random() * 100000000)::text, 8, '0') || '0001' || 
                  lpad(floor(random() * 100)::text, 2, '0');
        v_cnpj := substr(v_cnpj, 1, 2) || '.' || substr(v_cnpj, 3, 3) || '.' || 
                  substr(v_cnpj, 6, 3) || '/' || substr(v_cnpj, 9, 4) || '-' || substr(v_cnpj, 13, 2);
        
        -- Seleciona segmento, região e analista aleatórios
        SELECT id INTO v_segmento_id FROM segmentos_mercado ORDER BY random() LIMIT 1;
        SELECT id INTO v_regiao_id FROM regioes WHERE tipo = 'REGIAO_COMERCIAL' ORDER BY random() LIMIT 1;
        SELECT id INTO v_analista_id FROM analistas_comerciais WHERE ativo = TRUE ORDER BY random() LIMIT 1;
        
        -- Define estado e cidade baseado na região
        SELECT r_estado.sigla INTO v_estado 
        FROM regioes r_comercial
        JOIN regioes r_estado ON r_comercial.regiao_pai_id = r_estado.id
        WHERE r_comercial.id = v_regiao_id;
        
        -- Seleciona cidade baseada no estado
        CASE v_estado
            WHEN 'SP' THEN v_cidade := v_cidades_sp[1 + floor(random() * array_length(v_cidades_sp, 1))];
            WHEN 'RJ' THEN v_cidade := v_cidades_rj[1 + floor(random() * array_length(v_cidades_rj, 1))];
            WHEN 'MG' THEN v_cidade := v_cidades_mg[1 + floor(random() * array_length(v_cidades_mg, 1))];
            WHEN 'PR' THEN v_cidade := v_cidades_pr[1 + floor(random() * array_length(v_cidades_pr, 1))];
            WHEN 'RS' THEN v_cidade := v_cidades_rs[1 + floor(random() * array_length(v_cidades_rs, 1))];
            ELSE v_cidade := 'Cidade ' || i;
        END CASE;
        
        INSERT INTO empresas_clientes (
            cnpj,
            razao_social,
            nome_fantasia,
            email,
            telefone,
            logradouro,
            numero,
            bairro,
            cidade,
            estado,
            cep,
            regiao_id,
            segmento_id,
            porte,
            faturamento_anual_estimado,
            numero_funcionarios,
            status,
            origem,
            data_primeira_compra,
            analista_responsavel_id,
            score_cliente
        ) VALUES (
            v_cnpj,
            v_razao_social_base[1 + floor(random() * array_length(v_razao_social_base, 1))] || 
            ' ' || chr(65 + floor(random() * 26)::integer) || chr(65 + floor(random() * 26)::integer) ||
            v_sufixo[1 + floor(random() * array_length(v_sufixo, 1))],
            'Empresa ' || i || ' ' || v_razao_social_base[1 + floor(random() * array_length(v_razao_social_base, 1))],
            'contato' || i || '@empresa' || i || '.com.br',
            '(' || lpad((11 + floor(random() * 89))::text, 2, '0') || ') ' || 
            lpad((3000 + floor(random() * 4999))::text, 4, '0') || '-' || 
            lpad((1000 + floor(random() * 8999))::text, 4, '0'),
            'Rua ' || chr(65 + floor(random() * 26)::integer) || chr(65 + floor(random() * 26)::integer),
            (1 + floor(random() * 9999))::text,
            'Centro',
            v_cidade,
            v_estado,
            lpad((10000 + floor(random() * 89999))::text, 5, '0') || '-' || 
            lpad((100 + floor(random() * 899))::text, 3, '0'),
            v_regiao_id,
            v_segmento_id,
            v_portes[1 + floor(random() * array_length(v_portes, 1))],
            (100000 + random() * 50000000)::numeric(15,2),
            floor(5 + random() * 995)::integer,
            v_status[1 + floor(random() * array_length(v_status, 1))],
            v_origens[1 + floor(random() * array_length(v_origens, 1))],
            CASE WHEN random() > 0.3 THEN CURRENT_DATE - (random() * 1000)::integer ELSE NULL END,
            v_analista_id,
            floor(random() * 100)::integer
        );
        
        -- Adiciona contatos para empresas (1-3 contatos por empresa)
        FOR j IN 1..(1 + floor(random() * 3))::integer LOOP
            INSERT INTO contatos_empresas (
                empresa_id,
                nome,
                cargo,
                email,
                telefone,
                departamento,
                decisor
            ) VALUES (
                currval('empresas_clientes_id_seq'),
                chr(65 + floor(random() * 26)::integer) || chr(97 + floor(random() * 26)::integer) || 
                chr(97 + floor(random() * 26)::integer) || ' da Silva',
                CASE floor(random() * 5)::integer
                    WHEN 0 THEN 'Gerente de Compras'
                    WHEN 1 THEN 'Diretor Comercial'
                    WHEN 2 THEN 'Coordenador de Suprimentos'
                    WHEN 3 THEN 'Analista de Compras'
                    ELSE 'Assistente Administrativo'
                END,
                'contato' || j || '@empresa' || i || '.com.br',
                '(' || lpad((11 + floor(random() * 89))::text, 2, '0') || ') ' || 
                lpad((90000 + floor(random() * 9999))::text, 5, '0') || '-' || 
                lpad((1000 + floor(random() * 8999))::text, 4, '0'),
                CASE floor(random() * 4)::integer
                    WHEN 0 THEN 'Compras'
                    WHEN 1 THEN 'Comercial'
                    WHEN 2 THEN 'Administrativo'
                    ELSE 'Financeiro'
                END,
                j = 1 AND random() > 0.5
            );
        END LOOP;
    END LOOP;
END $$;

-- ============================================================================
-- 7. OPORTUNIDADES DE VENDAS (15000+)
-- ============================================================================

DO $$
DECLARE
    v_empresa_id INTEGER;
    v_analista_id INTEGER;
    v_pipeline_id INTEGER;
    v_status VARCHAR[] := ARRAY['EM_ANDAMENTO', 'EM_ANDAMENTO', 'EM_ANDAMENTO', 'GANHO', 'GANHO', 'PERDIDO', 'CANCELADO'];
    v_categorias VARCHAR[] := ARRAY['Matéria Prima', 'Equipamentos', 'Serviços', 'Consultoria', 'Manutenção'];
    i INTEGER;
    v_data_abertura DATE;
    v_data_fechamento DATE;
BEGIN
    FOR i IN 1..18000 LOOP
        SELECT id INTO v_empresa_id FROM empresas_clientes ORDER BY random() LIMIT 1;
        SELECT analista_responsavel_id INTO v_analista_id FROM empresas_clientes WHERE id = v_empresa_id;
        SELECT id INTO v_pipeline_id FROM pipeline_vendas ORDER BY random() LIMIT 1;
        
        v_data_abertura := CURRENT_DATE - (random() * 730)::integer; -- Últimos 2 anos
        v_data_fechamento := CASE 
            WHEN random() > 0.4 THEN v_data_abertura + (random() * 180)::integer 
            ELSE NULL 
        END;
        
        INSERT INTO oportunidades_vendas (
            empresa_id,
            titulo,
            descricao,
            valor_estimado,
            valor_real,
            probabilidade_fechamento,
            pipeline_id,
            status,
            data_abertura,
            data_previsao_fechamento,
            data_fechamento,
            analista_id,
            categoria_produto,
            quantidade_estimada
        ) VALUES (
            v_empresa_id,
            'Oportunidade ' || i || ' - ' || v_categorias[1 + floor(random() * array_length(v_categorias, 1))],
            'Descrição detalhada da oportunidade de venda ' || i,
            (5000 + random() * 500000)::numeric(15,2),
            CASE WHEN v_data_fechamento IS NOT NULL 
                 THEN (5000 + random() * 500000)::numeric(15,2) 
                 ELSE NULL 
            END,
            floor(20 + random() * 80)::integer,
            v_pipeline_id,
            v_status[1 + floor(random() * array_length(v_status, 1))],
            v_data_abertura,
            v_data_abertura + (30 + floor(random() * 120))::integer,
            v_data_fechamento,
            v_analista_id,
            v_categorias[1 + floor(random() * array_length(v_categorias, 1))],
            floor(1 + random() * 100)::integer
        );
    END LOOP;
END $$;

-- ============================================================================
-- 8. INTERAÇÕES COM CLIENTES (30000+)
-- ============================================================================

DO $$
DECLARE
    v_empresa_id INTEGER;
    v_analista_id INTEGER;
    v_tipos VARCHAR[] := ARRAY['REUNIAO', 'LIGACAO', 'EMAIL', 'VISITA', 'WHATSAPP'];
    v_resultados VARCHAR[] := ARRAY['POSITIVO', 'NEUTRO', 'NEGATIVO'];
    i INTEGER;
BEGIN
    FOR i IN 1..35000 LOOP
        SELECT id, analista_responsavel_id INTO v_empresa_id, v_analista_id 
        FROM empresas_clientes ORDER BY random() LIMIT 1;
        
        INSERT INTO interacoes_clientes (
            empresa_id,
            analista_id,
            tipo,
            assunto,
            descricao,
            resultado,
            data_interacao,
            duracao_minutos
        ) VALUES (
            v_empresa_id,
            v_analista_id,
            v_tipos[1 + floor(random() * array_length(v_tipos, 1))],
            'Assunto da interação ' || i,
            'Detalhes da interação realizada com o cliente ' || i,
            v_resultados[1 + floor(random() * array_length(v_resultados, 1))],
            CURRENT_TIMESTAMP - (random() * 730 || ' days')::interval,
            floor(5 + random() * 120)::integer
        );
    END LOOP;
END $$;

-- Continua no próximo arquivo...
