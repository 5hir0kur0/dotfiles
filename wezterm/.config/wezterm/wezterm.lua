local wezterm = require 'wezterm'
return {
    scrollback_lines = 10000,
    font =  wezterm.font_with_fallback {
        {
            family = 'Iosevka Term Slab',
            -- harfbuzz_features = { '+ss07' },
        },
        'Noto Serif CJK JP',
    },
    font_size = 16.0,
    color_scheme = 'GruvboxDark',
    hide_tab_bar_if_only_one_tab = true,
    window_decorations = "RESIZE",
    window_padding = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0,
    },
}
