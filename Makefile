.PHONY: check
check:
	llscheck --configpath .config/nvim/.luarc.json .config/nvim

.PHONY: format
format:
	stylua -v .config/nvim

# Copy the current config of Alfred to here for git-diff.
.PHONY: alfred-rsync
alfred-rsync:
	rsync --recursive --delete ~/alfred/ ./alfred

# Undo the effect of alfred-rsync.
.PHONY: alfred-clean
alfred-clean:
	git clean -fx ./alfred

.PHONY: test
test:
	nix-unit ./lib/md5toUUID.test.nix
	nix-unit ./lib/userscript_metadata_block/default.test.nix
