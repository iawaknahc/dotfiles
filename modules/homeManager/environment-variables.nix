{ ... }:
{
  # Set LANG.
  # LANG=C.UTF-8 causes zsh not to display Unicode characters such as Japanese.
  home.language.base = "en_US.UTF-8";

  home.sessionVariables = {
    # eza: https://github.com/eza-community/eza/blob/v0.23.4/src/options/vars.rs#L21
    # lsd: https://github.com/lsd-rs/lsd/blob/v1.2.0/src/flags/date.rs#L78
    # ls from GNU coreutils: https://www.gnu.org/software/coreutils/manual/html_node/Formatting-file-timestamps.html
    TIME_STYLE = "+%Y-%m-%d %H:%M:%S %z";
  };
}
