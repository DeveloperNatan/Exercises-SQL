-- 8) Quantidade de chamados por cliente, mostrando SOMENTE os clientes
--    com mais de 60 chamados. Ordene do maior para o menor.
SELECT cl.nome, COUNT(ch.id) AS total_chamados
FROM clientes cl
	LEFT JOIN chamados ch ON ch.cliente_id = cl.id
	GROUP BY cl.id, cl.nome
	HAVING COUNT(ch.id) >= 60
	ORDER BY total_chamados DESC;