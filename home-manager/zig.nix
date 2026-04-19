{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # zig < 0.16 does not work with Xcode 26.4
    # See https://codeberg.org/ziglang/zig/issues/31658
    # As of 2026-04-17, zig 0.16 is not available on nixpkgs yet.
    # See https://github.com/NixOS/nixpkgs/pull/509719
    zig
    zls
  ];
  programs.git.ignores = [
    ".zig-cache/"
    "zig-out/"
  ];
}
