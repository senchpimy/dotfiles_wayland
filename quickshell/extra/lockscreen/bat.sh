#!/bin/bash

# Itera sobre todos los dispositivos que reporta upower
for device_path in $(upower -e); do
    # Omitir dispositivos de "display" que no son baterías reales
    if [[ "$device_path" == *"/DisplayDevice"* || "$device_path" == *"/line_power"* ]]; then
        continue
    fi

    # Obtener información detallada del dispositivo
    device_info=$(upower -i "$device_path")

    # Extraer el porcentaje. Si no existe, se salta el dispositivo.
    percentage=$(echo "$device_info" | awk -F': +' '/percentage/ {gsub(/%/, "", $2); print $2}')
    if [[ -z "$percentage" ]]; then
        continue
    fi
    
    # Extraer otros datos
    state=$(echo "$device_info" | awk -F': +' '/state/ {print $2}')
    type=$(echo "$device_info" | awk -F': +' '/type/ {print $2}')
    
    # Asignar un nombre de icono por defecto
    icon_name="unknown"
    
    # --- LÓGICA DE DETECCIÓN MEJORADA ---

    # 1. Prioridad para la batería del portátil (la más fiable)
    if [[ "$device_path" == *"/battery_BAT"* ]]; then
        icon_name="laptop"
    else
        # 2. Intento de detección por el campo 'type' (el método limpio)
        case "$type" in
            "headset")  icon_name="headphones" ;;
            "mouse")    icon_name="mouse" ;;
            "keyboard") icon_name="keyboard" ;;
            "phone")    icon_name="phone" ;;
            "tablet")   icon_name="tablet" ;;
        esac
    fi

    # 3. Respaldo: Si sigue sin ser identificado, buscamos palabras clave
    #    en TODA la información del dispositivo. (Esto es lo que arreglará tus auriculares)
    if [[ "$icon_name" == "unknown" ]]; then
        if echo "$device_info" | grep -iq "headset"; then
            icon_name="headphones"
        elif echo "$device_info" | grep -iq "mouse"; then
            icon_name="mouse"
        elif echo "$device_info" | grep -iq "keyboard"; then
            icon_name="keyboard"
        fi
    fi
    
    # Si después de todo sigue siendo desconocido, no lo mostramos para evitar iconos rotos.
    if [[ "$icon_name" == "unknown" ]]; then
        continue
    fi
    
    # --- FIN DE LA LÓGICA DE DETECCIÓN ---

    # Simplificar el estado para el nombre del icono (ej. charging.svg)
    if [[ "$state" == "pending-charge" ]]; then
        state="charging"
    elif [[ "$state" == "pending-discharge" ]]; then
        state="discharging"
    fi
    
    # Generar la salida JSON
    echo "{\"percentage\": $percentage, \"icon\": \"$icon_name\", \"state\": \"$state\"}"
done
