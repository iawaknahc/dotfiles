{ config, pkgs, ... }:
{
  programs.ghostty.enable = true;
  programs.ghostty.package = (
    pkgs.writeShellScriptBin "ghostty" ''
      # ghostty on macOS is broken.
      # So this is a wrapper script that invokes the actual ghostty installed with .dmg.
      /Applications/Ghostty.app/Contents/MacOS/ghostty "$@"
    ''
  );
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
    shell-integration = "none";
    cursor-style-blink = false;

    # selection-foreground does not support cell-foreground
    # See https://github.com/ghostty-org/ghostty/issues/2685
  };
}
