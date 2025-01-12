{
  pkgs,
  config,
  lib,
  ...
}:
lib.mkMerge [
  {
    home.packages = [
      pkgs.stylua
    ];
    home.file.".stylua.toml" = {
      enable = true;
      source = ../.stylua.toml;
    };
  }

  {
    home.packages = [
      # Some parsers like ocamllex and swift requires the tree-sitter executable.
      # So we install it for them.
      pkgs.tree-sitter
    ];
  }

  {
    programs.neovim.enable = true;
    home.sessionVariables = lib.mkIf config.programs.neovim.enable {
      EDITOR = "nvim";
      VISUAL = "nvim";
      MANPAGER = "nvim +Man!";
    };
    home.shellAliases = lib.mkIf config.programs.neovim.enable {
      vi = "nvim";
      vim = "nvim";
      view = "nvim -R";
      vimdiff = "nvim -d";
    };
    programs.neovim.withNodeJs = false;
    programs.neovim.withPython3 = false;
    programs.neovim.withRuby = false;
    # Instead of enabling nodejs support in neovim, we just make nodejs available to neovim,
    # for nvim-treesitter to compile parser from grammar.
    programs.neovim.extraPackages = [
      pkgs.nodejs
    ];
    xdg.configFile."nvim/init.lua" = {
      enable = true;
      source = ../.config/nvim/init.lua;
    };
    xdg.configFile."nvim/colors" = {
      enable = true;
      recursive = true;
      source = ../.config/nvim/colors;
    };
    xdg.configFile."nvim/lua" = {
      enable = true;
      recursive = true;
      source = ../.config/nvim/lua;
    };
  }

  (
    let
      # The REPL of Fennel without readline is very limited.
      # So we install readline for it.
      # See https://fennel-lang.org/setup#adding-readline-support-to-fennel
      # Note that the parenthesis around this is very important.
      # Otherwise, the function is not called and it becomes an item in the list, which is unexpected.
      fennel = (
        pkgs.luajitPackages.fennel.overrideAttrs (oldAttrs: {
          buildInputs = oldAttrs.buildInputs ++ [
            pkgs.readline
            pkgs.luajitPackages.readline
          ];
        })
      );
    in
    {
      home.packages = [ fennel ];
      xdg.configFile =
        let
          nvimFennelDir = ../.config/nvim/fnl;
          nvimFennelFileList = pkgs.lib.fileset.toList (pkgs.lib.fileset.maybeMissing nvimFennelDir);
        in
        pkgs.lib.pipe nvimFennelFileList [
          (builtins.map (
            path:
            let
              relativePathString = pkgs.lib.strings.removePrefix ((builtins.toString nvimFennelDir) + "/") (
                builtins.toString path
              );
              target = (pkgs.lib.strings.removeSuffix ".fnl" relativePathString) + ".lua";
              compiledSourceCode = builtins.readFile "${pkgs.runCommand "fennel" { } ''
                ${fennel}/bin/fennel --compile ${path} > $out
              ''}";
            in
            {
              "nvim/lua/${target}" = {
                enable = true;
                text = compiledSourceCode;
              };
            }

          ))
          pkgs.lib.attrsets.mergeAttrsList
        ];
    }
  )
]
