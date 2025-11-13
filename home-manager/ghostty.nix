{ config, pkgs, ... }:
{
  programs.ghostty.enable = true;
  programs.ghostty.package = pkgs.ghostty-bin;
  programs.ghostty.enableBashIntegration = false;
  programs.ghostty.enableFishIntegration = false;
  programs.ghostty.enableZshIntegration = false;
  programs.ghostty.installBatSyntax = false;
  programs.ghostty.installVimSyntax = false;
  programs.ghostty.settings = {
    # Treat the left option key as ALT, keeping the right option key unchanged.
    # In Karabiner, I have configured the right option key to type more symbols.
    # So it follows logically that the left option key should be remapped to something more useful.
    macos-option-as-alt = "left";

    font-family = [
      "" # Reset instead of appending to the default.
      "JetBrainsMonoNL Nerd Font Mono"
      # It has these variants:
      # - Source Han Mono (Japanese)
      # - Source Han Mono HC (Hong Kong)
      # - Source Han Mono K (Korean)
      # - Source Han Mono SC (Simplified Chinese)
      # - Source Han Mono TC (Traditional Chinese)
      #
      # The details can be found at https://raw.githubusercontent.com/adobe-fonts/source-han-mono/master/SourceHanMonoReadMe.pdf
      # In context like an HTML document, we can rely on `<html lang=>` to determine the language,
      # and select a suitable variant.
      # The strokes of a character then can conform to the convention of the language.
      # In a terminal environment, we have no such information available.
      # So we just use the Hong Kong version here.
      "Source Han Mono HC"
    ];
    font-style = "Light";
    font-style-bold = "Bold";
    font-style-italic = "Light Italic";
    font-style-bold-italic = "Bold Italic";
    font-size = 13;

    command = "${config.home.profileDirectory}/bin/fish --login --interactive";

    # In preparation for using neovim as default terminal program,
    # we disable vi mode in shell.
    # Thus the cursor should look like a bar.
    cursor-style = "bar";
    cursor-style-blink = false;
    # It is better not to set cursor-color and cursor-text.
    #
    # We want to be able to locate the cursor very easily.
    # Thus, the cursor should always have the same color.
    # If we set it to "cell-background", it will be indistinguishable from the cell background.
    # If we set it to "cell-foreground", it will not always be the same easy-to-locate color.
    #
    # The theme we are using is Catppuccin, which defines cursor color and cursor text color.
    # See https://github.com/catppuccin/catppuccin/blob/main/docs/style-guide.md#terminals

    shell-integration = "none";

    # selection-foreground supports cell-foreground since 1.2.0
    # See https://github.com/ghostty-org/ghostty/issues/2685
    selection-foreground = "cell-foreground";

    # selection background is Overlay 2 with 20% to 30% opacity.
    # But ghostty does not support selection opacity as of 1.2.0
    # See https://github.com/catppuccin/catppuccin/blob/main/docs/style-guide.md#general-usage
    # selection-background = "#9399b2";

    # The cursor-text color is incorrect in dark flavors
    # See https://github.com/catppuccin/ghostty/pull/16
    cursor-text = "#11111b";
  };
}
