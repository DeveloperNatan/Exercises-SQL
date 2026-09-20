-- 2) Liste os clientes de Joinville ou Blumenau que NAO sejam do plano 'Basico',
--    ordenados pela data de contrato (mais antigo primeiro).OK

SELECT * FROM clientes 
WHERE cidade IN('Joinville', 'Blumenau')
	AND plano NOT IN('Basico')
ORDER BY data_contrato ASC;
