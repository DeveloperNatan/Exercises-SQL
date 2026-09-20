-- ============================================================
--  Carga de dados - volume pequeno, porem realista
--  setseed garante que os dados sejam sempre os mesmos
-- ============================================================
SELECT setseed(0.42);

INSERT INTO clientes (nome, cidade, plano, data_contrato, ativo, sla_atendimento_horas, sla_solucao_horas) VALUES
('Metalurgica Joinville S.A.', 'Joinville',    'Premium', '2021-03-15', TRUE,   1,  8),
('Transportes Babitonga',      'Joinville',    'Padrao',  '2022-07-01', TRUE,   2, 24),
('Clinica Sao Marcos',         'Blumenau',     'Basico',  '2023-01-20', TRUE,   4, 48),
('Industria Textil Vale',      'Blumenau',     'Premium', '2020-11-05', TRUE,   1,  8),
('Supermercados Norte',        'Itajai',       'Padrao',  '2022-02-14', TRUE,   2, 24),
('Construtora Horizonte',      'Joinville',    'Padrao',  '2023-09-10', TRUE,   2, 24),
('Logistica Sul Cargas',       'Sao Francisco','Basico',  '2024-04-02', TRUE,   4, 48),
('Escritorio Contabil Prisma', 'Joinville',    'Basico',  '2021-08-30', FALSE,  4, 48),
('Auto Pecas Schmitt',         'Jaragua',      'Padrao',  '2023-05-22', TRUE,   2, 24),
('Hospital Santa Clara',       'Blumenau',     'Premium', '2019-06-11', TRUE,   1,  4),
-- Contas novas, ainda SEM SLA configurado (igual a mesa Satake no TiFlux):
('Satake Equipamentos',        'Joinville',    'Padrao',  '2026-05-18', TRUE, NULL, NULL),
('Rede Farma Vida',            'Itajai',       'Basico',  '2026-06-30', TRUE, NULL, NULL);

INSERT INTO tecnicos (nome, nivel, data_admissao, ativo) VALUES
('Natan de Souza',   'N2', '2026-03-02', TRUE),
('Carla Bittencourt','N2', '2024-08-12', TRUE),
('Eduardo Prado',    'N1', '2025-11-03', TRUE),
('Marina Lopes',     'N1', '2026-01-15', TRUE),
('Rafael Tissot',    'N3', '2022-05-09', TRUE),
('Juliana Wagner',   'N2', '2023-10-01', TRUE),
('Pedro Hammes',     'N1', '2026-07-20', TRUE),
('Silvia Kretzer',   'N2', '2021-04-19', FALSE);   -- inativa, sem chamados: bom para LEFT JOIN

INSERT INTO categorias (nome, area) VALUES
('Impressora',            'Infraestrutura'),
('Estacao de trabalho',   'Infraestrutura'),
('Rede / Conectividade',  'Infraestrutura'),
('Servidor',              'Infraestrutura'),
('E-mail / M365',         'Infraestrutura'),
('Customizacao / Script', 'Aplicacao'),
('Relatorio',             'Aplicacao'),
('Erro de sistema',       'Aplicacao'),
('Integracao / API',      'Integracao'),
('Importacao de dados',   'Integracao');

-- ---------- chamados ----------
WITH base AS (
    SELECT g AS n,
           1 + floor(random() * 12)::int AS cliente_id,
           1 + floor(random() * 10)::int AS categoria_id,
           timestamp '2026-03-02 08:00'
             + (floor(random() * 195))::int * interval '1 day'
             + (floor(random() * 10))::int  * interval '1 hour'
             + (floor(random() * 60))::int  * interval '1 minute' AS criado_em,
           random() AS r_status, random() AS r_prio, random() AS r_orig,
           random() AS r_tec,    random() AS r_fat,  random() AS r_sol,
           random() AS r_reab
    FROM generate_series(1, 800) g
)
INSERT INTO chamados (cliente_id, tecnico_id, categoria_id, titulo, prioridade, status,
                      origem, criado_em, primeiro_atendimento_em, fechado_em, reaberto)
SELECT
    b.cliente_id,
    CASE WHEN b.r_status < 0.04 THEN NULL              -- sem responsavel ainda
         ELSE 1 + floor(b.r_tec * 7)::int END,          -- tecnicos 1..7 (Silvia fica de fora)
    b.categoria_id,
    c.nome || ' - atendimento #' || b.n,
    CASE WHEN b.r_prio < 0.08 THEN 'Critica'
         WHEN b.r_prio < 0.45 THEN 'Alta'
         WHEN b.r_prio < 0.85 THEN 'Media'
         ELSE 'Baixa' END,
    CASE WHEN b.r_status < 0.04 THEN 'Novo'
         WHEN b.r_status < 0.13 THEN 'Em andamento'
         WHEN b.r_status < 0.19 THEN 'Aguardando cliente'
         ELSE 'Fechado' END,
    CASE WHEN b.r_orig < 0.20 THEN 'Agente'
         WHEN b.r_orig < 0.55 THEN 'Portal'
         WHEN b.r_orig < 0.85 THEN 'E-mail'
         ELSE 'Telefone' END,
    b.criado_em,
    -- origem 'Agente': o tecnico atende e abre o ticket depois -> data ANTERIOR a criacao
    CASE WHEN b.r_status < 0.04 THEN NULL
         WHEN b.r_orig  < 0.20 THEN b.criado_em - (floor(b.r_fat * 90) + 5)::int * interval '1 minute'
         ELSE b.criado_em + (floor(b.r_fat * 600) + 3)::int * interval '1 minute' END,
    -- tempo de solucao ancorado no SLA do cliente: ~85% dentro do prazo,
    -- o resto estoura (ate 4x). Clientes sem SLA usam 24h como referencia.
    CASE WHEN b.r_status < 0.19 THEN NULL
         ELSE b.criado_em
              + (15 + COALESCE(c.sla_solucao_horas, 24) * 60 *
                 CASE WHEN b.r_sol < 0.85 THEN (b.r_sol / 0.85) * 0.95
                      ELSE 1 + ((b.r_sol - 0.85) / 0.15) * 3 END
                )::int * interval '1 minute' END,
    (b.r_status >= 0.19 AND b.r_reab < 0.045)
FROM base b
JOIN clientes c ON c.id = b.cliente_id;

-- ---------- interacoes ----------
INSERT INTO interacoes (chamado_id, tecnico_id, tipo, minutos_apontados, criado_em)
SELECT ch.id,
       ch.tecnico_id,
       CASE WHEN random() < 0.65 THEN 'Publica' ELSE 'Interna' END,
       (floor(random() * 85) + 5)::int,
       ch.criado_em + (floor(random() * 2400) + 10)::int * interval '1 minute'
FROM chamados ch
CROSS JOIN generate_series(1, 5) s
WHERE ch.tecnico_id IS NOT NULL
  AND random() < 0.62;

-- ---------- avaliacoes (so uma parte dos fechados e avaliada) ----------
INSERT INTO avaliacoes (chamado_id, nota, comentario, criado_em)
SELECT ch.id,
       CASE WHEN random() < 0.78 THEN 5
            WHEN random() < 0.85 THEN 4
            WHEN random() < 0.93 THEN 3
            WHEN random() < 0.97 THEN 2
            ELSE 1 END,
       CASE WHEN random() < 0.4 THEN 'Atendimento rapido, obrigado!' ELSE NULL END,
       ch.fechado_em + interval '1 day'
FROM chamados ch
WHERE ch.status = 'Fechado'
  AND random() < 0.24;

ANALYZE;
