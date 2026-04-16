{ pkgs, ... }:
{
  home.packages = with pkgs; [
    docker-compose-language-service # docker-compose.yaml
    dockerfile-language-server # Dockerfile
    graphql-language-service-cli # GraphQL

    # marksman is written in F# and it is not prebuilt on nixpkgs as of 2026-02-03.
    # It takes an unpractical time to build the whole dotnet package.
    # marksman # .md

    markdown-oxide

    sqls # SQL
    tailwindcss-language-server # Tailwind
    taplo # TOML
    typescript-language-server # TypeScript
    vtsls # TypeScript
    vscode-langservers-extracted # HTML and CSS
    yaml-language-server # YAML
  ];
}
