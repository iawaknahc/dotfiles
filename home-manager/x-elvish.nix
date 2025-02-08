{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.x-elvish;
  elvishEscape = builtins.replaceStrings [ "'" ] [ "''" ];
  sessionVariablesStr = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (
      k: v: "set-env ${k} '${elvishEscape (builtins.toString v)}'"
    ) config.home.sessionVariables
  );
  aliasesStr = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (k: v: "fn ${k} {|@a| e:${v} $@a }") config.home.shellAliases
  );
in
{
  options = {
    programs.x-elvish = {
      enable = lib.mkEnableOption "https://elv.sh/";

      package = lib.mkPackageOption pkgs "elvish" { default = "elvish"; };

      rcExtra = lib.mkOption {
        default = "";
        type = lib.types.lines;
        description = ''
          ~/.config/elvish/rc.elv
        '';
      };
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
    xdg.configFile."elvish/rc.elv" = {
      enable = true;
      text = ''
        # ~/.config/elvish/rc.elv: DO NOT EDIT -- this file has been generated
        # automatically by home-manager.

        if (eq $E:__elvish_home_manager_config_sourced 1) {
          exit
        }
        set-env __elvish_home_manager_config_sourced 1

        set paths = [ $E:HOME'/.nix-profile/bin' /run/current-system/sw/bin /nix/var/nix/profiles/default/bin /usr/local/bin /usr/bin /bin /usr/sbin /sbin ]
        set-env NIX_SSL_CERT_FILE '/etc/ssl/certs/ca-certificates.crt'
        set-env PAGER 'less -R'
        set-env TERMINFO_DIRS $E:HOME'/.nix-profile/share/terminfo:/run/current-system/sw/share/terminfo:/nix/var/nix/profiles/default/share/terminfo:/usr/share/terminfo'
        set-env XDG_CONFIG_DIRS $E:HOME'/.nix-profile/etc/xdg:/run/current-system/sw/etc/xdg:/nix/var/nix/profiles/default/etc/xdg'
        set-env XDG_DATA_DIRS $E:HOME'/.nix-profile/share:/run/current-system/sw/share:/nix/var/nix/profiles/default/share'
        set-env TERM $E:TERM
        set-env NIX_USER_PROFILE_DIR '/nix/var/nix/profiles/per-user/'$E:USER
        set-env NIX_PROFILES '/nix/var/nix/profiles/default /run/current-system/sw '$E:HOME'/.nix-profile'
        set-env NIX_REMOTE 'daemon'

        ${sessionVariablesStr}

        ${aliasesStr}

        ${cfg.rcExtra}
      '';
    };
  };
}
