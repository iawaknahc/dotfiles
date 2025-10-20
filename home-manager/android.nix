{ ... }:
{
  # We cannot use home.sessionPath and home.sessionVariables
  # because home.sessionPath prepends to PATH
  # But $ANDROID_HOME/platform-tools/sqlite3 can shadow the intended copy of sqlite3.
  # So we have to append to PATH.
  # Since appending to PATH is not supported by home-manager, we have to do that ourselves.
  home.sessionVariablesExtra = ''
    export ANDROID_HOME="$HOME/.local/share/android"
    export ANDROID_SDK_ROOT="$ANDROID_HOME"
    export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
    export PATH="$PATH:$ANDROID_HOME/platform-tools"
  '';
}
