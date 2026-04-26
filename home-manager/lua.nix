{
  pkgs,
  ...
}:
let
  lua55 = with pkgs; lua5_5;
in
{
  assertions = [
    {
      assertion = pkgs.lua55Packages.argparse.version == "0.7.1-1";
      message = ''
        The Lua package argparse may have a new release that supports Lua 5.5.
        Consider re-installing `llscheck` and `luaprompt`.
        See https://github.com/luarocks/argparse/issues/35
      '';
    }
  ];

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

        #llscheck # llscheck requires lua-language-server on PATH.
        #luaprompt # luap provides a better REPL experience than lua(1).

        lua-cjson
        inspect
        sbarlua # sbarlua is the Lua API to SketchyBar
      ]
    ))
  ];
}
