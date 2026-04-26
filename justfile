STYLUA_FLAGS := "--verbose"
STYLUA_ARGS := ".config/nvim .hammerspoon"

# List recipes
default:
    just --list --unsorted

# Do all checking
check: harper codebook codespell test
    stylua --check {{STYLUA_FLAGS}} {{STYLUA_ARGS}}

# Clean up any generated files
clean:
    rm -f .config/nvim/.emmyrc.json

# Run clean, followed by generate-emmyrc-json
setup: clean generate-emmyrc-json

# Run `stylua`
format:
    stylua {{STYLUA_FLAGS}} {{STYLUA_ARGS}}

harper *FLAGS:
    fd --type f --ignore-file harperignore | xargs harper-cli-lint --format compact {{FLAGS}}

# Run `codebook-lsp lint` with respect to codebookignore
codebook *FLAGS:
    fd --type f --ignore-file codebookignore | xargs codebook-lsp lint {{FLAGS}}

# Run `codespell` with respect to codespellignore
codespell *FLAGS:
    fd --type f --ignore-file codespellignore | xargs codespell {{FLAGS}}

# Copy the current config of Alfred to here for git-diff
alfred-rsync:
    rsync --recursive --delete ~/alfred/ ./alfred

# Undo the effect of alfred-rsync
alfred-clean:
    git clean -fx ./alfred

# Run Nix unit tests
test:
    nix-unit --flake '.#tests'

# Generate ./.config/nvim/.emmyrc.json
generate-emmyrc-json:
    .config/nvim/.emmyrc.py

flake-update:
    nix flake metadata --json | jq -r '.locks.nodes.root.inputs | keys | map(select(. != "android-nixpkgs")) | .[]' | xargs nix flake update
