-- ============================================================================
-- OBSERVATÓRIO DA INDÚSTRIA - DADOS SIMULADOS (CONTINUAÇÃO)
-- ============================================================================
-- Parte 2: Pedidos, Notas Fiscais, Contas a Receber e Dados de Campo
-- ============================================================================

-- ============================================================================
-- 9. PEDIDOS DE VENDA (20000+)
-- ============================================================================

DO $$
DECLARE
    v_empresa_id INTEGER;
    v_analista_id INTEGER;
    v_oportunidade_id INTEGER;
    v_status VARCHAR[] := ARRAY['APROVADO', 'APROVADO', 'APROVADO', 'FATURADO', 'FATURADO', 'PENDENTE', 'CANCELADO'];
    i INTEGER;
    v_data_pedido DATE;
    v_valor_bruto NUMERIC(15,2);
    v_valor_desconto NUMERIC(15,2);
    v_pedido_id INTEGER;
    v_produto_id INTEGER;
    v_quantidade INTEGER;
    v_preco_unitario NUMERIC(15,2);
    j INTEGER;
BEGIN
    FOR i IN 1..25000 LOOP
        -- Seleciona empresa e analista
        SELECT id, analista_responsavel_id INTO v_empresa_id, v_analista_id 
        FROM empresas_clientes WHERE status = 'ATIVO' ORDER BY random() LIMIT 1;
        
        -- Tenta encontrar uma oportunidade GANHO para vincular
        SELECT id INTO v_oportunidade_id FROM oportunidades_vendas 
        WHERE empresa_id = v_empresa_id AND status = 'GANHO' 
        ORDER BY random() LIMIT 1;
        
        v_data_pedido := CURRENT_DATE - (random() * 730)::integer;
        v_valor_bruto := (500 + random() * 200000)::numeric(15,2);
        v_valor_desconto := (v_valor_bruto * random() * 0.15)::numeric(15,2);
        
        INSERT INTO pedidos_venda (
            numero_pedido,
            empresa_id,
            oportunidade_id,
            valor_bruto,
            valor_desconto,
            valor_liquido,
            status,
            data_pedido,
            data_previsao_entrega,
            data_aprovacao,
            analista_id,
            observacoes
        ) VALUES (
            'PV-' || TO_CHAR(v_data_pedido, 'YYYYMM') || '-' || lpad(i::text, 6, '0'),
            v_empresa_id,
            v_oportunidade_id,
            v_valor_bruto,
            v_valor_desconto,
            v_valor_bruto - v_valor_desconto,
            v_status[1 + floor(random() * array_length(v_status, 1))],
            v_data_pedido,
            v_data_pedido + (5 + floor(random() * 30))::integer,
            CASE WHEN random() > 0.2 THEN v_data_pedido + floor(random() * 5)::integer ELSE NULL END,
            v_analista_id,
            CASE WHEN random() > 0.7 THEN 'Observações do pedido ' || i ELSE NULL END
        ) RETURNING id INTO v_pedido_id;
        
        -- Adiciona itens ao pedido (2-8 itens por pedido)
        FOR j IN 1..(2 + floor(random() * 7))::integer LOOP
            SELECT id, preco_base INTO v_produto_id, v_preco_unitario 
            FROM produtos WHERE ativo = TRUE ORDER BY random() LIMIT 1;
            
            v_quantidade := (1 + floor(random() * 50))::integer;
            
            INSERT INTO itens_pedido (
                pedido_id,
                produto_id,
                quantidade,
                preco_unitario,
                desconto,
                valor_total
            ) VALUES (
                v_pedido_id,
                v_produto_id,
                v_quantidade,
                v_preco_unitario,
                (v_preco_unitario * v_quantidade * random() * 0.1)::numeric(15,2),
                (v_preco_unitario * v_quantidade * (1 - random() * 0.1))::numeric(15,2)
            );
        END LOOP;
    END LOOP;
END $$;

-- ============================================================================
-- 10. NOTAS FISCAIS (18000+)
-- ============================================================================

