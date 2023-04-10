local wezterm = require 'wezterm'
return {
    scrollback_lines = 10000,
    font =  wezterm.font_with_fallback {
        {
            family = 'Iosevka Term Slab',
            harfbuzz_features = { '+ss07' },
        },
        'Noto Serif CJK JP',
    },
    font_size = 14.0,
    color_scheme = "Gruvbox Dark",
}
