{ pkgs, config, ... }:
{
  # The primary use case of chezmoi is to manage the configuration of Alfred, due to the following reasons:
  # - Alfred does not quite like symlinks. For example, when the prefs.plist of a workflow is a symlink, saving the prefs will turn it into a regular file.
  # - Alfred has many prefs.plist files. And using the GUI to change settings will cause them to appear and disappear.
  #   `chezmoi status`, `chezmoi diff` will be very helpful on seeing what Alfred has changed, and integrate the changes.
  home.packages = with pkgs; [
    chezmoi
  ];

  xdg.configFile."chezmoi/chezmoi.yaml".text = ''
    sourceDir: "${config.home.homeDirectory}/dotfiles/chezmoi"
  '';
}
