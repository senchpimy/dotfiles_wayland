#!/usr/bin/env sh

scrDir=$(dirname "$(realpath "$0")")

confDir="${confDir:-$HOME/.config}"
rofiScale="${rofiScale:-10}"
hypr_border="${hypr_border:-2}"
roconf="${confDir}/rofi/clipboard.rasi"


[[ "${rofiScale}" =~ ^[0-9]+$ ]] || rofiScale=10
r_scale="configuration {font: \"JetBrainsMono Nerd Font ${rofiScale}\";}"


wind_border=$((hypr_border * 2))
r_override="window{width:85%;} listview{columns:2; lines:8;}"


json_output=$(hyprkeys -t -j)

if [ -z "$json_output" ]; then
    rofi -e "No se pudieron cargar los atajos de Hyprland."
    exit 1
fi

command_list=$(echo "$json_output" | jq -r '.[] | "\(.dispatcher) \(.arg)"')

display_list=$(echo "$json_output" | \
    jq -r '.[] | "\(.mods) + \(.key)\t\(.dispatcher) \(.arg)"' | \
    sed -E 's/^[[:space:]]*\+[[:space:]]+//' | \
    column -t -s $'\t' -o '  ->  '
)


chosen_line=$(echo -e "$display_list" | rofi \
    -dmenu \
    -i \
    -p "Atajos de Hyprland" \
    -mesg "Selecciona un atajo para ejecutarlo..." \
    -theme-str "${r_scale}" \
    -theme-str "${r_override}" \
    -config "${roconf}"
)

if [ -n "$chosen_line" ]; then
    line_num=$(echo -e "$display_list" | grep -Fxn "$chosen_line" | cut -d: -f1)

    if [ -n "$line_num" ]; then
        command_to_run=$(echo -e "$command_list" | sed -n "${line_num}p")

        hyprctl dispatch $command_to_run
    fi
fi
