{ config, ... }:
{
  programs.kitty.enable = true;
  programs.kitty.shellIntegration.mode = "disabled";
  programs.kitty.settings = {
    # shell
    shell = "${config.home.profileDirectory}/bin/fish --interactive --login";
    # color
    include = "${../.config/kitty/catppuccin-mocha.conf}";
    # Do not check for update.
    update_check_interval = 0;
    # Remote control
    listen_on = "unix:/tmp/mykitty";
    allow_remote_control = "socket-only";
    # Stop the cursor from blinking
    cursor_blink_interval = 0;
    # font
    font_family = "JetBrains Mono NL Light";
    italic_font = "JetBrains Mono NL Light Italic";
    bold_font = "JetBrains Mono NL Bold";
    bold_italic_font = "JetBrains Mono NL Bold Italic";
    font_size = 13.0;
    disable_ligatures = "always";
    undercurl_style = "thick-sparse";
    # Selection and clipboard
    strip_trailing_spaces = "smart";
    # macOS
    macos_quit_when_last_window_closed = "yes";
    # When we enable shell integration,
    # we may want to set this back to -1.
    # See https://sw.kovidgoyal.net/kitty/conf/#opt-kitty.confirm_os_window_close
    confirm_os_window_close = 0;
  };
  programs.kitty.keybindings = {
    # Make ctrl+shift+6 the same as ctrl+6
    # This makes CTRL-^ works in vim again.
    #
    # ESC [ \x16 ; 5 ~
    #   ^     ^  ^ ^ ^
    #   |     |  | | |- End of CSI
    #   |     |  | |- The modifier 1+4, which is ctrl.
    #   |     |  |- The separator
    #   |     |- The byte of the key "6", which is 0x16.
    #   |- Start of Control Sequence Introducer (CSI)
    #
    # See https://en.wikipedia.org/wiki/ANSI_escape_code#Terminal_input_sequences
    "ctrl+shift+6" = "send_text \e[\x16;5~";
  };
  programs.kitty.extraConfig = ''
    # tmux bind-key R
    #map ctrl+space>shift+r load_config_file

    # kitty main font must be monospace.
    # We ask kitty to use this font for CJK.
    symbol_map        U+4E00-U+9FFF   Source Han Mono
    symbol_map        U+3400–U+4DBF   Source Han Mono
    symbol_map        U+20000–U+2A6DF Source Han Mono
    symbol_map        U+2A700–U+2B73F Source Han Mono
    symbol_map        U+2B740–U+2B81F Source Han Mono
    symbol_map        U+2B820–U+2CEAF Source Han Mono
    symbol_map        U+2CEB0–U+2EBEF Source Han Mono
    symbol_map        U+30000–U+3134F Source Han Mono
    symbol_map        U+31350–U+323AF Source Han Mono
    symbol_map        U+2EBF0–U+2EE5F Source Han Mono
    symbol_map        U+F900–U+FAFF   Source Han Mono
    symbol_map        U+3300–U+33FF   Source Han Mono
    symbol_map        U+FE30–U+FE4F   Source Han Mono
    symbol_map        U+F900–U+FAFF   Source Han Mono
    symbol_map        U+2F800–U+2FA1F Source Han Mono

    # Tabs
    tab_bar_style        hidden
    #tab_bar_style        separator
    #tab_bar_min_tabs     1
    #tab_bar_align        left
    #tab_switch_strategy  left
    #tab_title_max_length 0
    #tab_title_template   "{index}:{title}"
    #map cmd+1 goto_tab 1
    #map cmd+2 goto_tab 2
    #map cmd+3 goto_tab 3
    #map cmd+4 goto_tab 4
    #map cmd+5 goto_tab 5
    #map cmd+6 goto_tab 6
    #map cmd+7 goto_tab 7
    #map cmd+8 goto_tab 8
    #map cmd+9 goto_tab 9

    # Windows
    #enabled_layouts        splits
    #map ctrl+space>%       launch --location=vsplit --cwd=current
    #map ctrl+space>"       launch --location=hsplit --cwd=current
    #map ctrl+space>c       launch --type=tab --cwd=current
    #map ctrl+space>q       close_window
    #map ctrl+space>k       neighboring_window up
    #map ctrl+space>l       neighboring_window right
    #map ctrl+space>j       neighboring_window down
    #map ctrl+space>h       neighboring_window left
    #map ctrl+space>shift+k move_window up
    #map ctrl+space>shift+l move_window right
    #map ctrl+space>shift+j move_window down
    #map ctrl+space>shift+h move_window left
    #map ctrl+space>w       launch --type overlay ~/.config/kitty/choose_tab.py
  '';
}
