#!/bin/bash

folders=("alacritty" "hyde" "hypr" "lvim" "rofi" "wal" "waybar" "wlogout" "lf" "eww" "spicetify"  "ags" "matugen" "rio" "cava" "quickshell" "nwg-dock-hyprland" "kitty") 

source="/home/plof/configs"

for folder in "${folders[@]}"; do
    rm -rf ~/.config/"$folder"
    
    ln -s "$source/$folder" ~/.config/"$folder"
done

echo "Enlaces simbólicos creados para todas las carpetas."

ln -s $source/.zshrc ~/.zshrc
ln -s $source/.Xdefaults ~/.Xdefaults
