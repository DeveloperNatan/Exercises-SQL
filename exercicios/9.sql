
-- 9) Por categoria: total de chamados, quantos estao fechados e a media de
--    minutos apontados nas interacoes (arredondada com 1 casa).
SELECT cat.nome, COUNT(ch.id) AS total_chamados, COUNT(*) FILTER(WHERE ch.status = 'Fechado') AS total_fechado
FROM chamados ch
	INNER JOIN  categorias cat ON cat.id = ch.categoria_id
	GROUP BY cat.nome
	ORDER BY total_chamados DESC;