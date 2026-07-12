{
  pkgs,
  ...
}:
let
  # Luarocks hits a limit of LuaJIT.
  # So we have to run luarocks with Lua 5.4
  # See https://github.com/luarocks/luarocks/issues/1797
  #
  # Hammerspoon supports Lua 5.4 only
  # See https://github.com/Hammerspoon/hammerspoon/issues/3867
  lua54 = with pkgs; lua5_4;
in
{
  home.packages = with pkgs; [
    emmylua-ls
    emmylua-check

    lua-language-server
    stylua

    fennel-ls
    fnlfmt

    (lua54.withPackages (
      luaPackages: with luaPackages; [
        luautf8
        inspect
        luarocks

        fennel
        luaPackages.readline

        llscheck # llscheck requires lua-language-server on PATH.
        luaprompt # luap provides a better REPL experience than lua(1).
      ]
    ))
  ];
}
