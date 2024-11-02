function fish_mode_prompt --description "Show SHLVL before fish_default_mode_prompt"
    if test -n "$SHLVL"
        set_color --bold yellow
        printf "[%s]" "$SHLVL"
    end
    fish_default_mode_prompt
end
