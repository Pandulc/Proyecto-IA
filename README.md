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

1. **Ingesta (solo Google Chat).** El flujo (`flows/VoC_Miner.json`) expone un endpoint `Webhook /gchat` en n8n para recibir mensajes desde Google Chat y normaliza el payload (`Parse Google Chat`). La integración bidireccional con Google Chat como fuente y destino de mensajes se incorporará en la Entrega 2.
2. **Normalización y deduplicado.** `Dedup & Clean` pasa todo a minúsculas, limpia URLs y calcula un hash FNV a partir de `{day|channel|user|text}` para descartar duplicados estrictos. El branch `Original` conserva el mensaje crudo.
3. **Persistencia.** `DB: Insert Message` guarda cada mensaje limpiado en Postgres. Usa `database/voc_schema.sql` y `scripts/voc_init_db.sh` para inicializar.
4. **Etiquetado de tópicos.** `Groq: Topic Label` envía el texto sanitizado a `llama-3.1-8b-instant` (Groq) y devuelve un label/resumen corto.
5. **Prioridad MoSCoW.** `Groq: Prioridad (MoSCoW)` procesa el contexto y devuelve una prioridad restringida a `MUST/SHOULD/COULD/WONT` y un puntaje 0‑100. La calibración del impact scoring con volúmenes históricos se incorporará en la Entrega 2.
6. **Backlog automático.** `Format to osTicket` + `osTicket: Create ticket` generan un backlog item por tópico: `[MUST] <label>` + resumen, 3 ejemplos y links a fuentes. Configurá la API de osTicket a partir de `config/env/local.example`. Podés reutilizar el payload formateado para GitHub/Jira.
7. **Notificaciones y ruteo.** `Area & Routing Map` enriquece el evento usando `config/areas_mapping.template.json`. Los niveles `MUST` y `SHOULD` abren tickets en osTicket; los restantes (`COULD` y `WONT`) se gestionan vía notificación en Google Chat (parte de la integración prevista para la Entrega 2).

## MVP (Entrega 1)

- **Objetivo:** convertir mensajes entrantes de Google Chat en temas accionables → backlog limpio.
- **Pipeline:** ingesta (webhook Google Chat) → normalización → etiquetado → prioridad MoSCoW → creación de tickets (solo MUST/SHOULD) en osTicket.
- **Plantilla de backlog:** `[MUST] Error de login desde móvil` + resumen + 3 ejemplos + metadata (`topic_id`, label, priority, sample_ids).

## Entrega 2: mejoras a implementar

- **Integración completa con Google Chat:** actualmente los mensajes ingresan por webhook; el próximo paso es integrar Google Chat como fuente y destino de mensajes (envío de notificaciones y respuestas).
- **Impact scoring con volúmenes históricos:** mejorar la determinación del puntaje de impacto usando el volumen de pedidos anteriores. Requiere completar la carga histórica en la base de datos (los volúmenes actuales estaban vacíos).
- **Resolución directa por similitud:** en base a los pedidos registrados en la base, detectar si el problema actual es similar a uno previo y ofrecer la solución existente en vez de abrir un nuevo ticket o enviar un nuevo mensaje.

## Puesta en marcha

1. **Variables:** copiá `config/env/local.example` a `.env` (o exportá variables) y cargá claves de Groq y credenciales de osTicket + Postgres.
2. **Stack local:** desde `infrastructure/`, ejecutá `docker compose --env-file ../config/env/local.example up -d` (ajustá rutas según tu shell). Levanta n8n, Postgres y osTicket.
3. **Base de datos VoC:** desde `database/`, ejecutá `../scripts/voc_init_db.sh` para crear las tablas `voc_messages` y `voc_topics` en Postgres.
4. **Configuración osTicket (manual):**
   - Accedé a la interfaz web de osTicket (por defecto `http://localhost:8080`).
   - Configurá los **Help Topics** correspondientes a cada área (Pagos, Acceso, Catálogo, Logística, Infra, Soporte) según `config/areas_mapping.template.json`.
   - Creá los **Teams** necesarios para rutear los tickets a los equipos correctos.
5. **n8n:** importá `flows/VoC_Miner.json`, actualizá credenciales (Groq API key, Postgres, osTicket) y activá el workflow.
6. **Google Chat:** generá un webhook entrante y apuntalo al endpoint público de n8n (`/webhook/gchat`). Probalo con `scripts/test_gchat_webhook.sh`.

## Scripts útiles

- `scripts/test_gchat_webhook.sh`: envía 4 payloads de prueba (MUST, SHOULD, COULD, WONT) al webhook de n8n para validar el flujo completo. Uso: `./scripts/test_gchat_webhook.sh [URL]` (default: `http://localhost:5678/webhook/gchat`).
- `scripts/voc_init_db.sh`: crea tablas y carga seeds basados en `database/voc_schema.sql`.

## Próximos pasos (alineados con Entrega 2)

1. Integrar Google Chat como canal bidireccional (fuente y destino) para notificaciones y respuestas.
2. Cargar volúmenes históricos en la base y ajustar el cálculo de impacto.
3. Implementar coincidencia de similitud y respuesta directa sobre problemas previamente registrados.
