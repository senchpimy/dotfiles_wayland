-- Startup Configuration
local HOME = os.getenv("HOME")
local scrPath = HOME .. "/.local/share/bin"

hl.on("hyprland.start", function()
    local cmds = {
        "sh ~/.config/hypr/bringtop.sh",
        "eww daemon",
        "qs &",
        "hyprpm reload -n",
        "qs -p ~/Documents/PythonProjects/TareasGenerador/pendientes.qml",
        HOME .. "/Documents/PythonProjects/TareasGenerador/server",
        "qs -p ~/.config/quickshell/extra/activate.qml",
        "awww init",
        HOME .. "/Documents/PythonProjects/audio/.venv/bin/python " .. HOME .. "/Documents/PythonProjects/audio/src/main.py",
        "nwg-look -a",
        "systemctl --user enable --now hyprpolkitagent.service",
        "hypridle",
        "xrdb ~/.Xdefaults",
        scrPath .. "/resetxdgportal.sh",
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP",
        "dbus-update-activation-environment --systemd --all",
        "systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP",
        "blueman-applet",
        "udiskie --no-automount --smart-tray",
        "nm-applet --indicator",
        "wl-paste --type text --watch cliphist store",
        "wl-paste --type image --watch cliphist store",
        scrPath .. "/awwwallpaper.sh",
        scrPath .. "/batterynotify.sh",
        "flameshot",
        "sh -c 'cd ~/Documents/RustProjects/captura-extractor/servidorOcr/ && uv run --no-sync ocr_server.py &'",
        HOME .. "/configs/bin/monitor_red.sh &",
        -- gsettings from exec
        "gsettings set org.gnome.desktop.interface font-name 'Cantarell 10'",
        "gsettings set org.gnome.desktop.interface document-font-name 'Cantarell 10'",
        "gsettings set org.gnome.desktop.interface monospace-font-name 'Nerd Font Mono 9'",
        "gsettings set org.gnome.desktop.interface font-antialiasing 'rgba'",
        "gsettings set org.gnome.desktop.interface font-hinting 'full'"
    }

    for _, cmd in ipairs(cmds) do
        hl.exec_cmd(cmd)
    end
end)
