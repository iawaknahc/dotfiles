vim.o.list = true
-- leadmultispace is powerful enough. I do not need https://github.com/lukas-reineke/indent-blankline.nvim now.
-- https://www.reddit.com/r/neovim/comments/17aponn/i_feel_like_leadmultispace_deserves_more_attention/
-- leadtab was added in 0.12.
-- leadtab:xyz means x is always used, z is always used, y is repeated.
-- This implies tab: must be configured in a way to align with leadtab.
-- Therefore, we have to use tab:xyz form.
--
-- Spaces should be shown as dot.
-- Therefore, leadmultispace, lead, and trail uses dot.
-- Tabs should be shown as multiple hyphens plus a greater-than sign tail so that it is visually different from spaces.
-- Non-breaking spaces should be visually different from spaces and tabs, so we take the default from neovim, the plus sign.
vim.opt.listchars = { leadmultispace = "▏.", leadtab = "▏->", lead = ".", tab = "-->", trail = ".", nbsp = "+" }
