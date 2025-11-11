#!/bin/bash

# Script para testear el webhook de Google Chat con casos de prueba MoSCoW
# Uso: ./test_gchat_webhook.sh [ENDPOINT_URL]

ENDPOINT="${1:-http://localhost:5678/webhook/gchat}"

echo "=========================================="
echo "Test VoC Miner - Google Chat Webhook"
echo "Endpoint: $ENDPOINT"
echo "=========================================="
echo ""

# Función auxiliar para enviar payload y mostrar resultado
send_test() {
  local test_name="$1"
  local payload="$2"
  
  echo "→ Enviando test: $test_name"
  
  response=$(curl -s -w "\nHTTP_STATUS:%{http_code}" \
    -X POST "$ENDPOINT" \
    -H "Content-Type: application/json" \
    -d "$payload")
  
  http_status=$(echo "$response" | grep "HTTP_STATUS" | cut -d: -f2)
  body=$(echo "$response" | sed '/HTTP_STATUS/d')
  
  if [ "$http_status" = "200" ] || [ "$http_status" = "201" ]; then
    echo "  ✓ Éxito (HTTP $http_status)"
  else
    echo "  ✗ Error (HTTP $http_status)"
  fi
  
  echo ""
  sleep 1
}

# Test MUST - Alta prioridad crítica
MUST_PAYLOAD='{
  "type": "MESSAGE",
  "message": {
    "name": "spaces/AAA/messages/MSG-MUST-002",
    "text": "URGENTE: Los clientes no pueden finalizar ninguna compra. El botón de pago no funciona en ningún navegador. Perdiendo ventas cada minuto!!!",
    "sender": {
      "email": "gerente.ventas@example.com",
      "displayName": "Gerente de Ventas"
    },
    "createTime": "2025-11-11T14:20:00.000Z",
    "thread": {
      "name": "spaces/AAA/threads/THREAD-MUST-2"
    },
    "space": {
      "name": "spaces/AAA",
      "spaceType": "SPACE"
    }
  }
}'

send_test "MUST (Crítico - debería abrir ticket)" "$MUST_PAYLOAD"

# Test SHOULD - Alta prioridad importante
SHOULD_PAYLOAD='{
  "type": "MESSAGE",
  "message": {
    "name": "spaces/AAA/messages/MSG-SHOULD-002",
    "text": "El stock del producto más vendido no se actualiza automáticamente. Los clientes compran productos que ya no tenemos disponibles.",
    "sender": {
      "email": "supervisor.logistica@example.com",
      "displayName": "Supervisor Logística"
    },
    "createTime": "2025-11-11T14:25:00.000Z",
    "thread": {
      "name": "spaces/AAA/threads/THREAD-SHOULD-2"
    },
    "space": {
      "name": "spaces/AAA",
      "spaceType": "SPACE"
    }
  }
}'

send_test "SHOULD (Importante - debería abrir ticket)" "$SHOULD_PAYLOAD"

# Test COULD - Prioridad media
COULD_PAYLOAD='{
  "type": "MESSAGE",
  "message": {
    "name": "spaces/AAA/messages/MSG-COULD-002",
    "text": "Me gustaría cambiar el color del logo en mi perfil de vendedor. ¿Es posible personalizar más la interfaz?",
    "sender": {
      "email": "vendedor.premium@example.com",
      "displayName": "Vendedor Premium"
    },
    "createTime": "2025-11-11T14:30:00.000Z",
    "thread": {
      "name": "spaces/AAA/threads/THREAD-COULD-2"
    },
    "space": {
      "name": "spaces/AAA",
      "spaceType": "SPACE"
    }
  }
}'

send_test "COULD (Media - notificación sin ticket)" "$COULD_PAYLOAD"

# Test WONT - Baja prioridad / ruido
WONT_PAYLOAD='{
  "type": "MESSAGE",
  "message": {
    "name": "spaces/AAA/messages/MSG-WONT-003",
    "text": "Hola equipo! Solo quería felicitarlos por el excelente trabajo. La plataforma funciona genial. Saludos desde Córdoba!",
    "sender": {
      "email": "cliente.feliz@example.com",
      "displayName": "Cliente Satisfecho"
    },
    "createTime": "2025-11-11T14:35:00.000Z",
    "thread": {
      "name": "spaces/AAA/threads/THREAD-WONT-3"
    },
    "space": {
      "name": "spaces/AAA",
      "spaceType": "SPACE"
    }
  }
}'

send_test "WONT (Baja - notificación sin ticket)" "$WONT_PAYLOAD"

echo "=========================================="
echo "Tests completados"
echo "Verificá en n8n y osTicket los resultados"
echo "=========================================="
