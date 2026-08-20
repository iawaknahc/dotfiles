{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # This program reliably switches input method on macOS.
    #
    # Here are the input methods I use on macOS:
    # com.apple.keylayout.ABC
    # com.apple.inputmethod.TYIM.Cangjie
    # com.apple.inputmethod.Kotoeri.RomajiTyping.Japanese
    #
    # The main use case of this program is to switch input method in text editors.
    #
    # When leaving insert mode in VIM, Neovim, or evil-mode,
    # input method should always be reset to English.
    macism
  ];
}
