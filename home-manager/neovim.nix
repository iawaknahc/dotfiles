{
  pkgs,
  config,
  lib,
  ...
}:
{
  programs.neovim.enable = true;
  # We need Python3's strptime.
  programs.neovim.withPython3 = true;

  home.packages = with pkgs; [
    tree-sitter
  ];

  programs.neovim.defaultEditor = true;
  home.sessionVariables = lib.mkIf config.programs.neovim.enable {
    MANPAGER = "nvim +Man!";
  };
  home.shellAliases = lib.mkIf config.programs.neovim.enable {
    # Open fugitive.
    g = "nvim +G +only";
  };
  xdg.configFile."nvim" = {
    source = ../.config/nvim;
    recursive = true;
  };

  programs.neovim.extraLuaPackages = (
    luaPkgs: with luaPkgs; [
      luautf8
    ]
  );

  programs.neovim.plugins = with pkgs.vimPlugins; [
    # Colorscheme
    catppuccin-nvim
    # A dependency of many other plugins.
    plenary-nvim
    # Another dependency of many other plugins.
    nvim-web-devicons

    # As of 2026-01-06, nvim-treesitter (main branch) is a data-only plugin.
    (nvim-treesitter.withPlugins (
      _:
      nvim-treesitter.allGrammars
      ++ [
        (pkgs.tree-sitter.buildGrammar {
          language = "colors";
          version = "2026-04-08";
          src = pkgs.fetchFromGitHub {
            owner = "iawaknahc";
            repo = "tree-sitter-colors";
            rev = "8d3ae3b08d7ce5d2641f9b41bab03c81e544c79e";
            hash = "sha256-NI/rTkXtKs9NRDHvKMm3bJjgWXIqC/qCR22Jz4vHfUc=";
          };
        })
      ]
    ))

    # Install the data files (RUNTIME/queries/*/textobjects.scm)
    # This is essentially treating nvim-treesitter-textobjects as a data-only plugin,
    # which should be compatible with the unreleased https://github.com/nvim-treesitter/nvim-treesitter-textobjects/tree/main
    # nvim-treesitter-textobjects is a plugin that serves the following purposes:
    # 1. Provide data files RUNTIME/queries/*/textobjects.scm. As far as I know, no other plugins rely on these data.
    # 2. Select. This purpose can be served by flash.nvim in a more intuitive way.
    # 3. Swap. This purpose can be served by treewalker.nvim in a more intuitive way.
    # 4. Move. From Neovim 0.12, there is :help v_]n and :help v_[n or just use flash.nvim
    # Thus, we no longer need it.
    #nvim-treesitter-textobjects

    # Language Plugins
    vim-hy
    fennel-vim

    # Find and replace
    grug-far-nvim

    ## Text editing
    # Unicode
    {
      optional = true;
      plugin = unicode-vim;
    }
    # Edit surroundings.
    nvim-surround
    # Motion
    flash-nvim
    # Completion
    blink-cmp
    # Swap treesitter nodes.
    treewalker-nvim
    # Split or join blocks of code.
    {
      optional = true;
      plugin = treesj;
    }
    # Enhanced version of :h CTRL-A and :h CTRL-X.
    dial-nvim
    # Edit table.
    {
      optional = true;
      plugin = vim-table-mode;
    }
    # Make indentation right.
    {
      optional = true;
      plugin = vim-sleuth;
    }

    ## Pick things.
    fzf-lua

    ## Visual aids
    # statusline
    mini-statusline
    # statuscolumn
    statuscol-nvim
    # Key clues and submodes.
    mini-clue
    # Show context.
    nvim-treesitter-context
    # Show colors.
    {
      plugin = (
        pkgs.vimUtils.buildVimPlugin {
          pname = "nvim-colors";
          version = "2026-04-08";
          src = pkgs.fetchFromGitHub {
            owner = "iawaknahc";
            repo = "nvim-colors";
            rev = "0a8a248e68de7cdac420287a2e5598cc20985387";
            hash = "sha256-YOqbBfqW2MJ0y88/FGr3wBNDh41DR3ZihmbgYx4BNZo=";
          };
        }
      );
    }
    # Rainbow delimiters for Lisp
    rainbow-delimiters-nvim

    ## LSP and diagnostics
    nvim-lspconfig
    nvim-lint

    ## Automation
    conform-nvim

    ## Git integration
    vim-fugitive
    vim-rhubarb
    gitsigns-nvim

    # Replace netrw.
    # Treating directories as buffers is more intuitive for me.
    oil-nvim

    ## Debugging
    nvim-dap
    nvim-dap-go
    nvim-dap-python

    ## REPL
    {
      optional = true;
      plugin = conjure;
    }
  ];
}
