if status is-login
    echo "login shell: true"
else
    echo "login shell: false"
end

echo "sourcing $(status filename)"

function before_set_path
    # Turn on vi mode
    fish_vi_key_bindings

    # Set locale
    set -gx LANG en_US.UTF-8

    # Set theme
    fish_config theme choose MyDracula

    # Unconditional abbreviations
    abbr -a k kubectl

    # https://www.w3.org/TR/SRI/#integrity-metadata
    abbr -a sri-sha256 --set-cursor -- 'openssl sha256 -binary % | openssl base64 | xargs printf "sha256-%s\n"'
    abbr -a sri-sha384 --set-cursor -- 'openssl sha384 -binary % | openssl base64 | xargs printf "sha384-%s\n"'
    abbr -a sri-sha512 --set-cursor -- 'openssl sha512 -binary % | openssl base64 | xargs printf "sha512-%s\n"'

    # delta
    # I have tried it out for a day but I still prefer the good old diff.
    # if test -x "$(command -v delta)"
    #   set -gx GIT_PAGER delta
    # end

    # terminfo
    # iTerm does not set TERMINFO automatically, so we help it here.
    if [ "$TERM_PROGRAM" = "iTerm.app" ]
        if test -d "/Applications/iTerm.app/Contents/Resources/terminfo"
            set -gx TERMINFO "/Applications/iTerm.app/Contents/Resources/terminfo"
        end
    end
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

    # Add ~/.local/bin to PATH
    fish_add_path -P "$HOME/.local/bin"

    # The rest of this file MUST BE sorted by the name of the section.
    # The name of the section is the comment.

    # android
    # The default location of when Android Studio installs the SDK.
    if test -d "$HOME/Library/Android/sdk"
        # ANDROID_SDK_ROOT is deprecated
        # https://developer.android.com/tools/variables
        set -gx ANDROID_HOME "$HOME/Library/Android/sdk"
        fish_add_path -P --append "$ANDROID_HOME/tools"
        fish_add_path -P --append "$ANDROID_HOME/tools/bin"
        # A binary sqlite3 lives here. So we want the binary provided by Android appear
        # at the end in PATH.
        fish_add_path -P --append "$ANDROID_HOME/platform-tools"
    end

    # flutter
    if test -d "$HOME/flutter"
        set -gx FLUTTER_ROOT "$HOME/flutter"
        fish_add_path -P "$FLUTTER_ROOT/bin"
        fish_add_path -P "$FLUTTER_ROOT/bin/cache/dart-sdk/bin"
        fish_add_path -P "$FLUTTER_ROOT/.pub-cache/bin"
    end

    # golang
    # I no longer install go system-wide.
    # If go is installed with asdf, then the binaries installed with `go install` are made
    # available with `asdf reshim`.
    #if test -x "$(command -v go)"
    #    set GOPATH "$(go env GOPATH)"
    #    fish_add_path -P "$GOPATH/bin"
    #end

    # google-cloud-sdk
    if test -d "$HOME/google-cloud-sdk"
        # If you have read the source code of "$HOME/google-cloud-sdk/path.fish.inc",
        # you can see that all it does is add google-cloud-sdk/bin to PATH.
        # So we do that ourselves here.
        fish_add_path -P "$HOME/google-cloud-sdk/bin"
    end

    # homebrew
    if test -x /opt/homebrew/bin/brew
        /opt/homebrew/bin/brew shellenv | source
    end
    if test -x "$(command -v brew)"
        set HOMEBREW_PREFIX "$(brew --prefix)"

        if test -d "$HOMEBREW_PREFIX/opt/icu4c/lib/pkgconfig"
            set -gx PKG_CONFIG_PATH "$HOMEBREW_PREFIX/opt/icu4c/lib/pkgconfig"
        end

        set -gx CGO_CFLAGS "-I$HOMEBREW_PREFIX/include"
        set -gx CGO_LDFLAGS "-L$HOMEBREW_PREFIX/lib"
    end

    # kitty
    if test -d "/Applications/kitty.app/Contents/MacOS"
        fish_add_path -P "/Applications/kitty.app/Contents/MacOS"
    end

    # opam
    if test -r "$HOME/.opam/opam-init/init.fish"
        source "$HOME/.opam/opam-init/init.fish"
    end

    # rust
    if test -d "$HOME/.cargo"
        fish_add_path -P "$HOME/.cargo/bin"
    end

    # wezterm
    if test -d "/Applications/WezTerm.app/Contents/MacOS"
        fish_add_path -P "/Applications/WezTerm.app/Contents/MacOS"
    end

    # asdf
    # asdf must be the last one because it has to be appear earlier in PATH.
    if test -r "$HOME/.asdf/asdf.fish"
        source "$HOME/.asdf/asdf.fish"
    end
    if test -r "$HOME/.asdf/completions/asdf.fish"
        source "$HOME/.asdf/completions/asdf.fish"
    end
end

function after_set_path
    # nvim
    set VIM vim
    if test -x "$(command -v nvim)"
        set VIM nvim
        abbr -a vi nvim
        abbr -a vim nvim
        abbr -a view nvim -R
        abbr -a vimdiff nvim -d
        set -gx MANPAGER 'nvim +Man!'
    end
    set -gx VISUAL "$VIM"
    set -gx EDITOR "$VIM"
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
