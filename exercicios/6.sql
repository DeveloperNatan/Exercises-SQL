SELECT ch.id, ch.titulo, ch.fechado_em, ch.status, a.nota
FROM chamados ch
	LEFT JOIN avaliacoes a ON a.chamado_id = ch.id
WHERE ch.status = 'Fechado'
	AND a.id IS NULL;