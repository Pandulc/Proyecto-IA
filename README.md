# Voice-of-Customer Miner (VoC Miner)

![n8n](https://img.shields.io/badge/n8n-workflow-orange?style=flat-square&logo=n8n)
![Docker](https://img.shields.io/badge/Docker-Compose-blue?style=flat-square&logo=docker)
![Postgres](https://img.shields.io/badge/Postgres-DB-336791?style=flat-square&logo=postgresql)
![Groq](https://img.shields.io/badge/AI-Llama3-purple?style=flat-square)
![osTicket](https://img.shields.io/badge/Support-osTicket-green?style=flat-square)

Plataforma inteligente que procesa pedidos de soporte de clientes recibidos vía Google Chat. Normaliza los mensajes, los agrupa por temas, calcula su severidad con el método MoSCoW, aplica estrategias de deflexión automática (RAG) y genera tickets priorizados en osTicket.

## 🚀 Características Principales

- **Ingesta & Normalización:** Sanitización de mensajes de Google Chat y deduplicación inteligente basada en hash.
- **Clasificación IA:** Etiquetado automático de tópicos y cálculo de prioridad (MoSCoW) utilizando Llama 3 vía Groq.
- **Deflexión Inteligente (RAG):** Consulta una base de conocimientos local antes de crear un ticket.
- **Ruteo Dinámico:** Asignación automática de áreas (Pagos, Infra, Acceso, etc.) basada en el tópico detectado.
- **Aprendizaje Continuo:** El Harvester monitorea tickets cerrados y aprende soluciones para futuros casos.
- **Full Stack Local:** Infraestructura completamente contenerizada en Docker Compose.

## 📊 Flujo de Arquitectura

```mermaid
graph TD
    subgraph Ingesta
    A[Webhook GChat] --> B(Parse & Dedup)
    end

    subgraph Inteligencia
    B --> C[Groq: Topic Label]
    C --> D{Solución Conocida?}
    D -->|Si - RAG| E[Responder GChat (Deflexión)]
    D -->|No| F[Groq: Prioridad MoSCoW]
    end

    subgraph Acción
    F --> G[Area & Routing Map]
    G --> H{Prioridad?}
    H -->|MUST/SHOULD| I[osTicket: Create Ticket]
    H -->|COULD/WONT| J[Groq: Generar Respuesta Social]
    end

    subgraph Feedback
    I --> K[Notificar GChat + Link Ticket]
    J --> L[Responder GChat]
    end
```

## 📂 Estructura del Repositorio

```
├── infrastructure/      # Stack docker-compose (n8n, Postgres, osTicket + MariaDB)
├── config/              # Archivos de configuración y plantillas de entorno
├── flows/               # Workflows JSON de n8n (Miner y Harvester)
├── database/            # Scripts SQL (esquema, seeds)
├── scripts/             # Scripts auxiliares (tests, bootstrap)
└── samples/             # Cargas sintéticas para testing
```

## ⚙️ Configuración

### Variables de Entorno

Crear `.env` basado en `config/env/local.example`:

| Variable | Descripción |
|---------|-------------|
| `N8N_ENCRYPTION_KEY` | Clave de cifrado para n8n |
| `GROQ_API_KEY` | API Key para Llama 3 |
| `POSTGRES_USER/PASS` | Credenciales Postgres |
| `OSTICKET_DB_*` | Credenciales DB osTicket |
| `N8N_WEBHOOK_URL` | URL pública para recibir mensajes |

### Mapeo de Áreas

Editar el nodo **Area & Routing Map** dentro de n8n para asignar Help Topics de osTicket.



## 🛠️ Puesta en Marcha

### 1. Infraestructura

```bash
cd infrastructure
docker compose --env-file ../config/env/local.example up -d
```

### 2. Base de Datos

```bash
cd ../database
../scripts/voc_init_db.sh
```

### 3. Configuración osTicket

1. Entrar a: `http://localhost:8080/scp`
2. Crear Help Topics y Teams
3. Generar API Key y registrarla en n8n

### 4. Configuración n8n

1. Entrar a: `http://localhost:5678`
2. Importar (versiones finales: final/flows):
   - `VoC_Miner.json` 
   - `VoC_Solution_Harvester.json`
3. Configurar credenciales (Postgres, MariaDB, Groq)
4. Activar flujos

### 5. Prueba

- Modo Sintético (Local): Utiliza el script para simular un mensaje JSON sin salir de tu red.
```bash
./scripts/test_gchat_webhook.sh "Hola, no puedo loguearme en la app"
```
- Modo Real (Google Chat + Ngrok): Para interactuar con el bot desde la interfaz real de Google Chat (como se realizó en las pruebas):

    1. Crea un proyecto en Google Cloud Console.

    2. Habilita la Google Chat API.

    3. En la configuración de la API ("Manage" > "Configuration"), define:

        App URL: Tu endpoint de Ngrok (ej. https://<tu-id>.ngrok-free.app/webhook/gchat).

    4. Agrega el bot a un espacio en Google Chat y menciónalo (@VoCMiner ...). El mensaje viajará por Ngrok hasta n8n.


## 🤖 Flujos Disponibles

### **1. VoC Miner (Principal)**
Actúa como cerebro del sistema: clasificación, RAG, prioridad MoSCoW, creación de tickets y respuestas sociales.

### **2. VoC Solution Harvester**
Proceso automático que aprende soluciones de tickets cerrados y las incorpora a la base de conocimientos.

---

