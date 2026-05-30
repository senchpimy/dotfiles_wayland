-- Keybindings
local HOME = os.getenv("HOME")
local scrPath = HOME .. "/.local/share/bin"
local mainMod = "SUPER"
local term = "kitty"
local file = "nautilus"

local function bind_global(key, func, desc)
    hl.bind(mainMod .. " +" .. key, hl.dsp.global(func), { description = desc })
end

local function bind_exec(key, func)
    hl.bind(mainMod .. " +" .. key, hl.dsp.exec_cmd(func))
end

-- General Binds
bind_global("V", "quickshell:overviewClipboardToggle", "Clipboard history")
bind_global("SHIFT + Tab", "quickshell:overviewToggle", "Toggle overview")
bind_global("Delete", "quickshell:sessionToggle", "Toggle session menu")
bind_global("ALT +M ", "quickshell:mediaControlsToggle", "Toggle media controls")

--bindd = Super+Shift, 8, Toggle cheatsheet, global, quickshell:wallpaperSelectorToggle # Toggle cheatsheet
--bindd = Super+Shift, 8, Toggle cheatsheet, global, quickshell:lock

hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.exit())
hl.bind(mainMod .. " + Space", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + G", hl.dsp.group.toggle())
hl.bind(mainMod .. " + D", hl.dsp.group.move_window("out"))
-- hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd(scrPath .. "/fuzzel-emoji.sh"))
-- #bind=ALT, TAB, changegroupactive
hl.bind(mainMod .. " + M", hl.dsp.window.fullscreen({ action = "toggle" }))
bind_exec("B", "qs -p ~/.config/quickshell/lockscreen.qml")
bind_exec("SHIFT + F", scrPath .. "/windowpin.sh") --TODO eliminar necesidad de script
bind_exec("SHIFT + Z", "woomer")
hl.bind(
    mainMod .. " + SHIFT + M",
    hl.dsp.exec_cmd(
        HOME
        .. "/Documents/PythonProjects/audio/.venv/bin/python "
        .. HOME
        .. "/Documents/PythonProjects/audio/src/local_client.py"
    )
)
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
hl.bind(mainMod .. " + CTRL + P", hl.dsp.exec_cmd(scrPath .. "/logoutlaunch.sh"))

-- Apps
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(term))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(file))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("pkill -x rofi || " .. scrPath .. "/runner.sh")) --TODO cambiar comando y script
hl.bind(mainMod .. " + TAB", hl.dsp.focus({ workspace = "previous" }))
--bind = $mainMod, C, exec, $editor # launch text editor
--bind = $mainMod, F, exec, $browser # launch web browser

-- Audio
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(scrPath .. "/volumecontrol.sh -o m"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd(scrPath .. "/volumecontrol.sh -i m"), { locked = true })
hl.bind(
    "XF86AudioLowerVolume",
    hl.dsp.exec_cmd(scrPath .. "/volumecontrol.sh -o d"),
    { locked = true, repeating = true }
)
hl.bind(
    "XF86AudioRaiseVolume",
    hl.dsp.exec_cmd(scrPath .. "/volumecontrol.sh -o i"),
    { locked = true, repeating = true }
)

-- Brightness
hl.bind(
    mainMod .. " + F3",
    hl.dsp.exec_cmd("qs -c .config/quickshell/shell.qml ipc call brightness increment || brightnessctl s 5%+"),
    { repeating = true }
)
hl.bind(
    mainMod .. " + F2",
    hl.dsp.exec_cmd("qs -c .config/quickshell/shell.qml ipc call brightness increment || brightnessctl s 5%-"),
    { repeating = true }
)

-- Custom Scripts
hl.bind(mainMod .. " + ALT + Right", hl.dsp.exec_cmd(scrPath .. "/awwwallpaper.sh -n"))
hl.bind(mainMod .. " + ALT + Left", hl.dsp.exec_cmd(scrPath .. "/awwwallpaper.sh -p"))
hl.bind(mainMod .. " + SHIFT + T", hl.dsp.exec_cmd("pkill -x rofi || " .. scrPath .. "/themeselect.sh"))
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.exec_cmd("pkill -x rofi || " .. scrPath .. "/rofiselect.sh"))
hl.bind(mainMod .. " + SHIFT + W", hl.dsp.exec_cmd("pkill -x rofi || " .. scrPath .. "/awwwallselect.sh"))

-- Focus
hl.bind(mainMod .. " + Left", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + Right", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + Up", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + Down", hl.dsp.focus({ direction = "d" }))

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
    hl.bind(mainMod .. " + " .. tostring(key), dispatch_workspace("workspace", i))
    hl.bind(mainMod .. " + SHIFT + " .. tostring(key), dispatch_workspace("movetoworkspace", i))
    hl.bind(mainMod .. " + ALT + " .. tostring(key), dispatch_workspace("movetoworkspacesilent", i))
end

-- Relative Workspaces
hl.bind(mainMod .. " + CTRL + Right", hl.dsp.focus({ workspace = "r+1" }))
hl.bind(mainMod .. " + CTRL + Left", hl.dsp.focus({ workspace = "r-1" }))
hl.bind(mainMod .. " + CTRL + Down", hl.dsp.focus({ workspace = "empty" }))

-- Resize
hl.bind(mainMod .. " + SHIFT + Right", hl.dsp.window.resize({ x = 30, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + Left", hl.dsp.window.resize({ x = -30, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + Up", hl.dsp.window.resize({ x = 0, y = -30, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + Down", hl.dsp.window.resize({ x = 0, y = 30, relative = true }), { repeating = true })

-- Move Windows
hl.bind(mainMod .. " + SHIFT + CTRL + Left", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + CTRL + Right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + CTRL + Up", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + CTRL + Down", hl.dsp.window.move({ direction = "d" }))

-- Mouse Binds
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind(mainMod .. " + Z", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + X", hl.dsp.window.resize(), { mouse = true })

-- Special Workspace
hl.bind(mainMod .. " + ALT + S", hl.dsp.window.move({ workspace = "special", follow = false }))
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special(""))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "+0", follow = false }))

-- Split
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))

-- Lid Switch
hl.bind("switch:on:Lid Switch", hl.dsp.exec_cmd("hyprctl dispatch dpms off"))
hl.bind("switch:off:Lid Switch", hl.dsp.exec_cmd("hyprctl dispatch dpms on"))

-- Group Move
hl.bind(mainMod .. " + SHIFT + ALT + Left", hl.dsp.group.move_window("l"))
hl.bind(mainMod .. " + SHIFT + ALT + Right", hl.dsp.group.move_window("r"))
hl.bind(mainMod .. " + SHIFT + ALT + Up", hl.dsp.group.move_window("u"))
hl.bind(mainMod .. " + SHIFT + ALT + Down", hl.dsp.group.move_window("d"))

-- Misc
hl.bind(mainMod .. " + F", hl.dsp.exec_cmd("ags run-js 'cycleMode();'"))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd('XDG_CURRENT_DESKTOP="gnome" gnome-control-center'))
