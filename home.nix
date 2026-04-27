_: {
  config = {
    # Since stateVersion 25.11, home-manager can now
    # copy macOS apps and make them Spotlight friendly.
    # See https://nix-community.github.io/home-manager/options.xhtml#opt-targets.darwin.copyApps.enable
    # You will likely encounter weird error in the switch that involves stateVersion change.
    # In that case, you delete $HOME/Applications/Home Manager*
    home.stateVersion = "26.05";
    programs.home-manager.enable = true;

    # It may be tempting to set XDG_*_HOME, in order to "correct"
    # the behavior of some CLI programs written in Rust, using the library
    # https://github.com/dirs-dev/directories-rs
    # That library does not follow XDG convention when the platform is macOS.
    # See https://github.com/dirs-dev/directories-rs/issues/47#issuecomment-2278253036
    # It seems that if the CLI program has switched to
    # https://github.com/lunacookies/etcetera
    # and use XDG convention, it would behave in a way most people expect.
    # However, when the shell is launched by a terminal, XDG_*_HOME is not set yet.
    # Thus, the shell still reads from the default location.
    # So let's just accept this.
    #xdg.enable = true;
    #xdg.cacheHome = lib.mkIf pkgs.stdenv.isDarwin "${config.home.homeDirectory}/Library/Caches";
  };
  imports = [
    ./home-manager/nix.nix

    ./home-manager/fonts.nix

    ./home-manager/unicode

    ./home-manager/tiling-window-manager.nix

    ./home-manager/karabiner.nix

    # For showing a customized date pattern in the menu bar on macOS.
    ./home-manager/itsycal.nix

    ./home-manager/hammerspoon

    ./home-manager/x-alfred.nix
    ./home-manager/alfred

    # Terminals.
    ./home-manager/terminal.nix
    ./home-manager/tmux.nix
    ./home-manager/kitty.nix
    ./home-manager/alacritty.nix
    ./home-manager/wezterm.nix
    ./home-manager/ghostty.nix

    # Browsers
    ./home-manager/firefox

    # Shells.
    ./home-manager/shell-integration.nix
    ./home-manager/environment-variables.nix
    ./home-manager/bash.nix
    ./home-manager/x-elvish.nix
    ./home-manager/elvish.nix
    ./home-manager/fish.nix
    ./home-manager/nushell.nix
    ./home-manager/zsh.nix
    ./home-manager/starship.nix
    ./home-manager/shell-completion.nix
    ./home-manager/direnv.nix
    ./home-manager/atuin.nix
    ./home-manager/zoxide.nix
    ./home-manager/ls.nix

    # Collections of programs.
    ./home-manager/replace-macos-stock-programs.nix
    ./home-manager/my-scripts.nix
    ./home-manager/simple-programs.nix
    ./home-manager/language-servers.nix
    ./home-manager/archive-and-compression.nix
    ./home-manager/diff-and-patch.nix
    ./home-manager/grep-and-sed.nix
    ./home-manager/pager.nix
    ./home-manager/networking-tools.nix
    ./home-manager/browser-automation.nix
    ./home-manager/multimedia.nix
    ./home-manager/grammar-and-spell-checking

    ./home-manager/awk.nix
    ./home-manager/lua.nix
    ./home-manager/nodejs.nix
    ./home-manager/clojure.nix
    ./home-manager/janet.nix
    ./home-manager/python.nix
    ./home-manager/ruby.nix
    ./home-manager/go.nix
    ./home-manager/java.nix
    ./home-manager/perl.nix
    ./home-manager/dart.nix
    ./home-manager/zig.nix

    # Text editors.
    ./home-manager/vim.nix
    ./home-manager/neovim.nix

    # Individual programs that require configurations.
    ./home-manager/_1password.nix
    ./home-manager/man.nix
    ./home-manager/mkcert.nix
    ./home-manager/git.nix
    ./home-manager/fd.nix
    ./home-manager/fzf.nix
    ./home-manager/ripgrep.nix
    ./home-manager/tldr.nix
    ./home-manager/gcloud.nix
    ./home-manager/gnuinfo.nix
    ./home-manager/btop.nix
    ./home-manager/fastfetch.nix
    ./home-manager/claude
    ./home-manager/tailscale.nix
    ./home-manager/plain-text-accounting.nix
    ./home-manager/timg.nix
    ./home-manager/jq.nix
    ./home-manager/numbat
    ./home-manager/syncthing.nix
    ./home-manager/smb.nix

    # PGP and friends
    ./home-manager/pgp.nix
    ./home-manager/ssh.nix

    # Flutter is now installed per project with flake.nix
  ];
}
