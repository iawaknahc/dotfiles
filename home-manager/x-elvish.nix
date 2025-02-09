{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.programs.x-elvish;
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
      # WARNING: nix-darwin setEnvironment.sh is not sourced.
      # WARNING: home.sessionVariables are not respected.
      # So elvish cannot be used as a main shell.
      text = ''
        # ~/.config/elvish/rc.elv: DO NOT EDIT -- this file has been generated
        # automatically by home-manager.

        if (eq $E:__elvish_home_manager_config_sourced 1) {
          exit
        }
        set-env __elvish_home_manager_config_sourced 1

        ${aliasesStr}

        ${cfg.rcExtra}
      '';
    };
  };
}
