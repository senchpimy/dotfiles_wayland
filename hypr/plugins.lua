-- Plugins Configuration
local function get_enabled_plugins()
	local handle = io.popen("hyprpm list 2>/dev/null")
	local enabled_plugins = {}
	if handle then
		local current_plugin = ""
		for line in handle:lines() do
			-- Extract plugin name (handling different possible formats)
			local plugin_match = line:match("Plugin%s+([%w%-%.%_]+)")
			if plugin_match then
				current_plugin = plugin_match
			end
			-- Check if it is enabled
			if line:match("enabled: true") and current_plugin ~= "" then
				enabled_plugins[current_plugin] = true
			end
		end
		handle:close()
	end
	return enabled_plugins
end

local enabled = get_enabled_plugins()
local plugin_config = {}

-- Dynamic Cursors
if enabled["dynamic-cursors"] then
	plugin_config["dynamic-cursors"] = {
		enabled = true,
		mode = "tilt",
		tilt = {
			limit = 1000,
			["function"] = "negative_quadratic",
		},
		stretch = {
			limit = 1000,
			["function"] = "quadratic",
		},
		shake = {
			enabled = true,
			base = 2.5,
			threshold = 4.0,
			timeout = 2000,
			speed = 1.0,
			nearest = false,
		},
		hyprcursor = {
			enabled = true,
			nearest = false,
			resolution = -1,
		},
	}
end

-- Imgborders
if enabled["imgborders"] then
	plugin_config.imgborders = {
		enabled = true,
		image = os.getenv("HOME") .. "/configs/hypr/gui.png",
		sizes = "4,4,4,4",
		insets = "3,3,2,2",
		scale = 4,
		smooth = false,
	}
end

-- Hyprbars
if enabled["hyprbars"] then
	plugin_config.hyprbars = {
		bar_height = 0,
		bar_color = "rgb(1e1e1e)",
		["col.text"] = "rgb(ffffff)",
		bar_text_size = 12,
		bar_text_font = "Jetbrains Mono Nerd Font Mono Bold",
		bar_button_padding = 20,
		bar_padding = 10,
		bar_precedence_over_border = true,
	}
end

-- Touch Gestures
if enabled["touch_gestures"] or enabled["hyprgrass"] then
	local name = enabled["touch_gestures"] and "touch_gestures" or "hyprgrass"
	plugin_config[name] = {
		sensitivity = 4.0,
		workspace_swipe_fingers = 3,
		workspace_swipe_edge = "d",
		long_press_delay = 100,
		resize_on_border_long_press = true,
		edge_margin = 30,
		emulate_touchpad_swipe = false,
	}
end

-- Hyprspace
if enabled["Hyprspace"] then
	plugin_config.Hyprspace = {
		-- Add Hyprspace specific config here if needed
	}
end

hl.config({
	plugin = plugin_config,
})

-- Funciones adicionales para plugins específicos
if enabled["hyprbars"] then
	pcall(function()
		hl.plugin.hyprbars.add_button({
			bg_color = "rgb(ffff00)",
			size = 25,
			icon = "",
			command = "hyprctl dispatch killactive",
		})
	end)
end
