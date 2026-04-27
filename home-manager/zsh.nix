# `zsh -i --login` reads ALL files in this order: .zprofile .zshrc .zlogin
# `zsh -i` reads .zshrc

{ lib, pkgs, ... }:
{
  assertions = [
    {
      assertion =
        builtins.convertHash {
          hash = builtins.hashFile "sha256" "${pkgs.path}/pkgs/by-name/zs/zsh/package.nix";
          hashAlgo = "sha256";
          toHashFormat = "sri";
        } == "sha256-hbaz9x1koNreZsMvh9DZ/ZjHqqjHcqyxVyC6lDTIu14=";
      message = ''
        https://github.com/NixOS/nixpkgs/blob/nixpkgs-unstable/pkgs/by-name/zs/zsh/package.nix has an update.
        Consider whether the workaround for https://github.com/NixOS/nixpkgs/issues/513543#issuecomment-4321051141 is still needed or not.
      '';
    }
  ];

  nixpkgs.overlays = [
    (final: prev: {
      # FIXME: zsh hangs if it reads .zshrc on start.
      # See https://github.com/NixOS/nixpkgs/issues/513543#issuecomment-4321051141
      # This bug also causes direnv to hang during its test.
      # See https://github.com/NixOS/nixpkgs/issues/513019
      zsh = prev.zsh.overrideAttrs (prevAttrs: {
        configureFlags = prevAttrs.configureFlags ++ [ "zsh_cv_sys_sigsuspend=yes" ];
      });
    })
  ];

  programs.zsh.enable = true;
  # In preparation for using neovim as default terminal program,
  # we disable vi mode in shell.
  # programs.zsh.defaultKeymap = "viins";
  programs.zsh.initContent = lib.mkBefore ''
    # Ensure SHELL is correctly set.
    # Note that this must appear after we have set up the PATH,
    # otherwise, `command -v zsh` points to a zsh that is not installed by Nix.
    export SHELL="$(command -v zsh)"
  '';
}
