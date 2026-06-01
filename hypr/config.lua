-- General Configuration
local col = require("colors")

local function is_laptop()
	local handle = io.popen("hostnamectl chassis 2>/dev/null")
	local result = ""
	if handle then
		result = handle:read("*a"):gsub("%s+", "")
		handle:close()
	end

	if result == "laptop" or result == "convertible" or result == "tablet" then
		return true
	end

	-- Fallback: Check for battery
	local f = io.open("/sys/class/power_supply/BAT0", "r")
	if f then
		f:close()
		return true
	end
	f = io.open("/sys/class/power_supply/BAT1", "r")
	if f then
		f:close()
		return true
	end

	return false
end

local kb_layout = is_laptop() and "us" or "es"

hl.config({
	general = {
		gaps_in = 4,
		gaps_out = 5,
		border_size = 3,

		col = {
			active_border = col.active_border,
			inactive_border = col.inactive_border,
		},
		--["col.inactive_border"] = "rgba(076978ff) rgba(CCF8FFff) 45deg",
		--["col.active_border"] = "rgba(962D26ff) rgba(E08882ff) 50deg",
		layout = "dwindle",
		resize_on_border = true,
		extend_border_grab_area = true,
		snap = {
			enabled = true,
		},
	},

	input = {
		kb_layout = kb_layout,
		follow_mouse = 1,
		sensitivity = 1.0,
		accel_profile = "flat",
		force_no_accel = true,
		touchpad = {
			natural_scroll = false,
		},
	},

	gestures = {
		workspace_swipe_touch = true,
		workspace_swipe_distance = 150,
		workspace_swipe_cancel_ratio = 0.15,
	},

	dwindle = {
		preserve_split = true,
	},

	misc = {
		vrr = 1,
		--vfr = 1,
		disable_hyprland_logo = true,
		disable_splash_rendering = true,
		force_default_wallpaper = 0,
		enable_swallow = false,
		swallow_regex = "^(Alacritty|kitty|footclient|rio)$",
		swallow_exception_regex = "^(?!.*firefox).+$",
	},

	xwayland = {
		force_zero_scaling = true,
	},

	decoration = {
		rounding = 30,
		blur = {
			enabled = true,
			size = 8,
			passes = 3,
			new_optimizations = true,
			ignore_opacity = true,
			xray = false,
			noise = 0.01,
			contrast = 1.6,
			brightness = 1.1,
			vibrancy = 0.1696,
			special = true,
		},
		dim_inactive = false,
		dim_strength = 0.1,
		dim_special = 0.3,
		shadow = {
			enabled = true,
			range = 70,
			render_power = 4,
			offset = "5 10",
			color = "rgb(000000)",
			scale = 0.97,
		},
	},

	group = {
		col = {
			border_active = col.group_active_border,
			border_inactive = col.group_inactive_border,
		},

		groupbar = {
			col = {
				active = col.groupbar_active,
				inactive = col.groupbar_inactive,
			},

			font_weight_active = "bold",
			font_weight_inactive = "bold",

			gradients = true,
			font_size = 14,
			height = 24,
			gradient_rounding = 10,
			text_color = col.groupbar_text_color,

			indicator_height = 0,
			indicator_gap = 2,
			keep_upper_gap = false,
		},
	},

	cursor = {
		no_hardware_cursors = true,
	},

	binds = {
		allow_workspace_cycles = true,
		movefocus_cycles_fullscreen = true,
	},

	debug = {
		disable_scale_checks = true,
		damage_tracking = 0, -- off
	},
})
