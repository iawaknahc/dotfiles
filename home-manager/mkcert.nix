{ pkgs, ... }:
{
  home.packages = with pkgs; [
    mkcert
    # nssTools includes a program called certutil,
    # which is required by mkcert to install CA for Firefox.
    nssTools
  ];
}
