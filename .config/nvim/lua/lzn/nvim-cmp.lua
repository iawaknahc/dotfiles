-- https://github.com/nvim-neorocks/lz.n/wiki/lazy%E2%80%90loading-nvim%E2%80%90cmp-and-its-extensions
local function trigger_load_with_after(plugin_name)
  for _, dir in ipairs(vim.opt.packpath:get()) do
    local glob = vim.fs.joinpath("pack", "*", "opt", plugin_name)
    local plugin_dirs = vim.fn.globpath(dir, glob, nil, true, true)
    if not vim.tbl_isempty(plugin_dirs) then
      require("lz.n").trigger_load(plugin_name)
      require("rtp_nvim").source_after_plugin_dir(plugin_dirs[1])
      return
    end
  end
end

require("lz.n").load {
  "cmp-nvim-lsp",
  lazy = true,
}

require("lz.n").load {
  "cmp-buffer",
  lazy = true,
}

require("lz.n").load {
  "cmp-path",
  lazy = true,
}

require("lz.n").load {
  "cmp-cmdline",
  lazy = true,
}

require("lz.n").load {
  "cmp-cmdline-history",
  lazy = true,
}

require("lz.n").load {
  "cmp-nvim-lua",
  lazy = true,
}

require("lz.n").load {
  "cmp-nvim-lsp-signature-help",
  lazy = true,
}

require("lz.n").load {
  "cmp-nvim-lsp-document-symbol",
  lazy = true,
}

require("lz.n").load {
  "cmp-tmux",
  lazy = true,
}

require("lz.n").load {
  "nvim-cmp",
  event = { "InsertEnter", "CmdlineEnter" },
  after = function()
    trigger_load_with_after("cmp-nvim-lsp")
    trigger_load_with_after("cmp-buffer")
    trigger_load_with_after("cmp-path")
    trigger_load_with_after("cmp-cmdline")
    trigger_load_with_after("cmp-cmdline-history")
    trigger_load_with_after("cmp-nvim-lua")
    trigger_load_with_after("cmp-nvim-lsp-signature-help")
    trigger_load_with_after("cmp-nvim-lsp-document-symbol")
    trigger_load_with_after("cmp-tmux")

    local cmp = require("cmp")

    local source_buffer = {
      name = "buffer",
      option = {
        keyword_pattern = [[\k\+]],
        -- complete from all buffers.
        get_bufnrs = function()
          return vim.api.nvim_list_bufs()
        end,
      },
    }
    local source_tmux = {
      name = "tmux",
      option = {
        all_panes = true,
      },
    }
    local source_path = { name = "path" }
    local source_cmdline_history = { name = "cmdline_history" }

    local mapping_cmdline = cmp.mapping.preset.cmdline()
    mapping_cmdline["<C-J>"] = mapping_cmdline["<C-N>"]
    mapping_cmdline["<C-K>"] = mapping_cmdline["<C-P>"]

    cmp.setup.cmdline({ "/", "?" }, {
      mapping = mapping_cmdline,
      sources = {
        -- The order implies priority.
        { name = "nvim_lsp_document_symbol" },
        source_buffer,
        source_tmux,
        source_cmdline_history,
      },
    })

    cmp.setup.cmdline(":", {
      mapping = mapping_cmdline,
      sources = {
        -- The order implies priority.
        { name = "cmdline" },
        source_cmdline_history,
        source_buffer,
        source_tmux,
        source_path,
      },
    })

    local make_jump = function(direction)
      return function(fallback)
        if vim.snippet.active({ direction = direction }) then
          vim.snippet.jump(direction)
        else
          fallback()
        end
      end
    end
    local tab = make_jump(1)
    local s_tab = make_jump(-1)

    local mapping_insert = cmp.mapping.preset.insert()
    mapping_insert["<CR>"] = mapping_insert["<C-Y>"]
    mapping_insert["<C-J>"] = mapping_insert["<C-N>"]
    mapping_insert["<C-K>"] = mapping_insert["<C-P>"]
    mapping_insert["<Tab>"] = {
      i = tab,
      s = tab,
    }
    mapping_insert["<S-Tab>"] = {
      i = s_tab,
      s = s_tab,
    }

    cmp.setup({
      preselect = cmp.PreselectMode.None,
      -- nvim-cmp itself does not require a snippet engine to run.
      -- But some LSP servers like CSS only return snippet items.
      -- Therefore a snippet engine is required.
      -- See https://github.com/hrsh7th/nvim-cmp/issues/373#issuecomment-947359057
      -- As of nvim 0.10, it provides a native snippet engine.
      snippet = {
        expand = function(args)
          vim.snippet.expand(args.body)
        end,
      },
      mapping = mapping_insert,
      sources = {
        { name = "nvim_lsp_signature_help" },
        { name = "nvim_lsp" },
        { name = "nvim_lua" },
        source_buffer,
        source_tmux,
        source_path,
      },
    })
  end,
}
