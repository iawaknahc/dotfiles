{
  pkgs,
  # android-nixpkgs is a extraSpecialArg passed from the flake.
  android-nixpkgs,
  ...
}:
{
  imports = [
    android-nixpkgs.hmModule
  ];

  config = {
    # android-nixpkgs.hmModule assumes pkgs.androidSdk is present.
    # pkgs.androidSdk can be added by the provided overlay.
    nixpkgs.overlays = [
      android-nixpkgs.overlays.default
    ];

    # Set JAVA_HOME
    programs.java.enable = true;
    programs.java.package = with pkgs; temurin-bin;

    # To make AndroidStudio.app to use this SDK,
    # Edit ~/Library/Application Support/Google/AndroidStudio{version}/options/jdk.table.xml and
    # Edit ~/Library/Application Support/Google/AndroidStudio{version}/options/other.xml
    # to point to ~/.local/share/android (the default value of android-sdk.path)
    android-sdk.enable = true;
    android-sdk.packages = (
      sdkPkgs: with sdkPkgs; [
        # Run `nix flake show github:tadfisher/android-nixpkgs` to list installable packages.

        # tools
        cmdline-tools-latest
        platform-tools
        tools

        # emulator
        emulator

        # ndk
        ndk-26-1-10909125 # Used by React Native 0.76.x
        ndk-27-1-12297006 # Used by React Native 0.77.x

        # cmake
        cmake-3-6-4111459
        cmake-3-10-2-4988404
        cmake-3-18-1
        cmake-3-22-1
        cmake-3-30-3
        cmake-3-30-4
        cmake-3-30-5
        cmake-3-31-0
        cmake-3-31-1

        # extras
        extras-android-m2repository
        extras-google-admob-ads-sdk
        extras-google-analytics-sdk-v2
        extras-google-auto
        extras-google-gcm
        extras-google-google-play-services
        extras-google-google-play-services-froyo
        extras-google-instantapps
        extras-google-m2repository
        extras-google-market-apk-expansion
        extras-google-market-licensing
        extras-google-simulators
        extras-google-webdriver

        # When you add a platform, you definitely want to add
        # 1. The platform
        # 2. The source code so that you can jump to the source in Android Studio.
        # 3. The build tools
        # 4. The Google play system image. This variant is shown as recommended in Android Studio. So this one is enough.
        #
        # Note that `avdmanager` and `emulator` commands DO NOT function properly.
        # To create a AVD, you must create it inside Android Studio.

        platforms-android-35
        sources-android-35
        build-tools-35-0-0
        build-tools-35-0-1
        system-images-android-35-google-apis-playstore-arm64-v8a

        platforms-android-34
        sources-android-34
        build-tools-34-0-0
        system-images-android-34-google-apis-playstore-arm64-v8a

        platforms-android-33
        sources-android-33
        build-tools-33-0-0
        build-tools-33-0-1
        build-tools-33-0-2
        build-tools-33-0-3
        system-images-android-33-google-apis-playstore-arm64-v8a

        platforms-android-32
        sources-android-32
        build-tools-32-0-0
        system-images-android-32-google-apis-playstore-arm64-v8a

        platforms-android-31
        sources-android-31
        build-tools-31-0-0
        system-images-android-31-google-apis-playstore-arm64-v8a

        platforms-android-30
        sources-android-30
        build-tools-30-0-0
        build-tools-30-0-1
        build-tools-30-0-2
        build-tools-30-0-3
        system-images-android-30-google-apis-playstore-arm64-v8a

        platforms-android-29
        sources-android-29
        build-tools-29-0-0
        build-tools-29-0-1
        build-tools-29-0-2
        build-tools-29-0-3
        system-images-android-29-google-apis-playstore-arm64-v8a

        platforms-android-28
        sources-android-28
        build-tools-28-0-0
        build-tools-28-0-1
        build-tools-28-0-2
        build-tools-28-0-3
        system-images-android-28-google-apis-playstore-arm64-v8a
      ]
    );
  };
}
