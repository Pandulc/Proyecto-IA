#!/usr/bin/env bash
set -euo pipefail
# Apply schema to the Postgres container used by n8n
CONTAINER=${1:-n8n_postgres}
DB_USER=${2:-n8n}
DB_NAME=${3:-n8n}
echo "[INFO] Applying schema to $CONTAINER (db=$DB_NAME user=$DB_USER)..."
docker cp ../database/voc_schema.sql "$CONTAINER:/tmp/voc_schema.sql"
docker exec -it "$CONTAINER" bash -lc "psql -U $DB_USER -d $DB_NAME -f /tmp/voc_schema.sql"
echo "[OK] Schema applied."
