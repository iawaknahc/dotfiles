{
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    lua-language-server
    stylua

    fennel-ls
    fnlfmt

    # Luarocks hits a limit of LuaJIT.
    # So we have to run luarocks with Lua 5.4
    # https://github.com/luarocks/luarocks/issues/1797
    (lua5_4_compat.withPackages (
      packages: with packages; [
        fennel
        luarocks
        # llscheck requires lua-language-server on PATH.
        llscheck
        # luap provides a better REPL experience than lua(1).
        luaprompt
      ]
    ))
  ];
}
