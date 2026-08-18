-- Keybindings
local HOME = os.getenv("HOME")
local scrPath = HOME .. "/.local/share/bin"
local mainMod = "SUPER"
local term = "kitty"
local file = "nautilus"

-- Función universal para todos los binds
local function bind(key, action, opts)
	local resolved_action
	-- Detecta si el parámetro es un comando (texto) o una función/dispatcher
	if type(action) == "string" then
		resolved_action = hl.dsp.exec_cmd(action)
	else
		resolved_action = action
	end
	hl.bind(key, resolved_action, opts)
end

-- General Binds
bind(mainMod .. " + V", hl.dsp.global("quickshell:overviewClipboardToggle"), { description = "Clipboard history" })
bind(mainMod .. " + SHIFT + Tab", hl.dsp.global("quickshell:overviewToggle"), { description = "Toggle overview" })
bind(mainMod .. " + Delete", hl.dsp.global("quickshell:sessionToggle"), { description = "Toggle session menu" })
bind(
	mainMod .. " + ALT + M",
	hl.dsp.global("quickshell:mediaControlsToggle"),
	{ description = "Toggle media controls" }
)

bind(mainMod .. " + Q", hl.dsp.window.close())
bind(mainMod .. " + SHIFT + Q", hl.dsp.exit())
bind(mainMod .. " + Space", hl.dsp.window.float({ action = "toggle" }))
bind(mainMod .. " + G", hl.dsp.group.toggle())
bind(mainMod .. " + D", hl.dsp.group.move_window("out"))
bind(mainMod .. " + M", hl.dsp.window.fullscreen({ action = "toggle" }))
bind(mainMod .. " + SHIFT + F", hl.dsp.window.pin())
bind(mainMod .. " + P", hl.dsp.window.pseudo())

-- Exec Binds (Pasan como string y la función los convierte automáticamente)
bind(mainMod .. " + SHIFT + E", scrPath .. "/fuzzel-emoji.sh")
bind(mainMod .. " + B", "qs -p ~/.config/quickshell/lockscreen.qml")
bind(mainMod .. " + SHIFT + Z", "woomer")
bind(
	mainMod .. " + SHIFT + M",
	HOME
		.. "/Documents/PythonProjects/audio/.venv/bin/python "
		.. HOME
		.. "/Documents/PythonProjects/audio/src/local_client.py"
)
bind(mainMod .. " + CTRL + P", scrPath .. "/logoutlaunch.sh")
bind("CTRL + Escape", "killall waybar || waybar")

-- Screenshot
bind("Print", "flameshot gui", { description = "Take a screenshot" })

-- Apps
bind(mainMod .. " + RETURN", term)
bind(mainMod .. " + E", file)
bind(mainMod .. " + R", "pkill -x rofi || rofi -show drun -config ~/.config/rofi/transparente.rasi -show-icons -icon-theme kora")
bind(mainMod .. " + TAB", hl.dsp.focus({ workspace = "previous" }))

-- Audio (Las teclas especiales XF86 pasan tal cual)
bind(mainMod .. " + F6", scrPath .. "/volumecontrol.sh -o m")
bind(mainMod .. " + F7", scrPath .. "/volumecontrol.sh -o d", { repeating = true })
bind(mainMod .. " + F8", scrPath .. "/volumecontrol.sh -o i", { repeating = true })
bind("XF86AudioMute", scrPath .. "/volumecontrol.sh -o m", { locked = true })
bind("XF86AudioMicMute", scrPath .. "/volumecontrol.sh -i m", { locked = true })
bind("XF86AudioLowerVolume", scrPath .. "/volumecontrol.sh -o d", { locked = true, repeating = true })
bind("XF86AudioRaiseVolume", scrPath .. "/volumecontrol.sh -o i", { locked = true, repeating = true })

-- Brightness
bind(
	mainMod .. " + F3",
	"qs ipc call brightness increment || brightnessctl s 5%+",
	{ repeating = true }
)
bind(
	mainMod .. " + F2",
	"qs ipc call brightness decrement || brightnessctl s 5%-",
	{ repeating = true }
)

-- Custom Scripts
bind(mainMod .. " + ALT + Right", scrPath .. "/awwwallpaper.sh -n")
bind(mainMod .. " + ALT + Left", scrPath .. "/awwwallpaper.sh -p")
bind(mainMod .. " + SHIFT + T", hl.dsp.global("quickshell:themeCarouselToggle"), { description = "Theme carousel" })
bind(mainMod .. " + SHIFT + A", "pkill -x rofi || " .. scrPath .. "/rofiselect.sh")
bind(mainMod .. " + SHIFT + W", hl.dsp.global("quickshell:wallpaperCarouselToggle"), { description = "Wallpaper carousel" })