DO $$
DECLARE
    v_pedido_id INTEGER;
    v_empresa_id INTEGER;
    v_valor_produtos NUMERIC(15,2);
    v_data_pedido DATE;
    v_status VARCHAR[] := ARRAY['AUTORIZADA', 'AUTORIZADA', 'AUTORIZADA', 'AUTORIZADA', 'EMITIDA', 'CANCELADA'];
    v_naturezas VARCHAR[] := ARRAY['Venda de Mercadoria', 'Venda de Produto', 'Prestação de Serviço', 
                                    'Venda de Mercadoria para Revenda'];
    i INTEGER;
    v_nf_id INTEGER;
    v_item RECORD;
BEGIN
    -- Notas fiscais para pedidos APROVADOS e FATURADOS
    FOR v_pedido_id, v_empresa_id, v_valor_produtos, v_data_pedido IN 
        SELECT pv.id, pv.empresa_id, pv.valor_liquido, pv.data_pedido
        FROM pedidos_venda pv
        WHERE pv.status IN ('APROVADO', 'FATURADO')
        ORDER BY pv.data_pedido
    LOOP
        i := i + 1;
        
        INSERT INTO notas_fiscais (
            numero_nota,
            serie,
            chave_acesso,
            pedido_id,
            empresa_id,
            tipo,
            modelo,
            valor_produtos,
            valor_desconto,
            valor_frete,
            valor_icms,
            valor_ipi,
            valor_pis,
            valor_cofins,
            valor_total,
            status,
            data_emissao,
            data_saida,
            data_autorizacao,
            natureza_operacao
        ) VALUES (
            lpad((100000 + i)::text, 9, '0'),
            '001',
            lpad((i * 12345)::text, 44, '0'),
            v_pedido_id,
            v_empresa_id,
            'SAIDA',
            'NFe',
            v_valor_produtos,
            (v_valor_produtos * random() * 0.05)::numeric(15,2),
            (50 + random() * 500)::numeric(15,2),
            (v_valor_produtos * 0.18)::numeric(15,2),
            (v_valor_produtos * 0.10)::numeric(15,2),
            (v_valor_produtos * 0.0165)::numeric(15,2),
            (v_valor_produtos * 0.076)::numeric(15,2),
            (v_valor_produtos * 1.20)::numeric(15,2),
            v_status[1 + floor(random() * array_length(v_status, 1))],
            v_data_pedido + (1 + floor(random() * 3))::integer,
            v_data_pedido + (2 + floor(random() * 5))::integer,
            v_data_pedido + (1 + floor(random() * 2))::integer,
            v_naturezas[1 + floor(random() * array_length(v_naturezas, 1))]
        ) RETURNING id INTO v_nf_id;
        
        -- Copia itens do pedido para a nota fiscal
        FOR v_item IN 
            SELECT produto_id, quantidade, preco_unitario, valor_total
            FROM itens_pedido WHERE pedido_id = v_pedido_id
        LOOP
            INSERT INTO itens_nota_fiscal (
                nota_fiscal_id,
                produto_id,
                quantidade,
                preco_unitario,
                valor_total,
                aliquota_icms,
                valor_icms,
                aliquota_ipi,
                valor_ipi
            ) VALUES (
                v_nf_id,
                v_item.produto_id,
                v_item.quantidade,
                v_item.preco_unitario,
                v_item.valor_total,
                18.00,
                (v_item.valor_total * 0.18)::numeric(15,2),
                10.00,
                (v_item.valor_total * 0.10)::numeric(15,2)
            );
        END LOOP;
    END LOOP;
END $$;

-- ============================================================================
-- 11. CONTAS A RECEBER (20000+)
-- ============================================================================

DO $$
DECLARE
    v_nf RECORD;
    v_parcelas INTEGER;
    v_valor_parcela NUMERIC(15,2);
    v_formas VARCHAR[] := ARRAY['BOLETO', 'PIX', 'CARTAO', 'TRANSFERENCIA'];
    i INTEGER;
    j INTEGER;
