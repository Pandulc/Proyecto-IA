# Instrucciones para Cargar el Dataset de Muestra (Seed)

Este script `seed_data.sql` poblará tu base de datos PostgreSQL (`n8n_postgres`) con datos históricos de `voc_messages` y `voc_topics`.

## Requisitos

1. Tener Docker y Docker Compose ejecutándose.
2. Tener el archivo `002_seed_data.sql`.
3. Tener los contenedores (`n8n_postgres`, `n8n`, etc.) corriendo. Si no están corriendo, ejecutá:

```bash
docker-compose up -d
```

## Cómo Cargar los Datos

El contenedor de Postgres (`n8n_postgres`) incluye la herramienta de línea de comandos `psql`. Podemos "pipear" (enviar) nuestro archivo `.sql` directamente a `psql` dentro del contenedor.

Abrí tu terminal en la carpeta donde tenés `002_seed_data.sql` y ejecutá el siguiente comando:

```bash
cat 002_seed_data.sql | docker exec -i n8n_postgres psql -U n8n -d n8n
```

## Desglose del Comando

- **`cat seed_data.sql`**: Lee el contenido de tu archivo SQL.
- **`|`**: "Pipe" o tubería. Envía la salida del primer comando como entrada al segundo.
- **`docker exec -i n8n_postgres`**: Ejecuta un comando en el contenedor `n8n_postgres`. La bandera `-i` es clave, significa "interactivo" y permite que reciba la entrada del "pipe".
- **`psql -U n8n -d n8n`**: Es el comando que se ejecuta dentro del contenedor.
  - `-U n8n`: Conectate como el usuario `n8n` (definido en tu `.env`).
  - `-d n8n`: Conectate a la base de datos `n8n` (definida en tu `.env`).

## Verificación

Si el comando se ejecuta sin errores, ¡listo! Tus datos están cargados.

Podés verificarlo entrando al contenedor:

```bash
docker exec -it n8n_postgres psql -U n8n -d n8n
```

Una vez dentro de `psql`, escribí:

```sql
SELECT topic, volume_7d, priority FROM voc_topics;
```

Deberías ver una tabla con los tópicos y sus volúmenes calculados.
