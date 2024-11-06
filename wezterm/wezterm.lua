-- Pull in the wezterm API
local wezterm = require("wezterm")

-- This will hold the configuration.
local config = wezterm.config_builder()

local my = wezterm.color.get_builtin_schemes()["tokyonight_night"]
my.cursor_bg = "red"

config.color_schemes = {
	["my"] = my,
}
config.color_scheme = "my"

config.window_background_opacity = 0.8

config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
-- config.show_tab_index_in_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.show_new_tab_button_in_tab_bar = false

config.window_decorations = "INTEGRATED_BUTTONS | RESIZE"

config.window_padding = {
	left = 5,
	right = 5,
	top = 0,
	bottom = 0,
}

return config
