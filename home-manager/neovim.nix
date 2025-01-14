{
  pkgs,
  config,
  lib,
  ...
}:
{
  programs.neovim.enable = true;
  programs.neovim.withNodeJs = false;
  programs.neovim.withPython3 = false;
  programs.neovim.withRuby = false;

  home.packages = [
    pkgs.stylua
  ];
  home.file.".stylua.toml" = {
    enable = true;
    source = ../.stylua.toml;
  };

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

  programs.neovim.extraLuaConfig = builtins.readFile ../.config/nvim/init.lua;
  xdg.configFile."nvim/colors" = {
    enable = true;
    recursive = true;
    source = ../.config/nvim/colors;
  };

  programs.neovim.plugins = with pkgs.vimPlugins; [
    # require("lz.n").load { PLUGIN_NAME }
    # where PLUGIN_NAME is the pname of a Nix vimPlugin.
    # To find the pname, see https://github.com/NixOS/nixpkgs/blob/nixpkgs-unstable/pkgs/applications/editors/vim/plugins/generated.nix
    lz-n

    # treesitter
    {
      type = "lua";
      optional = true;
      config = builtins.readFile ../.config/nvim/lua/lzn/nvim-treesitter.lua;
      plugin = nvim-treesitter.withAllGrammars;
    }
    {
      type = "lua";
      optional = true;
      plugin = nvim-treesitter-context;
    }
    {
      type = "lua";
      optional = true;
      plugin = nvim-treesitter-textobjects;
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
      plugin = (
        pkgs.vimUtils.buildVimPlugin {
          pname = "fzf-lua";
          version = "2025-01-14";
          src = pkgs.fetchFromGitHub {
            owner = "ibhagwan";
            repo = "fzf-lua";
            rev = "6f7249741168c0751356e3b6c5c1e3bade833b6b";
            hash = "sha256-rueyL7UJ+QBehsExZEWlN4y2wBEU1UGEyVewNyJh5bI=";
          };
          nvimSkipModule = [
            "fzf-lua.complete"
            "fzf-lua.providers.ui_select"
            "fzf-lua.providers.diagnostic"
            "fzf-lua.providers.buffers"
            "fzf-lua.providers.git"
            "fzf-lua.providers.files"
            "fzf-lua.providers.colorschemes"
            "fzf-lua.providers.oldfiles"
            "fzf-lua.providers.nvim"
            "fzf-lua.providers.lsp"
            "fzf-lua.providers.grep"
            "fzf-lua.providers.quickfix"
            "fzf-lua.providers.manpages"
            "fzf-lua.providers.module"
            "fzf-lua.providers.tags"
            "fzf-lua.providers.helptags"
            "fzf-lua.providers.dap"
            "fzf-lua.providers.tmux"
            "fzf-lua.win"
            "fzf-lua.config"
            "fzf-lua.defaults"
            "fzf-lua.core"
          ];
        }
      );
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
    {
      type = "lua";
      optional = true;
      config = builtins.readFile ../.config/nvim/lua/lzn/statuscol-nvim.lua;
      plugin = statuscol-nvim;
    }

    # Show a change sign next to line number.
    {
      type = "lua";
      optional = true;
      config = builtins.readFile ../.config/nvim/lua/lzn/vim-gitgutter.lua;
      plugin = vim-gitgutter;
    }

    # Show indentation guide.
    {
      type = "lua";
      optional = true;
      config = builtins.readFile ../.config/nvim/lua/lzn/indent-blankline-nvim.lua;
      plugin = indent-blankline-nvim;
    }

    # Enhance the statusline
    {
      type = "lua";
      optional = true;
      config = builtins.readFile ../.config/nvim/lua/lzn/lualine-nvim.lua;
      plugin = lualine-nvim;
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
