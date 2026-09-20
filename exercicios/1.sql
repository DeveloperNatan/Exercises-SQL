-- 1) Liste id, titulo, prioridade e criado_em dos chamados de prioridade
--    'Alta' ou 'Critica' criados em AGOSTO de 2026, do mais novo para o mais antigo.OK

SELECT id, titulo, prioridade, criado_em 
FROM chamados 
WHERE prioridade IN('Alta', 'Critica')
	AND criado_em >= DATE'2026-08-01'
	AND criado_em < DATE '2026-09-01'
ORDER BY criado_em DESC;




 