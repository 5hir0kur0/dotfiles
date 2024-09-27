local wezterm = require("wezterm")
return {
	font = wezterm.font_with_fallback({
		-- 'Monaspace Xenon',
		{
			family = "Iosevka Term Slab",
			harfbuzz_features = { "+ss07", "kern", "liga", "clig", "dlig" },
		},
		"Noto Serif CJK JP",
	}),
	font_rules = {
		{
			italic = true,
			font = wezterm.font({
				family = "Iosevka Term Slab",
				italic = true,
				-- Disable ss07 feature in italic text
				harfbuzz_features = {},
			}),
		},
	},
	font_size = 17,
	line_height = 1.15,
	-- color_scheme = 'Solarized Dark Higher Contrast (Gogh)',
	color_scheme = "GruvboxDarkHard",
	-- color_scheme = 'Gruvbox dark, hard (base16)',
	default_cursor_style = "SteadyBar",
	hide_tab_bar_if_only_one_tab = true,
	force_reverse_video_cursor = true,
	scrollback_lines = 10000,
	-- scroll less fast (useful when scrolling via touchpad)
	alternate_buffer_wheel_scroll_speed = 1,
	window_decorations = "RESIZE",
	window_padding = {
		left = 0,
		right = 0,
		top = 0,
		bottom = 0,
	},
}