BEGIN
    i := 1;
    FOR v_nf IN 
        SELECT id, empresa_id, valor_total, data_emissao
        FROM notas_fiscais
        WHERE status = 'AUTORIZADA'
        ORDER BY data_emissao
    LOOP
        -- Define número de parcelas (1-6)
        v_parcelas := 1 + floor(random() * 6)::integer;
        v_valor_parcela := v_nf.valor_total / v_parcelas;
        
        FOR j IN 1..v_parcelas LOOP
            INSERT INTO contas_receber (
                nota_fiscal_id,
                empresa_id,
                numero_titulo,
                valor,
                data_emissao,
                data_vencimento,
                data_pagamento,
                status,
                valor_pago,
                forma_pagamento
            ) VALUES (
                v_nf.id,
                v_nf.empresa_id,
                'CR-' || lpad(i::text, 8, '0') || '/' || j,
                v_valor_parcela,
                v_nf.data_emissao,
                v_nf.data_emissao + (30 * j)::integer,
                CASE 
                    WHEN random() > 0.3 THEN v_nf.data_emissao + (30 * j + floor(random() * 5 - 2))::integer
                    ELSE NULL 
                END,
                CASE 
                    WHEN random() > 0.3 THEN 'PAGO'
                    WHEN v_nf.data_emissao + (30 * j)::integer < CURRENT_DATE THEN 'VENCIDO'
                    ELSE 'ABERTO'
                END,
                CASE WHEN random() > 0.3 THEN v_valor_parcela ELSE NULL END,
                v_formas[1 + floor(random() * array_length(v_formas, 1))]
            );
        END LOOP;
        
        i := i + 1;
    END LOOP;
END $$;

-- ============================================================================
-- 12. VISITAS DE CAMPO (25000+)
-- ============================================================================

DO $$
DECLARE
    v_empresa_id INTEGER;
    v_analista_id INTEGER;
    v_niveis VARCHAR[] := ARRAY['BAIXO', 'MEDIO', 'ALTO'];
    v_status VARCHAR[] := ARRAY['REALIZADA', 'REALIZADA', 'REALIZADA', 'AGENDADA', 'CANCELADA'];
    i INTEGER;
    v_data_visita DATE;
BEGIN
    FOR i IN 1..28000 LOOP
        SELECT id, analista_responsavel_id INTO v_empresa_id, v_analista_id 
        FROM empresas_clientes ORDER BY random() LIMIT 1;
        
        v_data_visita := CURRENT_DATE - (random() * 730)::integer;
        
        INSERT INTO visitas_campo (
            empresa_id,
            analista_id,
            data_visita,
            hora_inicio,
            hora_fim,
            objetivo,
            resultado,
            observacoes,
            apresentou_produtos,
            coletou_feedback,
            identificou_necessidades,
            nivel_interesse,
            potencial_compra,
            status
        ) VALUES (
            v_empresa_id,
            v_analista_id,
            v_data_visita,
            (TIME '08:00:00' + (random() * INTERVAL '8 hours'))::TIME,
            (TIME '09:00:00' + (random() * INTERVAL '8 hours'))::TIME,
            CASE floor(random() * 4)::integer
                WHEN 0 THEN 'Apresentação de novos produtos'
                WHEN 1 THEN 'Levantamento de necessidades'
                WHEN 2 THEN 'Follow-up de proposta'
                ELSE 'Visita de relacionamento'
            END,
            'Resultado da visita ' || i || '. Cliente demonstrou interesse em ' || 
            CASE floor(random() * 3)::integer
                WHEN 0 THEN 'equipamentos industriais'
                WHEN 1 THEN 'matéria prima'
                ELSE 'serviços de consultoria'
            END,
            CASE WHEN random() > 0.5 THEN 'Observações adicionais sobre a visita ' || i ELSE NULL END,
            random() > 0.3,
            random() > 0.4,
            random() > 0.2,
            v_niveis[1 + floor(random() * array_length(v_niveis, 1))],
            CASE WHEN random() > 0.4 THEN (5000 + random() * 100000)::numeric(15,2) ELSE NULL END,
            v_status[1 + floor(random() * array_length(v_status, 1))]
        );
    END LOOP;
END $$;

-- ============================================================================
-- 13. PESQUISAS DE MERCADO (8000+)
-- ============================================================================

DO $$
DECLARE
    v_empresa_id INTEGER;
    v_analista_id INTEGER;
    v_frequencias VARCHAR[] := ARRAY['SEMANAL', 'QUINZENAL', 'MENSAL', 'BIMESTRAL', 'TRIMESTRAL'];
    i INTEGER;
