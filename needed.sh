#!/bin/bash

sudo pacman -S git curl wget

if ! command -v paru &> /dev/null
then
    sudo pacman -S --needed base-devel
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si
    cd ..
    rm -rf paru
fi

paru -S --needed \
    alacritty \
    alsa \
    bat \
    base-devel \
    blender \
    bottom \
    chafa \
    cowsay \
    cpio \
    eww \
    fprintd \
    fastfetch \
    flameshot \
    fortune-mod \
    gimp \
    gnome-control-center \
    gradience \
    grim \
    htop \
    hypridle \
    hyprpolkitagent \
    jq \
    kdenlive \
    keepassxc \
    kora-icon-theme \
    lazygit \
    lf \
    luarocks \
    ly \
    matugen \
    neo-matrix \
    neofetch \
    neovim \
    neovide \
    noto-fonts-cjk \
    npm \
    nwg-look \
    obsidian \
    pamixer \
    parallel \
    pfetch \
    pipewire-alsa \
    platformio \
    playerctl \
    pokemon-colorscripts \
    pywal \
    python-pip \
    qt5-base \
    qt5-graphicaleffects \
    qt5-svg \
    qt5-tools \
    qt5-wayland \
    qt6-5compat \
    qt6-graphicaleffects \
    ripgrep \
    rofi-wayland \
    sccache \
    screen \
    screenfetch \
    spotify \
    starship \
    awww \
    texlive-core \
    texlive-latexextra \
    texlive-pictures \
    texlive-science \
    tlp \
    tmux \
    ttf-cascadia-code \
    vim \
    wget \
    wlogout \
    yazi \
    zathura \
    zathura-pdf-mupdf \
    zen-browser \
    zsh 
