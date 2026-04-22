STYLUA_FLAGS := --verbose
STYLUA_ARGS := .config/nvim .hammerspoon

.PHONY: check
check:
#$(MAKE) harper
	$(MAKE) codebook
	$(MAKE) codespell
	$(MAKE) test
	stylua --check $(STYLUA_FLAGS) $(STYLUA_ARGS)

.PHONY: clean
clean:
	rm -f .config/nvim/.emmyrc.json

.PHONY: setup
setup: clean .config/nvim/.emmyrc.json

.PHONY: format
format:
	stylua $(STYLUA_FLAGS) $(STYLUA_ARGS)

# FIXME: harper-cli lint when harper < 2.0.0 always exit with 1 even there are no lint errors.
# https://github.com/Automattic/harper/issues/2832
.PHONY: harper
harper:
	fd --type f --ignore-file harperignore | xargs harper-cli-lint --format compact

.PHONY: codebook
codebook:
	fd --type f --ignore-file codebookignore | xargs codebook-lsp lint

.PHONY: codespell
codespell:
	fd --type f --ignore-file codespellignore | xargs codespell

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

.config/nvim/.emmyrc.json:
	.config/nvim/.emmyrc.py
