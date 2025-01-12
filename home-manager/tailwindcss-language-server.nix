{ pkgs, ... }:
{
  home.packages = [
    # It is observed that 0.0.27 tailwindcss-language-server is not an executable.
    # Let's fix that ourselves.
    # The upstream fix is https://github.com/NixOS/nixpkgs/commit/e4aacf43da9841ca12c530901dc8b45dc1235629
    # but it is on master only.
    (pkgs.tailwindcss-language-server.overrideAttrs (prev: {
      postInstall =
        (prev.postInstall or "")
        + ''
          chmod u+x $out/lib/tailwindcss-language-server/packages/tailwindcss-language-server/bin/tailwindcss-language-server
        '';
    }))
  ];
}
