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
        (pkgs.tree-sitter.buildGrammar {
          language = "nvimcolors";
          version = "2026-04-10";
          src = pkgs.fetchFromGitHub {
            owner = "iawaknahc";
            repo = "tree-sitter-colors";
            rev = "f387075b79c983a11e0eca13450781a89c6d185d";
            hash = "sha256-6Tf3gUPmsegzwhCmWoBKu6TIVwsS7+fBRmdvSc7rtYE=";
          };
        })
        (pkgs.tree-sitter.buildGrammar {
          language = "numbat";
          version = "2026-04-13";
          src = pkgs.fetchFromGitHub {
            owner = "irevoire";
            repo = "tree-sitter-numbat";
            rev = "4d9ce55767f7cc2a0ef97dd070de7e4519920607";
            hash = "sha256-eNr46I8YexE5rFIDoqmlivec9H6RB3tt5/8R6age5i4=";
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
          version = "2026-04-10";
          src = pkgs.fetchFromGitHub {
            owner = "iawaknahc";
            repo = "nvim-colors";
            rev = "7297f4702cc277a8cd41ae7b34740fc34ca7d1d0";
            hash = "sha256-RSe+/qu+0rIizaCPwOmk2RALs/WgqEZ2Upv5adAvTI4=";
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
  ];
}
