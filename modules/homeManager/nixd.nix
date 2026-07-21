{
  inputs,
  hostname,
  pkgs,
  config,
  ...
}:
let
  flake = "${inputs.self}";
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

  xdg.configFile."nvim/lsp/nixd.lua".text = ''
    return {
      -- Known issue: inlay hint works only in `with pkgs; [ ... ]`
      -- See https://github.com/nix-community/nixd/issues/629#issuecomment-2558520043
      cmd = { "nixd", "--inlay-hints=true", "--semantic-tokens=true" },
      settings = {
        nixd = {
          formatting = {
            command = { "nixfmt" },
          },
          nixpkgs = {
            -- This evaluates to the actual pkgs with all overlays applied.
            expr = [[(builtins.getFlake (builtins.toString "${flake}")).homeConfigurations."${config.home.username}@${hostname}".pkgs]],
          },
          options = {
            ["nix-darwin"] = {
              expr = [[(builtins.getFlake (builtins.toString "${flake}")).darwinConfigurations."${hostname}".options]],
            },
            ["home-manager"] = {
              expr = [[(builtins.getFlake (builtins.toString "${flake}")).homeConfigurations."${config.home.username}@${hostname}".options]],
            },
          },
        },
      },
    }
  '';

  home.file.".emacs.d/lisp/init-lsp-mode-nixd.el".text = ''
    ;;; -*- lexical-binding: t -*-

    (with-eval-after-load 'lsp-mode
      (with-eval-after-load 'lsp-nix
        (lsp-defcustom lsp-nix-nixd-darwin-options-expr nil
          "Option set for nix-darwin option completion."
          :type 'string
          :group 'lsp-nix-nixd
          :lsp-path "nixd.options.nix-darwin.expr"
          :package-version '(lsp-mode . "10.0.0"))

        (setq
          lsp-nix-nixd-formatting-command [ "nixfmt" ]
          lsp-nix-nixd-nixpkgs-expr "(builtins.getFlake (builtins.toString \"${flake}\")).homeConfigurations.\"${config.home.username}@${hostname}\".pkgs"
          lsp-nix-nixd-home-manager-options-expr "(builtins.getFlake (builtins.toString \"${flake}\")).homeConfigurations.\"${config.home.username}@${hostname}\".options"
          lsp-nix-nixd-nixos-options-expr "(builtins.getFlake (builtins.toString \"${flake}\")).nixosConfigurations.nas.options"
          lsp-nix-nixd-darwin-options-expr "(builtins.getFlake (builtins.toString \"${flake}\")).darwinConfigurations.\"${hostname}\".options"
          lsp-nix-nixd-server-arguments '("--log=verbose"))))

    (provide 'init-lsp-mode-nixd)
  '';
}
