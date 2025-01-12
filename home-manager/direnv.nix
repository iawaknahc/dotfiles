{ ... }:
{
  # Install the binary direnv.
  programs.direnv.enable = true;
  # Install nix-direnv to ~/.config/direnv/lib/hm-nix-direnv.sh
  programs.direnv.nix-direnv.enable = true;
}
