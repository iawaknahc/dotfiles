{
  username,
  homeDirectory,
  ...
}:
{
  config = {
    home.stateVersion = "24.05";
    programs.home-manager.enable = true;

    nixpkgs.config.allowUnfree = true;

    home.username = username;
    home.homeDirectory = homeDirectory;

    # Set LANG.
    # LANG=C.UTF-8 causes zsh not to display Unicode characters such as Japanese.
    home.language.base = "en_US.UTF-8";

    # It may be tempting to set XDG_*_HOME, in order to "correct"
    # the behavior of some CLI programs written in Rust, using the library
    # https://github.com/dirs-dev/directories-rs
    # That library does not follow XDG convention when the platform is macOS.
    # See https://github.com/dirs-dev/directories-rs/issues/47#issuecomment-2278253036
    # It seems that if the CLI program has switched to
    # https://github.com/lunacookies/etcetera
    # and use XDG convention, it would behave in a way most people expect.
    # However, when the shell is launched by a terminal, XDG_*_HOME is not set yet.
    # Thus the shell still reads from the default location.
    # So let's just accept this.
    #xdg.enable = true;
    #xdg.cacheHome = lib.mkIf pkgs.stdenv.isDarwin "${config.home.homeDirectory}/Library/Caches";
  };
  imports = [
    ./home-manager/fonts.nix

    # Terminals.
    ./home-manager/terminal.nix
    ./home-manager/tmux.nix
    ./home-manager/kitty.nix
    ./home-manager/alacritty.nix
    ./home-manager/wezterm.nix
    ./home-manager/ghostty.nix

    # Shells.
    ./home-manager/bash.nix
    ./home-manager/zsh.nix
    ./home-manager/fish.nix
    ./home-manager/nushell.nix
    ./home-manager/starship.nix
    ./home-manager/shell-completion.nix
    ./home-manager/direnv.nix

    # Collections of programs.
    ./home-manager/replace-macos-stock-programs.nix
    ./home-manager/my-scripts.nix
    ./home-manager/simple-programs.nix
    ./home-manager/language-servers.nix
    ./home-manager/languages.nix
    ./home-manager/databases.nix
    ./home-manager/qrcode.nix

    # Text editors.
    ./home-manager/vim.nix
    ./home-manager/neovim.nix

    # Programs that are not available on nixpkgs.
    ./home-manager/cronstrue.nix
    ./home-manager/json5.nix

    # Individual programs that require configurations.
    ./home-manager/mkcert.nix
    ./home-manager/gpg.nix
    ./home-manager/navi.nix
    ./home-manager/git.nix
    ./home-manager/fd.nix
    ./home-manager/fzf.nix
    ./home-manager/ripgrep.nix
    ./home-manager/tldr.nix
    ./home-manager/gcloud.nix
    ./home-manager/gnuinfo.nix

    ./home-manager/android.nix
    # Flutter is now installed per project with flake.nix
  ];
}
