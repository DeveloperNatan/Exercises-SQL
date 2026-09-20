-- 3) Liste os chamados cujo titulo contenha "Satake", sem diferenciar maiusculas.OK
SELECT * FROM chamados WHERE titulo ILIKE '%Satake%';