.PHONY: check
check:
	llscheck --configpath .config/nvim/.luarc.json .config/nvim

.PHONY: format
format:
	stylua -v .config/nvim
