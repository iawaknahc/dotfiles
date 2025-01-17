{ pkgs, ... }:
let
  wrapProgramForPackage = (
    package: postInstall:
    package.overrideAttrs (prev: {
      nativeBuildInputs = (prev.nativeBuildInputs or [ ]) ++ [ pkgs.makeWrapper ];
      postInstall = (prev.postInstall or "") + postInstall;
    })
  );
in
{
  # TLRC_CONFIG was implemented but not released yet.
  # So we need to wrap it and prepend --config
  # https://github.com/tldr-pages/tlrc/issues/89
  home.packages = with pkgs; [
    (wrapProgramForPackage tlrc ''
      wrapProgram $out/bin/tldr \
        --add-flags "--config ~/.config/tlrc/config.toml"
    '')
  ];
  xdg.configFile."tlrc" = {
    enable = true;
    recursive = true;
    source = ../.config/tlrc;
  };
}
