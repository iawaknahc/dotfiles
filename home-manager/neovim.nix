{
  pkgs,
  config,
  lib,
  ...
}:
{
  programs.neovim.enable = true;
  programs.neovim.withNodeJs = true;
  programs.neovim.withPython3 = false;
  programs.neovim.withRuby = false;

  home.packages = with pkgs; [
    lua-language-server
    stylua
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
    (luajit.withPackages (
      packages: with packages; [
        luarocks
        # llscheck requires lua-language-server on PATH.
        llscheck
        # luap provides a better REPL experience than lua(1).
        luaprompt
      ]
    ))
  ];

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

  xdg.configFile."nvim/stylua.toml".source = ../.config/nvim/stylua.toml;
  xdg.configFile."nvim/.luarc.json".source = ../.config/nvim/.luarc.json;

  programs.neovim.extraLuaConfig = builtins.readFile ../.config/nvim/init.lua;

  programs.neovim.plugins = with pkgs.vimPlugins; [
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

    # surround
    {
      type = "lua";
      optional = true;
      config = builtins.readFile ../.config/nvim/lua/lzn/mini-surround.lua;
      plugin = mini-surround;
    }

    # motion
    {
      type = "lua";
      optional = true;
      config = builtins.readFile ../.config/nvim/lua/lzn/flash-nvim.lua;
      plugin = flash-nvim;
    }

    # treesitter
    {
      type = "lua";
      optional = true;
      config = builtins.readFile ../.config/nvim/lua/lzn/nvim-treesitter.lua;
      plugin = nvim-treesitter.withPlugins (
        _:
        nvim-treesitter.allGrammars
        ++ [
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
        ]
      );
    }
    {
      type = "lua";
      optional = true;
      plugin = nvim-treesitter-textobjects;
    }
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
    {
      type = "lua";
      optional = true;
      plugin = treewalker-nvim;
    }

    # Show context.
    {
      type = "lua";
      optional = true;
      config = builtins.readFile ../.config/nvim/lua/lzn/nvim-treesitter-context.lua;
      plugin = nvim-treesitter-context;
    }

    # LSP
    {
      type = "lua";
      optional = true;
      config = builtins.readFile ../.config/nvim/lua/lzn/nvim-lspconfig.lua;
      plugin = nvim-lspconfig;
    }

    # fzf
    {
      type = "lua";
      optional = true;
      config = builtins.readFile ../.config/nvim/lua/lzn/fzf-lua.lua;
      plugin = fzf-lua;
    }

    # Completion
    {
      type = "lua";
      optional = true;
      config = builtins.readFile ../.config/nvim/lua/lzn/blink-cmp.lua;
      plugin = blink-cmp;
    }

    # Format on save.
    {
      type = "lua";
      optional = true;
      config = builtins.readFile ../.config/nvim/lua/lzn/conform.lua;
      plugin = conform-nvim;
    }

    # Run linter and set diagnostics.
    {
      type = "lua";
      optional = true;
      config = builtins.readFile ../.config/nvim/lua/lzn/nvim-lint.lua;
      plugin = nvim-lint;
    }

    # Set spaces or tabs.
    {
      type = "lua";
      optional = true;
      config = builtins.readFile ../.config/nvim/lua/lzn/vim-sleuth.lua;
      plugin = vim-sleuth;
    }

    # DAP
    {
      type = "lua";
      optional = true;
      config = builtins.readFile ../.config/nvim/lua/lzn/nvim-dap.lua;
      plugin = nvim-dap;
    }
    {
      type = "lua";
      optional = true;
      plugin = nvim-dap-go;
    }

    # statuscolumn
    {
      type = "lua";
      optional = true;
      config = builtins.readFile ../.config/nvim/lua/lzn/statuscol-nvim.lua;
      plugin = statuscol-nvim;
    }

    # Git integration.
    vim-fugitive
    vim-rhubarb
    {
      type = "lua";
      optional = true;
      config = builtins.readFile ../.config/nvim/lua/lzn/gitsigns-nvim.lua;
      plugin = gitsigns-nvim;
    }
    {
      type = "lua";
      optional = true;
      config = builtins.readFile ../.config/nvim/lua/lzn/diffview-nvim.lua;
      plugin = diffview-nvim;
    }

    # Enhance the statusline
    {
      type = "lua";
      optional = true;
      config = builtins.readFile ../.config/nvim/lua/lzn/lualine-nvim.lua;
      plugin = lualine-nvim;
    }

    # Hints on keymap
    {
      type = "lua";
      optional = true;
      config = builtins.readFile ../.config/nvim/lua/lzn/which-key-nvim.lua;
      plugin = which-key-nvim;
    }

    # Edit table.
    {
      type = "lua";
      optional = true;
      config = builtins.readFile ../.config/nvim/lua/lzn/vim-table-mode.lua;
      plugin = vim-table-mode;
    }

  ];
}
