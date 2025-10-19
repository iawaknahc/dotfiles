#!/bin/sh

set -eux

# mac,linux,win
PLATFORM="mac"
VERSION="13114758"
ANDROID_HOME="$HOME/.local/share/android"

wget "https://dl.google.com/android/repository/commandlinetools-${PLATFORM}-${VERSION}_latest.zip" -O "/tmp/commandlinetools-${PLATFORM}-${VERSION}_latest.zip"
rm -r "/tmp/commandlinetools-${PLATFORM}-${VERSION}_latest"
unzip "/tmp/commandlinetools-${PLATFORM}-${VERSION}_latest.zip" -d "/tmp/commandlinetools-${PLATFORM}-${VERSION}_latest"

yes | "/tmp/commandlinetools-${PLATFORM}-${VERSION}_latest/cmdline-tools/bin/sdkmanager" --sdk_root="$ANDROID_HOME" --licenses
xargs "/tmp/commandlinetools-${PLATFORM}-${VERSION}_latest/cmdline-tools/bin/sdkmanager" --sdk_root="$ANDROID_HOME" --install <<EOF
cmdline-tools;latest
platform-tools
emulator

ndk;25.1.8937393
ndk;26.1.10909125
ndk;26.3.11579264
ndk;27.1.12297006
ndk;27.3.13750724

cmake;3.6.4111459
cmake;3.10.2.4988404
cmake;3.18.1
cmake;3.22.1
cmake;3.30.3
cmake;3.30.4
cmake;3.30.5
cmake;3.31.0
cmake;3.31.1

extras;android;m2repository
extras;google;auto
extras;google;google_play_services
extras;google;instantapps
extras;google;m2repository
extras;google;market_apk_expansion
extras;google;market_licensing
extras;google;simulators
extras;google;webdriver

platforms;android-28
sources;android-28
build-tools;28.0.0
build-tools;28.0.1
build-tools;28.0.2
build-tools;28.0.3
system-images;android-28;google_apis_playstore;arm64-v8a

platforms;android-29
sources;android-29
build-tools;29.0.0
build-tools;29.0.1
build-tools;29.0.2
build-tools;29.0.3
system-images;android-29;google_apis_playstore;arm64-v8a

platforms;android-30
sources;android-30
build-tools;30.0.0
build-tools;30.0.1
build-tools;30.0.2
build-tools;30.0.3
system-images;android-30;google_apis_playstore;arm64-v8a

platforms;android-31
sources;android-31
build-tools;31.0.0
system-images;android-31;google_apis_playstore;arm64-v8a

platforms;android-32
sources;android-32
build-tools;32.0.0
system-images;android-32;google_apis_playstore;arm64-v8a

platforms;android-33
sources;android-33
build-tools;33.0.0
build-tools;33.0.1
build-tools;33.0.2
build-tools;33.0.3
system-images;android-33;google_apis_playstore;arm64-v8a

platforms;android-34
sources;android-34
build-tools;34.0.0
system-images;android-34;google_apis_playstore;arm64-v8a

platforms;android-35
sources;android-35
build-tools;35.0.0
build-tools;35.0.1
system-images;android-35;google_apis_playstore;arm64-v8a
EOF
