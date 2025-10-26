{ pkgs, ... }:
{
  # vivid set LS_COLORS
  # https://github.com/sharkdp/vivid
  programs.vivid.enable = true;
  programs.vivid.enableBashIntegration = true;
  programs.vivid.enableFishIntegration = true;
  programs.vivid.enableZshIntegration = true;

  home.packages = with pkgs; [
    catppuccin-whiskers
  ];
  catppuccin.flavor = "mocha";
  catppuccin.accent = "blue";
  # Do not enable all supported programs.
  # Instead we explicitly enable the programs we want.
  catppuccin.enable = false;
  catppuccin.alacritty.enable = true;
  catppuccin.btop.enable = true;
  catppuccin.ghostty.enable = true;
  catppuccin.kitty.enable = true;
  catppuccin.tmux.enable = true;
  catppuccin.tmux.extraConfig = ''
    set -g @catppuccin_status_background "default"
    set -g @catppuccin_window_status_style "rounded"
    set -g @catppuccin_window_current_number_color "#{@thm_yellow}"
  '';
  catppuccin.fish.enable = true;
  catppuccin.nushell.enable = true;
  catppuccin.atuin.enable = true;
  catppuccin.vivid.enable = true;
  services.jankyborders.settings = {
    style = "round";
    active_color = "0xff89b4fa";
    inactive_color = "0xff1e1e2e";
    width = 8.0;
  };

  # wezterm has catppuccin bundled so we need not enable it here.
}
