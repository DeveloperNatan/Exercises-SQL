-- 5) Quantos chamados cada tecnico tem?  Traga o nome do tecnico e a contagem.
SELECT A.nome, A.ativo, COUNT(B.id) AS total_chamados 
FROM tecnicos A 
	LEFT JOIN chamados B ON B.tecnico_id = A.id
		GROUP BY A.id, A.nome, A.ativo
		ORDER BY total_chamados DESC;
	
