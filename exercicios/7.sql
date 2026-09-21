SELECT ch.status, COUNT(ch.id) AS quantidade
FROM chamados ch
	GROUP BY  ch.status
	ORDER BY quantidade DESC;