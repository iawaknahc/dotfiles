.PHONY: check
check:
	llscheck --configpath .config/nvim/.luarc.json .config/nvim

.PHONY: format
format:
	stylua -v .config/nvim

# Copy the current config of Alfred to here for git-diff.
.PHONY: alfred-rsync
alfred-rsync:
	rsync --recursive ~/alfred/ ./alfred

# Undo the effect of alfred-rsync.
.PHONY: alfred-clean
alfred-clean:
	git clean -fx ./alfred
