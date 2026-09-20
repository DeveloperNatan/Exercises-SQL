-- ============================================================
--  SQL LAB - Service Desk  |  preparacao entrevista Neomind
--  Schema no estilo de um sistema de chamados (TiFlux-like)
-- ============================================================

DROP TABLE IF EXISTS avaliacoes, interacoes, chamados, categorias, tecnicos, clientes CASCADE;

-- Clientes atendidos. Repare: dois clientes novos estao SEM SLA
-- configurado (colunas NULL) - a mesma armadilha do TiFlux real.
CREATE TABLE clientes (
    id                      SERIAL PRIMARY KEY,
    nome                    TEXT        NOT NULL,
    cidade                  TEXT        NOT NULL,
    plano                   TEXT        NOT NULL,   -- Basico / Padrao / Premium
    data_contrato           DATE        NOT NULL,
    ativo                   BOOLEAN     NOT NULL DEFAULT TRUE,
    sla_atendimento_horas   INT,                    -- NULL = sem SLA configurado
    sla_solucao_horas       INT
);

CREATE TABLE tecnicos (
    id              SERIAL PRIMARY KEY,
    nome            TEXT    NOT NULL,
    nivel           TEXT    NOT NULL,   -- N1 / N2 / N3
    data_admissao   DATE    NOT NULL,
    ativo           BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE categorias (
    id      SERIAL PRIMARY KEY,
    nome    TEXT NOT NULL,
    area    TEXT NOT NULL    -- Infraestrutura / Aplicacao / Integracao
);

CREATE TABLE chamados (
    id                      SERIAL PRIMARY KEY,
    cliente_id              INT NOT NULL REFERENCES clientes(id),
    tecnico_id              INT          REFERENCES tecnicos(id),   -- NULL = sem responsavel
    categoria_id            INT NOT NULL REFERENCES categorias(id),
    titulo                  TEXT        NOT NULL,
    prioridade              TEXT        NOT NULL,   -- Baixa / Media / Alta / Critica
    status                  TEXT        NOT NULL,   -- Novo / Em andamento / Aguardando cliente / Fechado
    origem                  TEXT        NOT NULL,   -- Portal / E-mail / Telefone / Agente
    criado_em               TIMESTAMP   NOT NULL,
    primeiro_atendimento_em TIMESTAMP,              -- pode ser ANTERIOR a criado_em (origem Agente)
    fechado_em              TIMESTAMP,              -- NULL enquanto nao fecha
    reaberto                BOOLEAN     NOT NULL DEFAULT FALSE
);

CREATE TABLE interacoes (
    id                SERIAL PRIMARY KEY,
    chamado_id        INT NOT NULL REFERENCES chamados(id) ON DELETE CASCADE,
    tecnico_id        INT          REFERENCES tecnicos(id),
    tipo              TEXT      NOT NULL,   -- Publica / Interna
    minutos_apontados INT       NOT NULL,
    criado_em         TIMESTAMP NOT NULL
);

CREATE TABLE avaliacoes (
    id          SERIAL PRIMARY KEY,
    chamado_id  INT NOT NULL UNIQUE REFERENCES chamados(id) ON DELETE CASCADE,
    nota        INT NOT NULL CHECK (nota BETWEEN 1 AND 5),
    comentario  TEXT,
    criado_em   TIMESTAMP NOT NULL
);

CREATE INDEX idx_chamados_cliente   ON chamados(cliente_id);
CREATE INDEX idx_chamados_tecnico   ON chamados(tecnico_id);
CREATE INDEX idx_chamados_criado_em ON chamados(criado_em);
