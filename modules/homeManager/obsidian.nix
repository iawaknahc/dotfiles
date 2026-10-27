{ ... }:
{
  # The settings ARE NOT managed by Nix.
  # Obsidian stores settings in the vault.
  # The vault is configured to be synchronized between devices with Syncthing.
  programs.obsidian.enable = true;
  programs.obsidian.cli.enable = true;
}
