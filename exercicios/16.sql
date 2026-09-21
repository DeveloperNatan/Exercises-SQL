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
SELECT * FROM chamados;

SELECT COUNT(*) FROM chamados 
WHERE status = 'Aguardando cliente'
	AND criado_em < now() - interval '30 days';	

BEGIN;

UPDATE chamados
SET status = 'Fechado',
	fechado_em = now()
WHERE status = 'Aguardando cliente'
	AND criado_em < now() - interval '30 days';	

ROLLBACK;