BEGIN
    FOR i IN 1..9000 LOOP
        SELECT id, analista_responsavel_id INTO v_empresa_id, v_analista_id 
        FROM empresas_clientes ORDER BY random() LIMIT 1;
        
        INSERT INTO pesquisas_mercado (
            empresa_id,
            analista_id,
            data_pesquisa,
            concorrente_principal,
            preco_concorrente,
            diferenciais_concorrente,
            produtos_interesse,
            volume_compra_mensal,
            frequencia_compra,
            criterios_decisao,
            prazo_decisao,
            observacoes
        ) VALUES (
            v_empresa_id,
            v_analista_id,
            CURRENT_DATE - (random() * 730)::integer,
            'Concorrente ' || chr(65 + floor(random() * 26)::integer),
            (1000 + random() * 50000)::numeric(15,2),
            'Principais diferenciais: ' || 
            CASE floor(random() * 3)::integer
                WHEN 0 THEN 'Preço competitivo e prazo de entrega'
                WHEN 1 THEN 'Qualidade superior e suporte técnico'
                ELSE 'Tradição no mercado e variedade de produtos'
            END,
            'Produtos de interesse: ' ||
            CASE floor(random() * 4)::integer
                WHEN 0 THEN 'Matéria prima industrial'
                WHEN 1 THEN 'Equipamentos e ferramentas'
                WHEN 2 THEN 'Serviços de manutenção'
                ELSE 'Consultoria técnica'
            END,
            (5000 + random() * 100000)::numeric(15,2),
            v_frequencias[1 + floor(random() * array_length(v_frequencias, 1))],
            'Principais critérios: ' ||
            CASE floor(random() * 3)::integer
                WHEN 0 THEN 'Preço, qualidade e prazo de entrega'
                WHEN 1 THEN 'Qualidade, suporte técnico e garantia'
                ELSE 'Tradição, preço e condições de pagamento'
            END,
            CASE floor(random() * 4)::integer
                WHEN 0 THEN 'Imediato'
                WHEN 1 THEN 'Até 30 dias'
                WHEN 2 THEN 'Até 60 dias'
                ELSE 'Até 90 dias'
            END,
            CASE WHEN random() > 0.6 THEN 'Observações adicionais da pesquisa ' || i ELSE NULL END
        );
    END LOOP;
END $$;

-- ============================================================================
-- 14. METAS DE VENDAS (para todos analistas, últimos 24 meses)
-- ============================================================================

DO $$
DECLARE
    v_analista RECORD;
    v_ano INTEGER;
    v_mes INTEGER;
    v_data_base DATE;
BEGIN
    -- Para cada analista ativo
    FOR v_analista IN 
        SELECT id, regiao_id, meta_mensal, data_admissao
        FROM analistas_comerciais 
        WHERE ativo = TRUE
    LOOP
        -- Últimos 24 meses
        FOR i IN 0..23 LOOP
            v_data_base := CURRENT_DATE - (i || ' months')::interval;
            v_ano := EXTRACT(YEAR FROM v_data_base);
            v_mes := EXTRACT(MONTH FROM v_data_base);
            
            -- Só cria meta se o analista já estava admitido
            IF v_data_base >= v_analista.data_admissao THEN
                INSERT INTO metas_vendas (
                    analista_id,
                    regiao_id,
                    ano,
                    mes,
                    meta_faturamento,
                    meta_novos_clientes,
                    meta_visitas,
                    meta_oportunidades,
                    realizado_faturamento,
                    realizado_novos_clientes,
                    realizado_visitas,
                    realizado_oportunidades
                ) VALUES (
                    v_analista.id,
                    v_analista.regiao_id,
                    v_ano,
                    v_mes,
                    v_analista.meta_mensal,
                    5 + floor(random() * 10)::integer,
                    20 + floor(random() * 30)::integer,
                    10 + floor(random() * 20)::integer,
                    -- Realizado entre 60% e 140% da meta
                    (v_analista.meta_mensal * (0.6 + random() * 0.8))::numeric(15,2),
                    floor((5 + random() * 10) * (0.6 + random() * 0.8))::integer,
                    floor((20 + random() * 30) * (0.6 + random() * 0.8))::integer,
                    floor((10 + random() * 20) * (0.6 + random() * 0.8))::integer
                );
            END IF;
        END LOOP;
    END LOOP;
END $$;

