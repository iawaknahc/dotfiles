{ config, ... }:
{
  programs.wezterm.enable = true;
  programs.wezterm.enableBashIntegration = false;
  programs.wezterm.enableZshIntegration = false;
  programs.wezterm.extraConfig = ''
    local wezterm = require("wezterm")
    local config = wezterm.config_builder()

    -- The default in 20240203-110809-5046fc22 is still "OpenGL".
    -- Use platform-specific GPU backend.
    -- See https://github.com/wez/wezterm/issues/5990
    config.front_end = "WebGpu"

    config.window_close_confirmation = "NeverPrompt"

    -- $TERM
    config.term = "wezterm"
    config.set_environment_variables = {
      -- If we do not set TERMINFO, when wezterm starts, it complains TERM=wezterm is not found.
      TERMINFO = "${config.home.profileDirectory}/share/terminfo",
    }

    -- shell
    config.default_prog = {
      "${config.home.profileDirectory}/bin/fish",
      "--login",
      "--interactive",
    }

    -- tab
    config.enable_tab_bar = false

    -- font
    -- wezterm embeds JetBrains Mono by default.
    -- So it is unnecessary to configure font.
    -- But I am not a fan of ligatures.
    config.font = wezterm.font_with_fallback({
      family = "JetBrains Mono",
      harfbuzz_features = { "calt=0", "clig=0", "liga=0" },
    })
    config.font_rules = {
      {
        intensity = "Normal",
        italic = false,
        -- wezterm.font_with_fallback DOES NOT work here.
        font = wezterm.font({
          family = "JetBrains Mono",
          weight = "Light",
          harfbuzz_features = { "calt=0", "clig=0", "liga=0" },
        }),
      },
      {
        intensity = "Normal",
        italic = true,
        -- wezterm.font_with_fallback DOES NOT work here.
        font = wezterm.font({
          family = "JetBrains Mono",
          weight = "Light",
          italic = true,
          harfbuzz_features = { "calt=0", "clig=0", "liga=0" },
        }),
      },
      {
        intensity = "Bold",
        italic = false,
        -- wezterm.font_with_fallback DOES NOT work here.
        font = wezterm.font({
          family = "JetBrains Mono",
          weight = "Bold",
          harfbuzz_features = { "calt=0", "clig=0", "liga=0" },
        }),
      },
      {
        intensity = "Bold",
        italic = true,
        -- wezterm.font_with_fallback DOES NOT work here.
        font = wezterm.font({
          family = "JetBrains Mono",
          weight = "Bold",
          italic = true,
          harfbuzz_features = { "calt=0", "clig=0", "liga=0" },
        }),
      },
      {
        intensity = "Half",
        italic = false,
        -- wezterm.font_with_fallback DOES NOT work here.
        font = wezterm.font({
          family = "JetBrains Mono",
          weight = "Thin",
          harfbuzz_features = { "calt=0", "clig=0", "liga=0" },
        }),
      },
      {
        intensity = "Half",
        italic = true,
        -- wezterm.font_with_fallback DOES NOT work here.
        font = wezterm.font({
          family = "JetBrains Mono",
          weight = "Thin",
          italic = true,
          harfbuzz_features = { "calt=0", "clig=0", "liga=0" },
        }),
      },
    }
    config.font_size = 13.0

    -- color
    config.force_reverse_video_cursor = true
    config.colors = {
      foreground = "#f8f8f2",
      background = "#282a36",

      selection_fg = "none",
      selection_bg = "#44475a",

      ansi = {
        "#44475a",
        "#ff5555",
        "#50fa7b",
        "#f1fa8c",
        "#8be9fd",
        "#ff79c6",
        "#bd93f9",
        "#f8f8f2",
      },
      brights = {
        "#6272a4",
        "#ffb86c",
        "#50fa7b",
        "#f1fa8c",
        "#8be9fd",
        "#ff79c6",
        "#bd93f9",
        "#f8f8f2",
      },
    }

    return config
  '';
}
