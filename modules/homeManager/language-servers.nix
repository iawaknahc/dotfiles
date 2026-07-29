{ pkgs, ... }:
{
  home.packages = with pkgs; [
    tailwindcss-language-server # Tailwind
    taplo # TOML
    vscode-langservers-extracted # HTML and CSS
  ];
}