-- ============================================================================
-- 15. PROPOSTAS COMERCIAIS (12000+)
-- ============================================================================

DO $$
DECLARE
    v_empresa_id INTEGER;
    v_analista_id INTEGER;
    v_oportunidade_id INTEGER;
    v_status VARCHAR[] := ARRAY['ENVIADA', 'APROVADA', 'REJEITADA', 'NEGOCIACAO', 'RASCUNHO'];
    v_formas_pgto VARCHAR[] := ARRAY['30/60/90 dias', '28 dias', 'À vista', '30 dias', '45 dias', 
                                      '60 dias', 'Parcelado em 6x'];
    i INTEGER;
    v_data_criacao DATE;
BEGIN
    FOR i IN 1..14000 LOOP
        SELECT id, analista_responsavel_id INTO v_empresa_id, v_analista_id 
        FROM empresas_clientes ORDER BY random() LIMIT 1;
        
        -- Tenta vincular a uma oportunidade
        SELECT id INTO v_oportunidade_id FROM oportunidades_vendas 
        WHERE empresa_id = v_empresa_id ORDER BY random() LIMIT 1;
        
        v_data_criacao := CURRENT_DATE - (random() * 730)::integer;
        
        INSERT INTO propostas_comerciais (
            numero_proposta,
            empresa_id,
            oportunidade_id,
            analista_id,
            titulo,
            descricao,
            valor_proposta,
            prazo_validade,
            prazo_entrega,
            forma_pagamento,
            condicoes_especiais,
            status,
            data_criacao,
            data_envio,
            data_resposta,
            data_validade,
            motivo_rejeicao,
            observacoes
        ) VALUES (
            'PROP-' || TO_CHAR(v_data_criacao, 'YYYYMM') || '-' || lpad(i::text, 6, '0'),
            v_empresa_id,
            v_oportunidade_id,
            v_analista_id,
            'Proposta Comercial ' || i,
            'Proposta detalhada para fornecimento de ' ||
            CASE floor(random() * 4)::integer
                WHEN 0 THEN 'equipamentos industriais'
                WHEN 1 THEN 'matéria prima'
                WHEN 2 THEN 'serviços de consultoria'
                ELSE 'manutenção preventiva'
            END,
            (5000 + random() * 300000)::numeric(15,2),
            30 + floor(random() * 60)::integer,
            15 + floor(random() * 45)::integer,
            v_formas_pgto[1 + floor(random() * array_length(v_formas_pgto, 1))],
            CASE WHEN random() > 0.6 THEN 'Desconto especial para volumes acima de X unidades' ELSE NULL END,
            v_status[1 + floor(random() * array_length(v_status, 1))],
            v_data_criacao,
            CASE WHEN random() > 0.2 THEN v_data_criacao + floor(random() * 3)::integer ELSE NULL END,
            CASE WHEN random() > 0.5 THEN v_data_criacao + (5 + floor(random() * 20))::integer ELSE NULL END,
            v_data_criacao + (30 + floor(random() * 60))::integer,
            CASE WHEN random() > 0.7 THEN 
                CASE floor(random() * 3)::integer
                    WHEN 0 THEN 'Preço acima do orçamento disponível'
                    WHEN 1 THEN 'Prazo de entrega inadequado'
                    ELSE 'Optou por outro fornecedor'
                END
            ELSE NULL END,
            CASE WHEN random() > 0.7 THEN 'Observações sobre a proposta ' || i ELSE NULL END
        );
    END LOOP;
END $$;

-- ============================================================================
-- ATUALIZAÇÃO DE ESTATÍSTICAS
-- ============================================================================

ANALYZE regioes;
ANALYZE segmentos_mercado;
ANALYZE analistas_comerciais;
ANALYZE empresas_clientes;
ANALYZE contatos_empresas;
ANALYZE pipeline_vendas;
ANALYZE oportunidades_vendas;
ANALYZE interacoes_clientes;
ANALYZE produtos;
ANALYZE pedidos_venda;
ANALYZE itens_pedido;
ANALYZE notas_fiscais;
ANALYZE itens_nota_fiscal;
ANALYZE contas_receber;
ANALYZE visitas_campo;
ANALYZE pesquisas_mercado;
ANALYZE metas_vendas;
ANALYZE propostas_comerciais;
