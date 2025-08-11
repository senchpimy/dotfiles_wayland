#!/usr/bin/env bash

SAVE_DIR="$HOME/Videos"
mkdir -p "$SAVE_DIR"

getdate() {
    date '+%Y-%m-%d_%H.%M.%S'
}

getaudiooutput() {
    echo "alsa_output.pci-0000_13_00.6.analog-stereo.monitor"
}

getactivemonitor() {
    hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name'
}

if pgrep wf-recorder > /dev/null; then
    pkill -INT wf-recorder
    #notify-send "🎥 Grabación finalizada" "El video ha sido guardado."
    exit 0
fi

FILENAME="$SAVE_DIR/recording_$(getdate).mp4"
AUDIO_DEVICE="$(getaudiooutput)"

echo "Iniciando grabación en '$FILENAME'. Presiona Ctrl+C para detener."

case "$1" in
    --fullscreen)
        wf-recorder \
            -o "$(getactivemonitor)" \
            --pixel-format yuv420p \
            -f "$FILENAME" \
            --audio="$AUDIO_DEVICE"
        ;;
    *)
        wf-recorder \
            --pixel-format yuv420p \
            -f "$FILENAME" \
            --geometry "$(slurp)" \
            --audio="$AUDIO_DEVICE"
        ;;
esac

notify-send "🎥 Grabación finalizada" "Archivo guardado en $FILENAME"
