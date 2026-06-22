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

  xdg.configFile."nvim/ftdetect" = {
    source = ./config/nvim/ftdetect;
  };
  xdg.configFile."nvim/ftplugin" = {
    source = ./config/nvim/ftplugin;
  };
  xdg.configFile."nvim/lsp" = {
    source = ./config/nvim/lsp;
    recursive = true; # nvim/lsp has to be recursive because nvim/lsp/nixd.lua is generated.
  };
  xdg.configFile."nvim/lua" = {
    source = ./config/nvim/lua;
  };
  xdg.configFile."nvim/plugin" = {
    source = ./config/nvim/plugin;
    recursive = true; # Make nvim/plugin a normal directory instead of a symlink to the Nix store, so that I can place regular files in it.
  };
  xdg.configFile."nvim/snippets" = {
    source = ./config/nvim/snippets;
  };

  programs.neovim.extraLuaPackages = (
    luaPkgs: with luaPkgs; [
      luautf8
    ]
  );

  programs.neovim.initLua = builtins.readFile ./config/nvim/init.lua;

  programs.neovim.plugins = with pkgs.vimPlugins; [
    # Colorscheme
    catppuccin-nvim

    # plenary.nvim is going to be archived in 2026 Q2
    # See https://github.com/nvim-lua/plenary.nvim/pull/677
    # I checked that no plugins are using it at runtime.
    # Some plugins use it in their tests.
    #plenary-nvim

    # Another dependency of many other plugins.
    nvim-web-devicons

    # As of 2026-01-06, nvim-treesitter (main branch) is a data-only plugin.
    (nvim-treesitter.withPlugins (
      _:
      nvim-treesitter.allGrammars
      ++ [
        pkgs.tree-sitter-numbat
      ]
    ))

    # Install the data files (RUNTIME/queries/*/textobjects.scm)
    # This is essentially treating nvim-treesitter-textobjects as a data-only plugin,
    # which should be compatible with the unreleased https://github.com/nvim-treesitter/nvim-treesitter-textobjects/tree/main
    # nvim-treesitter-textobjects is a plugin that serves the following purposes:
    # 1. Provide data files RUNTIME/queries/*/textobjects.scm.
    #    As far as I know, nvim-dap-view depends on locals.scm.
    #    See https://github.com/igorlfs/nvim-dap-view/blob/v1.1.1/lua/dap-view/virtual-text.lua#L95
    # 2. Select. This purpose can be served by flash.nvim in a more intuitive way.
    # 3. Swap. This purpose can be served by treewalker.nvim in a more intuitive way.
    # 4. Move. From Neovim 0.12, there is :help v_]n and :help v_[n or just use flash.nvim
    nvim-treesitter-textobjects

    # Language Plugins
    vim-hy
    fennel-vim

    # Find and replace
    grug-far-nvim

    ## Text editing
    # Snippets
    luasnip
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
    # Enhanced version of `:h CTRL-A` and :h CTRL-X.
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
    # Key clues and submodes.
    mini-clue
    # Show context.
    nvim-treesitter-context
    # Show colors.
    {
      plugin = pkgs.nvim-colors;
    }
    # Rainbow delimiters for Lisp
    rainbow-delimiters-nvim
    # Highlight trailing spaces in red.
    mini-trailspace

    ## LSP and diagnostics
    nvim-lspconfig
    nvim-lint

    ## Automation
    conform-nvim

    ## Git integration
    vim-fugitive
    vim-rhubarb
    vim-flog
    gitsigns-nvim
    diffview-plus-nvim

    # Replace netrw.
    # Treating directories as buffers is more intuitive for me.
    oil-nvim

    ## Debugging
    nvim-dap
    nvim-dap-view
    nvim-dap-go
    nvim-dap-python

    ## REPL
    {
      optional = true;
      plugin = conjure.overrideAttrs {
        # conjure depends on plenary.nvim for tests.
        dependencies = [ ];
        doCheck = false;
      };
    }

    ## Databases
    vim-dadbod
    {
      optional = true;
      plugin = vim-dadbod-ui;
    }
    vim-dadbod-completion
  ];
}
