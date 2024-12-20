if status is-login
    echo "login shell: true"
else
    echo "login shell: false"
end

echo "sourcing $(status filename)"

function before_set_path
    # Turn on vi mode
    fish_vi_key_bindings

    # Set theme
    fish_config theme choose MyDracula
end

function set_path
    # We used to reset PATH to an empty string here.
    # With
    # 1. In iTerm.app, set shell to Custom Shell. This means $SHELL is correct.
    # 2. With tmux 3.5a, the default-command is left unset.
    # Then when open a new tmux window, the shell is only sourced once.

    # nix
    # For some unknown reason, this file is not executable.
    if test -e "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish"
        source "/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.fish"
        # The above script use "fish_add_path --global", which writes to
        # $fish_user_paths.
        # I do not use $fish_user_paths so I have to repeat what the script does here.
        # But this time, with "fish_add_path -P".
        set -e fish_user_paths
        fish_add_path -P /nix/var/nix/profiles/default/bin
        fish_add_path -P "$HOME/.nix-profile/bin"
    end

    # home-manager
    if test -x "$(command -v babelfish)"
        if test -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
            babelfish <"$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" | source
        end
    end
end

function after_set_path
    if test -x "$(command -v nvim)"
        abbr -a vi nvim
        abbr -a vim nvim
        abbr -a view nvim -R
        abbr -a vimdiff nvim -d
    end
end

before_set_path
if test -z "$IN_NIX_SHELL"
    set_path
end
after_set_path

if test -x "$(command -v direnv)"
    set -g direnv_fish_mode disable_arrow
    direnv hook fish | source
end
