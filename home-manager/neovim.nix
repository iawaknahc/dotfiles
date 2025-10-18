{
  pkgs,
  config,
  lib,
  ...
}:
{
  programs.neovim.enable = true;
  programs.neovim.withNodeJs = true;
  # We need Python3's strptime.
  programs.neovim.withPython3 = true;
  programs.neovim.withRuby = false;

  home.packages = with pkgs; [
    tree-sitter
    (stdenv.mkDerivation {
      name = "luv";
      src = fetchFromGitHub {
        owner = "LuaCATS";
        repo = "luv";
        rev = "3615eb12c94a7cfa7184b8488cf908abb5e94c9c";
        hash = "sha256-NGCJWE5Fl6/ffPhot8yGEuwBv5KedufJCcMXjYEYjbM=";
      };
      installPhase = ''
        runHook preInstall

        mkdir -p $out/share/LuaCATS/luv
        cp -R $src/. $out/share/LuaCATS/luv

        runHook postInstall
      '';
    })
  ];

  home.sessionVariables = lib.mkIf config.programs.neovim.enable {
    EDITOR = "nvim";
    VISUAL = "nvim";
    MANPAGER = "nvim +Man!";
  };
  home.shellAliases = lib.mkIf config.programs.neovim.enable {
    # Open fugitive.
    g = "nvim +G +only";
  };

  xdg.configFile."nvim/stylua.toml".source = ../.config/nvim/stylua.toml;
  xdg.configFile."nvim/.luarc.json".source = ../.config/nvim/.luarc.json;
  xdg.configFile."nvim/plugin" = {
    source = ../.config/nvim/plugin;
    recursive = true;
  };
  xdg.configFile."nvim/snippets" = {
    source = ../.config/nvim/snippets;
    recursive = true;
  };
  xdg.configFile."nvim/lua" = {
    source = ../.config/nvim/lua;
    recursive = true;
  };

  programs.neovim.extraLuaConfig = builtins.readFile ../.config/nvim/init.lua;

  programs.neovim.plugins =
    let
      allGrammars = pkgs.vimPlugins.nvim-treesitter.allGrammars ++ [
        (pkgs.tree-sitter.buildGrammar {
          language = "colors";
          version = "2025-01-28";
          src = pkgs.fetchFromGitHub {
            owner = "iawaknahc";
            repo = "tree-sitter-colors";
            rev = "598d804783446a908e2e2d3ea5cc4735802ceab6";
            hash = "sha256-9+rxVREm4BdscarnduRaQ5zYjpMP6ghlk6ekLff0LKE=";
          };
        })
      ];
      allGrammarPlugins = builtins.map pkgs.neovimUtils.grammarToPlugin allGrammars;
    in
    allGrammarPlugins
    ++ (with pkgs.vimPlugins; [
      # require("lz.n").load { PLUGIN_NAME }
      # where PLUGIN_NAME is the pname of a Nix vimPlugin.
      # To find the pname, see https://github.com/NixOS/nixpkgs/blob/nixpkgs-unstable/pkgs/applications/editors/vim/plugins/generated.nix

      # The plugin manager.
      lz-n
      # Colorscheme
      catppuccin-nvim
      # A dependency of many other plugins.
      plenary-nvim
      # Another dependency of many other plugins.
      nvim-web-devicons
      # Install the data files (RUNTIME/queries/*/{folds,highlights,injections,locals}.scm)
      # This is essentially treating nvim-treesitter as a data-only plugin,
      # which should be compatible with the unreleased https://github.com/nvim-treesitter/nvim-treesitter/tree/main
      nvim-treesitter
      # Install the data files (RUNTIME/queries/*/textobjects.scm)
      # This is essentially treating nvim-treesitter-textobjects as a data-only plugin,
      # which should be compatible with the unreleased https://github.com/nvim-treesitter/nvim-treesitter-textobjects/tree/main
      nvim-treesitter-textobjects
      # The missing utf8 package.
      # See https://www.lua.org/manual/5.4/manual.html#6.5
      (pkgs.vimUtils.buildVimPlugin {
        pname = "utf8.nvim";
        version = "2025-07-10";
        # The test is not intended for running during installation, skip it.
        doCheck = false;
        src = pkgs.fetchFromGitHub {
          owner = "uga-rosa";
          repo = "utf8.nvim";
          rev = "954cbbadabe5cd19f202e918fec191d64eea7766";
          hash = "sha256-pIQ3od4xb8Zn4aPtQPaYoVyb4pZ8S+6rEkGGv+kmdZM=";
        };
      })

      # Language Plugins
      (pkgs.vimUtils.buildVimPlugin {
        pname = "vim-hy";
        version = "2025-08-02";
        src = pkgs.fetchFromGitHub {
          owner = "hylang";
          repo = "vim-hy";
          rev = "ab1699bfa636e7355ac0030189331251c49c7d61";
          hash = "sha256-KZf+qPwni/8wWaaQf8XD2hRd9LWiXqYGAePI5Y0aaCc=";
        };
      })
      fennel-vim

      ## Text editing
      # Unicode
      {
        type = "lua";
        optional = true;
        plugin = unicode-vim;
      }
      # Text objects.
      {
        type = "lua";
        optional = true;
        plugin = mini-ai;
      }
      # Edit surroundings.
      {
        type = "lua";
        optional = true;
        plugin = mini-surround;
      }
      # Motion
      {
        type = "lua";
        optional = true;
        plugin = flash-nvim;
      }
      # Completion
      {
        type = "lua";
        optional = true;
        plugin = blink-cmp;
      }
      # Swap treesitter nodes.
      {
        type = "lua";
        optional = true;
        plugin = treewalker-nvim;
      }
      # Change cases.
      {
        type = "lua";
        optional = true;
        plugin = (
          pkgs.vimUtils.buildVimPlugin {
            pname = "vim-caser";
            version = "2025-05-28";
            src = pkgs.fetchFromGitHub {
              owner = "arthurxavierx";
              repo = "vim-caser";
              rev = "6bc9f41d170711c58e0157d882a5fe8c30f34bf6";
              hash = "sha256-PXAY01O/cHvAdWx3V/pyWFeiV5qJGvLcAKhl5DQc0Ps=";
            };
          }
        );
      }
      # Split or join blocks of code.
      {
        type = "lua";
        optional = true;
        plugin = treesj;
      }
      # Enhanced version of :h J.
      {
        type = "lua";
        optional = false;
        plugin = (
          pkgs.vimUtils.buildVimPlugin {
            pname = "join";
            version = "2025-06-24";
            src = pkgs.fetchFromGitHub {
              owner = "sk1418";
              repo = "Join";
              rev = "f48e7a785321ef7ecda6e401ccea8f44dde891d3";
              hash = "sha256-anZGUFkEM+YV8r+R0GCkf8xfEpUOZLct8PlOtTqmAwI=";
            };
          }
        );
      }
      # Enhanced version of :h CTRL-A and :h CTRL-X.
      {
        type = "lua";
        optional = true;
        plugin = dial-nvim;
      }
      # Edit table.
      {
        type = "lua";
        optional = true;
        plugin = vim-table-mode;
      }
      # Make indentation right.
      {
        type = "lua";
        optional = true;
        plugin = vim-sleuth;
      }
      # Improve :h quickfix and :h location-list
      {
        type = "lua";
        optional = true;
        plugin = nvim-pqf;
      }

      ## Pick things.
      {
        type = "lua";
        optional = true;
        plugin = fzf-lua;
      }

      ## Visual aids
      # statusline
      {
        type = "lua";
        optional = true;
        plugin = mini-statusline;
      }
      # statuscolumn
      {
        type = "lua";
        optional = true;
        plugin = statuscol-nvim;
      }
      # vim.notify
      {
        type = "lua";
        optional = true;
        plugin = nvim-notify;
      }
      # Key clues and submodes.
      {
        type = "lua";
        optional = true;
        plugin = mini-clue;
      }
      # Show context.
      {
        type = "lua";
        optional = true;
        plugin = nvim-treesitter-context;
      }
      # Show colors.
      {
        type = "lua";
        plugin = (
          pkgs.vimUtils.buildVimPlugin {
            pname = "nvim-colors";
            version = "2025-05-16";
            src = pkgs.fetchFromGitHub {
              owner = "iawaknahc";
              repo = "nvim-colors";
              rev = "2cdda505a260462c4c91c811e7d8a28ae196c90c";
              hash = "sha256-IyxwLZvIdn3c3XBGtWmtqC7Fmftlt2Gvvt74GJTfCgY=";
            };
          }
        );
      }
      # Rainbow delimiters for Lisp
      {
        type = "lua";
        optional = true;
        plugin = rainbow-delimiters-nvim;
      }

      ## LSP and diagnostics
      {
        type = "lua";
        optional = true;
        plugin = nvim-lspconfig;
      }
      {
        type = "lua";
        optional = true;
        plugin = nvim-lint;
      }

      ## Automation
      {
        type = "lua";
        optional = true;
        plugin = conform-nvim;
      }

      ## Git integration
      {
        type = "lua";
        optional = true;
        plugin = vim-fugitive;
      }
      {
        type = "lua";
        optional = true;
        plugin = vim-rhubarb;
      }
      {
        type = "lua";
        optional = true;
        plugin = gitsigns-nvim;
      }
      {
        type = "lua";
        optional = true;
        plugin = diffview-nvim;
      }

      # Replace netrw.
      # Treating directories as buffers is more intuitive for me.
      {
        type = "lua";
        optional = true;
        plugin = oil-nvim;
      }

      ## Debugging
      {
        type = "lua";
        optional = true;
        plugin = nvim-dap;
      }
      {
        type = "lua";
        optional = true;
        plugin = nvim-dap-go;
      }
      {
        type = "lua";
        optional = true;
        plugin = nvim-dap-python;
      }

      ## REPL
      {
        type = "lua";
        optional = true;
        plugin = conjure;
      }
    ]);
}
