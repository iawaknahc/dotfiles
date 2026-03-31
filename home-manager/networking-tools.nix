{ pkgs, ... }:
{
  home.packages = with pkgs; [
    dig
    subnetcalc
    ipcalc
  ];
}
