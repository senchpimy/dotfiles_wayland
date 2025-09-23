#!/bin/bash
#Este sript toma la configuracion actual y la guarda en la carpeta de configs

folders=("alacritty" "hyde" "hypr" "lvim" "rofi" "wal" "waybar" "wlogout" "lf" "eww" "spicetify"  "ags" "matugen" "rio" "cava" "quickshell" "nwg-dock-hyprland" "kitty" "nvim" "flameshot")

destination="/home/plof/configs"

for folder in "${folders[@]}"; do
    rm -rf "$folder"
    
    mv ~/.config/"$folder" .
    
    ln -s "$destination/$folder" ~/.config/"$folder"
done

echo "Operaciones completadas para todas las carpetas."

