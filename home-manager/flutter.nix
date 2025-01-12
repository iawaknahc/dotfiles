{ ... }:
{
  home.sessionVariablesExtra = ''
    if [ -d "$HOME/flutter" ]; then
      export FLUTTER_ROOT="$HOME/flutter"
      # Make flutter available
      export PATH="$HOME/flutter/bin:$PATH"
      # Make the executables of embedded dark-sdk, say dartfmt, available
      export PATH="$HOME/flutter/bin/cache/dart-sdk/bin:$PATH"
      # Make executables installed with `flutter packages pub global activate` available
      # Notably, we want to run `flutter packages pub global activate dart_language_server`
      export PATH="$HOME/flutter/.pub-cache/bin:$PATH"
    fi
  '';
}
