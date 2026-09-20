-- ============================================================
--  CARTAO DE SINTAXE - consulte a vontade enquanto resolve
--  (sintaxe nao e cola; a escolha da ferramenta e que e o exercicio)
-- ============================================================

-- ---------- o esqueleto, sempre nesta ordem ----------
SELECT   colunas
FROM     tabela
JOIN     outra   ON  condicao_de_ligacao
WHERE    filtro_de_linha
GROUP BY colunas_do_agrupamento
HAVING   filtro_do_grupo
ORDER BY coluna [ASC|DESC]
LIMIT    n;
-- escreve nessa ordem; executa nesta:
-- FROM -> JOIN -> WHERE -> GROUP BY -> HAVING -> SELECT -> ORDER BY -> LIMIT
-- (por isso apelido do SELECT nao funciona no WHERE, mas funciona no ORDER BY)

-- ---------- literais ----------
'texto'                 -- VALOR: sempre aspas simples
"coluna"                -- IDENTIFICADOR: aspas duplas (raro precisar)
'2026-08-01'            -- data, formato ISO AAAA-MM-DD
DATE '2026-08-01'       -- data explicita
TIMESTAMP '2026-08-01 14:30'
123                     -- numero: sem aspas
TRUE / FALSE / NULL

-- ---------- comparacao e filtro ----------
=  <>  <  <=  >  >=
coluna IN ('a','b')            -- um de varios (mesma coluna)
coluna NOT IN ('a','b')        -- cuidado: NULL na lista zera o resultado
coluna BETWEEN 1 AND 10        -- inclusivo nas DUAS pontas
coluna IS NULL / IS NOT NULL   -- NUNCA use "= NULL"
coluna LIKE  '%texto%'         -- % = qualquer coisa, _ = um caractere
coluna ILIKE '%texto%'         -- LIKE ignorando maiuscula/minuscula (Postgres)
cond1 AND cond2                -- AND tem precedencia sobre OR:
cond1 OR  cond2                -- misturou os dois? use parenteses
NOT cond

-- ---------- juntando tabelas ----------
FROM a JOIN       b ON b.a_id = a.id   -- INNER: so quem tem par nos dois lados
FROM a LEFT JOIN  b ON b.a_id = a.id   -- tudo de A; sem par vira NULL
FROM a RIGHT JOIN b ON b.a_id = a.id   -- tudo de B (raro; inverta e use LEFT)
FROM a FULL JOIN  b ON b.a_id = a.id   -- tudo dos dois lados
-- filtro da tabela da DIREITA em LEFT JOIN vai no ON, nao no WHERE
-- (no WHERE ele descarta os NULL e seu LEFT vira INNER)

-- ---------- agregacao ----------
COUNT(*)                 -- conta linhas
COUNT(coluna)            -- conta linhas onde a coluna NAO e NULL
COUNT(DISTINCT coluna)   -- conta valores distintos (salva de join 1:N)
SUM() AVG() MIN() MAX()
ROUND(valor::numeric, 2) -- arredonda com N casas
COUNT(*) FILTER (WHERE condicao)   -- conta so o que bate a condicao
-- equivalente classico: COUNT(CASE WHEN condicao THEN 1 END)
-- tudo que esta no SELECT e nao e agregacao TEM que estar no GROUP BY

-- ---------- condicional ----------
CASE WHEN cond1 THEN 'a'
     WHEN cond2 THEN 'b'
     ELSE 'c'
END
COALESCE(coluna, 'padrao')   -- primeiro valor nao-NULL

-- ---------- subconsulta ----------
WHERE coluna > (SELECT AVG(x) FROM t)              -- valor unico
WHERE EXISTS (SELECT 1 FROM t WHERE t.fk = a.id)   -- "tem pelo menos um?"
WITH nome AS (SELECT ...) SELECT * FROM nome;      -- CTE: organiza query grande

-- ---------- datas e tempo ----------
now()                                  -- timestamp atual
current_date                           -- data de hoje
now() - interval '30 days'             -- aritmetica ('1 hour','2 months'...)
EXTRACT(EPOCH FROM (fim - inicio))/3600   -- diferenca em HORAS
EXTRACT(HOUR FROM coluna)                 -- hora do dia (0-23)
date_trunc('month', coluna)               -- primeiro instante do mes
to_char(coluna, 'YYYY-MM')                -- formata para texto
age(fim, inicio)                          -- diferenca legivel
percentile_cont(0.5) WITHIN GROUP (ORDER BY x)   -- mediana
-- filtro de periodo: coluna >= inicio AND coluna < dia_seguinte
-- NUNCA aplique funcao na coluna filtrada: mata o indice

-- ---------- escrita e seguranca ----------
INSERT INTO t (c1, c2) VALUES ('a', 1);
UPDATE t SET c1 = 'x' WHERE id = 10;    -- sem WHERE = tabela inteira
DELETE FROM t WHERE id = 10;            -- idem, e sem volta

BEGIN;                 -- abre transacao
  -- SELECT com o WHERE exato ANTES do UPDATE, para conferir o alcance
  UPDATE ...;          -- o psql responde "UPDATE <n>": confira o n
ROLLBACK;              -- desfaz   (ou COMMIT; para confirmar)

-- ---------- comandos do psql ----------
-- \dt          lista tabelas
-- \d chamados  estrutura da tabela (colunas, tipos, indices)
-- \x           modo expandido (linha larga fica legivel)
-- \timing      mostra o tempo de cada query
-- \i arq.sql   executa um arquivo
-- \q           sair
-- EXPLAIN ANALYZE <query>   mostra o plano: Seq Scan = leu tudo; Index Scan = usou indice