-- Focus
bind(mainMod .. " + Left", hl.dsp.focus({ direction = "l" }))
bind(mainMod .. " + Right", hl.dsp.focus({ direction = "r" }))
bind(mainMod .. " + Up", hl.dsp.focus({ direction = "u" }))
bind(mainMod .. " + Down", hl.dsp.focus({ direction = "d" }))

-- Function to duplicate the behavior of monitor_workspaces.sh in Lua
local function dispatch_workspace(action, key_num)
	return function()
		local active_monitor = hl.get_active_monitor()
		local monitor_id = active_monitor and active_monitor.id or 0
		local target = (monitor_id * 10) + key_num

		if action == "workspace" then
			hl.dispatch(hl.dsp.focus({ workspace = target }))
		elseif action == "movetoworkspace" then
			hl.dispatch(hl.dsp.window.move({ workspace = target, follow = false }))
		elseif action == "movetoworkspacesilent" then
			hl.dispatch(hl.dsp.window.move({ workspace = target }))
		end
	end
end

-- Workspaces
for i = 1, 10 do
	local key = i % 10
	bind(mainMod .. " + " .. tostring(key), dispatch_workspace("workspace", i))
	bind(mainMod .. " + SHIFT + " .. tostring(key), dispatch_workspace("movetoworkspace", i))
	bind(mainMod .. " + ALT + " .. tostring(key), dispatch_workspace("movetoworkspacesilent", i))
end

-- Relative Workspaces
bind(mainMod .. " + CTRL + Right", hl.dsp.focus({ workspace = "r+1" }))
bind(mainMod .. " + CTRL + Left", hl.dsp.focus({ workspace = "r-1" }))
bind(mainMod .. " + CTRL + Down", hl.dsp.focus({ workspace = "empty" }))

-- Resize
bind(mainMod .. " + SHIFT + Right", hl.dsp.window.resize({ x = 30, y = 0, relative = true }), { repeating = true })
bind(mainMod .. " + SHIFT + Left", hl.dsp.window.resize({ x = -30, y = 0, relative = true }), { repeating = true })
bind(mainMod .. " + SHIFT + Up", hl.dsp.window.resize({ x = 0, y = -30, relative = true }), { repeating = true })
bind(mainMod .. " + SHIFT + Down", hl.dsp.window.resize({ x = 0, y = 30, relative = true }), { repeating = true })

-- Move Windows
bind(mainMod .. " + SHIFT + CTRL + Left", hl.dsp.window.move({ direction = "l" }))
bind(mainMod .. " + SHIFT + CTRL + Right", hl.dsp.window.move({ direction = "r" }))
bind(mainMod .. " + SHIFT + CTRL + Up", hl.dsp.window.move({ direction = "u" }))
bind(mainMod .. " + SHIFT + CTRL + Down", hl.dsp.window.move({ direction = "d" }))

-- Mouse Binds
bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
bind(mainMod .. " + Z", hl.dsp.window.drag(), { mouse = true })
bind(mainMod .. " + X", hl.dsp.window.resize(), { mouse = true })

-- Special Workspace
bind(mainMod .. " + ALT + S", hl.dsp.window.move({ workspace = "special", follow = false }))
bind(mainMod .. " + S", hl.dsp.workspace.toggle_special(""))
bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "+0", follow = false }))

-- Split
bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

-- Lid Switch
bind("switch:on:Lid Switch", "hyprctl dispatch dpms off")
bind("switch:off:Lid Switch", "hyprctl dispatch dpms on")

-- Group Move
bind(mainMod .. " + SHIFT + ALT + Left", hl.dsp.group.move_window("l"))
bind(mainMod .. " + SHIFT + ALT + Right", hl.dsp.group.move_window("r"))
bind(mainMod .. " + SHIFT + ALT + Up", hl.dsp.group.move_window("u"))
bind(mainMod .. " + SHIFT + ALT + Down", hl.dsp.group.move_window("d"))

-- Misc
--bind(mainMod .. " + F", "ags run-js 'cycleMode();'")
bind(mainMod .. " + C", 'XDG_CURRENT_DESKTOP="gnome" gnome-control-center')

-- Plugins
bind(mainMod .. " + L", hl.plugin.overview.toggle)
