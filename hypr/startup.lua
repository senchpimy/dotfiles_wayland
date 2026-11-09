-- Startup Configuration
local HOME = os.getenv("HOME")
local scrPath = HOME .. "/.local/share/bin"
local brightnessFile = HOME .. "/.cache/backlight-percent"

local function is_systemd()
	local f = io.open("/proc/1/comm", "r")
	if f then
		local comm = f:read("*l")
		f:close()
		return comm == "systemd"
	end
	return false
end

local audio_start
if is_systemd() then
	audio_start = "systemctl --user --now enable pipewire pipewire-pulse wireplumber"
else
	audio_start = "sh -c 'pipewire & sleep 1 && wireplumber & sleep 1 && pipewire-pulse &'"
end

local function currentBrightnessPercent()
	local b = io.popen("brightnessctl g")
	local m = io.popen("brightnessctl m")
	if not (b and m) then
		return nil
	end
	local bv, mv = b:read("*l"), m:read("*l")
	b:close()
	m:close()
	local n, mx = tonumber(bv), tonumber(mv)
	if n and mx and mx > 0 then
		return math.floor(n * 100 / mx)
	end
	return nil
end

hl.on("hyprland.shutdown", function()
	local percent = currentBrightnessPercent()
	if percent then
		local f = io.open(brightnessFile, "w")
		if f then
			f:write(tostring(percent))
			f:close()
		end
	end
end)

hl.on("hyprland.start", function()
	local f = io.open(brightnessFile, "r")
	if f then
		local line = f:read("*l")
		f:close()
		local percent = tonumber(line)
		if percent and percent >= 0 and percent <= 100 then
			hl.exec_cmd("brightnessctl s " .. percent .. "% --quiet")
		end
		os.remove(brightnessFile)
	end
end)

hl.on("hyprland.start", function()
	local cmds = {
		audio_start,
		"sh ~/.config/hypr/bringtop.sh",
		-- Servidor kitty en segundo plano: las ventanas nuevas se abren en ~150 ms
		"kitty --single-instance --start-as=hidden",
		"eww daemon",
		"qs &",
		"hyprpm reload -n",
		"qs -p ~/Documents/PythonProjects/TareasGenerador/pendientes.qml",
		HOME .. "/Documents/PythonProjects/TareasGenerador/server",
		"qs -p ~/.config/quickshell/extra/activate.qml",
		"awww init",
		HOME
			.. "/Documents/PythonProjects/audio/.venv/bin/python "
			.. HOME
			.. "/Documents/PythonProjects/audio/src/main.py",
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
		"gsettings set org.gnome.desktop.interface font-hinting 'full'",
	}

	for _, cmd in ipairs(cmds) do
		hl.exec_cmd(cmd)
	end
end)
