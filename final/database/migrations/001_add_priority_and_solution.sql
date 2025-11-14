-- Migración: Agregar columnas de clasificación y solución a voc_messages
-- Fecha: 2025-11-12
-- Descripción: Extensión del esquema para soportar priorización MoSCoW y cierre del ciclo

-- 1. Agregar columnas de clasificación
ALTER TABLE voc_messages ADD COLUMN IF NOT EXISTS priority VARCHAR(20);
ALTER TABLE voc_messages ADD COLUMN IF NOT EXISTS score INT;

-- 2. Agregar columnas para el cierre del ciclo (Solución)
ALTER TABLE voc_messages ADD COLUMN IF NOT EXISTS osticket_id INT; -- Para vincular con osTicket
ALTER TABLE voc_messages ADD COLUMN IF NOT EXISTS solution TEXT;    -- Para guardar la respuesta del agente
ALTER TABLE voc_messages ADD COLUMN IF NOT EXISTS solution_at TIMESTAMPTZ;

-- 3. Verificar estructura actualizada
\d voc_messages
