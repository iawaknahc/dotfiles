{ ... }:
{
  catppuccin.flavor = "mocha";
  catppuccin.accent = "blue";
  # Do not enable all supported programs.
  # Instead we explicitly enable the programs we want.
  catppuccin.enable = false;
  catppuccin.alacritty.enable = true;
  catppuccin.ghostty.enable = true;
  catppuccin.kitty.enable = true;
  catppuccin.fish.enable = true;
  catppuccin.atuin.enable = true;
  # wezterm has catppuccin bundled so we need not enable it here.
}
