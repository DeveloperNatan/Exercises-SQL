-- ============================================================
--  EXERCICIOS - resolva escrevendo a query abaixo de cada enunciado.
--  Gabarito comentado em 04_gabarito.sql (so olhe depois de tentar!)
--  Rodar: psql -p 5433 suporte_lab
-- ============================================================

-- ---------- BLOCO 1: SELECT, WHERE, LIKE, IN, BETWEEN (15 min) ----------

-- 1) Liste id, titulo, prioridade e criado_em dos chamados de prioridade
--    'Alta' ou 'Critica' criados em AGOSTO de 2026, do mais novo para o mais antigo.


-- 2) Liste os clientes de Joinville ou Blumenau que NAO sejam do plano 'Basico',
--    ordenados pela data de contrato (mais antigo primeiro).


-- 3) Liste os chamados cujo titulo contenha "Satake", sem diferenciar maiusculas.


-- ---------- BLOCO 2: JOIN (30 min - o que mais cai) ----------

-- 4) Mostre id do chamado, titulo, nome do CLIENTE e nome da CATEGORIA.
--    Limite em 20 linhas.


-- 5) Quantos chamados cada tecnico tem?  Traga o nome do tecnico e a contagem.
--    ATENCAO: a tecnica Silvia Kretzer esta inativa e nao tem nenhum chamado.
--    Ela PRECISA aparecer na lista, com zero. Faca com LEFT JOIN.
--    Depois troque por INNER JOIN e veja o que acontece - essa e a resposta
--    que o entrevistador quer ouvir sobre a diferenca entre os dois.


-- 6) Liste os chamados com status 'Fechado' que NAO receberam avaliacao.
--    (LEFT JOIN + IS NULL)


-- ---------- BLOCO 3: GROUP BY, HAVING, agregacoes (30 min) ----------

-- 7) Quantidade de chamados por status, do maior para o menor.


-- 8) Quantidade de chamados por cliente, mostrando SOMENTE os clientes
--    com mais de 60 chamados. Ordene do maior para o menor.


-- 9) Por categoria: total de chamados, quantos estao fechados e a media de
--    minutos apontados nas interacoes (arredondada com 1 casa).


-- ---------- BLOCO 4: CASE WHEN, subquery, EXISTS (25 min) ----------

-- 10) Classifique os chamados FECHADOS por tempo de solucao em tres faixas:
--     'Ate 4h', 'De 4h a 24h', 'Mais de 24h' - e conte quantos caem em cada uma.
--     Dica: fechado_em - criado_em da um interval; EXTRACT(EPOCH FROM ...)/3600 da horas.


-- 11) Taxa de reabertura por tecnico: nome, total de chamados fechados,
--     quantos foram reabertos e o percentual com 1 casa decimal.
--     Ordene do menor percentual para o maior (o melhor primeiro).


-- 12) Quais clientes tem pelo menos um chamado de prioridade 'Critica'?
--     Resolva com EXISTS.


-- 13) Liste os chamados fechados cujo tempo de solucao foi MAIOR que a media
--     geral de tempo de solucao de todos os chamados fechados.


-- ---------- BLOCO 5: as armadilhas reais + UPDATE seguro (20 min) ----------

-- 14) SLA: para cada cliente, calcule o percentual de chamados fechados dentro
--     do SLA de solucao (fechado_em - criado_em <= sla_solucao_horas).
--     CUIDADO: os clientes Satake e Rede Farma Vida estao SEM SLA configurado
--     (colunas NULL). Eles NAO podem aparecer como 0% - precisam sair marcados
--     como 'Sem SLA configurado'. Esse e exatamente o problema do seu export.


-- 15) Duas perguntas numa query so (ou duas queries, se preferir):
--     a) Quantos chamados tem primeiro_atendimento_em ANTERIOR a criado_em?
--        (acontece quando o tecnico atende e abre o ticket depois - origem 'Agente')
--     b) Qual a MEDIANA do tempo de primeiro atendimento, em horas, considerando
--        apenas os chamados em que a ordem faz sentido?
--        Dica: percentile_cont(0.5) WITHIN GROUP (ORDER BY ...)


-- 16) UPDATE SEGURO - o exercicio mais importante para a entrevista.
--     Objetivo: fechar os chamados com status 'Aguardando cliente' parados
--     ha mais de 30 dias (sem interacao desde entao).
--     Faca NA ORDEM:
--       a) escreva o SELECT com o WHERE exato, e veja quantas linhas retornam
--       b) BEGIN;
--       c) o UPDATE com o MESMO WHERE  (marque status='Fechado', fechado_em=now())
--       d) confira o numero de linhas afetadas - bate com o SELECT?
--       e) ROLLBACK;  (para o lab continuar intacto)
--     Treine falar isso em voz alta enquanto executa.

