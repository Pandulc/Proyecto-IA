# Voice-of-Customer Miner

Plataforma que procesa pedidos de soporte de clientes recibidos vía Google Chat, los normaliza, agrupa por temas recurrentes, calcula su severidad con el método MoSCoW y genera tickets priorizados en osTicket.

## Estructura del repositorio

```
infrastructure/          stack docker-compose (n8n, Postgres, osTicket + MariaDB)
config/                  plantillas en tiempo de ejecución (mapa de áreas, ejemplos de env)
flows/                   export de n8n — importar VoC_Miner.json en n8n
database/                assets SQL (esquema de tópicos y mensajes)
scripts/                 scripts auxiliares para modelos y bootstrap de la DB
samples/                 cargas sintéticas para test local (p.ej. webhook de Google Chat)
```

## Arquitectura y flujo

### Flujo Principal (VoC_Miner.json)

1. **Ingesta (Google Chat).** El flujo expone un endpoint `Webhook /gchat` en n8n para recibir mensajes desde Google Chat y normaliza el payload (`Parse Google Chat`).
2. **Normalización y deduplicado.** `Dedup & Clean` pasa todo a minúsculas, limpia URLs y calcula un hash FNV a partir de `{day|channel|user|text}` para descartar duplicados estrictos.
3. **Etiquetado de tópicos.** `Groq: Topic Label` envía el texto sanitizado a `llama-3.1-8b-instant` (Groq) y devuelve un label/resumen corto.
4. **Persistencia.** `DB: Insert Message` guarda el mensaje con su tópico y prioridad en Postgres (`voc_messages`). El esquema incluye campos para `priority`, `score`, `osticket_id`, `solution` y `solution_at`.
5. **Verificación de soluciones conocidas.** `DB: Get Solutions + Groq: Deflector de Tickets & Priorizador (MoSCoW)` consulta si existe una solución previa para el mismo tópico y problema similar. Si se encuentra, responde directamente al usuario vía Google Chat (deflección).
6. **Prioridad MoSCoW.** `Groq: Deflector de Tickets & Priorizador (MoSCoW)` procesa el contexto con información histórica y devuelve una prioridad (`MUST/SHOULD/COULD/WONT`) y un puntaje 0‑100.
7. **Ruteo y tickets.** `Area & Routing Map` enriquece el evento usando `config/areas_mapping.template.json`. Los niveles `MUST` y `SHOULD` sin solución conocida crean tickets en osTicket mediante `Format to osTicket` + `osTicket: Create ticket`. Los restantes se notifican vía Google Chat.
8. **Actualización de tópicos.** `DB: Upsert Topic` registra o actualiza el tópico en `voc_topics` con su label, prioridad y timestamp.

### Flujo de Recolección (VoC_Solution_Harvester.json)

1. **Trigger programado.** Se ejecuta cada 1 hora para recolectar soluciones de tickets cerrados.
2. **Consulta de tickets.** `MySQL: Get Recent Closed Tickets` lee tickets cerrados en osTicket en el intervalo.
3. **Extracción de respuestas.** `MySQL: Get Last Agent Reply` obtiene la última respuesta del agente de soporte.
4. **Resumen con LLM.** `Groq: Summarize Solution` estandariza el texto de la solución.
5. **Persistencia de soluciones.** `Postgres: Update Solution` asocia la solución al mensaje original mediante `osticket_id` y registra `solution_at`.

## MVP (Entrega 1)

- **Objetivo:** convertir mensajes entrantes de Google Chat en temas accionables → backlog limpio.
- **Pipeline:** ingesta (webhook Google Chat simulado) → normalización → etiquetado → prioridad MoSCoW → creación de tickets (solo MUST/SHOULD) en osTicket.
- **Plantilla de backlog:** `[MUST] Error de login desde móvil` + resumen + 3 ejemplos + metadata (`topic_id`, label, priority, sample_ids).

## Entrega 2: Mejoras Implementadas

### 1. Poblado de la Base de Datos

Se realizó un poblado inicial de la base de datos con soluciones históricas a problemas frecuentes y no tan frecuentes, clasificados por prioridad (MUST/SHOULD/COULD/WONT). Esta base de conocimiento permite:

- Mejorar la priorización de nuevos problemas mediante comparación con casos históricos
- Habilitar respuestas directas cuando existe una solución conocida
- Reducir la carga de tickets mediante deflección inteligente

