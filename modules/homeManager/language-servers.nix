{ pkgs, ... }:
{
  home.packages = with pkgs; [
    tailwindcss-language-server # Tailwind
    taplo # TOML
    vtsls # TypeScript
    vscode-langservers-extracted # HTML and CSS
  ];
}
