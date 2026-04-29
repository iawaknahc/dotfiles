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
    ./nix.nix

    ./fonts.nix

    ./unicode

    ./tiling-window-manager.nix

    ./karabiner.nix

    # For showing a customized date pattern in the menu bar on macOS.
    ./itsycal.nix

    ./hammerspoon

    ./x-alfred.nix
    ./alfred

    # Terminals.
    ./terminal.nix
    ./tmux.nix
    ./kitty.nix
    ./alacritty.nix
    ./wezterm.nix
    ./ghostty.nix

    # Browsers
    ./firefox

    # Shells.
    ./shell-integration.nix
    ./environment-variables.nix
    ./bash.nix
    ./x-elvish.nix
    ./elvish.nix
    ./fish.nix
    ./nushell.nix
    ./zsh.nix
    ./starship.nix
    ./shell-completion.nix
    ./direnv.nix
    ./atuin.nix
    ./zoxide.nix
    ./ls.nix

    # Collections of programs.
    ./replace-macos-stock-programs.nix
    ./my-scripts.nix
    ./simple-programs.nix
    ./language-servers.nix
    ./archive-and-compression.nix
    ./diff-and-patch.nix
    ./grep-and-sed.nix
    ./pager.nix
    ./networking-tools.nix
    ./browser-automation.nix
    ./multimedia.nix
    ./grammar-and-spell-checking

    ./awk.nix
    ./lua.nix
    ./nodejs.nix
    ./clojure.nix
    ./janet.nix
    ./python.nix
    ./ruby.nix
    ./go.nix
    ./java.nix
    ./perl.nix
    ./dart.nix
    ./zig.nix

    # Text editors.
    ./vim.nix
    ./neovim.nix

    # Individual programs that require configurations.
    ./_1password.nix
    ./man.nix
    ./mkcert.nix
    ./git.nix
    ./fd.nix
    ./fzf.nix
    ./ripgrep.nix
    ./tldr.nix
    ./gcloud.nix
    ./gnuinfo.nix
    ./btop.nix
    ./fastfetch.nix
    ./claude
    ./tailscale.nix
    ./plain-text-accounting.nix
    ./timg.nix
    ./jq.nix
    ./numbat
    ./syncthing.nix
    ./smb.nix
    ./obsidian.nix

    # PGP and friends
    ./pgp.nix
    ./ssh.nix

    # Flutter is now installed per project with flake.nix
  ];
}
