android-nixpkgs:
{ pkgs, ... }:
{
  imports = [ android-nixpkgs.hmModule ];
  config = {
    # The home-manager module of android-nixpkgs expects `pkgs.androidSdk` to be present.
    # One way of making it present is to use `android-nixpkgs.overlays.default`.
    # But `android-nixpkgs.overlays.default` uses `final`[1], which means the Android SDK
    # depends on OUR nixpkgs.
    # So even, if we do not override the input `nixpkgs` of `android-nixpkgs`,
    # at evaluation time, the Android SDK still depends on OUR nixpkgs.
    #
    # To make the Android SDK solely depends on its own `nixpkgs`, we need:
    # 1. Do not override the input `nixpkgs` of `android-nixpkgs`. This is trivial.
    # 2. Use an overlay to populate `pkgs.androidSdk`, AND it MUST depend on the input `nixpkgs` of `android-nixpkgs`.
    #    Fortunately, `android-nixpkgs` exposes an output `sdk`[2], which is an attrset of system names to `androidSdk`.
    #
    # [1]: https://github.com/tadfisher/android-nixpkgs/blob/2026-04-15-stable/flake.nix#L28
    # [2]: https://github.com/tadfisher/android-nixpkgs/blob/2026-04-15-stable/flake.nix#L58
    nixpkgs.overlays = [
      (final: prev: {
        androidSdk = android-nixpkgs.sdk."${pkgs.stdenv.hostPlatform.system}";
      })
    ];

    # We switched back to use android-nixpkgs to manage Android SDK installation.
    # To avoid massive re-download, we pin android-nixpkgs to a specific version.
    # `nix flake update --flake .` will not bump the version of android-nixpkgs.
    # To update, first visit the release notes of platform-tools https://developer.android.com/tools/releases/platform-tools to get the month and year.
    # Then visit https://github.com/tadfisher/android-nixpkgs/blame/main/channels/stable/default.nix to see which commit is the first commit that includes the release.
    android-sdk.enable = true;
    # Use `nix flake show github:tadfisher/android-nixpkgs/2026-04-15-stable` to list available packages.
    android-sdk.packages =
      sdk: with sdk; [
        cmdline-tools-latest
        platform-tools
        emulator

        ndk-25-1-8937393
        ndk-26-1-10909125
        ndk-26-3-11579264
        ndk-27-1-12297006
        ndk-27-3-13750724

        cmake-3-6-4111459
        cmake-3-10-2-4988404
        cmake-3-18-1
        cmake-3-22-1
        cmake-3-30-3
        cmake-3-30-4
        cmake-3-30-5
        cmake-3-31-0
        cmake-3-31-1

        extras-android-m2repository
        extras-google-auto
        extras-google-google-play-services
        extras-google-instantapps
        extras-google-m2repository
        extras-google-market-apk-expansion
        extras-google-market-licensing
        extras-google-simulators
        extras-google-webdriver

        platforms-android-33
        sources-android-33
        build-tools-33-0-0
        build-tools-33-0-1
        build-tools-33-0-2
        build-tools-33-0-3
        system-images-android-33-google-apis-playstore-arm64-v8a

        platforms-android-34
        sources-android-34
        build-tools-34-0-0
        system-images-android-34-google-apis-playstore-arm64-v8a

        platforms-android-35
        sources-android-35
        build-tools-35-0-0
        build-tools-35-0-1
        system-images-android-35-google-apis-playstore-arm64-v8a
      ];
  };
}
