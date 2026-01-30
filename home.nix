{
  username,
  homeDirectory,
  nixPath_nixpkgs,
  nixPath_home-manager,
  nixPath_nix-darwin,
  nixPath_darwin-config,
  nixPath_for-nixd,
  mcp-servers-nix,
  nur,
  ...
}:
{
  config = {
    # Since stateVersion 25.11, home-manager can now
    # copy macOS apps and make them Spotlight friendly.
    # See https://nix-community.github.io/home-manager/options.xhtml#opt-targets.darwin.copyApps.enable
    # You will likely encounter wierd error in the switch that involves stateVersion change.
    # In that case, you delete $HOME/Applications/Home Manager*
    home.stateVersion = "25.11";
    programs.home-manager.enable = true;

    nixpkgs.overlays = [
      mcp-servers-nix.overlays.default
      nur.overlays.default
    ];

    nixpkgs.config.allowUnfree = true;
    # Allow ghostty, which is marked as broken on macOS.
    nixpkgs.config.allowBroken = true;

    home.username = username;
    home.homeDirectory = homeDirectory;

    # Set LANG.
    # LANG=C.UTF-8 causes zsh not to display Unicode characters such as Japanese.
    home.language.base = "en_US.UTF-8";

    # Set NIX_PATH
    # nix-darwin also offers a similar option but we do this in home-manager because
    # nix-darwin only supports a limited number of shells.
    # nix.nixPath in home-manager is implemented by home.sessionVariables, and
    # we expect the shell module supports home.sessionVariables, like ./home-manager/x-elvish.nix
    nix.keepOldNixPath = false;
    nix.nixPath = [
      "nixpkgs=${nixPath_nixpkgs}"
      "home-manager=${nixPath_home-manager}"
      "nix-darwin=${nixPath_nix-darwin}"
      "darwin-config=${nixPath_darwin-config}"
      "for-nixd=${nixPath_for-nixd}"
    ];

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

    # Unicode
    ./home-manager/unicode

    # Theme
    ./home-manager/catppuccin.nix

    # Tiling Window Manager
    ./home-manager/tiling-window-manager.nix

    # Karabiner
    ./home-manager/karabiner.nix

    # For showing a customized date pattern in the menu bar on macOS.
    ./home-manager/itsycal.nix

    # Hammerspoon
    ./home-manager/hammerspoon

    # Alfred
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
    ./home-manager/eza.nix

    # Collections of programs.
    ./home-manager/replace-macos-stock-programs.nix
    ./home-manager/my-scripts.nix
    ./home-manager/simple-programs.nix
    ./home-manager/language-servers.nix
    ./home-manager/languages.nix

    # Grammar and spell checking
    ./home-manager/grammar-and-spell-checking.nix

    ./home-manager/lua.nix
    ./home-manager/nodejs.nix
    ./home-manager/clojure.nix
    ./home-manager/janet.nix
    # Python and programs distributed as Python packages.
    ./home-manager/python.nix
    # Ruby and its support packages.
    ./home-manager/ruby.nix
    # Go and its support packages.
    ./home-manager/go.nix
    ./home-manager/java.nix

    # Text editors.
    ./home-manager/vim.nix
    ./home-manager/neovim.nix

    # Individual programs that require configurations.
    ./home-manager/man.nix
    ./home-manager/mkcert.nix
    ./home-manager/git.nix
    ./home-manager/fd.nix
    ./home-manager/fzf.nix
    ./home-manager/ripgrep.nix
    ./home-manager/tldr.nix
    ./home-manager/gcloud.nix
    ./home-manager/gnuinfo.nix
    # ./home-manager/codex
    ./home-manager/btop.nix
    ./home-manager/fastfetch.nix
    ./home-manager/claude
    ./home-manager/tailscale.nix

    # SOPS and PGP
    ./home-manager/pgp.nix
    ./home-manager/sops.nix
    ./home-manager/rclone.nix

    # Sync between devices
    ./home-manager/syncthing.nix

    # Android SDK is now installed with a shell script.
    # Managing Android SDK with Nix incurs an overhead when
    # we update flake.lock.
    # Every time we update flake.lock,
    # the 40GB+ Android SDK has to be downloaded again.
    # That is a waste in both bandwidth and time.
    ./home-manager/android.nix

    # Flutter is now installed per project with flake.nix
  ];
}
