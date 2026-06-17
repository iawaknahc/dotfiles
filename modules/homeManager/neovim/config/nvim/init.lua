-- Enable project specific settings
-- vim.o.exrc has to be set in init.lua to take effect.
-- It is because plugin/*.lua is sourced after project-specific exrc.
-- vim.o.exrc set by a plugin has no effect.
-- This makes sense because otherwise external plugin can turn on vim.o.exrc.
-- See `:help initialization`
vim.o.exrc = true
