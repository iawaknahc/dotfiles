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
    ./home-manager/terminal.nix
    ./home-manager/my-scripts.nix
    ./home-manager/fonts.nix

    ./home-manager/kitty.nix
    ./home-manager/alacritty.nix
    ./home-manager/wezterm.nix
    ./home-manager/ghostty.nix

    ./home-manager/simple-programs.nix

    ./home-manager/tailwindcss-language-server.nix
    ./home-manager/cronstrue.nix
    ./home-manager/json5.nix
    ./home-manager/mkcert.nix
    ./home-manager/gpg.nix
    ./home-manager/navi.nix
    ./home-manager/vim.nix
    ./home-manager/tmux.nix
    ./home-manager/bat.nix
    ./home-manager/delta.nix
    ./home-manager/git.nix
    ./home-manager/pip.nix
    ./home-manager/bash.nix
    ./home-manager/zsh.nix
    ./home-manager/fish.nix
    ./home-manager/nushell.nix
    ./home-manager/starship.nix
    ./home-manager/direnv.nix
    ./home-manager/fd.nix
    ./home-manager/fzf.nix
    ./home-manager/ripgrep.nix
    ./home-manager/neovim.nix
    ./home-manager/tldr.nix
    ./home-manager/gcloud.nix
    ./home-manager/gnuinfo.nix
    ./home-manager/qrcode.nix
    ./home-manager/databases.nix

    ./home-manager/android.nix
    ./home-manager/flutter.nix
  ];
}
