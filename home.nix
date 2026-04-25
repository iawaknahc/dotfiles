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
  androidSdk,
  ...
}:
{
  config = {
    # Since stateVersion 25.11, home-manager can now
    # copy macOS apps and make them Spotlight friendly.
    # See https://nix-community.github.io/home-manager/options.xhtml#opt-targets.darwin.copyApps.enable
    # You will likely encounter weird error in the switch that involves stateVersion change.
    # In that case, you delete $HOME/Applications/Home Manager*
    home.stateVersion = "25.11";
    programs.home-manager.enable = true;

    nixpkgs.overlays = [
      mcp-servers-nix.overlays.default
      nur.overlays.default

      # The home-manager module of android-nixpkgs expects `pkgs.androidSdk` to be present.
      # One way of making it present is to use `android-nixpkgs.overlays.default`.
      # But `android-nixpkgs.overlays.default` uses `final`[1], which means the Android SDK
      # depends on OUR nixpkgs.
      # So even, if we do not override the input `nixpkgs` of `android-nixpkgs`,
      # at evaluation time, the Android SDK still depends on OUR nixpkgs.
      #
      # To make the Android SDK solely depends on its own `nixpkgs`, we need:
      # 1. Do not override the input `nixpkgs` of `android-nixpkgs`. This is trivial.
      # 2. Use an overlay to populate `pkgs.androidSdk`, AND it MUST depend on the input `nixpkgs` of `android-nixpkgs`.
      #    Fortunately, `android-nixpkgs` exposes an output `sdk`[2], which is an attrset of system names to `androidSdk`.
      #
      # [1]: https://github.com/tadfisher/android-nixpkgs/blob/2026-04-15-stable/flake.nix#L28
      # [2]: https://github.com/tadfisher/android-nixpkgs/blob/2026-04-15-stable/flake.nix#L58
      (final: prev: {
        inherit androidSdk;
      })
    ];

    nixpkgs.config.allowUnfree = true;
    # Allow ghostty, which is marked as broken on macOS.
    nixpkgs.config.allowBroken = true;

    home.username = username;
    home.homeDirectory = homeDirectory;

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
    ./home-manager/nix.nix

    ./home-manager/fonts.nix

    ./home-manager/unicode

    ./home-manager/catppuccin.nix

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
    ./home-manager/sops.nix
    ./home-manager/ssh.nix

    ./home-manager/android.nix

    # Flutter is now installed per project with flake.nix
  ];
}
