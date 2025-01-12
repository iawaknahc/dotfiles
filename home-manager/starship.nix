{ ... }:
{
  programs.starship.enable = true;
  programs.starship.enableBashIntegration = true;
  programs.starship.enableFishIntegration = true;
  programs.starship.enableNushellIntegration = false;
  programs.starship.enableZshIntegration = true;
  programs.starship.settings = {
    add_newline = false;
    follow_symlinks = false;
    format = "$kubernetes$direnv$shell$shlvl$character $status ";
    shell = {
      disabled = false;
      format = "[$indicator]($style)";
      bash_indicator = "bash";
      fish_indicator = "fish";
      nu_indicator = "nu";
      unknown_indicator = "unknown";
    };
    character = {
      disabled = false;
      format = "$symbol";
      success_symbol = "[I](bold green)";
      error_symbol = "[I](bold green)";
      vimcmd_symbol = "[N](bold red)";
      vimcmd_replace_one_symbol = "[R](bold green)";
      vimcmd_replace_symbol = "[R](bold cyan)";
      vimcmd_visual_symbol = "[V](bold purple)";
    };
    # It is a known issue that SHLVL does not work in bash
    # See https://github.com/starship/starship/issues/2407#issuecomment-1433682262
    # See https://github.com/starship/starship/pull/4912
    shlvl = {
      disabled = false;
      threshold = 0;
      format = "[$shlvl](bold yellow)";
    };
    status = {
      disabled = false;
      format = "$symbol";
      success_symbol = "\\$";
      symbol = "[$status \\$](bold red)";
      not_executable_symbol = "[$status \\$](bold red)";
      not_found_symbol = "[$status \\$](bold red)";
      sigint_symbol = "[$status \\$](bold red)";
      signal_symbol = "[$status \\$](bold red)";
    };
    direnv = {
      disabled = false;
      format = "[$loaded]($style)";
      loaded_msg = ".";
      unloaded_msg = "";
    };
    kubernetes = {
      disabled = false;
      format = "[\\($context\\)]($style)";
    };
  };
}
