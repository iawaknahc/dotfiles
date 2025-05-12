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
    # ghostty embeds JetBrains Mono by default.
    # So it is unnecessary to configure font.
    # But I am not a fan of ligatures.
    font-style = "Light";
    font-style-bold = "Bold";
    font-style-italic = "Light Italic";
    font-style-bold-italic = "Bold Italic";
    font-feature = [
      "-calt"
      "-liga"
      "-dlig"
    ];
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
