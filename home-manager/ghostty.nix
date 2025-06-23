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
      "JetBrainsMonoNL Nerd Font Mono"
      # Japanese sans preinstalled on macOS Sequoia.
      # https://support.apple.com/en-hk/120414#:~:text=biz%20udgothic%2018.0d1e2
      "BIZ UDGothic"
      # Chinese sans preinstalled on macOS Sequoia.
      # https://support.apple.com/en-hk/120414#:~:text=lantinghei%20tc%20demibold%2013.0d2e1
      "Lantinghei TC"
      # Korean serif preinstalled on macOS Sequoia.
      # https://support.apple.com/en-hk/120414#:~:text=pcmyungjo%20regular%2013.0d2e1
      "PCMyungjo"
    ];
    font-style = "Light";
    font-style-bold = "Bold";
    font-style-italic = "Light Italic";
    font-style-bold-italic = "Bold Italic";
    font-size = 13;

    command = "${config.home.profileDirectory}/bin/fish --login --interactive";

    # I use fish vi mode.
    # When the mode is normal, the cursor does not become block.
    # As a workaround, let's always use a block.
    cursor-style = "block";
    shell-integration = "none";
    cursor-style-blink = false;

    # selection-foreground does not support cell-foreground
    # See https://github.com/ghostty-org/ghostty/issues/2685
  };
}
