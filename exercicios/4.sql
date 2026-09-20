-- 4) Mostre id do chamado, titulo, nome do CLIENTE e nome da CATEGORIA.
--    Limite em 20 linhas.

SELECT A.id AS chamado, A.titulo AS titulo, 
B.nome AS nome_cliente, C.nome AS categoria FROM chamados A 
	LEFT JOIN clientes B ON A.cliente_id = B.id
	LEFT JOIN categorias C ON A.categoria_id = C.id
	LIMIT 20;

