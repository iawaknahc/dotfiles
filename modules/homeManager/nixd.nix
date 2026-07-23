{
  inputs,
  hostname,
  pkgs,
  lib,
  config,
  ...
}:
let
  flake = "${inputs.self}";

  nixd-configuration = {
    nixd = {
      formatting = {
        command = [ "nixfmt" ];
      };
      nixpkgs = {
        # This evaluates to the actual pkgs with all overlays applied.
        expr = lib.strings.trim ''
          (builtins.getFlake (builtins.toString "${flake}")).homeConfigurations."${config.home.username}@${hostname}".pkgs
        '';
      };
      options = {
        nix-dawrin = {
          expr = lib.strings.trim ''
            (builtins.getFlake (builtins.toString "${flake}")).darwinConfigurations."${hostname}".options
          '';
        };
        home-manager = {
          expr = lib.strings.trim ''
            (builtins.getFlake (builtins.toString "${flake}")).homeConfigurations."${config.home.username}@${hostname}".options
          '';
        };
      };
    };
  };

  nixd-lspconfig = {
    # Known issue: inlay hint works only in `with pkgs; [ ... ]`
    # See https://github.com/nix-community/nixd/issues/629#issuecomment-2558520043
    cmd = [
      "nixd"
      "--inlay-hints=true"
      "--semantic-tokens=true"
    ];
    settings = nixd-configuration;
  };

  nixd-configuration-json = pkgs.writeText "nixd-configuration.json" (
    builtins.toJSON nixd-configuration
  );

  nixd-lspconfig-json = pkgs.writeText "nixd-lspconfig.json" (builtins.toJSON nixd-lspconfig);

  nixd-lspconfig-lua = pkgs.runCommand "nixd-lspconfig.lua" { } ''
    printf "return " > $out
    "${pkgs.lua55Packages.cjson}"/bin/json2lua "${nixd-lspconfig-json}" >> $out
  '';
in
{
  home.packages = with pkgs; [
    nixd
  ];
  home.shellAliases = {
    # Launch `nix repl` having `pkgs` with all overlays applied.
    # We use environment variable here so that the repl is never stale.
    nixrepl = ''nix repl --expr '(builtins.getFlake ((builtins.getEnv "HOME") + "/dotfiles")).homeConfigurations."${config.home.username}@${hostname}".pkgs' '';
  };

  # FIXME: Nixd integration with Eglot in Emacs is broken.
  # From Eglot log, I see the configuration is sent to Nixd.
  # But Nixd behaves as if it never received it.
  # It falls back to its behavior of popoulating just NixOS options.
  xdg.configFile."rassumfrassum/nixd-configuration.json".source = "${nixd-configuration-json}";
  xdg.configFile."nvim/lsp/nixd.lua".source = "${nixd-lspconfig-lua}";
}
