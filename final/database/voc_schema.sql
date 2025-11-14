-- Voice-of-Customer (VoC) minimal schema

CREATE TABLE IF NOT EXISTS voc_messages (
  id          SERIAL PRIMARY KEY,
  msg_id      TEXT NOT NULL,
  space       TEXT NOT NULL,
  user_email  TEXT,
  text        TEXT NOT NULL,
  topic       TEXT NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  -- Clasificación MoSCoW
  priority    VARCHAR(20),
  score       INT,
  -- Cierre del ciclo (Solución)
  osticket_id INT,
  solution    TEXT,
  solution_at TIMESTAMPTZ
);

-- Único para que ON CONFLICT (msg_id) funcione
CREATE UNIQUE INDEX IF NOT EXISTS ux_voc_messages_msg_id
  ON voc_messages (msg_id);

CREATE INDEX IF NOT EXISTS idx_voc_messages_topic_created_at
  ON voc_messages (topic, created_at);

CREATE TABLE IF NOT EXISTS voc_topics (
  topic             TEXT PRIMARY KEY,
  label             TEXT,
  last_seen         TIMESTAMPTZ NOT NULL DEFAULT now(),
  priority          TEXT
);
