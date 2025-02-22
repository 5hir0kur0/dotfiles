local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.font = wezterm.font_with_fallback({
	-- 'Monaspace Xenon',
	{
		family = "Iosevka Term Slab",
		harfbuzz_features = { "+ss07", "kern", "liga", "clig", "dlig" },
	},
	"Noto Serif CJK JP",
})
config.font_rules = {
	{
		italic = true,
		font = wezterm.font({
			family = "Iosevka Term Slab",
			italic = true,
			-- Disable ss07 feature in italic text
			harfbuzz_features = {},
		}),
	},
}
config.font_size = 15
config.line_height = 1.15
-- color_scheme = 'Solarized Dark Higher Contrast (Gogh)'
config.color_scheme = "GruvboxDarkHard"
-- color_scheme = 'Gruvbox dark, hard (base16)'
config.default_cursor_style = "SteadyBar"
config.hide_tab_bar_if_only_one_tab = true
config.force_reverse_video_cursor = true
config.scrollback_lines = 10000
-- scroll less fast (useful when scrolling via touchpad)
config.alternate_buffer_wheel_scroll_speed = 1
config.window_decorations = "RESIZE"
config.window_padding = {
	left = 0,
	right = 0,
	top = 0,
	bottom = 0,
}
config.enable_wayland = true
config.use_fancy_tab_bar = false

local ok, local_config = pcall(require, "wezterm-local")
if ok and type(local_config) == "table" then
  for k, v in pairs(local_config) do
    config[k] = v
  end
end

return config 
