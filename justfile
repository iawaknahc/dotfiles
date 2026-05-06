STYLUA_FLAGS := "--verbose"

# List all recipes
default:
    just --list --unsorted

# Clean up any generated files
clean:
    rm -f ./home-manager/neovim/config/nvim/.emmyrc.json

# Run `clean`, followed by `generate-emmyrc-json`
setup: clean generate-emmyrc-json

# Run all checkers
check: harper codebook codespell test
    find . -type f -name 'stylua.toml' -exec dirname {} \; | xargs stylua --check {{STYLUA_FLAGS}}

# Run checker `harper-cli-lint`
harper *FLAGS:
    fd --hidden --type file --ignore-file harperignore | xargs harper-cli-lint --format compact {{FLAGS}}

# Run checker `codebook-lsp lint` with respect to codebookignore
codebook *FLAGS:
    fd --hidden --type file --ignore-file codebookignore | xargs codebook-lsp lint {{FLAGS}}

# Run checker `codespell` with respect to codespellignore
codespell *FLAGS:
    fd --hidden --type file --ignore-file codespellignore | xargs codespell {{FLAGS}}

# Run all formatters
format: stylua nufmt

# Run formatter `stylua`
stylua:
    find . -type f -name 'stylua.toml' -exec dirname {} \; | xargs stylua {{STYLUA_FLAGS}}

# Run formatter `nufmt`. FIXME: This is no-op due to https://github.com/nushell/nufmt/issues/111 and https://github.com/nushell/nufmt/issues/169
nufmt:
    # fd --hidden --type file --extension nu | xargs nufmt

# Copy the current config of Alfred to here for git-diff
alfred-rsync:
    rsync --recursive --delete ~/alfred/ ./home-manager/alfred/alfred

# Undo the effect of `alfred-rsync`
alfred-clean:
    git clean -fx ./home-manager/alfred/alfred

# Run Nix unit tests
test:
    nix-unit --flake '.#tests'

# Generate `./home-manager/neovim/config/nvim/.emmyrc.json`
generate-emmyrc-json:
    ./home-manager/neovim/config/nvim/.emmyrc.py

# Update `flake.lock` without touching `android-nixpkgs`
flake-update:
    nix flake metadata --json | jq -r '.locks.nodes.root.inputs | keys | map(select(. != "android-nixpkgs")) | .[]' | xargs nix flake update
