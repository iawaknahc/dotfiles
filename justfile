# List all recipes
default:
    just --list --unsorted

# Clean up any generated files
clean:
    rm -f ./modules/homeManager/neovim/config/nvim/.emmyrc.json

# Run `clean`, followed by `generate-emmyrc-json`
setup: clean generate-emmyrc-json

# Run all checkers
check: harper codebook codespell test shellcheck stylua-check shfmt-check ruff-fmt-check nufmt-check pyright basedpyright pyrefly ty

# Run checker `shellcheck`
shellcheck:
    fd --hidden --type file --extension sh | xargs shellcheck

# Run checker `shfmt --list`
shfmt-check:
    shfmt --list .

# Run checker `stylua --check`
stylua-check:
    find . -type f -name 'stylua.toml' -exec dirname {} \; | xargs stylua --check

# Run checker `ruff format --check`
ruff-fmt-check:
    ruff format --check

# Run checker `nufmt --dry-run`
nufmt-check:
    fd --hidden --type file --extension nu | xargs nufmt --dry-run

# Run checker `harper-cli-lint`
harper *FLAGS:
    fd --hidden --type file --ignore-file harperignore | xargs harper-cli-lint --format compact {{FLAGS}}

# Run checker `codebook-lsp lint` with respect to codebookignore
codebook *FLAGS:
    fd --hidden --type file --ignore-file codebookignore | xargs codebook-lsp lint {{FLAGS}}

# Run checker `codespell` with respect to codespellignore
codespell *FLAGS:
    fd --hidden --type file --ignore-file codespellignore | xargs codespell {{FLAGS}}

# Run checker `pyright`
pyright:
    pyright

# Run checker `basedpyright`
basedpyright:
    basedpyright

# Run checker `pyrefly`
pyrefly:
    pyrefly check

# Run checker `ty`
ty:
    ty check

# Run all formatters
format: shfmt stylua-fmt nufmt ruff-fmt

# Run formatter `shfmt --write --list`
shfmt:
    shfmt --write --list .

# Run formatter `stylua`
stylua-fmt:
    find . -type f -name 'stylua.toml' -exec dirname {} \; | xargs stylua

# Run formatter `nufmt`.
nufmt:
    fd --hidden --type file --extension nu | xargs nufmt

ruff-fmt:
    ruff format

# Copy the current config of Alfred to here for git-diff
alfred-rsync:
    rsync --recursive --delete ~/alfred/ ./modules/homeManager/alfred/alfred

# Undo the effect of `alfred-rsync`
alfred-clean:
    git clean -fx ./modules/homeManager/alfred/alfred

# Run Nix unit tests
test:
    nix-unit --flake '.#tests'

# Generate `./modules/homeManager/neovim/config/nvim/.emmyrc.json`
generate-emmyrc-json:
    ./modules/homeManager/neovim/config/nvim/emmyrc.py

# Update `flake.lock` without touching `android-nixpkgs`
flake-update:
    nix flake metadata --json | jq -r '.locks.nodes.root.inputs | keys | map(select(. != "android-nixpkgs")) | .[]' | xargs nix flake update

# Update all Unicode Nix packages
update-unicode *FLAGS:
    just update-UAX44-ucd {{FLAGS}}
    just update-UTS39-security {{FLAGS}}
    just update-UTS46-idna {{FLAGS}}
    just update-UTS51-emoji {{FLAGS}}
    just update-UTS58-linkification {{FLAGS}}

# Update the Nix package `UAX44-ucd`
update-UAX44-ucd *FLAGS:
    nix-update UAX44-ucd --flake --version {{FLAGS}}

# Update the Nix package `UTS39-security`
update-UTS39-security *FLAGS:
    nix-update UTS39-security --flake --version {{FLAGS}}

# Update the Nix package `UTS46-idna`
update-UTS46-idna *FLAGS:
    nix-update UTS46-idna \
        --subpackage Idna2008_txt \
        --subpackage IdnaMappingTable_txt \
        --subpackage IdnaTestV2_txt \
        --flake --version {{FLAGS}}

# Update the Nix package `UTS51-emoji`
update-UTS51-emoji *FLAGS:
    nix-update UTS51-emoji \
        --subpackage emoji-sequences_txt \
        --subpackage emoji-test_txt \
        --subpackage emoji-zwj-sequences_txt \
        --flake --version {{FLAGS}}

# Update the Nix package `UTS58-linkification`
update-UTS58-linkification *FLAGS:
    nix-update UTS58-linkification \
        --subpackage LinkBracket_txt \
        --subpackage LinkDetectionTest_txt \
        --subpackage LinkEmail_txt \
        --subpackage LinkFormattingTest_txt \
        --subpackage LinkTerm_txt \
        --flake --version {{FLAGS}}

# Update trivial packages to their latest version
update-trivial-packages:
    nix-update EmmyLua_spoon --flake --version branch=master
    nix-update nu_plugin_dt --flake --version branch=main
    nix-update nu_plugin_regex --flake --version branch=main
    nix-update alfred-workflow-switch-appearance --flake
    nix-update tree-sitter-numbat --flake --version branch=main
    nix-update nvim-colors --flake --version branch=main
    nix-update hledger-lsp --flake
    nix-update py2hy --flake
    nix-update beancount2ledger --flake
    nix-update autobean_refactor --flake
    nix-update autobean_format --flake
    nix-update pyxirr --flake
