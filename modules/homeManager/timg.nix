{ pkgs, ... }:
{
  home.packages = with pkgs; [ timg ];
  home.sessionVariables = {
    TIMG_PIXELATION = "kitty";
  };
}
