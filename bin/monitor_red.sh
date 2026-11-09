#!/bin/bash

# Puertos exactos de minería o malware (usando anclaje de puerto)
# 3333/4444/5555: Stratum/Mining
PUERTOS_SOSPECHOSOS=":12301$|:3333$|:4444$|:5555$"

# Archivo de log
LOG_NOTIFICACION="/tmp/red_alert.log"

echo "Iniciando monitoreo de red preciso..."

while true; do
    # Buscar conexiones establecidas a puertos sospechosos
    # Filtramos para que la coincidencia sea al final de la dirección (el puerto)
    ALERTA=$(ss -atp | grep -E "($PUERTOS_SOSPECHOSOS)")
    
    if [ ! -z "$ALERTA" ]; then
        IP_REMOTA=$(echo "$ALERTA" | awk '{print $5}' | head -n 1)
        # Intentar extraer el proceso de forma más robusta
        PROCESO=$(echo "$ALERTA" | grep -oP 'users:\(\("\K[^"]+' | head -n 1)
        
        if [ -z "$PROCESO" ]; then PROCESO="Desconocido"; fi

        # Enviar notificación
        notify-send -u critical "ALERTA DE SEGURIDAD REAL" "Conexión a puerto de minería detectada!\nIP: $IP_REMOTA\nProceso: $PROCESO" -i dialog-error
        
        echo "$(date): ALERTA CONFIRMADA de $PROCESO a $IP_REMOTA" >> $LOG_NOTIFICACION
    fi
    
    sleep 10
done
