{
  pkgs,
  ...
}:
let
  lua55 = with pkgs; lua5_5;
in
{
  home.packages = with pkgs; [
    emmylua-ls
    emmylua-check

    lua-language-server
    stylua

    fennel-ls
    fnlfmt

    # Luarocks hits a limit of LuaJIT.
    # So we have to run luarocks with Lua > 5.1
    # https://github.com/luarocks/luarocks/issues/1797
    (lua55.withPackages (
      packages: with packages; [
        luautf8
        fennel
        luarocks

        # llscheck requires lua-language-server on PATH.
        # FIXME: llscheck depends on argparse which does not have a release supporting Lua 5.5 yet
        # See https://github.com/luarocks/argparse/issues/35
        #llscheck
        # luap provides a better REPL experience than lua(1).
        # FIXME: luap depends on argparse which does not have a release supporting Lua 5.5 yet
        # See https://github.com/luarocks/argparse/issues/35
        #luaprompt

        # JSON
        lua-cjson
        # inspect
        inspect
        # sbarlua is the Lua API to SketchyBar
        sbarlua
      ]
    ))
  ];
}