El script `voc_init_db.sh` ahora ejecuta automáticamente el poblado mediante `002_seed_data.sql`.

### 2. Optimización del Flujo Principal

Comparado con MVP1, el flujo final (`VoC_Miner.json`) presenta mejoras significativas:

**Eliminaciones:**

- Nodos puramente de flujo (`Original (passthrough)`, múltiples `Merge` intermedios)
- Consulta `DB: Get Volume 7d` (ahora integrado en el prompt de priorización)
- Nodos redundantes de ruteo (`Merge: to osTicket`, `Merge: to GChat`)

**Mejoras en prompts:**

- Priorización más precisa con contexto histórico embebido
- Topic labeling optimizado para consistencia
- Instrucciones más específicas para deflección de tickets

**Nueva esquematización:**

- Flujo lineal simplificado: `Webhook → Parse → Dedup → Topic → Insert → Check Solution → Route`
- Decisión temprana de deflección antes de crear ticket
- Ruteo directo basado en prioridad sin nodos intermedios

### 3. Respuesta Directa (Deflección de Tickets)

Se implementó un mecanismo de deflección que:

- Consulta la base de datos de soluciones (`voc_messages.solution`) antes de crear un ticket
- Busca problemas similares mediante coincidencia de tópico y contexto
- Si existe una solución registrada, responde directamente al usuario vía Google Chat
- Solo crea ticket en osTicket cuando no hay solución conocida y la prioridad es MUST/SHOULD sin match

Esto reduce significativamente el volumen de tickets duplicados y mejora el tiempo de respuesta.

### 4. Harvester de Soluciones

Nuevo flujo automatizado (`VoC_Solution_Harvester.json`) que:

- Se ejecuta periódicamente (cada 1 hora) mediante Schedule Trigger
- Lee tickets cerrados en osTicket (MariaDB) en el periodo
- Extrae la última respuesta del agente usando consultas SQL
- Resume la solución mediante Groq LLM para estandarizar el formato
- Actualiza `voc_messages.solution` y `voc_messages.solution_at` en Postgres
- Asocia la solución al mensaje original usando `osticket_id`

Este ciclo cerrado asegura que el conocimiento capturado en tickets se reutilice automáticamente.

## Puesta en marcha

1. **Variables:** copiá `config/env/local.example` a `.env` (o exportá variables) y cargá claves de Groq y credenciales de osTicket + Postgres.
2. **Stack local:** desde `infrastructure/`, ejecutá `docker compose --env-file ../config/env/local.example up -d` (ajustá rutas según tu shell). Levanta n8n, Postgres y osTicket.
3. **Base de datos VoC:** desde `database/`, ejecutá `../scripts/voc_init_db.sh` para crear las tablas `voc_messages` y `voc_topics` en Postgres y poblarlas con datos históricos de soluciones.
4. **Configuración osTicket (manual):**
   - Accedé a la interfaz web de osTicket (por defecto `http://localhost:8080`).
   - Configurá los **Help Topics** correspondientes a cada área (Pagos, Acceso, Catálogo, Logística, Infra, Soporte) según `config/areas_mapping.template.json`.
   - Creá los **Teams** necesarios para rutear los tickets a los equipos correctos.
5. **n8n:** importá ambos flujos `flows/VoC_Miner.json` y `flows/VoC_Solution_Harvester.json`, actualizá credenciales (Groq API key, Postgres, osTicket/MySQL) y activá los workflows.
6. **Google Chat:** generá un webhook entrante y apuntalo al endpoint público de n8n (`/webhook/gchat`). Probalo con `scripts/test_gchat_webhook.sh`.

## Scripts útiles

- `scripts/test_gchat_webhook.sh`: envía 4 payloads de prueba (MUST, SHOULD, COULD, WONT) al webhook de n8n para validar el flujo completo. Uso: `./scripts/test_gchat_webhook.sh [URL]` (default: `http://localhost:5678/webhook/gchat`).
- `scripts/voc_init_db.sh`: crea tablas (`voc_schema.sql`) y carga datos históricos de soluciones (`002_seed_data.sql`) en Postgres.

## Flujos disponibles

- **`VoC_Miner.json`**: Flujo principal de ingesta, clasificación, deflección y creación de tickets.
- **`VoC_Solution_Harvester.json`**: Flujo de recolección automática de soluciones desde tickets cerrados en osTicket.
